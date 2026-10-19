-- ============================================
-- LESSON 41: Healthcare & Clinical Operations Analytics
-- ============================================
-- Topics Covered:
-- 1. 30-Day All-Cause Unplanned Hospital Readmission Rates
-- 2. Average Length of Stay (ALOS) & Outlier Inpatient Days
-- 3. Daily Hospital Bed Census & Capacity Utilization
-- 4. Outpatient Clinic Appointment No-Show Rates
-- 5. High-Risk Chronic Care Cohort Identification
-- ============================================

DROP TABLE IF EXISTS clinic_appointments;
DROP TABLE IF EXISTS hospital_admissions;
DROP TABLE IF EXISTS patients;

-- 1. Setup Practice Schema
CREATE TABLE patients (
    patient_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    chronic_flag BOOLEAN DEFAULT FALSE
);

CREATE TABLE hospital_admissions (
    admission_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    admission_date DATE NOT NULL,
    discharge_date DATE NOT NULL,
    drg_category VARCHAR(50) NOT NULL, -- Diagnosis-Related Group
    admission_type VARCHAR(20) NOT NULL, -- 'Emergency', 'Elective', 'Urgent'
    discharge_disposition VARCHAR(30) NOT NULL -- 'Home', 'SNF' (Skilled Nursing), 'AMA'
);

CREATE TABLE clinic_appointments (
    appointment_id INT PRIMARY KEY AUTO_INCREMENT,
    patient_id INT NOT NULL,
    department VARCHAR(50) NOT NULL, -- 'Cardiology', 'Oncology', 'Primary Care'
    appointment_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL -- 'Completed', 'No-Show', 'Cancelled'
);

-- Seed Data
INSERT INTO patients (patient_id, full_name, dob, gender, chronic_flag) VALUES
(201, 'Eleanor Vance', '1952-03-12', 'F', TRUE),
(202, 'Marcus Brody',  '1965-07-25', 'M', TRUE),
(203, 'Chloe Bennett', '1988-11-04', 'F', FALSE),
(204, 'Julian Thorne', '1947-01-19', 'M', TRUE),
(205, 'Sofia Ramirez', '1995-09-30', 'F', FALSE);

INSERT INTO hospital_admissions (patient_id, admission_date, discharge_date, drg_category, admission_type, discharge_disposition) VALUES
-- Eleanor Vance (Readmission within 14 days)
(201, '2024-01-05', '2024-01-10', 'Heart Failure',    'Emergency', 'Home'),
(201, '2024-01-24', '2024-01-31', 'Heart Failure',    'Emergency', 'Home'), -- Readmission within 14 days of discharge
(201, '2024-03-01', '2024-03-06', 'Pneumonia',        'Emergency', 'Home'), -- Readmission > 30 days

-- Marcus Brody (Single admission, standard stay)
(202, '2024-01-15', '2024-01-19', 'Joint Replacement','Elective',  'Home'),

-- Chloe Bennett (Short stay)
(203, '2024-02-02', '2024-02-04', 'Appendectomy',     'Emergency', 'Home'),

-- Julian Thorne (Rapid readmission within 9 days, multiple chronic episodes)
(204, '2024-02-10', '2024-02-18', 'COPD Flare',       'Emergency', 'SNF'),
(204, '2024-02-27', '2024-03-08', 'COPD Flare',       'Emergency', 'Home'), -- Readmitted within 9 days
(204, '2024-03-20', '2024-03-28', 'Heart Failure',    'Emergency', 'SNF'); -- 3rd admission within 2 months

INSERT INTO clinic_appointments (patient_id, department, appointment_date, status) VALUES
(201, 'Cardiology',   '2024-02-15', 'Completed'),
(201, 'Cardiology',   '2024-03-15', 'Completed'),
(202, 'Primary Care', '2024-01-10', 'No-Show'),
(202, 'Primary Care', '2024-01-20', 'Completed'),
(203, 'Primary Care', '2024-02-12', 'Cancelled'),
(203, 'Primary Care', '2024-02-20', 'Completed'),
(204, 'Pulmonology',  '2024-01-14', 'No-Show'),
(204, 'Pulmonology',  '2024-02-05', 'No-Show'),
(205, 'Cardiology',   '2024-03-01', 'Completed'),
(205, 'Primary Care', '2024-03-10', 'No-Show');

-- ============================================
-- QUERY 1: 30-Day Hospital Readmission Rate
-- ============================================
-- A critical CMS quality indicator.
-- Track whether the patient returns to the hospital within 30 days of prior discharge.
WITH SequencedStays AS (
    SELECT 
        a.admission_id,
        a.patient_id,
        p.full_name,
        a.drg_category,
        a.admission_date,
        a.discharge_date,
        LEAD(a.admission_date) OVER (PARTITION BY a.patient_id ORDER BY a.admission_date) AS next_admission_date,
        DATEDIFF(LEAD(a.admission_date) OVER (PARTITION BY a.patient_id ORDER BY a.admission_date), a.discharge_date) AS days_to_readmit
    FROM hospital_admissions a
    JOIN patients p ON a.patient_id = p.patient_id
)
SELECT 
    admission_id,
    patient_id,
    full_name,
    drg_category,
    admission_date,
    discharge_date,
    next_admission_date,
    days_to_readmit,
    CASE 
        WHEN days_to_readmit BETWEEN 0 AND 30 THEN 1 
        ELSE 0 
    END AS is_30day_readmit
FROM SequencedStays;

-- Aggregate Readmission Rate by DRG Category
WITH SequencedStays AS (
    SELECT 
        drg_category,
        DATEDIFF(LEAD(admission_date) OVER (PARTITION BY patient_id ORDER BY admission_date), discharge_date) AS days_to_readmit
    FROM hospital_admissions
)
SELECT 
    drg_category,
    COUNT(*) AS total_discharges,
    SUM(CASE WHEN days_to_readmit BETWEEN 0 AND 30 THEN 1 ELSE 0 END) AS readmitted_within_30_days,
    ROUND((SUM(CASE WHEN days_to_readmit BETWEEN 0 AND 30 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS readmission_rate_pct
FROM SequencedStays
GROUP BY drg_category;

-- ============================================
-- QUERY 2: Average Length of Stay (ALOS) by Diagnosis
-- ============================================
SELECT 
    drg_category,
    COUNT(*) AS patient_stays,
    ROUND(AVG(DATEDIFF(discharge_date, admission_date)), 1) AS avg_length_of_stay_days,
    MIN(DATEDIFF(discharge_date, admission_date)) AS min_stay_days,
    MAX(DATEDIFF(discharge_date, admission_date)) AS max_stay_days,
    ROUND(STDDEV(DATEDIFF(discharge_date, admission_date)), 2) AS stddev_stay_days
FROM hospital_admissions
GROUP BY drg_category
ORDER BY avg_length_of_stay_days DESC;

-- ============================================
-- QUERY 3: Active Inpatient Bed Census Snapshot
-- ============================================
-- How many patients were physically in a hospital bed on a given date (e.g., '2024-02-12')?
SELECT 
    '2024-02-12' AS census_date,
    COUNT(*) AS active_inpatients,
    GROUP_CONCAT(p.full_name SEPARATOR ', ') AS admitted_patients
FROM hospital_admissions a
JOIN patients p ON a.patient_id = p.patient_id
WHERE '2024-02-12' >= a.admission_date AND '2024-02-12' < a.discharge_date;

-- ============================================
-- QUERY 4: Outpatient Clinic Appointment No-Show Rate
-- ============================================
SELECT 
    department,
    COUNT(*) AS total_scheduled,
    SUM(CASE WHEN status = 'Completed' THEN 1 ELSE 0 END) AS completed_visits,
    SUM(CASE WHEN status = 'No-Show' THEN 1 ELSE 0 END) AS no_shows,
    SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END) AS cancellations,
    ROUND((SUM(CASE WHEN status = 'No-Show' THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 2) AS no_show_rate_pct
FROM clinic_appointments
GROUP BY department
ORDER BY no_show_rate_pct DESC;

-- ============================================
-- QUERY 5: High-Risk Chronic Frequent Flyer Cohort
-- ============================================
-- Patients with >= 2 hospital admissions AND >= 1 clinic no-show
WITH InpatientCount AS (
    SELECT 
        patient_id,
        COUNT(*) AS hospital_admissions_count
    FROM hospital_admissions
    GROUP BY patient_id
),
NoShowCount AS (
    SELECT 
        patient_id,
        COUNT(*) AS no_show_count
    FROM clinic_appointments
    WHERE status = 'No-Show'
    GROUP BY patient_id
)
SELECT 
    p.patient_id,
    p.full_name,
    TIMESTAMPDIFF(YEAR, p.dob, CURRENT_DATE) AS age,
    p.chronic_flag,
    COALESCE(i.hospital_admissions_count, 0) AS total_admissions,
    COALESCE(n.no_show_count, 0) AS clinic_no_shows,
    CASE 
        WHEN COALESCE(i.hospital_admissions_count, 0) >= 2 AND COALESCE(n.no_show_count, 0) >= 1 
        THEN 'PRIORITY: Case Manager Intervention Needed'
        ELSE 'STANDARD CARE'
    END AS patient_risk_tier
FROM patients p
LEFT JOIN InpatientCount i ON p.patient_id = i.patient_id
LEFT JOIN NoShowCount n ON p.patient_id = n.patient_id
ORDER BY total_admissions DESC, clinic_no_shows DESC;

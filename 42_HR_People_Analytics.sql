-- ============================================
-- LESSON 42: HR & People Analytics
-- ============================================
-- Topics Covered:
-- 1. Employee Turnover & Attrition Rate (Voluntary vs Involuntary)
-- 2. Compa-Ratio & Pay Equity Analysis by Job Band & Gender
-- 3. Promotion Velocity & Average Time-in-Role
-- 4. Manager Span of Control & Org Hierarchy Analytics
-- 5. Hire Cohort Retention Survival Matrix
-- ============================================

DROP TABLE IF EXISTS hr_promotions;
DROP TABLE IF EXISTS hr_employees;
DROP TABLE IF EXISTS hr_job_bands;

-- 1. Setup Practice Schema
CREATE TABLE hr_job_bands (
    band_id VARCHAR(10) PRIMARY KEY, -- 'IC1', 'IC2', 'IC3', 'M1', 'M2'
    title VARCHAR(50) NOT NULL,
    min_salary DECIMAL(10, 2) NOT NULL,
    mid_salary DECIMAL(10, 2) NOT NULL,
    max_salary DECIMAL(10, 2) NOT NULL
);

CREATE TABLE hr_employees (
    emp_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    department VARCHAR(50) NOT NULL,
    band_id VARCHAR(10) NOT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    hire_date DATE NOT NULL,
    termination_date DATE NULL,
    term_reason VARCHAR(30) NULL, -- 'Voluntary', 'Involuntary', NULL (Active)
    manager_id INT NULL
);

CREATE TABLE hr_promotions (
    promo_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT NOT NULL,
    from_band VARCHAR(10) NOT NULL,
    to_band VARCHAR(10) NOT NULL,
    promotion_date DATE NOT NULL
);

-- Seed Data
INSERT INTO hr_job_bands (band_id, title, min_salary, mid_salary, max_salary) VALUES
('IC1', 'Associate Analyst', 50000.00,  60000.00,  70000.00),
('IC2', 'Senior Analyst',    70000.00,  85000.00, 100000.00),
('IC3', 'Staff Analyst',    100000.00, 120000.00, 140000.00),
('M1',  'Engineering Mgr',  110000.00, 130000.00, 150000.00),
('M2',  'Director',         150000.00, 180000.00, 210000.00);

INSERT INTO hr_employees (emp_id, full_name, gender, department, band_id, salary, hire_date, termination_date, term_reason, manager_id) VALUES
(1, 'Rachel Green',  'F', 'Engineering', 'M2',  185000.00, '2021-01-10', NULL,         NULL,          NULL),
(2, 'Ross Geller',   'M', 'Engineering', 'M1',  135000.00, '2021-03-15', NULL,         NULL,          1),
(3, 'Monica Geller', 'F', 'Data Science', 'M1', 128000.00, '2021-06-01', NULL,         NULL,          1),
(4, 'Chandler Bing', 'M', 'Data Science', 'IC3',118000.00, '2022-01-15', NULL,         NULL,          3),
(5, 'Joey Tribbiani','M', 'Engineering', 'IC2', 82000.00,  '2022-04-10', '2023-11-01', 'Voluntary',   2),
(6, 'Phoebe Buffay', 'F', 'Engineering', 'IC2', 88000.00,  '2022-05-20', NULL,         NULL,          2),
(7, 'Gunther Central','M','Engineering', 'IC1', 58000.00,  '2023-01-15', '2023-09-30', 'Involuntary', 2),
(8, 'Janice Litman', 'F', 'Data Science', 'IC1',64000.00,  '2023-02-01', NULL,         NULL,          3),
(9, 'Mike Hannigan', 'M', 'Engineering', 'IC1', 56000.00,  '2023-07-10', NULL,         NULL,          2),
(10,'Emma Geller',   'F', 'Data Science', 'IC2',92000.00,  '2023-08-01', NULL,         NULL,          3);

INSERT INTO hr_promotions (emp_id, from_band, to_band, promotion_date) VALUES
(2, 'IC3', 'M1',  '2022-06-01'),
(4, 'IC2', 'IC3', '2023-03-15'),
(6, 'IC1', 'IC2', '2023-10-01');

-- ============================================
-- QUERY 1: Attrition & Turnover Rate Calculation
-- ============================================
-- Annual Turnover % = (Terminations during period / Avg Headcount) * 100
SELECT 
    department,
    COUNT(emp_id) AS total_ever_hired,
    SUM(CASE WHEN termination_date IS NULL THEN 1 ELSE 0 END) AS active_headcount,
    SUM(CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END) AS total_terminations,
    SUM(CASE WHEN term_reason = 'Voluntary' THEN 1 ELSE 0 END) AS voluntary_exits,
    SUM(CASE WHEN term_reason = 'Involuntary' THEN 1 ELSE 0 END) AS involuntary_exits,
    ROUND((SUM(CASE WHEN termination_date IS NOT NULL THEN 1 ELSE 0 END) * 100.0) / COUNT(emp_id), 1) AS attrition_rate_pct
FROM hr_employees
GROUP BY department;

-- ============================================
-- QUERY 2: Compa-Ratio & Pay Equity Analysis
-- ============================================
-- Compa-Ratio = (Employee Actual Salary / Band Midpoint) * 100.
-- 100% means paid exactly at market midpoint. < 80% is underpaid; > 120% is overpaid.
SELECT 
    e.emp_id,
    e.full_name,
    e.gender,
    e.department,
    e.band_id,
    e.salary,
    b.mid_salary,
    ROUND((e.salary / b.mid_salary) * 100.0, 1) AS compa_ratio_pct,
    CASE 
        WHEN (e.salary / b.mid_salary) < 0.90 THEN 'Below Range Target (< 90%)'
        WHEN (e.salary / b.mid_salary) > 1.10 THEN 'Above Range Target (> 110%)'
        ELSE 'Target Range (90% - 110%)'
    END AS pay_equity_band
FROM hr_employees e
JOIN hr_job_bands b ON e.band_id = b.band_id
WHERE e.termination_date IS NULL
ORDER BY compa_ratio_pct ASC;

-- Gender Pay Equity Check by Department
SELECT 
    e.department,
    e.gender,
    COUNT(*) AS headcount,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    ROUND(AVG((e.salary / b.mid_salary) * 100.0), 1) AS avg_compa_ratio
FROM hr_employees e
JOIN hr_job_bands b ON e.band_id = b.band_id
WHERE e.termination_date IS NULL
GROUP BY e.department, e.gender
ORDER BY e.department, e.gender;

-- ============================================
-- QUERY 3: Promotion Velocity & Time-to-Promotion
-- ============================================
SELECT 
    p.emp_id,
    e.full_name,
    e.department,
    p.from_band,
    p.to_band,
    e.hire_date,
    p.promotion_date,
    TIMESTAMPDIFF(MONTH, e.hire_date, p.promotion_date) AS months_to_promotion
FROM hr_promotions p
JOIN hr_employees e ON p.emp_id = e.emp_id
ORDER BY months_to_promotion ASC;

-- ============================================
-- QUERY 4: Manager Span of Control
-- ============================================
-- Span of control evaluates whether managers are overextended (> 7 reports) or underextended (< 3 reports).
SELECT 
    m.emp_id AS manager_id,
    m.full_name AS manager_name,
    m.band_id AS manager_band,
    COUNT(r.emp_id) AS direct_reports_count,
    CASE 
        WHEN COUNT(r.emp_id) > 6 THEN 'High Span (Risk of Burnout)'
        WHEN COUNT(r.emp_id) < 2 THEN 'Narrow Span (Potential Micro-management)'
        ELSE 'Balanced Span (2-6 Reports)'
    END AS span_evaluation
FROM hr_employees m
JOIN hr_employees r ON m.emp_id = r.manager_id
WHERE m.termination_date IS NULL AND r.termination_date IS NULL
GROUP BY m.emp_id, m.full_name, m.band_id
ORDER BY direct_reports_count DESC;

-- ============================================
-- QUERY 5: Hire Cohort Retention Survival Matrix
-- ============================================
SELECT 
    YEAR(hire_date) AS hire_cohort_year,
    COUNT(*) AS cohort_initial_hires,
    SUM(CASE WHEN termination_date IS NULL OR YEAR(termination_date) > YEAR(hire_date) THEN 1 ELSE 0 END) AS retained_after_y1,
    SUM(CASE WHEN termination_date IS NULL OR YEAR(termination_date) > YEAR(hire_date) + 1 THEN 1 ELSE 0 END) AS retained_after_y2,
    ROUND((SUM(CASE WHEN termination_date IS NULL OR YEAR(termination_date) > YEAR(hire_date) THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 1) AS y1_retention_rate_pct
FROM hr_employees
GROUP BY YEAR(hire_date)
ORDER BY hire_cohort_year;

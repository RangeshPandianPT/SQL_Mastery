-- ============================================
-- LESSON 33: SaaS Analytics & Recurring Revenue Metrics
-- ============================================
-- Topics Covered:
-- 1. Monthly Recurring Revenue (MRR) & Annual Recurring Revenue (ARR)
-- 2. Churn Rate (Customer & Revenue Churn)
-- 3. Cohort Retention Matrix
-- 4. Average Revenue Per User (ARPU) & Customer Lifetime Value (LTV)
-- ============================================

-- Setup Practice Data for SaaS Subscriptions
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS saas_customers;

CREATE TABLE saas_customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    company_name VARCHAR(100) NOT NULL,
    signup_date DATE NOT NULL,
    plan_tier VARCHAR(20) NOT NULL, -- Free, Basic, Pro, Enterprise
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE subscriptions (
    subscription_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    billing_month DATE NOT NULL, -- First of each month e.g. 2024-01-01
    monthly_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL -- Active, Churned, Upgraded, Downgraded
);

-- Seed Data
INSERT INTO saas_customers (company_name, signup_date, plan_tier, is_active) VALUES
('Acme Corp', '2024-01-10', 'Enterprise', TRUE),
('Beta Tech', '2024-01-15', 'Pro', TRUE),
('Gamma Design', '2024-02-01', 'Basic', TRUE),
('Delta Logistics', '2024-02-20', 'Pro', FALSE),
('Epsilon Media', '2024-03-05', 'Enterprise', TRUE);

INSERT INTO subscriptions (customer_id, billing_month, monthly_amount, status) VALUES
-- Jan 2024
(1, '2024-01-01', 500.00, 'Active'),
(2, '2024-01-01', 150.00, 'Active'),

-- Feb 2024
(1, '2024-02-01', 500.00, 'Active'),
(2, '2024-02-01', 150.00, 'Active'),
(3, '2024-02-01', 50.00,  'Active'),
(4, '2024-02-01', 150.00, 'Active'),

-- Mar 2024
(1, '2024-03-01', 750.00, 'Upgraded'), -- Expansion MRR
(2, '2024-03-01', 150.00, 'Active'),
(3, '2024-03-01', 50.00,  'Active'),
(4, '2024-03-01', 0.00,   'Churned'), -- Churned MRR
(5, '2024-03-01', 500.00, 'Active'); -- New MRR

-- ============================================
-- QUERY 1: Monthly Recurring Revenue (MRR) Trend
-- ============================================
SELECT 
    billing_month,
    SUM(monthly_amount) AS total_mrr,
    SUM(monthly_amount) * 12 AS run_rate_arr,
    COUNT(DISTINCT customer_id) AS active_subscribers
FROM subscriptions
WHERE monthly_amount > 0
GROUP BY billing_month
ORDER BY billing_month;

-- ============================================
-- QUERY 2: Average Revenue Per User (ARPU)
-- ============================================
SELECT 
    billing_month,
    ROUND(SUM(monthly_amount) / COUNT(DISTINCT customer_id), 2) AS arpu
FROM subscriptions
WHERE monthly_amount > 0
GROUP BY billing_month;

-- ============================================
-- QUERY 3: Customer Churn Rate Calculation
-- ============================================
WITH MonthlyCounts AS (
    SELECT 
        billing_month,
        COUNT(DISTINCT CASE WHEN status != 'Churned' THEN customer_id END) AS active_cust,
        COUNT(DISTINCT CASE WHEN status = 'Churned' THEN customer_id END) AS churned_cust
    FROM subscriptions
    GROUP BY billing_month
)
SELECT 
    billing_month,
    active_cust,
    churned_cust,
    ROUND((churned_cust * 100.0) / NULLIF(active_cust + churned_cust, 0), 2) AS churn_rate_percentage
FROM MonthlyCounts;

-- ============================================
-- QUERY 4: Signup Cohort Retention Matrix
-- ============================================
SELECT 
    DATE_FORMAT(c.signup_date, '%Y-%m') AS cohort_month,
    COUNT(DISTINCT c.customer_id) AS total_cohort_size,
    COUNT(DISTINCT CASE WHEN s.billing_month = '2024-01-01' THEN s.customer_id END) AS m1_active,
    COUNT(DISTINCT CASE WHEN s.billing_month = '2024-02-01' THEN s.customer_id END) AS m2_active,
    COUNT(DISTINCT CASE WHEN s.billing_month = '2024-03-01' THEN s.customer_id END) AS m3_active
FROM saas_customers c
LEFT JOIN subscriptions s ON c.customer_id = s.customer_id AND s.monthly_amount > 0
GROUP BY cohort_month
ORDER BY cohort_month;

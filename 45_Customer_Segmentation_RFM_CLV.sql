-- ============================================
-- LESSON 45: Customer Lifetime Value (CLV/LTV) & RFM Segmentation
-- ============================================
-- Topics Covered:
-- 1. Recency, Frequency, Monetary (RFM) Raw Feature Engineering
-- 2. Statistical RFM Scoring via NTILE(5) Quantile Windows
-- 3. Behavioral Segmentation Matrix (Champions, Loyalists, At Risk, Lost)
-- 4. Unit Economics & Historical LTV by Acquisition Channel
-- 5. Inter-Purchase Velocity & Dynamic Churn Hazard Early Warning Indicator
-- ============================================

DROP TABLE IF EXISTS rfm_orders;
DROP TABLE IF EXISTS rfm_customers;

-- 1. Setup Practice Schema
CREATE TABLE rfm_customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    signup_date DATE NOT NULL,
    channel VARCHAR(50) NOT NULL,
    cac_cost DECIMAL(10, 2) NOT NULL -- Customer Acquisition Cost in USD
);

CREATE TABLE rfm_orders (
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL,
    order_status VARCHAR(20) NOT NULL -- 'COMPLETED', 'CANCELLED', 'REFUNDED'
);

-- 2. Seed Data
INSERT INTO rfm_customers (customer_id, customer_name, email, signup_date, channel, cac_cost) VALUES
(1,  'Eleanor Vance',    'eleanor@hill.org',     '2023-01-15', 'Organic Search', 45.00),
(2,  'Marcus Holloway',  'marcus@dedsec.net',    '2023-02-10', 'Paid Social',   120.00),
(3,  'Clara Oswald',     'clara@tardis.io',      '2023-03-05', 'Referral',       35.00),
(4,  'Arthur Pendragon', 'arthur@camelot.co.uk', '2023-04-12', 'Direct',        15.00),
(5,  'Beatrix Kiddo',    'beatrix@viper.org',    '2023-05-20', 'Organic Search', 45.00),
(6,  'Geralt of Rivia',  'geralt@kaer.witch',    '2023-06-01', 'Paid Search',   140.00),
(7,  'Yennefer Venger',  'yennefer@aretuza.edu', '2023-07-15', 'Referral',       35.00),
(8,  'Miles Morales',    'miles@brooklyn.ny',    '2023-08-22', 'Paid Social',   110.00),
(9,  'Diana Prince',     'diana@themyscira.gov', '2023-09-10', 'Organic Search', 45.00),
(10, 'Barry Allen',      'barry@starlabs.com',   '2023-10-05', 'Paid Search',   135.00);

INSERT INTO rfm_orders (order_id, customer_id, order_date, order_amount, order_status) VALUES
-- Eleanor Vance: Champion (Very recent, high frequency, consistent spend)
(101, 1, '2024-01-10', 120.00, 'COMPLETED'),
(102, 1, '2024-02-14', 250.00, 'COMPLETED'),
(103, 1, '2024-03-22', 180.00, 'COMPLETED'),
(104, 1, '2024-05-28', 310.00, 'COMPLETED'),

-- Marcus Holloway: Loyalist (Recent, frequent, moderate spend)
(105, 2, '2023-11-05', 75.00,  'COMPLETED'),
(106, 2, '2024-02-01', 95.00,  'COMPLETED'),
(107, 2, '2024-05-15', 110.00, 'COMPLETED'),

-- Clara Oswald: At Risk / Churning High Spender (High past spend, long inactivity)
(108, 3, '2023-04-10', 450.00, 'COMPLETED'),
(109, 3, '2023-07-18', 520.00, 'COMPLETED'),
(110, 3, '2023-09-02', 380.00, 'COMPLETED'),

-- Arthur Pendragon: Lost / Dormant (Single low-value order > 1 year ago)
(111, 4, '2023-05-01', 45.00,  'COMPLETED'),

-- Beatrix Kiddo: Champion (Recent high spend)
(112, 5, '2024-01-20', 300.00, 'COMPLETED'),
(113, 5, '2024-03-15', 420.00, 'COMPLETED'),
(114, 5, '2024-05-20', 600.00, 'COMPLETED'),

-- Geralt of Rivia: Potential Loyalist (Multiple moderate purchases recently)
(115, 6, '2024-03-01', 130.00, 'COMPLETED'),
(116, 6, '2024-05-10', 160.00, 'COMPLETED'),

-- Yennefer Venger: High-Value Recent
(117, 7, '2024-04-05', 780.00, 'COMPLETED'),

-- Miles Morales: Promising New Customer (Single recent purchase)
(118, 8, '2024-05-25', 140.00, 'COMPLETED'),

-- Diana Prince: Hibernating (Inactive for 6+ months)
(119, 9, '2023-11-20', 210.00, 'COMPLETED'),

-- Barry Allen: Needs Nurturing (Single small completed order, one cancelled)
(120, 10, '2024-02-10', 80.00,  'CANCELLED'),
(121, 10, '2024-04-18', 65.00,  'COMPLETED');

-- ============================================
-- QUERY 1: Base Recency, Frequency, and Monetary (RFM) Aggregations
-- ============================================
-- Benchmark analysis date is simulated as '2024-06-01'
-- Dialect note: DATEDIFF(date1, date2) in MySQL.
-- In PostgreSQL: ('2024-06-01'::DATE - MAX(o.order_date))
-- In SQLite: CAST(julianday('2024-06-01') - julianday(MAX(o.order_date)) AS INTEGER)
SELECT 
    c.customer_id,
    c.customer_name,
    c.channel,
    DATEDIFF('2024-06-01', MAX(o.order_date)) AS recency_days,
    COUNT(o.order_id) AS frequency_orders,
    COALESCE(SUM(o.order_amount), 0.00) AS monetary_total,
    ROUND(AVG(o.order_amount), 2) AS average_order_value
FROM rfm_customers c
JOIN rfm_orders o ON c.customer_id = o.customer_id AND o.order_status = 'COMPLETED'
GROUP BY c.customer_id, c.customer_name, c.channel
ORDER BY monetary_total DESC;

-- ============================================
-- QUERY 2: RFM Quantile Scoring via NTILE(5)
-- ============================================
-- Scores customers on a 1-5 scale for R, F, and M:
-- Recency: Lower days = more recent = higher score (5)
-- Frequency & Monetary: Higher count/spend = higher score (5)
WITH CustomerRFM AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        DATEDIFF('2024-06-01', MAX(o.order_date)) AS recency_days,
        COUNT(o.order_id) AS frequency_orders,
        SUM(o.order_amount) AS monetary_total
    FROM rfm_customers c
    JOIN rfm_orders o ON c.customer_id = o.customer_id AND o.order_status = 'COMPLETED'
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    recency_days,
    frequency_orders,
    monetary_total,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency_orders ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary_total ASC) AS m_score
FROM CustomerRFM
ORDER BY r_score DESC, m_score DESC;

-- ============================================
-- QUERY 3: Customer Lifecycle Archetype Mapping
-- ============================================
-- Classifies customer relationships into actionable CRM segments
WITH CustomerRFM AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.email,
        DATEDIFF('2024-06-01', MAX(o.order_date)) AS recency_days,
        COUNT(o.order_id) AS frequency_orders,
        SUM(o.order_amount) AS monetary_total
    FROM rfm_customers c
    JOIN rfm_orders o ON c.customer_id = o.customer_id AND o.order_status = 'COMPLETED'
    GROUP BY c.customer_id, c.customer_name, c.email
),
ScoredRFM AS (
    SELECT 
        customer_id,
        customer_name,
        email,
        recency_days,
        frequency_orders,
        monetary_total,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency_orders ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary_total ASC) AS m_score
    FROM CustomerRFM
)
SELECT 
    customer_id,
    customer_name,
    email,
    r_score,
    f_score,
    m_score,
    (r_score * 100 + f_score * 10 + m_score) AS rfm_cell_code,
    CASE 
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champion (Reward & VIP Access)'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customer (Upsell & Loyalty Program)'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'Promising New Buyer (Onboarding Flow)'
        WHEN r_score <= 2 AND (f_score >= 3 OR m_score >= 4) THEN 'At Risk / Churning Whale (Winback Offer)'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost / Dormant (Low-cost Reactivation)'
        ELSE 'Needs Nurturing (Cross-sell)'
    END AS segment_strategy
FROM ScoredRFM
ORDER BY rfm_cell_code DESC;

-- ============================================
-- QUERY 4: Acquisition Channel Unit Economics (CAC vs Historical LTV)
-- ============================================
-- Evaluates channel ROI by comparing acquisition cost against total customer revenue
SELECT 
    c.channel,
    COUNT(DISTINCT c.customer_id) AS total_acquired_customers,
    ROUND(AVG(c.cac_cost), 2) AS avg_cac_per_user,
    ROUND(SUM(o.order_amount), 2) AS total_cohort_revenue,
    ROUND(SUM(o.order_amount) / COUNT(DISTINCT c.customer_id), 2) AS historical_ltv_per_user,
    ROUND(
        (SUM(o.order_amount) / COUNT(DISTINCT c.customer_id)) / AVG(c.cac_cost), 
        2
    ) AS ltv_to_cac_ratio,
    CASE 
        WHEN (SUM(o.order_amount) / COUNT(DISTINCT c.customer_id)) / AVG(c.cac_cost) >= 3.0 
        THEN 'EXCELLENT: Highly profitable channel (Ratio >= 3.0)'
        WHEN (SUM(o.order_amount) / COUNT(DISTINCT c.customer_id)) / AVG(c.cac_cost) >= 1.0 
        THEN 'VIABLE: Profitable but monitor CAC'
        ELSE 'UNECONOMIC: Acquisition cost exceeds realized revenue'
    END AS channel_health_rating
FROM rfm_customers c
JOIN rfm_orders o ON c.customer_id = o.customer_id AND o.order_status = 'COMPLETED'
GROUP BY c.channel
ORDER BY ltv_to_cac_ratio DESC;

-- ============================================
-- QUERY 5: Inter-Purchase Velocity & Dynamic Churn Hazard Early Warning
-- ============================================
-- Uses LAG() window function to calculate each customer's personalized purchase rhythm.
-- Flags high churn hazard when elapsed dormancy exceeds 2.0x their personalized cycle.
WITH OrderSequencing AS (
    SELECT 
        order_id,
        customer_id,
        order_date,
        order_amount,
        LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS prev_order_date,
        DATEDIFF(order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date)) AS days_since_prev_order
    FROM rfm_orders
    WHERE order_status = 'COMPLETED'
),
CustomerIntervals AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        COUNT(os.order_id) AS total_orders,
        MAX(os.order_date) AS last_order_date,
        DATEDIFF('2024-06-01', MAX(os.order_date)) AS days_since_last_order,
        ROUND(AVG(os.days_since_prev_order), 1) AS avg_days_between_orders
    FROM rfm_customers c
    JOIN OrderSequencing os ON c.customer_id = os.customer_id
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_id,
    customer_name,
    total_orders,
    last_order_date,
    days_since_last_order,
    COALESCE(avg_days_between_orders, 0.0) AS avg_repurchase_cycle_days,
    CASE 
        WHEN total_orders = 1 AND days_since_last_order > 180 
        THEN 'CHURNED: Single purchaser dormant > 180 days'
        WHEN total_orders = 1 
        THEN 'RECENT_NEW: Awaiting second order conversion'
        WHEN days_since_last_order > (2.0 * avg_days_between_orders) 
        THEN 'HIGH_CHURN_RISK: Dormancy exceeds 2x personalized cycle'
        WHEN days_since_last_order > (1.2 * avg_days_between_orders) 
        THEN 'MEDIUM_ALERT: Purchase window is past due'
        ELSE 'HEALTHY_ACTIVE: Within predicted repeat window'
    END AS churn_hazard_status
FROM CustomerIntervals
ORDER BY days_since_last_order ASC;

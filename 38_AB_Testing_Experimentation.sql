-- ============================================
-- LESSON 38: A/B Testing & Product Experimentation Analytics
-- ============================================
-- Topics Covered:
-- 1. Experiment Setup & Sample Ratio Mismatch (SRM) Checks
-- 2. Conversion Rate Lift & Relative Lift Calculation
-- 3. Continuous Metrics: Average Order Value (AOV) & ARPU with Variance
-- 4. Metric Winsorization / Outlier Capping for High Spenders
-- 5. Cumulative Day-over-Day Experiment Convergence
-- ============================================

DROP TABLE IF EXISTS experiment_events;
DROP TABLE IF EXISTS experiment_users;

-- 1. Setup Practice Schema for A/B Testing
CREATE TABLE experiment_users (
    user_id INT PRIMARY KEY,
    variant VARCHAR(20) NOT NULL, -- 'control', 'treatment'
    device VARCHAR(20) NOT NULL,  -- 'mobile', 'desktop'
    assigned_at DATETIME NOT NULL
);

CREATE TABLE experiment_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_type VARCHAR(30) NOT NULL, -- 'page_view', 'add_to_cart', 'purchase'
    amount DECIMAL(10, 2) DEFAULT 0.00,
    event_time DATETIME NOT NULL
);

-- Seed Data
INSERT INTO experiment_users (user_id, variant, device, assigned_at) VALUES
(101, 'control',   'mobile',  '2024-04-01 09:00:00'),
(102, 'treatment', 'mobile',  '2024-04-01 09:05:00'),
(103, 'control',   'desktop', '2024-04-01 09:10:00'),
(104, 'treatment', 'desktop', '2024-04-01 09:15:00'),
(105, 'control',   'mobile',  '2024-04-01 09:20:00'),
(106, 'treatment', 'mobile',  '2024-04-01 09:25:00'),
(107, 'control',   'desktop', '2024-04-01 09:30:00'),
(108, 'treatment', 'desktop', '2024-04-01 09:35:00'),
(109, 'control',   'mobile',  '2024-04-02 10:00:00'),
(110, 'treatment', 'mobile',  '2024-04-02 10:05:00'),
(111, 'control',   'desktop', '2024-04-02 10:10:00'),
(112, 'treatment', 'desktop', '2024-04-02 10:15:00'),
(113, 'control',   'mobile',  '2024-04-02 10:20:00'),
(114, 'treatment', 'mobile',  '2024-04-02 10:25:00');

INSERT INTO experiment_events (user_id, event_type, amount, event_time) VALUES
(101, 'page_view', 0.00,   '2024-04-01 09:01:00'),
(101, 'purchase',  45.00,  '2024-04-01 09:12:00'),
(102, 'page_view', 0.00,   '2024-04-01 09:06:00'),
(102, 'purchase',  85.00,  '2024-04-01 09:14:00'),
(103, 'page_view', 0.00,   '2024-04-01 09:11:00'),
(104, 'page_view', 0.00,   '2024-04-01 09:16:00'),
(104, 'purchase',  120.00, '2024-04-01 09:22:00'),
(105, 'page_view', 0.00,   '2024-04-01 09:21:00'),
(106, 'page_view', 0.00,   '2024-04-01 09:26:00'),
(106, 'purchase',  95.00,  '2024-04-01 09:30:00'),
(107, 'page_view', 0.00,   '2024-04-01 09:31:00'),
(107, 'purchase',  35.00,  '2024-04-01 09:40:00'),
(108, 'page_view', 0.00,   '2024-04-01 09:36:00'),
(108, 'purchase',  520.00, '2024-04-01 09:45:00'), -- Extreme outlier/whale
(109, 'page_view', 0.00,   '2024-04-02 10:01:00'),
(110, 'page_view', 0.00,   '2024-04-02 10:06:00'),
(110, 'purchase',  60.00,  '2024-04-02 10:18:00'),
(111, 'page_view', 0.00,   '2024-04-02 10:11:00'),
(112, 'page_view', 0.00,   '2024-04-02 10:16:00'),
(112, 'purchase',  110.00, '2024-04-02 10:24:00'),
(113, 'page_view', 0.00,   '2024-04-02 10:21:00'),
(114, 'page_view', 0.00,   '2024-04-02 10:26:00');

-- ============================================
-- QUERY 1: Sample Ratio Mismatch (SRM) Check
-- ============================================
-- A critical sanity check: Ensure traffic split matches expected ratio (50/50).
-- Chi-Square approx: sum((observed - expected)^2 / expected)
WITH TrafficCounts AS (
    SELECT 
        variant,
        COUNT(*) AS observed_users,
        SUM(COUNT(*)) OVER() AS total_users
    FROM experiment_users
    GROUP BY variant
)
SELECT 
    variant,
    observed_users,
    total_users * 0.50 AS expected_users,
    ROUND(observed_users * 100.0 / total_users, 2) AS traffic_percentage,
    ROUND(POWER(observed_users - (total_users * 0.50), 2) / (total_users * 0.50), 4) AS chi_square_stat,
    CASE 
        WHEN POWER(observed_users - (total_users * 0.50), 2) / (total_users * 0.50) < 3.841 
        THEN 'PASS (No SRM detected at p=0.05)'
        ELSE 'FAIL (SRM detected - investigate assignment bias)'
    END AS srm_status
FROM TrafficCounts;

-- ============================================
-- QUERY 2: Conversion Rate & Relative Lift
-- ============================================
WITH UserConversions AS (
    SELECT 
        u.user_id,
        u.variant,
        MAX(CASE WHEN e.event_type = 'purchase' THEN 1 ELSE 0 END) AS has_purchased,
        COALESCE(SUM(e.amount), 0.00) AS user_spend
    FROM experiment_users u
    LEFT JOIN experiment_events e ON u.user_id = e.user_id
    GROUP BY u.user_id, u.variant
),
VariantMetrics AS (
    SELECT 
        variant,
        COUNT(*) AS total_users,
        SUM(has_purchased) AS converted_users,
        ROUND(AVG(has_purchased) * 100.0, 2) AS conversion_rate_pct,
        ROUND(AVG(user_spend), 2) AS arpu,
        ROUND(SUM(user_spend) / NULLIF(SUM(has_purchased), 0), 2) AS avg_order_value
    FROM UserConversions
    GROUP BY variant
)
SELECT 
    vm.variant,
    vm.total_users,
    vm.converted_users,
    vm.conversion_rate_pct,
    vm.arpu,
    vm.avg_order_value,
    ROUND(vm.conversion_rate_pct - ctrl.conversion_rate_pct, 2) AS absolute_lift_pct,
    ROUND(((vm.conversion_rate_pct - ctrl.conversion_rate_pct) / ctrl.conversion_rate_pct) * 100.0, 2) AS relative_lift_pct
FROM VariantMetrics vm
CROSS JOIN (SELECT conversion_rate_pct FROM VariantMetrics WHERE variant = 'control') ctrl;

-- ============================================
-- QUERY 3: Outlier Capping (Winsorization) on ARPU
-- ============================================
-- Extreme spenders (whales) can distort experiment conclusions.
-- Cap individual user spend at $200 to test robustness.
WITH UserSpend AS (
    SELECT 
        u.user_id,
        u.variant,
        COALESCE(SUM(e.amount), 0.00) AS raw_spend,
        CASE 
            WHEN COALESCE(SUM(e.amount), 0.00) > 200.00 THEN 200.00 
            ELSE COALESCE(SUM(e.amount), 0.00) 
        END AS winsorized_spend
    FROM experiment_users u
    LEFT JOIN experiment_events e ON u.user_id = e.user_id
    GROUP BY u.user_id, u.variant
)
SELECT 
    variant,
    COUNT(*) AS total_users,
    ROUND(AVG(raw_spend), 2) AS raw_arpu,
    ROUND(AVG(winsorized_spend), 2) AS winsorized_arpu,
    ROUND(STDDEV(winsorized_spend), 2) AS std_dev_winsorized
FROM UserSpend
GROUP BY variant;

-- ============================================
-- QUERY 4: Cumulative Day-over-Day Convergence
-- ============================================
WITH DailyActivity AS (
    SELECT 
        DATE(u.assigned_at) AS exp_date,
        u.variant,
        u.user_id,
        MAX(CASE WHEN e.event_type = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM experiment_users u
    LEFT JOIN experiment_events e ON u.user_id = e.user_id
    GROUP BY DATE(u.assigned_at), u.variant, u.user_id
),
DailyAggregates AS (
    SELECT 
        exp_date,
        variant,
        COUNT(user_id) AS new_users,
        SUM(purchased) AS new_conversions
    FROM DailyActivity
    GROUP BY exp_date, variant
)
SELECT 
    exp_date,
    variant,
    SUM(new_users) OVER (PARTITION BY variant ORDER BY exp_date) AS cum_users,
    SUM(new_conversions) OVER (PARTITION BY variant ORDER BY exp_date) AS cum_conversions,
    ROUND((SUM(new_conversions) OVER (PARTITION BY variant ORDER BY exp_date) * 100.0) /
          SUM(new_users) OVER (PARTITION BY variant ORDER BY exp_date), 2) AS cum_cvr_pct
FROM DailyAggregates
ORDER BY exp_date, variant;

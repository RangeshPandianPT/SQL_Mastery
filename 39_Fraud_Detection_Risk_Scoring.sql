-- ============================================
-- LESSON 39: Fraud Detection & Risk Scoring Engine
-- ============================================
-- Topics Covered:
-- 1. High-Frequency Velocity Checks (Burst Transactions)
-- 2. Rapid Geographic "Impossible Travel" Detection
-- 3. Statistical Anomaly Detection (Z-Score on Spending Amounts)
-- 4. Multi-Factor Weighted Risk Scoring Rule Engine
-- ============================================

DROP TABLE IF EXISTS card_transactions;
DROP TABLE IF EXISTS user_cards;

-- 1. Setup Practice Schema
CREATE TABLE user_cards (
    card_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    card_holder VARCHAR(100) NOT NULL,
    home_country VARCHAR(10) NOT NULL,
    created_at DATETIME NOT NULL
);

CREATE TABLE card_transactions (
    txn_id INT PRIMARY KEY AUTO_INCREMENT,
    card_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    merchant VARCHAR(100) NOT NULL,
    merchant_category VARCHAR(50) NOT NULL, -- 'retail', 'crypto', 'electronics', 'grocery'
    country_code VARCHAR(10) NOT NULL,
    txn_time DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'approved'
);

-- Seed Data
INSERT INTO user_cards (card_id, user_id, card_holder, home_country, created_at) VALUES
(1001, 501, 'Alex Mercer',  'US', '2023-01-10 10:00:00'),
(1002, 502, 'Sara Connor',  'GB', '2023-03-15 11:30:00'),
(1003, 503, 'David Miller', 'CA', '2023-05-20 14:00:00');

INSERT INTO card_transactions (card_id, amount, merchant, merchant_category, country_code, txn_time) VALUES
-- Normal spending for Alex
(1001, 15.50,  'Starbucks',       'grocery',     'US', '2024-04-10 08:30:00'),
(1001, 42.00,  'Shell Gas',       'retail',      'US', '2024-04-10 12:15:00'),
(1001, 85.00,  'Target',          'retail',      'US', '2024-04-10 17:00:00'),
-- Rapid-fire micro-transactions (Card Testing Attack on Alex)
(1001, 1.00,   'Online Game Store','crypto',     'NG', '2024-04-10 20:01:00'),
(1001, 1.25,   'Digital Credits', 'crypto',      'NG', '2024-04-10 20:02:30'),
(1001, 1.50,   'Cloud Hosting',   'crypto',      'NG', '2024-04-10 20:03:45'),
(1001, 899.00, 'Luxury Watches',  'retail',      'NG', '2024-04-10 20:06:00'),

-- Sara Connor: Impossible Travel (London to Tokyo in 20 minutes)
(1002, 35.00,  'Tesco Supermarket', 'grocery',   'GB', '2024-04-10 14:00:00'),
(1002, 950.00, 'Shinjuku Camera',   'electronics','JP', '2024-04-10 14:22:00'),

-- David Miller: Huge statistical outlier compared to baseline
(1003, 25.00,  'Tim Hortons',     'grocery',     'CA', '2024-04-01 09:00:00'),
(1003, 30.00,  'Metro Grocer',    'grocery',     'CA', '2024-04-03 14:00:00'),
(1003, 28.50,  'Petro Canada',    'retail',      'CA', '2024-04-05 18:30:00'),
(1003, 32.00,  'Rexall Pharmacy', 'retail',      'CA', '2024-04-08 11:15:00'),
(1003, 31.00,  'Esso Gas',        'retail',      'CA', '2024-04-09 16:45:00'),
(1003, 4850.00,'Gold Exchange Inc','crypto',     'CA', '2024-04-10 19:00:00'); -- Extreme spike

-- ============================================
-- QUERY 1: Velocity Rule - High Frequency in Rolling Window
-- ============================================
-- Flag any transaction where the card had >= 3 transactions within the prior 10 minutes.
WITH PriorTxnCount AS (
    SELECT 
        t1.txn_id,
        t1.card_id,
        t1.amount,
        t1.merchant,
        t1.txn_time,
        COUNT(t2.txn_id) AS txns_last_10_mins,
        SUM(t2.amount) AS amount_last_10_mins
    FROM card_transactions t1
    JOIN card_transactions t2 
      ON t1.card_id = t2.card_id 
     AND t2.txn_time BETWEEN DATE_SUB(t1.txn_time, INTERVAL 10 MINUTE) AND t1.txn_time
    GROUP BY t1.txn_id, t1.card_id, t1.amount, t1.merchant, t1.txn_time
)
SELECT 
    txn_id,
    card_id,
    merchant,
    amount,
    txn_time,
    txns_last_10_mins,
    amount_last_10_mins,
    CASE WHEN txns_last_10_mins >= 3 THEN 'ALERT: HIGH VELOCITY BURST' ELSE 'NORMAL' END AS velocity_status
FROM PriorTxnCount
ORDER BY card_id, txn_time;

-- ============================================
-- QUERY 2: Impossible Travel (Cross-Border Hop in < 2 Hours)
-- ============================================
WITH SequencedTxns AS (
    SELECT 
        txn_id,
        card_id,
        amount,
        merchant,
        country_code,
        txn_time,
        LAG(country_code) OVER (PARTITION BY card_id ORDER BY txn_time) AS prev_country,
        LAG(txn_time) OVER (PARTITION BY card_id ORDER BY txn_time) AS prev_time
    FROM card_transactions
)
SELECT 
    txn_id,
    card_id,
    merchant,
    amount,
    prev_country,
    country_code AS current_country,
    prev_time,
    txn_time AS current_time,
    TIMESTAMPDIFF(MINUTE, prev_time, txn_time) AS elapsed_minutes,
    CASE 
        WHEN prev_country IS NOT NULL 
         AND prev_country != country_code 
         AND TIMESTAMPDIFF(MINUTE, prev_time, txn_time) < 120 
        THEN 'ALERT: IMPOSSIBLE TRAVEL DETECTED'
        ELSE 'NORMAL'
    END AS travel_status
FROM SequencedTxns
WHERE prev_country IS NOT NULL;

-- ============================================
-- QUERY 3: Statistical Outlier (Rolling Z-Score)
-- ============================================
-- Z-Score = (amount - mean) / stddev. A score > 3 indicates a 3-sigma anomaly.
WITH CardStats AS (
    SELECT 
        txn_id,
        card_id,
        amount,
        merchant,
        txn_time,
        AVG(amount) OVER (PARTITION BY card_id) AS avg_amount,
        STDDEV(amount) OVER (PARTITION BY card_id) AS std_amount
    FROM card_transactions
)
SELECT 
    txn_id,
    card_id,
    merchant,
    amount,
    ROUND(avg_amount, 2) AS user_avg_amount,
    ROUND(std_amount, 2) AS user_std_amount,
    ROUND((amount - avg_amount) / NULLIF(std_amount, 0), 2) AS z_score,
    CASE 
        WHEN (amount - avg_amount) / NULLIF(std_amount, 0) >= 3.0 THEN 'CRITICAL: 3-SIGMA OUTLIER'
        WHEN (amount - avg_amount) / NULLIF(std_amount, 0) >= 2.0 THEN 'WARNING: 2-SIGMA ELEVATED'
        ELSE 'NORMAL'
    END AS anomaly_level
FROM CardStats;

-- ============================================
-- QUERY 4: Composite Multi-Factor Fraud Risk Engine
-- ============================================
-- Combines velocity, travel, high-risk merchant category, and foreign country flags into a 0-100 score.
WITH RiskFactors AS (
    SELECT 
        t.txn_id,
        t.card_id,
        c.card_holder,
        t.amount,
        t.merchant,
        t.merchant_category,
        t.country_code,
        t.txn_time,
        -- Signal 1: Foreign country swipe (+25 pts)
        CASE WHEN t.country_code != c.home_country THEN 25 ELSE 0 END AS pts_foreign_country,
        -- Signal 2: High risk category like crypto/electronics (+20 pts)
        CASE WHEN t.merchant_category IN ('crypto', 'electronics') THEN 20 ELSE 0 END AS pts_high_risk_mcc,
        -- Signal 3: Large ticket over $500 (+25 pts)
        CASE WHEN t.amount >= 500.00 THEN 25 ELSE 0 END AS pts_large_amount,
        -- Signal 4: Rapid previous activity in < 15 mins (+30 pts)
        CASE 
            WHEN TIMESTAMPDIFF(MINUTE, 
                LAG(t.txn_time) OVER (PARTITION BY t.card_id ORDER BY t.txn_time), 
                t.txn_time) <= 15 THEN 30 
            ELSE 0 
        END AS pts_velocity
    FROM card_transactions t
    JOIN user_cards c ON t.card_id = c.card_id
)
SELECT 
    txn_id,
    card_id,
    card_holder,
    merchant,
    amount,
    country_code,
    (pts_foreign_country + pts_high_risk_mcc + pts_large_amount + pts_velocity) AS total_risk_score,
    CASE 
        WHEN (pts_foreign_country + pts_high_risk_mcc + pts_large_amount + pts_velocity) >= 70 THEN 'AUTO_BLOCK'
        WHEN (pts_foreign_country + pts_high_risk_mcc + pts_large_amount + pts_velocity) >= 40 THEN 'STEP_UP_AUTH (2FA)'
        ELSE 'ALLOW'
    END AS decision
FROM RiskFactors
ORDER BY total_risk_score DESC, txn_id;

-- ============================================
-- LESSON 44: Automated Data Quality & Testing Framework
-- ============================================
-- Topics Covered:
-- 1. Primary Key Uniqueness & Nullability Checks
-- 2. Foreign Key Referential Integrity & Orphan Record Scans
-- 3. Value Range & Allowed Set Domain Validation
-- 4. Pipeline Data Freshness & Ingestion SLA Monitoring
-- 5. Consolidated Executive DQ Audit Scorecard (PASS / FAIL)
-- ============================================

DROP TABLE IF EXISTS raw_order_items;
DROP TABLE IF EXISTS raw_orders;
DROP TABLE IF EXISTS raw_users;

-- 1. Setup Practice Schema with Intentional Data Quality Defects
CREATE TABLE raw_users (
    user_id INT, -- Note: intentionally no PK constraint to test duplicate detection
    email VARCHAR(100),
    age INT,
    country_code VARCHAR(10),
    created_at DATETIME
);

CREATE TABLE raw_orders (
    order_id INT,
    user_id INT,
    order_date DATE,
    order_amount DECIMAL(10, 2),
    order_status VARCHAR(20)
);

-- Seed Data (Contains valid records and deliberate dirty data)
INSERT INTO raw_users (user_id, email, age, country_code, created_at) VALUES
(1, 'alice@example.com', 29, 'US', '2024-04-01 10:00:00'),
(2, 'bob@example.com',   34, 'CA', '2024-04-02 11:30:00'),
(2, 'bob_duplicate@test.com', 34, 'CA', '2024-04-02 11:35:00'), -- Defect: Duplicate user_id
(3, NULL,                41, 'GB', '2024-04-03 14:00:00'),        -- Defect: Missing / NULL email
(4, 'charlie@bademail',  -5, 'US', '2024-04-04 15:20:00'),        -- Defect: Invalid negative age
(5, 'diana@example.com', 185,'DE', '2024-04-05 09:10:00');        -- Defect: Out-of-bounds age (> 120)

INSERT INTO raw_orders (order_id, user_id, order_date, order_amount, order_status) VALUES
(1001, 1, '2024-04-10', 150.00,  'COMPLETED'),
(1002, 2, '2024-04-11', 220.00,  'SHIPPED'),
(1003, 999, '2024-04-12', 85.00, 'COMPLETED'), -- Defect: Orphan order! user_id 999 does not exist
(1004, 1, '2024-04-12', -45.00,  'COMPLETED'),  -- Defect: Negative order amount
(1005, 3, '2024-04-13', 310.00,  'UNKNOWN_STATUS'), -- Defect: Invalid status code
(1006, 1, '2024-01-01', 50.00,   'COMPLETED');  -- Freshness check baseline

-- ============================================
-- QUERY 1: Primary Key Uniqueness Test
-- ============================================
-- Finds duplicated IDs that violate entity integrity
SELECT 
    user_id,
    COUNT(*) AS occurrence_count
FROM raw_users
GROUP BY user_id
HAVING COUNT(*) > 1;

-- ============================================
-- QUERY 2: Critical Column Nullability Check
-- ============================================
SELECT 
    'raw_users' AS table_name,
    'email' AS column_name,
    COUNT(*) AS null_count
FROM raw_users
WHERE email IS NULL OR TRIM(email) = '';

-- ============================================
-- QUERY 3: Referential Integrity (Orphan Record Scan)
-- ============================================
-- Orders referencing users that do not exist in the parent table
SELECT 
    o.order_id,
    o.user_id AS invalid_foreign_key,
    o.order_amount,
    o.order_date
FROM raw_orders o
LEFT JOIN raw_users u ON o.user_id = u.user_id
WHERE u.user_id IS NULL;

-- ============================================
-- QUERY 4: Domain & Business Logic Rule Assertions
-- ============================================
-- Rule A: Age must be between 18 and 120
-- Rule B: Order amount must be strictly positive (> 0)
-- Rule C: Order status must belong to allowed enum: ('PENDING', 'PROCESSING', 'SHIPPED', 'COMPLETED', 'CANCELLED')
SELECT 
    order_id,
    order_amount,
    order_status,
    CASE 
        WHEN order_amount <= 0 THEN 'RULE_FAIL: Non-positive amount'
        WHEN order_status NOT IN ('PENDING', 'PROCESSING', 'SHIPPED', 'COMPLETED', 'CANCELLED') THEN 'RULE_FAIL: Unrecognized status enum'
        ELSE 'PASS'
    END AS validation_outcome
FROM raw_orders
WHERE order_amount <= 0 
   OR order_status NOT IN ('PENDING', 'PROCESSING', 'SHIPPED', 'COMPLETED', 'CANCELLED');

-- ============================================
-- QUERY 5: Ingestion Freshness SLA Monitoring
-- ============================================
-- Check if newest ingested order is older than 24 hours (simulated against '2024-04-14')
SELECT 
    'raw_orders' AS table_name,
    MAX(order_date) AS latest_record_date,
    DATEDIFF('2024-04-14', MAX(order_date)) AS days_since_last_ingestion,
    CASE 
        WHEN DATEDIFF('2024-04-14', MAX(order_date)) > 1 
        THEN 'SLA_BREACH: Pipeline is stale (> 1 day delay)'
        ELSE 'SLA_MET: Data is fresh'
    END AS freshness_sla_status
FROM raw_orders;

-- ============================================
-- QUERY 6: Consolidated Data Quality Audit Scorecard
-- ============================================
-- Combines all individual tests into a unified report for CI/CD or daily dbt/Airflow pipelines.
WITH TestResults AS (
    -- Test 1: Duplicate User IDs
    SELECT 
        'raw_users' AS target_table,
        'uniqueness_user_id' AS test_name,
        'Integrity' AS test_category,
        COALESCE(SUM(occurrence_count - 1), 0) AS failed_record_count
    FROM (
        SELECT COUNT(*) AS occurrence_count 
        FROM raw_users 
        GROUP BY user_id 
        HAVING COUNT(*) > 1
    ) dupes

    UNION ALL

    -- Test 2: Null Emails
    SELECT 
        'raw_users',
        'not_null_email',
        'Completeness',
        COUNT(*)
    FROM raw_users
    WHERE email IS NULL OR TRIM(email) = ''

    UNION ALL

    -- Test 3: Valid Age Range (18 to 120)
    SELECT 
        'raw_users',
        'valid_age_range_18_to_120',
        'Validity',
        COUNT(*)
    FROM raw_users
    WHERE age < 18 OR age > 120

    UNION ALL

    -- Test 4: Orphan Orders (Referential Integrity)
    SELECT 
        'raw_orders',
        'fk_orders_to_users_orphan_check',
        'Consistency',
        COUNT(*)
    FROM raw_orders o
    LEFT JOIN raw_users u ON o.user_id = u.user_id
    WHERE u.user_id IS NULL

    UNION ALL

    -- Test 5: Positive Order Amount
    SELECT 
        'raw_orders',
        'positive_order_amount',
        'Validity',
        COUNT(*)
    FROM raw_orders
    WHERE order_amount <= 0

    UNION ALL

    -- Test 6: Valid Status Allowed Enum
    SELECT 
        'raw_orders',
        'allowed_order_status_enum',
        'Conformance',
        COUNT(*)
    FROM raw_orders
    WHERE order_status NOT IN ('PENDING', 'PROCESSING', 'SHIPPED', 'COMPLETED', 'CANCELLED')
)
SELECT 
    target_table,
    test_name,
    test_category,
    failed_record_count,
    CASE 
        WHEN failed_record_count = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS test_status
FROM TestResults
ORDER BY test_status DESC, failed_record_count DESC;

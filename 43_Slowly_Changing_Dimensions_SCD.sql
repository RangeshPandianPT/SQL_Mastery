-- ============================================
-- LESSON 43: Slowly Changing Dimensions (SCD Types 1, 2, and 3)
-- ============================================
-- Topics Covered:
-- 1. Concept of Slowly Changing Dimensions in Data Warehousing
-- 2. SCD Type 1: In-Place Overwrite (No History)
-- 3. SCD Type 2: Full Historical Tracking with Date Bounds & is_current Flag
-- 4. Point-in-Time (AS-OF) Joins with Fact Tables
-- 5. SCD Type 3: Previous Attribute Column Tracking
-- 6. SQL Patterns for Expiring and Inserting SCD Type 2 Records
-- ============================================

DROP TABLE IF EXISTS fact_order_sales;
DROP TABLE IF EXISTS dim_customers_scd2;
DROP TABLE IF EXISTS dim_suppliers_scd3;
DROP TABLE IF EXISTS dim_customers_scd1;

-- 1. Setup Practice Schemas

-- SCD Type 1: Overwrite table (stores only current values)
CREATE TABLE dim_customers_scd1 (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    tier VARCHAR(20) NOT NULL
);

-- SCD Type 2: Versioned table with surrogate key and validity dates
CREATE TABLE dim_customers_scd2 (
    customer_surrogate_key INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    city VARCHAR(50) NOT NULL,
    tier VARCHAR(20) NOT NULL,
    effective_start DATE NOT NULL,
    effective_end DATE NULL,        -- NULL or '9999-12-31' denotes currently active record
    is_current BOOLEAN DEFAULT TRUE
);

-- SCD Type 3: Preserves original/previous value in a dedicated column
CREATE TABLE dim_suppliers_scd3 (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    current_tier VARCHAR(20) NOT NULL,
    previous_tier VARCHAR(20) NULL,
    tier_change_date DATE NULL
);

-- Fact table representing transaction sales at specific points in time
CREATE TABLE fact_order_sales (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_amount DECIMAL(10, 2) NOT NULL
);

-- 2. Seed Data
-- Customer 101 moved from Boston to Austin on 2023-06-01, then upgraded from Silver to Gold on 2024-01-01
INSERT INTO dim_customers_scd2 (customer_id, customer_name, city, tier, effective_start, effective_end, is_current) VALUES
(101, 'Sophia Loren', 'Boston', 'Silver', '2023-01-01', '2023-05-31', FALSE), -- Version 1
(101, 'Sophia Loren', 'Austin', 'Silver', '2023-06-01', '2023-12-31', FALSE), -- Version 2
(101, 'Sophia Loren', 'Austin', 'Gold',   '2024-01-01', NULL,         TRUE),  -- Version 3 (Active)

-- Customer 102 has lived in Seattle since creation
(102, 'Liam Neeson',  'Seattle','Bronze', '2023-03-01', NULL,         TRUE);  -- Version 1 (Active)

-- Fact Table with orders placed across different historical periods
INSERT INTO fact_order_sales (customer_id, order_date, order_amount) VALUES
(101, '2023-02-15', 250.00), -- Occurred during Version 1 (Boston / Silver)
(101, '2023-08-10', 400.00), -- Occurred during Version 2 (Austin / Silver)
(101, '2024-02-20', 850.00), -- Occurred during Version 3 (Austin / Gold)
(102, '2023-07-04', 120.00);

-- SCD 3 Seed
INSERT INTO dim_suppliers_scd3 (supplier_id, supplier_name, current_tier, previous_tier, tier_change_date) VALUES
(1, 'Apex Logistics',   'Tier 1 (Preferred)', 'Tier 2 (Standard)',  '2024-01-15'),
(2, 'Vanguard Freight', 'Tier 2 (Standard)',  NULL,                 NULL);

-- ============================================
-- QUERY 1: Querying the Latest / Current State (SCD Type 2)
-- ============================================
SELECT 
    customer_surrogate_key,
    customer_id,
    customer_name,
    city,
    tier,
    effective_start
FROM dim_customers_scd2
WHERE is_current = TRUE;

-- ============================================
-- QUERY 2: Point-in-Time (AS-OF) Historical Fact Join
-- ============================================
-- Notice how Order 1 gets linked to 'Boston / Silver', Order 2 to 'Austin / Silver', 
-- and Order 3 to 'Austin / Gold' - perfectly preserving history!
SELECT 
    f.order_id,
    f.order_date,
    f.order_amount,
    d.customer_name,
    d.city AS customer_city_at_purchase,
    d.tier AS customer_tier_at_purchase,
    d.customer_surrogate_key AS dim_key_used
FROM fact_order_sales f
JOIN dim_customers_scd2 d 
  ON f.customer_id = d.customer_id
 AND f.order_date >= d.effective_start 
 AND (f.order_date <= d.effective_end OR d.effective_end IS NULL)
ORDER BY f.order_id;

-- ============================================
-- QUERY 3: Revenue by Historical City vs. Current City Comparison
-- ============================================
-- Showing why SCD2 prevents historical distortion:
-- If we joined on current city only, Boston would show $0 revenue!
WITH HistoricalJoin AS (
    SELECT 
        d.city AS historical_city,
        f.order_amount
    FROM fact_order_sales f
    JOIN dim_customers_scd2 d 
      ON f.customer_id = d.customer_id
     AND f.order_date >= d.effective_start 
     AND (f.order_date <= d.effective_end OR d.effective_end IS NULL)
),
CurrentStateJoin AS (
    SELECT 
        d.city AS current_city,
        f.order_amount
    FROM fact_order_sales f
    JOIN dim_customers_scd2 d 
      ON f.customer_id = d.customer_id
     AND d.is_current = TRUE
)
SELECT 
    h.historical_city AS city,
    SUM(h.order_amount) AS revenue_accurate_historical,
    COALESCE(c.revenue_distorted_current, 0.00) AS revenue_distorted_current
FROM HistoricalJoin h
LEFT JOIN (
    SELECT current_city, SUM(order_amount) AS revenue_distorted_current
    FROM CurrentStateJoin
    GROUP BY current_city
) c ON h.historical_city = c.current_city
GROUP BY h.historical_city, c.revenue_distorted_current;

-- ============================================
-- QUERY 4: Complete SCD Type 2 Transition Pipeline Pattern
-- ============================================
-- Demonstrates the two-step transaction when Customer 102 upgrades from 'Bronze' to 'Platinum' on '2024-04-01':
-- Step A: Close the currently active record
UPDATE dim_customers_scd2
SET 
    effective_end = '2024-03-31',
    is_current = FALSE
WHERE customer_id = 102 AND is_current = TRUE;

-- Step B: Insert the new active record
INSERT INTO dim_customers_scd2 (customer_id, customer_name, city, tier, effective_start, effective_end, is_current)
VALUES (102, 'Liam Neeson', 'Seattle', 'Platinum', '2024-04-01', NULL, TRUE);

-- Verify the audit trail for Customer 102
SELECT * FROM dim_customers_scd2 WHERE customer_id = 102 ORDER BY effective_start ASC;

-- ============================================
-- QUERY 5: SCD Type 3 Analysis
-- ============================================
-- Allows comparing old vs. new state side-by-side in a single row without joins
SELECT 
    supplier_id,
    supplier_name,
    current_tier,
    previous_tier,
    tier_change_date,
    CASE 
        WHEN previous_tier IS NOT NULL THEN CONCAT('Transitioned from ', previous_tier, ' to ', current_tier)
        ELSE 'No Tier Changes Recorded'
    END AS status_audit_summary
FROM dim_suppliers_scd3;

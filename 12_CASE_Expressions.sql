-- =====================================================
-- SQL Mastery: 12 - CASE Expressions
-- =====================================================
-- CASE provides conditional logic in SQL queries

-- =====================================================
-- 1. SIMPLE CASE EXPRESSION
-- =====================================================

SELECT product_name, category,
    CASE category
        WHEN 'Electronics' THEN 'Tech'
        WHEN 'Furniture' THEN 'Home'
        WHEN 'Stationery' THEN 'Office'
        ELSE 'Other'
    END AS category_group
FROM products;

-- =====================================================
-- 2. SEARCHED CASE EXPRESSION
-- =====================================================

SELECT product_name, price,
    CASE 
        WHEN price < 50 THEN 'Budget'
        WHEN price < 200 THEN 'Standard'
        WHEN price < 500 THEN 'Premium'
        ELSE 'Luxury'
    END AS price_tier
FROM products;

-- =====================================================
-- 3. CASE IN ORDER BY
-- =====================================================

SELECT * FROM orders
ORDER BY 
    CASE status
        WHEN 'Processing' THEN 1
        WHEN 'Shipped' THEN 2
        WHEN 'Delivered' THEN 3
        ELSE 4
    END;

-- =====================================================
-- 4. CASE WITH AGGREGATION
-- =====================================================

SELECT 
    SUM(CASE WHEN category = 'Electronics' THEN 1 ELSE 0 END) AS electronics_count,
    SUM(CASE WHEN category = 'Furniture' THEN 1 ELSE 0 END) AS furniture_count,
    SUM(CASE WHEN category = 'Stationery' THEN 1 ELSE 0 END) AS stationery_count
FROM products;

-- Pivot-style report
SELECT department,
    SUM(CASE WHEN salary < 55000 THEN 1 ELSE 0 END) AS low_salary,
    SUM(CASE WHEN salary >= 55000 AND salary < 70000 THEN 1 ELSE 0 END) AS mid_salary,
    SUM(CASE WHEN salary >= 70000 THEN 1 ELSE 0 END) AS high_salary
FROM employees
GROUP BY department;

-- =====================================================
-- 5. COALESCE AND NULLIF
-- =====================================================

-- COALESCE - Return first non-null value
SELECT first_name, COALESCE(commission, 0) AS commission FROM employees;
SELECT COALESCE(NULL, NULL, 'default') AS result;

-- NULLIF - Return NULL if values are equal
SELECT NULLIF(10, 10) AS result;  -- Returns NULL
SELECT NULLIF(10, 5) AS result;   -- Returns 10

-- Prevent division by zero
SELECT total / NULLIF(count, 0) AS average FROM stats;

-- =====================================================
-- PRACTICE: Create your own CASE expressions!
-- =====================================================

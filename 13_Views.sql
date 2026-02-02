-- =====================================================
-- SQL Mastery: 13 - Views
-- =====================================================
-- Views are virtual tables based on query results

-- =====================================================
-- 1. CREATING VIEWS
-- =====================================================

-- Basic view
CREATE VIEW active_products AS
SELECT product_id, product_name, price
FROM products
WHERE is_active = TRUE;

-- View with joins
CREATE VIEW customer_orders AS
SELECT c.customer_name, c.email, o.order_id, o.order_date, o.total_amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id;

-- View with calculations
CREATE VIEW employee_compensation AS
SELECT employee_id, first_name, last_name, 
       salary, COALESCE(commission, 0) AS commission,
       salary + COALESCE(commission, 0) AS total_compensation
FROM employees;

-- =====================================================
-- 2. USING VIEWS
-- =====================================================

-- Query a view like a table
SELECT * FROM active_products WHERE price > 100;
SELECT * FROM customer_orders ORDER BY order_date DESC;

-- Join with views
SELECT v.product_name, s.sale_date
FROM active_products v
JOIN sales s ON v.product_id = s.product_id;

-- =====================================================
-- 3. MODIFYING VIEWS
-- =====================================================

-- Replace existing view
CREATE OR REPLACE VIEW active_products AS
SELECT product_id, product_name, category, price
FROM products
WHERE is_active = TRUE;

-- Alter view (MySQL)
ALTER VIEW active_products AS
SELECT * FROM products WHERE is_active = TRUE AND stock_quantity > 0;

-- =====================================================
-- 4. DROPPING VIEWS
-- =====================================================

DROP VIEW IF EXISTS active_products;
DROP VIEW customer_orders;

-- =====================================================
-- 5. VIEW BENEFITS
-- =====================================================
/*
- Simplify complex queries
- Security: Hide sensitive columns
- Abstraction: Change underlying tables without affecting queries
- Reusability: Write once, use many times
*/

-- =====================================================
-- PRACTICE: Create views for your common queries!
-- =====================================================

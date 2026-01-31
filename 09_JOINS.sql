-- =====================================================
-- SQL Mastery: 09 - SQL JOINS
-- =====================================================
-- JOINs combine rows from two or more tables

-- =====================================================
-- 1. INNER JOIN - Returns only matching rows
-- =====================================================

SELECT o.order_id, c.customer_name, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- =====================================================
-- 2. LEFT JOIN - All from left + matching from right
-- =====================================================

SELECT c.customer_name, o.order_id, o.total_amount
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id;

-- Find customers with NO orders
SELECT c.customer_name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- =====================================================
-- 3. RIGHT JOIN - All from right + matching from left
-- =====================================================

SELECT o.order_id, c.customer_name
FROM orders o
RIGHT JOIN customers c ON o.customer_id = c.customer_id;

-- =====================================================
-- 4. CROSS JOIN - Cartesian Product (all combinations)
-- =====================================================

SELECT c.customer_name, p.product_name
FROM customers c
CROSS JOIN products p;

-- =====================================================
-- 5. SELF JOIN - Joining table to itself
-- =====================================================

-- Find employees and their managers
SELECT e.first_name AS employee, m.first_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id;

-- =====================================================
-- 6. MULTIPLE TABLE JOINS
-- =====================================================

SELECT c.customer_name, o.order_date, p.product_name, oi.quantity
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id;

-- =====================================================
-- 7. JOIN WITH AGGREGATION
-- =====================================================

SELECT c.customer_name, COUNT(o.order_id) AS total_orders,
       SUM(o.total_amount) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- =====================================================
-- PRACTICE: Try different join types with your tables!
-- =====================================================

-- =====================================================
-- SQL Mastery: 10 - Subqueries
-- =====================================================
-- A subquery is a query nested inside another query

-- =====================================================
-- 1. SUBQUERY IN WHERE CLAUSE
-- =====================================================

-- Find employees earning more than average
SELECT * FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);

-- Find products in the most popular category
SELECT * FROM products
WHERE category = (SELECT category FROM products 
                  GROUP BY category ORDER BY COUNT(*) DESC LIMIT 1);

-- =====================================================
-- 2. SUBQUERY WITH IN OPERATOR
-- =====================================================

-- Find customers who have placed orders
SELECT * FROM customers
WHERE customer_id IN (SELECT DISTINCT customer_id FROM orders);

-- Find products never ordered
SELECT * FROM products
WHERE product_id NOT IN (SELECT product_id FROM order_items);

-- =====================================================
-- 3. SUBQUERY WITH EXISTS
-- =====================================================

-- More efficient than IN for large datasets
SELECT * FROM customers c
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- Customers with no orders
SELECT * FROM customers c
WHERE NOT EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id);

-- =====================================================
-- 4. SUBQUERY IN SELECT (Scalar Subquery)
-- =====================================================

SELECT product_name, price,
    (SELECT AVG(price) FROM products) AS avg_price,
    price - (SELECT AVG(price) FROM products) AS diff_from_avg
FROM products;

-- =====================================================
-- 5. SUBQUERY IN FROM (Derived Table)
-- =====================================================

SELECT dept, avg_salary
FROM (SELECT department AS dept, AVG(salary) AS avg_salary 
      FROM employees GROUP BY department) AS dept_stats
WHERE avg_salary > 60000;

-- =====================================================
-- 6. CORRELATED SUBQUERIES
-- =====================================================

-- Employees earning more than their department average
SELECT e.first_name, e.salary, e.department
FROM employees e
WHERE salary > (SELECT AVG(salary) FROM employees 
                WHERE department = e.department);

-- =====================================================
-- PRACTICE: Try creating your own subqueries!
-- =====================================================

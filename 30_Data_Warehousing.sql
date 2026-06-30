-- ============================================
-- SQL MASTERY - 30 DATA WAREHOUSING (OLAP)
-- ============================================
-- Topics:
-- 1) Analytical Queries
-- 2) WITH ROLLUP
-- 3) Grouping Sets & Data Cubes concepts
-- ============================================

USE school_management;

-- ============================================
-- PART 1: ROLLUP FOR SUBTOTALS
-- ============================================
-- The WITH ROLLUP modifier adds extra rows to the result set that represent 
-- higher-level subtotals and a grand total.

-- Let's see revenue by category and product.
SELECT 
    IFNULL(category, 'GRAND TOTAL') AS category,
    IFNULL(product_name, 'CATEGORY SUBTOTAL') AS product_name,
    SUM(price * stock_quantity) AS total_inventory_value
FROM products
GROUP BY category, product_name WITH ROLLUP;

-- Notice how the output gives:
-- 1) Each product's value
-- 2) The subtotal for the category (where product_name is NULL)
-- 3) The grand total (where both category and product_name are NULL)

-- ============================================
-- PART 2: ANALYTICAL AGGREGATIONS
-- ============================================

-- Counting active vs inactive employees by department
SELECT 
    department,
    COUNT(employee_id) AS total_employees,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) AS active_employees,
    SUM(CASE WHEN is_active = FALSE THEN 1 ELSE 0 END) AS inactive_employees,
    ROUND(AVG(salary), 2) AS avg_department_salary
FROM employees
GROUP BY department
ORDER BY total_employees DESC;

-- ============================================
-- PART 3: STAR SCHEMA CONCEPTS
-- ============================================
/*
In Data Warehousing (OLAP), data is often restructured from normalized tables (3NF)
into a "Star Schema" consisting of:
1. Fact Tables: The central table containing measurable metrics (e.g., Sales, Orders).
2. Dimension Tables: Descriptive tables surrounding the fact table (e.g., Time, Store, Product, Customer).

While our current database is an OLTP (Online Transaction Processing) system, 
we can simulate a Fact table query by joining our transaction (orders) to dimensions (products).
*/

-- Simulating a Star Schema query (FactOrders joined with DimProducts)
SELECT 
    DATE_FORMAT(o.order_date, '%Y-%m') AS order_month, -- DimTime equivalent
    p.category,                                        -- DimProduct equivalent
    COUNT(o.order_id) AS total_orders,                 -- Fact metric
    SUM(o.total_amount) AS total_revenue               -- Fact metric
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY order_month, p.category WITH ROLLUP;

-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Write a query using `WITH ROLLUP` to show the total salary expense per department, 
including a grand total of all salaries across the company.
Handle the NULL values using IFNULL or COALESCE to say "All Departments" for the grand total.
*/

-- ============================================
-- REFERENCE SOLUTION
-- ============================================
/*
SELECT 
    COALESCE(department, 'All Departments (Grand Total)') AS department,
    SUM(salary) AS total_salary_expense
FROM employees
GROUP BY department WITH ROLLUP;
*/

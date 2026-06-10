-- ============================================
-- SQL MASTERY - 20 QUERY OPTIMIZATION
-- ============================================
-- Topics:
-- 1) EXPLAIN & EXPLAIN ANALYZE
-- 2) Table Scans vs Index Seeks
-- 3) Optimizing WHERE and JOIN clauses
-- ============================================

USE school_management;

-- ============================================
-- PART 1: USING EXPLAIN
-- ============================================
-- The EXPLAIN statement tells you how the database engine plans to execute your query.
-- Pay attention to the 'type' column:
-- 'ALL' means full table scan (bad for large tables).
-- 'ref' or 'eq_ref' or 'const' means it's using an index (good!).

-- Example A: Full Table Scan (No Index on 'department')
-- (Assuming we haven't added an index to 'department' yet)
EXPLAIN SELECT * FROM employees WHERE department = 'Engineering';

-- Example B: Primary Key Lookup (Fastest)
-- 'type' will likely be 'const' because employee_id is the primary key
EXPLAIN SELECT * FROM employees WHERE employee_id = 5;


-- ============================================
-- PART 2: INDEX IMPACT
-- ============================================

-- Let's see the plan for a query checking emails
EXPLAIN SELECT employee_id, first_name FROM employees WHERE email = 'john.doe@email.com';

-- Now, add an index to the email column
CREATE INDEX idx_employee_email ON employees(email);

-- Run EXPLAIN again - notice the 'type' changes from 'ALL' to 'ref'
-- and the 'possible_keys' shows the new index.
EXPLAIN SELECT employee_id, first_name FROM employees WHERE email = 'john.doe@email.com';


-- ============================================
-- PART 3: OPTIMIZING JOINS AND AGGREGATIONS
-- ============================================

-- A JOIN without proper indexes can result in a "Cartesian product" or nested loops scan.
EXPLAIN 
SELECT o.order_id, c.first_name, o.total_amount
FROM orders o
JOIN employees c ON c.employee_id = o.customer_id;

-- Adding foreign keys automatically creates indexes in MySQL,
-- which makes JOINs much faster.

-- Grouping operations can also be slow if they require temporary tables or file sorts.
-- Notice the 'Extra' column in EXPLAIN for this query:
EXPLAIN
SELECT department, SUM(salary) 
FROM employees 
GROUP BY department;


-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Write an EXPLAIN statement for a query that finds all products with a price > 100.
Observe the output.

Task 2:
Create an index on the `price` column of the `products` table.
Run the EXPLAIN statement from Task 1 again and compare the differences.

Task 3:
Write an EXPLAIN statement for a query that JOINs `orders` and `products`. 
Try to identify which table is scanned first (the driving table).
*/

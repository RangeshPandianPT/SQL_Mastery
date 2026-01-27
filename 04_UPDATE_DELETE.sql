-- ============================================
-- SQL MASTERY - LESSON 4: UPDATE & DELETE
-- ============================================
-- Author: RangeshPandian PT
-- Level: Beginner
-- ============================================

USE school_management;

-- ============================================
-- UPDATE STATEMENT
-- ============================================

/*
    UPDATE modifies existing data in a table.
    
    Syntax:
    UPDATE table_name
    SET column1 = value1, column2 = value2, ...
    WHERE condition;
    
    ⚠️ WARNING: Always use WHERE clause!
    Without WHERE, ALL rows will be updated!
*/

-- ============================================
-- BASIC UPDATE
-- ============================================

-- Update a single column for one employee
UPDATE employees
SET salary = 85000
WHERE employee_id = 1;

-- Update multiple columns
UPDATE employees
SET 
    salary = 90000,
    department = 'Senior Engineering'
WHERE employee_id = 1;

-- Verify the update
SELECT * FROM employees WHERE employee_id = 1;

-- ============================================
-- UPDATE WITH CALCULATIONS
-- ============================================

-- Give 10% raise to all Engineering employees
UPDATE employees
SET salary = salary * 1.10
WHERE department = 'Engineering';

-- Give $5000 bonus to specific employee
UPDATE employees
SET salary = salary + 5000
WHERE first_name = 'Jane' AND last_name = 'Smith';

-- ============================================
-- UPDATE MULTIPLE ROWS
-- ============================================

-- Update all employees in Marketing
UPDATE employees
SET is_active = TRUE
WHERE department = 'Marketing';

-- Update based on multiple conditions
UPDATE products
SET stock_quantity = stock_quantity + 50
WHERE category = 'Electronics' AND stock_quantity < 100;

-- ============================================
-- UPDATE WITH IN CLAUSE
-- ============================================

-- Update multiple specific records
UPDATE employees
SET department = 'Technology'
WHERE employee_id IN (1, 2, 3);

-- ============================================
-- UPDATE WITH CASE STATEMENT
-- ============================================

-- Conditional updates based on values
UPDATE employees
SET salary = CASE
    WHEN department = 'Engineering' THEN salary * 1.15
    WHEN department = 'Marketing' THEN salary * 1.10
    WHEN department = 'HR' THEN salary * 1.08
    ELSE salary * 1.05
END
WHERE is_active = TRUE;

-- Update status based on conditions
UPDATE orders
SET status = CASE
    WHEN DATEDIFF(NOW(), order_date) > 7 THEN 'Delivered'
    WHEN DATEDIFF(NOW(), order_date) > 3 THEN 'Shipped'
    WHEN DATEDIFF(NOW(), order_date) > 1 THEN 'Processing'
    ELSE 'Pending'
END;

-- ============================================
-- UPDATE WITH SUBQUERY
-- ============================================

-- Update based on another table's data
UPDATE orders
SET total_amount = (
    SELECT price * orders.quantity
    FROM products
    WHERE products.product_id = orders.product_id
)
WHERE total_amount IS NULL;

-- Update using values from same table
UPDATE products p1
SET price = (
    SELECT AVG(price)
    FROM (SELECT price FROM products WHERE category = p1.category) AS subq
)
WHERE product_id = 10;

-- ============================================
-- UPDATE WITH LIMIT (MySQL specific)
-- ============================================

-- Update only first 5 matching rows
UPDATE employees
SET is_active = TRUE
WHERE department IS NULL
LIMIT 5;

-- ============================================
-- UPDATE WITH ORDER BY and LIMIT
-- ============================================

-- Update top 3 lowest-paid employees
UPDATE employees
SET salary = salary + 2000
ORDER BY salary ASC
LIMIT 3;

-- ============================================
-- DELETE STATEMENT
-- ============================================

/*
    DELETE removes rows from a table.
    
    Syntax:
    DELETE FROM table_name
    WHERE condition;
    
    ⚠️ WARNING: Always use WHERE clause!
    Without WHERE, ALL rows will be deleted!
*/

-- ============================================
-- BASIC DELETE
-- ============================================

-- Delete a specific employee
DELETE FROM employees
WHERE employee_id = 100;

-- Delete by condition
DELETE FROM employees
WHERE is_active = FALSE AND hire_date < '2020-01-01';

-- ============================================
-- DELETE WITH MULTIPLE CONDITIONS
-- ============================================

-- Delete with AND
DELETE FROM orders
WHERE status = 'Cancelled' AND order_date < '2024-01-01';

-- Delete with OR
DELETE FROM products
WHERE stock_quantity = 0 OR price IS NULL;

-- Delete with IN
DELETE FROM employees
WHERE department IN ('Temp', 'Contract');

-- ============================================
-- DELETE WITH LIKE
-- ============================================

-- Delete test records
DELETE FROM employees
WHERE email LIKE '%test%' OR email LIKE '%demo%';

-- ============================================
-- DELETE WITH SUBQUERY
-- ============================================

-- Delete orders for products that no longer exist
DELETE FROM orders
WHERE product_id NOT IN (SELECT product_id FROM products);

-- Delete employees with no orders (example concept)
-- DELETE FROM employees
-- WHERE employee_id NOT IN (SELECT DISTINCT employee_id FROM orders);

-- ============================================
-- DELETE WITH LIMIT
-- ============================================

-- Delete only first 10 matching rows
DELETE FROM orders
WHERE status = 'Cancelled'
LIMIT 10;

-- Delete oldest cancelled orders first
DELETE FROM orders
WHERE status = 'Cancelled'
ORDER BY order_date ASC
LIMIT 5;

-- ============================================
-- DELETE ALL ROWS (Use with caution!)
-- ============================================

-- Method 1: DELETE without WHERE (slow, logged)
-- DELETE FROM table_name;

-- Method 2: TRUNCATE (faster, resets auto_increment)
-- TRUNCATE TABLE table_name;

-- ⚠️ DIFFERENCE:
-- DELETE: Can use WHERE, can be rolled back, keeps auto_increment
-- TRUNCATE: Faster, cannot be rolled back, resets auto_increment

-- ============================================
-- SAFE UPDATE MODE
-- ============================================

/*
    MySQL has a safe update mode that prevents
    UPDATE/DELETE without WHERE using a key column.
    
    To check status:
    SHOW VARIABLES LIKE 'sql_safe_updates';
    
    To disable (not recommended for beginners):
    SET SQL_SAFE_UPDATES = 0;
    
    To enable:
    SET SQL_SAFE_UPDATES = 1;
*/

-- ============================================
-- BEST PRACTICES
-- ============================================

/*
    1. ALWAYS test with SELECT first:
       Before: DELETE FROM employees WHERE department = 'Temp';
       Test:   SELECT * FROM employees WHERE department = 'Temp';
    
    2. Use transactions for important updates:
       START TRANSACTION;
       UPDATE employees SET salary = salary * 1.1;
       -- Verify results
       COMMIT;  -- or ROLLBACK; if something is wrong
    
    3. Always have a WHERE clause
    4. Use LIMIT when testing
    5. Back up data before bulk updates/deletes
*/

-- ============================================
-- TRANSACTIONS FOR SAFETY
-- ============================================

-- Start a transaction
START TRANSACTION;

-- Make changes
UPDATE employees
SET salary = salary * 1.20
WHERE department = 'Engineering';

-- Check the results
SELECT * FROM employees WHERE department = 'Engineering';

-- If looks good: COMMIT;
-- If not: ROLLBACK;

-- Commit the changes (or use ROLLBACK to undo)
COMMIT;

-- Example with ROLLBACK
START TRANSACTION;
DELETE FROM products WHERE category = 'Electronics';
-- Oops! Wrong category!
ROLLBACK;  -- Undo the delete

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

/*
    EXERCISE 1:
    Give a 15% raise to all employees in the 'Sales' department.
    First SELECT to see who will be affected.
    
    EXERCISE 2:
    Update the stock_quantity to 0 for all products
    with price greater than $1000.
    
    EXERCISE 3:
    Change the status of all 'Pending' orders to 'Processing'.
    
    EXERCISE 4:
    Delete all products where stock_quantity is 0.
    (First SELECT to preview)
    
    EXERCISE 5:
    Update employee department to 'Inactive' where
    is_active is FALSE, then delete those employees.
    
    EXERCISE 6:
    Use CASE to update product prices:
    - Electronics: increase by 5%
    - Furniture: increase by 10%
    - Others: no change
*/

-- ============================================
-- SOLUTIONS (with SELECT verification)
-- ============================================

-- Solution 1:
-- First check who will be affected
SELECT * FROM employees WHERE department = 'Sales';

-- Then update
UPDATE employees
SET salary = salary * 1.15
WHERE department = 'Sales';

-- Solution 2:
SELECT * FROM products WHERE price > 1000;

UPDATE products
SET stock_quantity = 0
WHERE price > 1000;

-- Solution 3:
SELECT * FROM orders WHERE status = 'Pending';

UPDATE orders
SET status = 'Processing'
WHERE status = 'Pending';

-- Solution 4:
SELECT * FROM products WHERE stock_quantity = 0;

DELETE FROM products
WHERE stock_quantity = 0;

-- Solution 5:
SELECT * FROM employees WHERE is_active = FALSE;

UPDATE employees
SET department = 'Inactive'
WHERE is_active = FALSE;

DELETE FROM employees
WHERE department = 'Inactive';

-- Solution 6:
UPDATE products
SET price = CASE
    WHEN category = 'Electronics' THEN price * 1.05
    WHEN category = 'Furniture' THEN price * 1.10
    ELSE price
END;

-- ============================================
-- KEY TAKEAWAYS
-- ============================================

/*
    UPDATE:
    1. Always use WHERE to target specific rows
    2. Can update multiple columns in one statement
    3. Can use calculations (salary = salary * 1.1)
    4. CASE statements enable conditional updates
    5. Test with SELECT first
    
    DELETE:
    1. Always use WHERE to target specific rows
    2. Cannot be undone without transaction
    3. TRUNCATE is faster but cannot be rolled back
    4. Use LIMIT for safer bulk deletes
    5. Test with SELECT first
    
    Both:
    1. Use transactions for important changes
    2. Back up data before bulk operations
    3. Verify affected rows before committing
*/

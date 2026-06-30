-- ============================================
-- SQL MASTERY - 28 DYNAMIC SQL
-- ============================================
-- Topics:
-- 1) What is Dynamic SQL?
-- 2) PREPARE and EXECUTE
-- 3) Preventing SQL Injection
-- ============================================

USE school_management;

-- ============================================
-- PART 1: BASIC DYNAMIC SQL
-- ============================================
-- Dynamic SQL allows you to construct a SQL query as a string at runtime, 
-- and then execute it. This is useful when table names or column names 
-- need to be dynamic (which standard parameterization doesn't allow).

-- Set a query string into a variable
SET @sql_query = 'SELECT product_name, price FROM products WHERE category = "Electronics"';

-- Prepare the statement
PREPARE stmt1 FROM @sql_query;

-- Execute the statement
EXECUTE stmt1;

-- Clean up (Deallocate)
DEALLOCATE PREPARE stmt1;

-- ============================================
-- PART 2: DYNAMIC SQL WITH PARAMETERS
-- ============================================
-- To prevent SQL injection when dealing with user inputs like values, 
-- use the '?' placeholder instead of concatenating strings.

SET @category_filter = 'Furniture';
SET @min_price = 100.00;

-- String with placeholders
SET @sql_query2 = 'SELECT product_name, price FROM products WHERE category = ? AND price > ?';

PREPARE stmt2 FROM @sql_query2;

-- Execute using USING clause to pass in the variables
EXECUTE stmt2 USING @category_filter, @min_price;

DEALLOCATE PREPARE stmt2;

-- ============================================
-- PART 3: DYNAMIC SQL IN STORED PROCEDURES
-- ============================================
-- Dynamic SQL is most powerful inside stored procedures.

DROP PROCEDURE IF EXISTS GetSortedProducts;

DELIMITER //

CREATE PROCEDURE GetSortedProducts(IN sort_column VARCHAR(50), IN sort_order VARCHAR(4))
BEGIN
    -- VERY IMPORTANT: Whitelist the sort_order to prevent SQL injection
    IF sort_order NOT IN ('ASC', 'DESC') THEN
        SET sort_order = 'ASC';
    END IF;

    -- Note: We CANNOT use '?' for column names in PREPARE statements, 
    -- so we must concatenate. This requires extreme caution regarding SQL injection!
    -- In production, validate `sort_column` against the information_schema first!
    
    SET @dynamic_sql = CONCAT('SELECT product_name, category, price FROM products ORDER BY ', sort_column, ' ', sort_order);
    
    PREPARE stmt3 FROM @dynamic_sql;
    EXECUTE stmt3;
    DEALLOCATE PREPARE stmt3;
END //

DELIMITER ;

-- Test the procedure
CALL GetSortedProducts('price', 'DESC');
CALL GetSortedProducts('product_name', 'ASC');

-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Write a script that uses Dynamic SQL to select all columns from the `teachers` table.
The table name should be stored in a variable `@table_name = 'teachers'`.
*/

-- ============================================
-- REFERENCE SOLUTION
-- ============================================
/*
SET @table_name = 'teachers';
SET @query = CONCAT('SELECT * FROM ', @table_name);
PREPARE stmt_task FROM @query;
EXECUTE stmt_task;
DEALLOCATE PREPARE stmt_task;
*/

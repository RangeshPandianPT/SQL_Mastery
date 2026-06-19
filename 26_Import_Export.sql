-- ============================================
-- SQL MASTERY - 26 DATA IMPORT AND EXPORT
-- ============================================
-- Topics:
-- 1) SELECT ... INTO OUTFILE (Exporting to CSV)
-- 2) LOAD DATA INFILE (Importing from CSV)
-- ============================================

USE school_management;

-- Note: To run these commands, the MySQL server needs file write/read permissions,
-- and the 'secure_file_priv' variable must allow the directory path.
-- You can check your secure path by running:
-- SHOW VARIABLES LIKE 'secure_file_priv';

-- ============================================
-- PART 1: Exporting Data (OUTFILE)
-- ============================================
-- This command exports the result of a query directly into a CSV file.

/*
SELECT employee_id, first_name, last_name, salary
INTO OUTFILE '/var/lib/mysql-files/employees_export.csv'  -- Use an allowed path
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM employees
WHERE is_active = TRUE;
*/

-- ============================================
-- PART 2: Importing Data (LOAD DATA INFILE)
-- ============================================
-- This is the fastest way to insert millions of rows from a text/CSV file.

-- Assume we created a temporary table
CREATE TABLE IF NOT EXISTS temp_bulk_employees (
    emp_id INT,
    f_name VARCHAR(50),
    l_name VARCHAR(50),
    salary DECIMAL(10,2)
);

/*
LOAD DATA INFILE '/var/lib/mysql-files/employees_export.csv'
INTO TABLE temp_bulk_employees
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
(emp_id, f_name, l_name, salary); -- Mapping columns
*/

-- ============================================
-- PART 3: mysqldump (Command Line tool)
-- ============================================
-- 'mysqldump' is not an SQL command. It's run from the terminal to backup databases.

-- Backup a single database:
-- > mysqldump -u username -p school_management > backup.sql

-- Backup a specific table:
-- > mysqldump -u username -p school_management employees > employees_backup.sql

-- Restore a database from backup:
-- > mysql -u username -p school_management < backup.sql

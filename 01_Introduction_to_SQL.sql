-- ============================================
-- SQL MASTERY - LESSON 1: INTRODUCTION TO SQL
-- ============================================
-- Author: RangeshPandian PT
-- Level: Beginner
-- ============================================

/*
    WHAT IS SQL?
    ============
    SQL (Structured Query Language) is a standard programming language
    specifically designed for managing and manipulating relational databases.
    
    SQL allows you to:
    - Create databases and tables
    - Insert, update, and delete data
    - Query and retrieve data
    - Control access to data
    - Set permissions
*/

-- ============================================
-- BASIC DATABASE OPERATIONS
-- ============================================

-- View all existing databases on the server
SHOW DATABASES;

-- Create a new database
CREATE DATABASE my_first_database;

-- Select/Use a specific database
USE my_first_database;

-- Delete a database (BE CAREFUL!)
-- DROP DATABASE my_first_database;

-- ============================================
-- UNDERSTANDING DATA TYPES
-- ============================================

/*
    COMMON SQL DATA TYPES:
    ======================
    
    NUMERIC TYPES:
    - INT         : Whole numbers (-2,147,483,648 to 2,147,483,647)
    - BIGINT      : Large whole numbers
    - SMALLINT    : Small whole numbers (-32,768 to 32,767)
    - TINYINT     : Very small numbers (0 to 255)
    - DECIMAL(p,s): Exact decimal numbers (p = precision, s = scale)
    - FLOAT       : Floating point numbers
    - DOUBLE      : Double precision floating point
    
    STRING TYPES:
    - CHAR(n)     : Fixed-length string (max 255 characters)
    - VARCHAR(n)  : Variable-length string (max 65,535 characters)
    - TEXT        : Large text (up to 65,535 characters)
    - LONGTEXT    : Very large text (up to 4GB)
    
    DATE/TIME TYPES:
    - DATE        : Date (YYYY-MM-DD)
    - TIME        : Time (HH:MM:SS)
    - DATETIME    : Date and time combined
    - TIMESTAMP   : Timestamp (auto-updates)
    - YEAR        : Year value
    
    OTHER TYPES:
    - BOOLEAN     : True or False
    - BLOB        : Binary Large Object (for files, images)
    - ENUM        : Enumerated list of values
*/

-- ============================================
-- CREATING YOUR FIRST TABLE
-- ============================================

-- Syntax for creating a table:
-- CREATE TABLE table_name (
--     column1 datatype constraints,
--     column2 datatype constraints,
--     ...
-- );

-- Example: Create a students table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    date_of_birth DATE,
    enrollment_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- View the structure of a table
DESCRIBE students;

-- Alternative way to view table structure
SHOW COLUMNS FROM students;

-- View all tables in current database
SHOW TABLES;

-- ============================================
-- BASIC CONSTRAINTS EXPLAINED
-- ============================================

/*
    CONSTRAINTS:
    ============
    - PRIMARY KEY   : Unique identifier for each row (cannot be NULL)
    - FOREIGN KEY   : Links to primary key in another table
    - UNIQUE        : Ensures all values in column are unique
    - NOT NULL      : Column cannot have NULL values
    - DEFAULT       : Sets default value if none provided
    - CHECK         : Validates data against a condition
    - AUTO_INCREMENT: Automatically generates unique numbers
*/

-- Example with multiple constraints
CREATE TABLE courses (
    course_id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    course_code VARCHAR(10) UNIQUE NOT NULL,
    credits INT DEFAULT 3,
    max_students INT CHECK (max_students > 0 AND max_students <= 100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- MODIFYING TABLES
-- ============================================

-- Add a new column
ALTER TABLE students ADD COLUMN phone_number VARCHAR(20);

-- Modify an existing column
ALTER TABLE students MODIFY COLUMN phone_number VARCHAR(15);

-- Rename a column
ALTER TABLE students CHANGE COLUMN phone_number contact_number VARCHAR(15);

-- Delete a column
ALTER TABLE students DROP COLUMN contact_number;

-- Rename a table
-- ALTER TABLE old_name RENAME TO new_name;

-- ============================================
-- DELETING TABLES
-- ============================================

-- Delete table and all its data (BE CAREFUL!)
-- DROP TABLE table_name;

-- Delete table only if it exists
-- DROP TABLE IF EXISTS table_name;

-- Delete all data but keep table structure
-- TRUNCATE TABLE table_name;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

/*
    EXERCISE 1:
    Create a database called "school_management"
    
    EXERCISE 2:
    Create a table called "teachers" with:
    - teacher_id (auto-increment primary key)
    - first_name (required, max 50 chars)
    - last_name (required, max 50 chars)
    - email (unique)
    - subject (max 50 chars)
    - hire_date (date)
    - salary (decimal with 2 decimal places)
    
    EXERCISE 3:
    Add a column "department" to the teachers table
    
    EXERCISE 4:
    View the structure of the teachers table
*/

-- ============================================
-- SOLUTIONS TO EXERCISES
-- ============================================

-- Solution 1:
CREATE DATABASE IF NOT EXISTS school_management;
USE school_management;

-- Solution 2:
CREATE TABLE IF NOT EXISTS teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    subject VARCHAR(50),
    hire_date DATE,
    salary DECIMAL(10, 2)
);

-- Solution 3:
ALTER TABLE teachers ADD COLUMN department VARCHAR(50);

-- Solution 4:
DESCRIBE teachers;

-- ============================================
-- KEY TAKEAWAYS
-- ============================================

/*
    1. SQL is used to interact with relational databases
    2. CREATE DATABASE creates a new database
    3. USE selects a database to work with
    4. CREATE TABLE defines a new table with columns and types
    5. Constraints ensure data integrity
    6. ALTER TABLE modifies existing tables
    7. DROP TABLE removes tables
    8. Always be careful with DROP and DELETE operations!
*/

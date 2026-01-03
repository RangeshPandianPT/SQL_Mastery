-- ============================================
-- SQL MASTERY - LESSON 2: INSERTING DATA
-- ============================================
-- Author: SQL Learning Path
-- Level: Beginner
-- ============================================

USE school_management;

-- ============================================
-- BASIC INSERT SYNTAX
-- ============================================

/*
    The INSERT statement is used to add new records to a table.
    
    Syntax 1 (Specify columns):
    INSERT INTO table_name (column1, column2, column3, ...)
    VALUES (value1, value2, value3, ...);
    
    Syntax 2 (All columns):
    INSERT INTO table_name
    VALUES (value1, value2, value3, ...);
*/

-- ============================================
-- INSERTING SINGLE ROWS
-- ============================================

-- Create a sample table for practice
CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

-- Method 1: Insert with specified columns (RECOMMENDED)
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date)
VALUES ('John', 'Doe', 'john.doe@email.com', 'Engineering', 75000.00, '2024-01-15');

-- Method 2: Insert with all columns (must provide all values in order)
-- Note: NULL for auto_increment, and explicit value for boolean
INSERT INTO employees
VALUES (NULL, 'Jane', 'Smith', 'jane.smith@email.com', 'Marketing', 65000.00, '2024-02-20', TRUE);

-- Method 3: Insert with partial columns (uses defaults for others)
INSERT INTO employees (first_name, last_name, email)
VALUES ('Bob', 'Johnson', 'bob.johnson@email.com');

-- ============================================
-- INSERTING MULTIPLE ROWS AT ONCE
-- ============================================

-- Multiple rows in single statement (more efficient)
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date)
VALUES 
    ('Alice', 'Williams', 'alice.w@email.com', 'HR', 55000.00, '2024-03-01'),
    ('Charlie', 'Brown', 'charlie.b@email.com', 'Engineering', 80000.00, '2024-03-05'),
    ('Diana', 'Ross', 'diana.r@email.com', 'Sales', 60000.00, '2024-03-10'),
    ('Edward', 'Norton', 'edward.n@email.com', 'Finance', 70000.00, '2024-03-15'),
    ('Fiona', 'Apple', 'fiona.a@email.com', 'Marketing', 58000.00, '2024-03-20');

-- ============================================
-- INSERT WITH DEFAULT VALUES
-- ============================================

-- Using DEFAULT keyword
INSERT INTO employees (first_name, last_name, email, is_active)
VALUES ('George', 'Harrison', 'george.h@email.com', DEFAULT);

-- ============================================
-- INSERT ... SELECT (Copy from another table)
-- ============================================

-- Create a backup table
CREATE TABLE IF NOT EXISTS employees_backup (
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    is_active BOOLEAN
);

-- Copy all data from employees to employees_backup
INSERT INTO employees_backup
SELECT * FROM employees;

-- Copy only specific columns/rows
INSERT INTO employees_backup (employee_id, first_name, last_name, email)
SELECT employee_id, first_name, last_name, email
FROM employees
WHERE department = 'Engineering';

-- ============================================
-- INSERT IGNORE (Skip Duplicates)
-- ============================================

-- If a duplicate key exists, skip the insert (no error)
INSERT IGNORE INTO employees (first_name, last_name, email, department)
VALUES ('John', 'Doe', 'john.doe@email.com', 'Engineering');
-- This won't insert because email already exists (UNIQUE constraint)

-- ============================================
-- INSERT ... ON DUPLICATE KEY UPDATE
-- ============================================

-- If duplicate key, update instead of insert (UPSERT)
INSERT INTO employees (employee_id, first_name, last_name, email, salary)
VALUES (1, 'John', 'Doe', 'john.doe@email.com', 78000.00)
ON DUPLICATE KEY UPDATE salary = VALUES(salary);

-- ============================================
-- REPLACE INTO
-- ============================================

-- Deletes existing row with same key and inserts new one
REPLACE INTO employees (employee_id, first_name, last_name, email, department, salary)
VALUES (1, 'John', 'Doe', 'john.doe@email.com', 'Engineering', 80000.00);

-- ============================================
-- WORKING WITH NULL VALUES
-- ============================================

-- Insert with explicit NULL
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date)
VALUES ('Henry', 'Ford', 'henry.f@email.com', NULL, NULL, NULL);

-- ============================================
-- DATE AND TIME INSERTIONS
-- ============================================

-- Various date formats
INSERT INTO employees (first_name, last_name, email, hire_date)
VALUES ('Iris', 'Chen', 'iris.c@email.com', '2024-06-15');

-- Using date functions
INSERT INTO employees (first_name, last_name, email, hire_date)
VALUES ('Jack', 'Ryan', 'jack.r@email.com', CURDATE());

-- Using NOW() for current date and time
-- (Note: hire_date is DATE type, so time portion is discarded)
INSERT INTO employees (first_name, last_name, email, hire_date)
VALUES ('Karen', 'White', 'karen.w@email.com', NOW());

-- ============================================
-- PRACTICE TABLES WITH SAMPLE DATA
-- ============================================

-- Create and populate products table
CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO products (product_name, category, price, stock_quantity)
VALUES 
    ('Laptop Pro 15', 'Electronics', 1299.99, 50),
    ('Wireless Mouse', 'Electronics', 29.99, 200),
    ('USB-C Hub', 'Electronics', 49.99, 150),
    ('Mechanical Keyboard', 'Electronics', 89.99, 100),
    ('Monitor 27 inch', 'Electronics', 399.99, 75),
    ('Office Chair', 'Furniture', 299.99, 30),
    ('Standing Desk', 'Furniture', 499.99, 25),
    ('Desk Lamp', 'Furniture', 39.99, 80),
    ('Notebook Pack', 'Stationery', 12.99, 500),
    ('Pen Set', 'Stationery', 8.99, 300);

-- Create and populate orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_name VARCHAR(100) NOT NULL,
    product_id INT,
    quantity INT NOT NULL,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10, 2),
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled') DEFAULT 'Pending'
);

INSERT INTO orders (customer_name, product_id, quantity, total_amount, status)
VALUES 
    ('Alice Johnson', 1, 1, 1299.99, 'Delivered'),
    ('Bob Smith', 2, 3, 89.97, 'Shipped'),
    ('Carol Davis', 4, 1, 89.99, 'Processing'),
    ('David Wilson', 6, 2, 599.98, 'Pending'),
    ('Eva Martinez', 1, 1, 1299.99, 'Delivered'),
    ('Frank Brown', 5, 1, 399.99, 'Shipped'),
    ('Grace Lee', 3, 2, 99.98, 'Delivered'),
    ('Henry Taylor', 7, 1, 499.99, 'Processing'),
    ('Ivy Chen', 9, 10, 129.90, 'Pending'),
    ('Jack Anderson', 2, 5, 149.95, 'Cancelled');

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

/*
    EXERCISE 1:
    Insert a new employee with all fields filled in.
    
    EXERCISE 2:
    Insert 3 new products in a single INSERT statement.
    
    EXERCISE 3:
    Create a table called "customers" with:
    - customer_id (auto-increment primary key)
    - name (required)
    - email (unique)
    - phone
    - city
    - join_date (default current date)
    Then insert 5 customers.
    
    EXERCISE 4:
    Use INSERT ... SELECT to copy all products with 
    price > 100 to a new table called "premium_products".
*/

-- ============================================
-- SOLUTIONS
-- ============================================

-- Solution 1:
INSERT INTO employees (first_name, last_name, email, department, salary, hire_date, is_active)
VALUES ('Michael', 'Scott', 'michael.s@email.com', 'Management', 100000.00, '2024-04-01', TRUE);

-- Solution 2:
INSERT INTO products (product_name, category, price, stock_quantity)
VALUES 
    ('Webcam HD', 'Electronics', 79.99, 120),
    ('Mouse Pad XL', 'Accessories', 19.99, 300),
    ('Laptop Stand', 'Accessories', 45.99, 90);

-- Solution 3:
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(50),
    join_date DATE DEFAULT (CURRENT_DATE)
);

INSERT INTO customers (name, email, phone, city)
VALUES 
    ('Sarah Connor', 'sarah.c@email.com', '555-0101', 'Los Angeles'),
    ('John Wick', 'john.w@email.com', '555-0102', 'New York'),
    ('Tony Stark', 'tony.s@email.com', '555-0103', 'Malibu'),
    ('Bruce Wayne', 'bruce.w@email.com', '555-0104', 'Gotham'),
    ('Peter Parker', 'peter.p@email.com', '555-0105', 'Queens');

-- Solution 4:
CREATE TABLE IF NOT EXISTS premium_products AS
SELECT * FROM products WHERE price > 100;

-- Or using INSERT ... SELECT:
-- CREATE TABLE premium_products LIKE products;
-- INSERT INTO premium_products
-- SELECT * FROM products WHERE price > 100;

-- ============================================
-- KEY TAKEAWAYS
-- ============================================

/*
    1. Always specify column names for clarity
    2. Use multi-row INSERT for better performance
    3. INSERT IGNORE skips duplicate key errors
    4. ON DUPLICATE KEY UPDATE performs "upsert"
    5. INSERT ... SELECT copies data between tables
    6. Use DEFAULT keyword or omit columns for default values
    7. NULL can be explicitly inserted for nullable columns
    8. CURDATE(), NOW() provide current date/time values
*/

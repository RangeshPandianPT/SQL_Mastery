-- ============================================
-- SQL MASTERY - SETUP SCRIPT
-- ============================================
-- Purpose: Create a clean practice database with base tables and seed data.
-- Run this file before lessons if you want a predictable starting state.
-- ============================================

DROP DATABASE IF EXISTS school_management;
CREATE DATABASE school_management;
USE school_management;

-- ============================================
-- TABLE: teachers
-- ============================================
CREATE TABLE teachers (
    teacher_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    subject VARCHAR(50),
    hire_date DATE,
    salary DECIMAL(10, 2),
    department VARCHAR(50)
);

INSERT INTO teachers (first_name, last_name, email, subject, hire_date, salary, department)
VALUES
    ('Emma', 'Stone', 'emma.stone@school.com', 'Mathematics', '2021-06-10', 52000.00, 'Science'),
    ('Liam', 'Carter', 'liam.carter@school.com', 'History', '2020-08-15', 50000.00, 'Humanities'),
    ('Noah', 'Brooks', 'noah.brooks@school.com', 'Physics', '2019-02-20', 56000.00, 'Science');

-- ============================================
-- TABLE: employees
-- ============================================
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE
);

INSERT INTO employees (first_name, last_name, email, department, salary, hire_date, is_active)
VALUES
    ('John', 'Doe', 'john.doe@email.com', 'Engineering', 75000.00, '2024-01-15', TRUE),
    ('Jane', 'Smith', 'jane.smith@email.com', 'Marketing', 65000.00, '2024-02-20', TRUE),
    ('Bob', 'Johnson', 'bob.johnson@email.com', 'Engineering', 72000.00, '2024-03-01', TRUE),
    ('Alice', 'Williams', 'alice.w@email.com', 'HR', 55000.00, '2024-03-10', TRUE),
    ('Charlie', 'Brown', 'charlie.b@email.com', 'Finance', 70000.00, '2024-03-15', FALSE);

-- ============================================
-- TABLE: products
-- ============================================
CREATE TABLE products (
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
    ('Office Chair', 'Furniture', 299.99, 30),
    ('Standing Desk', 'Furniture', 499.99, 25),
    ('Notebook Pack', 'Stationery', 12.99, 500),
    ('Pen Set', 'Stationery', 8.99, 300);

-- ============================================
-- TABLE: orders
-- ============================================
CREATE TABLE orders (
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
    ('David Wilson', 5, 2, 599.98, 'Pending'),
    ('Eva Martinez', 6, 1, 499.99, 'Delivered'),
    ('Frank Brown', 3, 2, 99.98, 'Shipped'),
    ('Grace Lee', 7, 10, 129.90, 'Pending'),
    ('Jack Anderson', 2, 5, 149.95, 'Cancelled');

-- ============================================
-- QUICK CHECKS
-- ============================================
SHOW TABLES;
SELECT COUNT(*) AS teachers_count FROM teachers;
SELECT COUNT(*) AS employees_count FROM employees;
SELECT COUNT(*) AS products_count FROM products;
SELECT COUNT(*) AS orders_count FROM orders;

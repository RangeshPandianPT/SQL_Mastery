-- ============================================
-- SQL MASTERY - SETUP SCRIPT (SQLite Version)
-- ============================================
-- Purpose: Create clean practice database tables and seed data for SQLite.
-- Usage: sqlite3 practice.db < 00_Setup_Database_SQLite.sql
-- ============================================

DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS teachers;

-- ============================================
-- TABLE: teachers
-- ============================================
CREATE TABLE teachers (
    teacher_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    subject TEXT,
    hire_date TEXT,
    salary REAL,
    department TEXT
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
    employee_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    email TEXT UNIQUE,
    department TEXT,
    salary REAL,
    hire_date TEXT,
    is_active INTEGER DEFAULT 1
);

INSERT INTO employees (first_name, last_name, email, department, salary, hire_date, is_active)
VALUES
    ('John', 'Doe', 'john.doe@email.com', 'Engineering', 75000.00, '2024-01-15', 1),
    ('Jane', 'Smith', 'jane.smith@email.com', 'Marketing', 65000.00, '2024-02-20', 1),
    ('Bob', 'Johnson', 'bob.johnson@email.com', 'Engineering', 72000.00, '2024-03-01', 1),
    ('Alice', 'Williams', 'alice.w@email.com', 'HR', 55000.00, '2024-03-10', 1),
    ('Charlie', 'Brown', 'charlie.b@email.com', 'Finance', 70000.00, '2024-03-15', 0);

-- ============================================
-- TABLE: products
-- ============================================
CREATE TABLE products (
    product_id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_name TEXT NOT NULL,
    category TEXT,
    price REAL NOT NULL,
    stock_quantity INTEGER DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now'))
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
    order_id INTEGER PRIMARY KEY AUTOINCREMENT,
    customer_name TEXT NOT NULL,
    product_id INTEGER REFERENCES products(product_id),
    quantity INTEGER NOT NULL,
    order_date TEXT DEFAULT (datetime('now')),
    total_amount REAL,
    status TEXT CHECK(status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled')) DEFAULT 'Pending'
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
-- CHECKS
-- ============================================
SELECT 'teachers:' AS tbl, COUNT(*) FROM teachers;
SELECT 'employees:' AS tbl, COUNT(*) FROM employees;
SELECT 'products:' AS tbl, COUNT(*) FROM products;
SELECT 'orders:' AS tbl, COUNT(*) FROM orders;

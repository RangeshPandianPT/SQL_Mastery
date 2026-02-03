-- =====================================================
-- SQL Mastery: 15 - Constraints
-- =====================================================
-- Constraints enforce rules on data in tables

-- =====================================================
-- 1. PRIMARY KEY
-- =====================================================

CREATE TABLE users (
    user_id INT PRIMARY KEY,
    username VARCHAR(50)
);

-- Composite primary key
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id)
);

-- =====================================================
-- 2. FOREIGN KEY
-- =====================================================

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- =====================================================
-- 3. UNIQUE CONSTRAINT
-- =====================================================

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20) UNIQUE
);

-- =====================================================
-- 4. NOT NULL CONSTRAINT
-- =====================================================

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL
);

-- =====================================================
-- 5. CHECK CONSTRAINT
-- =====================================================

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    balance DECIMAL(15,2) CHECK (balance >= 0),
    status VARCHAR(20) CHECK (status IN ('Active', 'Inactive', 'Closed'))
);

-- =====================================================
-- 6. DEFAULT CONSTRAINT
-- =====================================================

CREATE TABLE articles (
    article_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    status VARCHAR(20) DEFAULT 'Draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 7. ADDING/REMOVING CONSTRAINTS
-- =====================================================

-- Add constraint
ALTER TABLE products ADD CONSTRAINT chk_price CHECK (price > 0);
ALTER TABLE orders ADD CONSTRAINT fk_customer 
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id);

-- Remove constraint
ALTER TABLE products DROP CONSTRAINT chk_price;
ALTER TABLE orders DROP FOREIGN KEY fk_customer;

-- =====================================================
-- PRACTICE: Design tables with appropriate constraints!
-- =====================================================

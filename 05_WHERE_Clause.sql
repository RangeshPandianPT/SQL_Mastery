-- =====================================================
-- SQL Mastery: 05 - WHERE Clause (Filtering Data)
-- =====================================================
-- The WHERE clause is used to filter records based on conditions
-- It extracts only those records that fulfill specified criteria

-- =====================================================
-- Sample Tables for Practice
-- =====================================================

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10, 2),
    stock_quantity INT,
    supplier_id INT,
    is_active BOOLEAN DEFAULT TRUE,
    created_date DATE
);

CREATE TABLE IF NOT EXISTS orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20),
    shipping_city VARCHAR(50)
);

-- Insert sample data
INSERT INTO products (product_name, category, price, stock_quantity, supplier_id, is_active, created_date) VALUES
('Laptop Pro', 'Electronics', 1299.99, 50, 1, TRUE, '2024-01-15'),
('Wireless Mouse', 'Electronics', 29.99, 200, 1, TRUE, '2024-02-10'),
('Office Chair', 'Furniture', 349.99, 30, 2, TRUE, '2024-01-20'),
('Desk Lamp', 'Furniture', 59.99, 100, 2, FALSE, '2023-11-05'),
('Notebook Set', 'Stationery', 15.99, 500, 3, TRUE, '2024-03-01'),
('Pen Pack', 'Stationery', 8.99, 1000, 3, TRUE, '2024-02-15'),
('Monitor 27"', 'Electronics', 449.99, 75, 1, TRUE, '2024-01-25'),
('Keyboard', 'Electronics', 79.99, 150, 1, TRUE, '2024-02-20'),
('Filing Cabinet', 'Furniture', 199.99, 25, 2, FALSE, '2023-10-10'),
('Stapler', 'Stationery', 12.99, 300, 3, TRUE, '2024-03-10');

INSERT INTO orders (customer_id, order_date, total_amount, status, shipping_city) VALUES
(101, '2024-01-15', 1329.98, 'Delivered', 'New York'),
(102, '2024-01-20', 449.99, 'Delivered', 'Los Angeles'),
(103, '2024-02-05', 89.98, 'Shipped', 'Chicago'),
(101, '2024-02-10', 349.99, 'Processing', 'New York'),
(104, '2024-02-15', 1749.98, 'Delivered', 'Houston'),
(105, '2024-03-01', 24.98, 'Cancelled', 'Phoenix'),
(102, '2024-03-05', 529.98, 'Shipped', 'Los Angeles'),
(106, '2024-03-10', 199.99, 'Processing', 'Philadelphia');

-- =====================================================
-- 1. BASIC COMPARISON OPERATORS
-- =====================================================

-- Equal to (=)
SELECT * FROM products WHERE category = 'Electronics';

-- Not equal to (<> or !=)
SELECT * FROM products WHERE category <> 'Electronics';
SELECT * FROM products WHERE category != 'Furniture';

-- Greater than (>)
SELECT * FROM products WHERE price > 100;

-- Less than (<)
SELECT * FROM products WHERE stock_quantity < 100;

-- Greater than or equal to (>=)
SELECT * FROM products WHERE price >= 50;

-- Less than or equal to (<=)
SELECT * FROM products WHERE stock_quantity <= 50;

-- =====================================================
-- 2. LOGICAL OPERATORS (AND, OR, NOT)
-- =====================================================

-- AND - All conditions must be true
SELECT * FROM products 
WHERE category = 'Electronics' AND price > 100;

SELECT * FROM products 
WHERE category = 'Electronics' AND price > 50 AND stock_quantity > 100;

-- OR - At least one condition must be true
SELECT * FROM products 
WHERE category = 'Electronics' OR category = 'Furniture';

SELECT * FROM products 
WHERE price < 20 OR price > 500;

-- NOT - Negates a condition
SELECT * FROM products 
WHERE NOT category = 'Electronics';

SELECT * FROM products 
WHERE NOT is_active;

-- Combining AND, OR, NOT (use parentheses for clarity)
SELECT * FROM products 
WHERE (category = 'Electronics' OR category = 'Furniture') 
AND price > 100;

SELECT * FROM products 
WHERE category = 'Electronics' 
AND (price < 50 OR stock_quantity > 100);

-- =====================================================
-- 3. BETWEEN OPERATOR
-- =====================================================

-- BETWEEN includes both boundary values (inclusive)
SELECT * FROM products 
WHERE price BETWEEN 50 AND 500;

-- Same as:
SELECT * FROM products 
WHERE price >= 50 AND price <= 500;

-- NOT BETWEEN
SELECT * FROM products 
WHERE price NOT BETWEEN 50 AND 500;

-- BETWEEN with dates
SELECT * FROM orders 
WHERE order_date BETWEEN '2024-01-01' AND '2024-02-28';

-- =====================================================
-- 4. IN OPERATOR
-- =====================================================

-- IN - Matches any value in a list
SELECT * FROM products 
WHERE category IN ('Electronics', 'Furniture');

-- Same as:
SELECT * FROM products 
WHERE category = 'Electronics' OR category = 'Furniture';

-- NOT IN
SELECT * FROM products 
WHERE category NOT IN ('Electronics', 'Furniture');

-- IN with numeric values
SELECT * FROM products 
WHERE supplier_id IN (1, 3);

-- IN with subquery (we'll cover this in detail later)
SELECT * FROM orders 
WHERE customer_id IN (SELECT customer_id FROM orders WHERE status = 'Delivered');

-- =====================================================
-- 5. LIKE OPERATOR (Pattern Matching)
-- =====================================================

-- Wildcards:
-- % - Represents zero, one, or multiple characters
-- _ - Represents exactly one character

-- Starts with 'L'
SELECT * FROM products 
WHERE product_name LIKE 'L%';

-- Ends with 'er'
SELECT * FROM products 
WHERE product_name LIKE '%er';

-- Contains 'ouse'
SELECT * FROM products 
WHERE product_name LIKE '%ouse%';

-- Second character is 'a'
SELECT * FROM products 
WHERE product_name LIKE '_a%';

-- Exactly 7 characters long
SELECT * FROM products 
WHERE product_name LIKE '_______';

-- NOT LIKE
SELECT * FROM products 
WHERE product_name NOT LIKE '%Pro%';

-- Case-insensitive search (depends on collation)
SELECT * FROM products 
WHERE LOWER(product_name) LIKE '%laptop%';

-- =====================================================
-- 6. NULL VALUES
-- =====================================================

-- IS NULL - Check for NULL values
-- IMPORTANT: You cannot use = NULL, always use IS NULL
SELECT * FROM products 
WHERE category IS NULL;

-- IS NOT NULL
SELECT * FROM products 
WHERE category IS NOT NULL;

-- Combining with other conditions
SELECT * FROM products 
WHERE category IS NOT NULL AND price > 100;

-- =====================================================
-- 7. BOOLEAN CONDITIONS
-- =====================================================

-- Check for TRUE
SELECT * FROM products 
WHERE is_active = TRUE;

-- Shorthand for TRUE
SELECT * FROM products 
WHERE is_active;

-- Check for FALSE
SELECT * FROM products 
WHERE is_active = FALSE;

-- Shorthand for FALSE
SELECT * FROM products 
WHERE NOT is_active;

-- =====================================================
-- 8. DATE COMPARISONS
-- =====================================================

-- Exact date match
SELECT * FROM orders 
WHERE order_date = '2024-02-10';

-- Orders after a specific date
SELECT * FROM orders 
WHERE order_date > '2024-02-01';

-- Orders in a specific month
SELECT * FROM orders 
WHERE order_date >= '2024-02-01' AND order_date < '2024-03-01';

-- Using date functions (MySQL specific)
SELECT * FROM orders 
WHERE YEAR(order_date) = 2024 AND MONTH(order_date) = 2;

-- =====================================================
-- 9. ADVANCED FILTERING EXAMPLES
-- =====================================================

-- Multiple complex conditions
SELECT 
    product_name, 
    category, 
    price, 
    stock_quantity
FROM products 
WHERE (category = 'Electronics' AND price > 100)
   OR (category = 'Furniture' AND stock_quantity < 50)
   AND is_active = TRUE;

-- Filtering with calculated values
SELECT * FROM products 
WHERE price * stock_quantity > 10000;  -- Total inventory value

-- Using expressions
SELECT * FROM orders 
WHERE total_amount > 100 AND status IN ('Delivered', 'Shipped');

-- =====================================================
-- 10. COMMON MISTAKES TO AVOID
-- =====================================================

-- WRONG: Using = with NULL
-- SELECT * FROM products WHERE category = NULL;  -- Won't work!

-- CORRECT:
SELECT * FROM products WHERE category IS NULL;

-- WRONG: String comparison without quotes
-- SELECT * FROM products WHERE category = Electronics;  -- Error!

-- CORRECT:
SELECT * FROM products WHERE category = 'Electronics';

-- WRONG: Case sensitivity (depends on database)
-- Be aware of your database's collation settings

-- =====================================================
-- PRACTICE EXERCISES
-- =====================================================

-- 1. Find all products that cost between $20 and $100
-- Your query here...

-- 2. Find all orders from New York or Los Angeles
-- Your query here...

-- 3. Find all products whose name contains 'Pro' or 'Set'
-- Your query here...

-- 4. Find all active products in Electronics with stock > 50
-- Your query here...

-- 5. Find all orders that are NOT cancelled and have amount > $500
-- Your query here...

-- =====================================================
-- SOLUTIONS
-- =====================================================

-- 1. 
SELECT * FROM products WHERE price BETWEEN 20 AND 100;

-- 2.
SELECT * FROM orders WHERE shipping_city IN ('New York', 'Los Angeles');

-- 3.
SELECT * FROM products WHERE product_name LIKE '%Pro%' OR product_name LIKE '%Set%';

-- 4.
SELECT * FROM products 
WHERE is_active = TRUE AND category = 'Electronics' AND stock_quantity > 50;

-- 5.
SELECT * FROM orders WHERE status != 'Cancelled' AND total_amount > 500;

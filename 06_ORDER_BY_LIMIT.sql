-- =====================================================
-- SQL Mastery: 06 - ORDER BY and LIMIT Clauses
-- =====================================================
-- ORDER BY: Sorts the result set in ascending or descending order
-- LIMIT: Specifies the number of records to return

-- =====================================================
-- Using the same tables from previous lessons
-- =====================================================

-- =====================================================
-- 1. BASIC ORDER BY
-- =====================================================

-- Sort by single column (ascending - default)
SELECT * FROM products ORDER BY price;

-- Explicitly specify ascending order
SELECT * FROM products ORDER BY price ASC;

-- Sort in descending order
SELECT * FROM products ORDER BY price DESC;

-- Sort by text column (alphabetical)
SELECT * FROM products ORDER BY product_name;

-- Sort by date
SELECT * FROM orders ORDER BY order_date DESC;

-- =====================================================
-- 2. MULTIPLE COLUMN SORTING
-- =====================================================

-- Sort by multiple columns
-- First by category (ascending), then by price (descending)
SELECT * FROM products 
ORDER BY category ASC, price DESC;

-- Sort by status, then by total_amount
SELECT * FROM orders 
ORDER BY status, total_amount DESC;

-- Three-level sorting
SELECT * FROM products 
ORDER BY category, is_active DESC, price;

-- =====================================================
-- 3. ORDER BY WITH EXPRESSIONS
-- =====================================================

-- Sort by calculated value
SELECT 
    product_name,
    price,
    stock_quantity,
    price * stock_quantity AS total_value
FROM products 
ORDER BY price * stock_quantity DESC;

-- Sort by alias (using column alias)
SELECT 
    product_name,
    price,
    stock_quantity,
    price * stock_quantity AS total_value
FROM products 
ORDER BY total_value DESC;

-- Sort by column position (not recommended, but works)
SELECT product_name, price, stock_quantity 
FROM products 
ORDER BY 2 DESC;  -- Sorts by the 2nd column (price)

-- =====================================================
-- 4. ORDER BY WITH NULL VALUES
-- =====================================================

-- NULL values handling varies by database
-- In MySQL: NULLs appear first with ASC, last with DESC

-- Force NULLs to appear last (MySQL workaround)
SELECT * FROM products 
ORDER BY category IS NULL, category;

-- Force NULLs to appear first (MySQL workaround)
SELECT * FROM products 
ORDER BY category IS NOT NULL, category;

-- =====================================================
-- 5. LIMIT CLAUSE
-- =====================================================

-- Get first 5 records
SELECT * FROM products LIMIT 5;

-- Get top 3 most expensive products
SELECT * FROM products 
ORDER BY price DESC 
LIMIT 3;

-- Get 5 cheapest products
SELECT * FROM products 
ORDER BY price ASC 
LIMIT 5;

-- =====================================================
-- 6. LIMIT WITH OFFSET (Pagination)
-- =====================================================

-- LIMIT with OFFSET: LIMIT <count> OFFSET <skip>
-- Skip first 5 records, then get next 5
SELECT * FROM products LIMIT 5 OFFSET 5;

-- Alternative syntax: LIMIT <offset>, <count>
SELECT * FROM products LIMIT 5, 5;  -- Skip 5, get 5

-- Pagination Example:
-- Page 1: Records 1-5
SELECT * FROM products ORDER BY product_id LIMIT 5 OFFSET 0;

-- Page 2: Records 6-10
SELECT * FROM products ORDER BY product_id LIMIT 5 OFFSET 5;

-- Page 3: Records 11-15
SELECT * FROM products ORDER BY product_id LIMIT 5 OFFSET 10;

-- General formula: OFFSET = (page_number - 1) * page_size

-- =====================================================
-- 7. COMBINING ORDER BY, LIMIT WITH WHERE
-- =====================================================

-- Top 3 most expensive electronics
SELECT * FROM products 
WHERE category = 'Electronics'
ORDER BY price DESC 
LIMIT 3;

-- 5 most recent delivered orders
SELECT * FROM orders 
WHERE status = 'Delivered'
ORDER BY order_date DESC 
LIMIT 5;

-- Get the single most expensive product
SELECT * FROM products 
ORDER BY price DESC 
LIMIT 1;

-- Get the oldest order
SELECT * FROM orders 
ORDER BY order_date ASC 
LIMIT 1;

-- =====================================================
-- 8. TOP-N QUERIES (Common Patterns)
-- =====================================================

-- Second highest price
SELECT * FROM products 
ORDER BY price DESC 
LIMIT 1 OFFSET 1;

-- Top 5 highest value orders
SELECT * FROM orders 
ORDER BY total_amount DESC 
LIMIT 5;

-- 3 products with lowest stock
SELECT product_name, stock_quantity 
FROM products 
WHERE is_active = TRUE
ORDER BY stock_quantity ASC 
LIMIT 3;

-- =====================================================
-- 9. RANDOM ORDERING
-- =====================================================

-- Get random records (MySQL)
SELECT * FROM products 
ORDER BY RAND() 
LIMIT 3;

-- Note: RAND() can be slow on large tables

-- =====================================================
-- 10. CASE-BASED ORDERING (Custom Sort Order)
-- =====================================================

-- Custom status order: Processing first, then Shipped, then Delivered
SELECT * FROM orders 
ORDER BY 
    CASE status
        WHEN 'Processing' THEN 1
        WHEN 'Shipped' THEN 2
        WHEN 'Delivered' THEN 3
        WHEN 'Cancelled' THEN 4
        ELSE 5
    END;

-- Custom category priority
SELECT * FROM products 
ORDER BY 
    CASE category
        WHEN 'Electronics' THEN 1
        WHEN 'Furniture' THEN 2
        WHEN 'Stationery' THEN 3
        ELSE 4
    END,
    price DESC;

-- =====================================================
-- 11. DISTINCT WITH ORDER BY
-- =====================================================

-- Get unique categories sorted alphabetically
SELECT DISTINCT category 
FROM products 
ORDER BY category;

-- Get unique cities from orders
SELECT DISTINCT shipping_city 
FROM orders 
ORDER BY shipping_city;

-- =====================================================
-- 12. ORDER BY WITH BOOLEAN
-- =====================================================

-- Active products first, then inactive
SELECT * FROM products 
ORDER BY is_active DESC, product_name;

-- Inactive products first
SELECT * FROM products 
ORDER BY is_active ASC, product_name;

-- =====================================================
-- CLAUSE ORDER (Important!)
-- =====================================================

-- The correct order of SQL clauses:
-- SELECT
-- FROM
-- WHERE
-- GROUP BY (covered later)
-- HAVING (covered later)
-- ORDER BY
-- LIMIT

-- Example with multiple clauses
SELECT product_name, category, price 
FROM products 
WHERE is_active = TRUE 
ORDER BY price DESC 
LIMIT 5;

-- =====================================================
-- PRACTICE EXERCISES
-- =====================================================

-- 1. Get all products sorted by category (A-Z), then by price (high to low)
-- Your query here...

-- 2. Find the 3 least expensive active products
-- Your query here...

-- 3. Get orders from page 2 of a paginated list (5 items per page),
--    sorted by order_date descending
-- Your query here...

-- 4. Find the second most recent order
-- Your query here...

-- 5. Get unique categories sorted in reverse alphabetical order
-- Your query here...

-- =====================================================
-- SOLUTIONS
-- =====================================================

-- 1.
SELECT * FROM products 
ORDER BY category ASC, price DESC;

-- 2.
SELECT * FROM products 
WHERE is_active = TRUE 
ORDER BY price ASC 
LIMIT 3;

-- 3.
SELECT * FROM orders 
ORDER BY order_date DESC 
LIMIT 5 OFFSET 5;

-- 4.
SELECT * FROM orders 
ORDER BY order_date DESC 
LIMIT 1 OFFSET 1;

-- 5.
SELECT DISTINCT category 
FROM products 
ORDER BY category DESC;

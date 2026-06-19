-- ============================================
-- SQL MASTERY - 25 FULL-TEXT SEARCH
-- ============================================
-- Topics:
-- 1) Creating FULLTEXT Indexes
-- 2) MATCH() AGAINST() Queries
-- 3) Boolean Text Search
-- ============================================

USE school_management;

-- Imagine we have a table of articles or product descriptions.
-- LIKE '%search%' is very slow on large texts because it requires a full table scan.
-- FULLTEXT indexes solve this.

-- ============================================
-- PART 1: Creating a FULLTEXT Index
-- ============================================

CREATE TABLE IF NOT EXISTS product_descriptions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100),
    description TEXT,
    FULLTEXT(product_name, description) -- Creating the index
);

INSERT INTO product_descriptions (product_name, description) VALUES 
('Ergonomic Chair', 'A comfortable mesh chair with lumbar support. Perfect for office.'),
('Gaming Mouse', 'High precision wireless mouse with RGB lighting.'),
('Mechanical Keyboard', 'Clicky keyboard with RGB lighting. Great for coding and gaming.'),
('Office Desk', 'Sturdy wooden desk with adjustable height.');

-- ============================================
-- PART 2: Natural Language Search
-- ============================================

-- MATCH() goes in the WHERE clause. AGAINST() takes the search string.
-- It returns results sorted by relevance!
SELECT 
    product_name, 
    description,
    MATCH(product_name, description) AGAINST('office chair') AS relevance_score
FROM product_descriptions
WHERE MATCH(product_name, description) AGAINST('office chair');

-- ============================================
-- PART 3: Boolean Text Search
-- ============================================
-- IN BOOLEAN MODE allows operators like + (must include), - (must not include), * (wildcard)

-- Find descriptions that MUST have 'gaming' but MUST NOT have 'mouse'
SELECT product_name, description
FROM product_descriptions
WHERE MATCH(product_name, description) AGAINST('+gaming -mouse' IN BOOLEAN MODE);

-- Find descriptions starting with 'ergonom'
SELECT product_name, description
FROM product_descriptions
WHERE MATCH(product_name, description) AGAINST('ergonom*' IN BOOLEAN MODE);

-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Write a query to find all products containing the word 'RGB' using FULLTEXT search.
*/

/*
Task 2:
Write a boolean search query to find products that contain 'keyboard' but NOT 'coding'.
*/

-- ============================================
-- REFERENCE SOLUTIONS
-- ============================================
/*
-- Solution 1:
SELECT product_name, description
FROM product_descriptions
WHERE MATCH(product_name, description) AGAINST('RGB');

-- Solution 2:
SELECT product_name, description
FROM product_descriptions
WHERE MATCH(product_name, description) AGAINST('+keyboard -coding' IN BOOLEAN MODE);
*/

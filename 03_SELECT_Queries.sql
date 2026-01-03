-- ============================================
-- SQL MASTERY - LESSON 3: SELECT QUERIES
-- ============================================
-- Author: RangeshPandian PT
-- Level: Beginner
-- ============================================

USE school_management;

-- ============================================
-- BASIC SELECT SYNTAX
-- ============================================

/*
    SELECT is the most commonly used SQL statement.
    It retrieves data from one or more tables.
    
    Basic Syntax:
    SELECT column1, column2, ...
    FROM table_name
    WHERE condition
    ORDER BY column
    LIMIT number;
*/

-- ============================================
-- SELECTING ALL COLUMNS
-- ============================================

-- Select all columns from employees (use * sparingly in production)
SELECT * FROM employees;

-- Select all columns from products
SELECT * FROM products;

-- ============================================
-- SELECTING SPECIFIC COLUMNS
-- ============================================

-- Select only specific columns
SELECT first_name, last_name, email FROM employees;

-- Select with different order
SELECT last_name, first_name, department, salary FROM employees;

-- ============================================
-- COLUMN ALIASES
-- ============================================

-- Rename columns in output using AS
SELECT 
    first_name AS "First Name",
    last_name AS "Last Name",
    salary AS "Annual Salary"
FROM employees;

-- Aliases without AS (also works)
SELECT 
    first_name FirstName,
    last_name LastName,
    department Dept
FROM employees;

-- ============================================
-- CALCULATED COLUMNS
-- ============================================

-- Arithmetic operations in SELECT
SELECT 
    product_name,
    price,
    price * 1.1 AS "Price with Tax",
    price * 0.9 AS "Discounted Price"
FROM products;

-- Calculate monthly salary from annual
SELECT 
    first_name,
    last_name,
    salary AS annual_salary,
    salary / 12 AS monthly_salary,
    salary / 52 AS weekly_salary
FROM employees;

-- ============================================
-- DISTINCT - Remove Duplicates
-- ============================================

-- Get unique departments
SELECT DISTINCT department FROM employees;

-- Get unique categories
SELECT DISTINCT category FROM products;

-- Distinct on multiple columns
SELECT DISTINCT department, is_active FROM employees;

-- Count distinct values
SELECT COUNT(DISTINCT department) AS unique_departments FROM employees;

-- ============================================
-- WHERE CLAUSE - Filtering Data
-- ============================================

-- Basic comparison operators: =, <>, !=, <, >, <=, >=

-- Equal to
SELECT * FROM employees WHERE department = 'Engineering';

-- Not equal to
SELECT * FROM employees WHERE department != 'Engineering';
SELECT * FROM employees WHERE department <> 'Engineering';

-- Greater than
SELECT * FROM products WHERE price > 100;

-- Less than or equal
SELECT * FROM products WHERE stock_quantity <= 50;

-- ============================================
-- COMPOUND CONDITIONS (AND, OR, NOT)
-- ============================================

-- AND - Both conditions must be true
SELECT * FROM employees 
WHERE department = 'Engineering' AND salary > 70000;

-- OR - At least one condition must be true
SELECT * FROM employees 
WHERE department = 'Engineering' OR department = 'Marketing';

-- NOT - Negates the condition
SELECT * FROM employees 
WHERE NOT department = 'Engineering';

-- Combining AND, OR with parentheses
SELECT * FROM employees 
WHERE (department = 'Engineering' OR department = 'Marketing') 
AND salary > 60000;

-- ============================================
-- IN Operator - Multiple Values
-- ============================================

-- Instead of multiple OR conditions
SELECT * FROM employees 
WHERE department IN ('Engineering', 'Marketing', 'Sales');

-- NOT IN
SELECT * FROM employees 
WHERE department NOT IN ('HR', 'Finance');

-- IN with numbers
SELECT * FROM products 
WHERE product_id IN (1, 3, 5, 7, 9);

-- ============================================
-- BETWEEN Operator - Range of Values
-- ============================================

-- Numeric range (inclusive)
SELECT * FROM products 
WHERE price BETWEEN 50 AND 200;

-- Date range
SELECT * FROM employees 
WHERE hire_date BETWEEN '2024-01-01' AND '2024-06-30';

-- NOT BETWEEN
SELECT * FROM products 
WHERE price NOT BETWEEN 100 AND 500;

-- ============================================
-- LIKE Operator - Pattern Matching
-- ============================================

/*
    Wildcards:
    % - Matches any sequence of characters (including none)
    _ - Matches exactly one character
*/

-- Names starting with 'J'
SELECT * FROM employees WHERE first_name LIKE 'J%';

-- Names ending with 'son'
SELECT * FROM employees WHERE last_name LIKE '%son';

-- Names containing 'ar'
SELECT * FROM employees WHERE first_name LIKE '%ar%';

-- Exactly 4-letter names
SELECT * FROM employees WHERE first_name LIKE '____';

-- Second letter is 'o'
SELECT * FROM employees WHERE first_name LIKE '_o%';

-- NOT LIKE
SELECT * FROM employees WHERE email NOT LIKE '%@email.com';

-- ============================================
-- NULL Values
-- ============================================

-- Check for NULL (cannot use = or !=)
SELECT * FROM employees WHERE department IS NULL;

-- Check for NOT NULL
SELECT * FROM employees WHERE department IS NOT NULL;

-- COALESCE - Replace NULL with default value
SELECT 
    first_name,
    last_name,
    COALESCE(department, 'Unassigned') AS department,
    COALESCE(salary, 0) AS salary
FROM employees;

-- IFNULL (MySQL specific, similar to COALESCE)
SELECT 
    first_name,
    IFNULL(department, 'No Department') AS department
FROM employees;

-- ============================================
-- ORDER BY - Sorting Results
-- ============================================

-- Ascending order (default)
SELECT * FROM employees ORDER BY last_name;
SELECT * FROM employees ORDER BY last_name ASC;

-- Descending order
SELECT * FROM employees ORDER BY salary DESC;

-- Multiple columns
SELECT * FROM employees 
ORDER BY department ASC, salary DESC;

-- Order by column position (not recommended)
SELECT first_name, last_name, salary 
FROM employees 
ORDER BY 3 DESC;  -- Orders by salary (3rd column)

-- Order by alias
SELECT first_name, salary, salary * 12 AS annual
FROM employees
ORDER BY annual DESC;

-- ============================================
-- LIMIT and OFFSET - Pagination
-- ============================================

-- Get first 5 records
SELECT * FROM employees LIMIT 5;

-- Get top 3 highest paid employees
SELECT * FROM employees ORDER BY salary DESC LIMIT 3;

-- Skip first 2, get next 5 (for pagination)
SELECT * FROM employees LIMIT 5 OFFSET 2;

-- Alternative syntax
SELECT * FROM employees LIMIT 2, 5;  -- LIMIT offset, count

-- ============================================
-- COMBINING EVERYTHING
-- ============================================

-- Complex query example
SELECT 
    first_name AS "First Name",
    last_name AS "Last Name",
    department AS "Department",
    salary AS "Salary",
    ROUND(salary / 12, 2) AS "Monthly Pay"
FROM employees
WHERE 
    is_active = TRUE
    AND department IN ('Engineering', 'Marketing', 'Sales')
    AND salary BETWEEN 50000 AND 90000
ORDER BY 
    department ASC,
    salary DESC
LIMIT 10;

-- ============================================
-- PRACTICE EXERCISES
-- ============================================

/*
    Using the employees and products tables:
    
    EXERCISE 1:
    Select first_name, last_name, and salary for employees
    in the Engineering department with salary > 70000.
    
    EXERCISE 2:
    Find all products that cost between $20 and $100,
    ordered by price descending.
    
    EXERCISE 3:
    Find employees whose last name starts with 'S' or 'B'.
    
    EXERCISE 4:
    Get the top 5 most expensive products showing
    name, price, and price with 15% discount.
    
    EXERCISE 5:
    Find all employees with NULL salary or NULL department.
    
    EXERCISE 6:
    Select distinct categories from products where
    stock quantity is greater than 50.
*/

-- ============================================
-- SOLUTIONS
-- ============================================

-- Solution 1:
SELECT first_name, last_name, salary
FROM employees
WHERE department = 'Engineering' AND salary > 70000;

-- Solution 2:
SELECT * FROM products
WHERE price BETWEEN 20 AND 100
ORDER BY price DESC;

-- Solution 3:
SELECT * FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'B%';

-- Solution 4:
SELECT 
    product_name,
    price,
    ROUND(price * 0.85, 2) AS discounted_price
FROM products
ORDER BY price DESC
LIMIT 5;

-- Solution 5:
SELECT * FROM employees
WHERE salary IS NULL OR department IS NULL;

-- Solution 6:
SELECT DISTINCT category
FROM products
WHERE stock_quantity > 50;

-- ============================================
-- KEY TAKEAWAYS
-- ============================================

/*
    1. SELECT * gets all columns, but specify columns in production
    2. Use aliases (AS) for readable output and calculations
    3. WHERE filters rows based on conditions
    4. Use AND, OR, NOT for complex conditions
    5. IN is cleaner than multiple OR conditions
    6. BETWEEN is inclusive on both ends
    7. LIKE with % and _ for pattern matching
    8. Use IS NULL / IS NOT NULL for NULL checks
    9. ORDER BY for sorting (ASC/DESC)
    10. LIMIT with OFFSET for pagination
*/

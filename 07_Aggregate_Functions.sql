-- =====================================================
-- SQL Mastery: 07 - Aggregate Functions
-- =====================================================
-- Aggregate functions perform calculations on a set of values
-- and return a single summarized value

-- =====================================================
-- Sample Tables
-- =====================================================

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50),
    salary DECIMAL(10, 2),
    hire_date DATE,
    commission DECIMAL(10, 2),
    manager_id INT
);

CREATE TABLE IF NOT EXISTS sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    sale_date DATE,
    amount DECIMAL(10, 2),
    product_category VARCHAR(50),
    region VARCHAR(50)
);

-- Insert sample data
INSERT INTO employees (first_name, last_name, department, salary, hire_date, commission, manager_id) VALUES
('John', 'Smith', 'Sales', 55000.00, '2020-03-15', 5000.00, NULL),
('Jane', 'Doe', 'Sales', 52000.00, '2021-06-20', 4500.00, 1),
('Mike', 'Johnson', 'IT', 75000.00, '2019-01-10', NULL, NULL),
('Sarah', 'Williams', 'IT', 72000.00, '2020-08-05', NULL, 3),
('Tom', 'Brown', 'HR', 48000.00, '2022-02-01', NULL, NULL),
('Emily', 'Davis', 'Sales', 58000.00, '2020-11-15', 6000.00, 1),
('David', 'Wilson', 'IT', 68000.00, '2021-04-10', NULL, 3),
('Lisa', 'Taylor', 'HR', 51000.00, '2021-09-20', NULL, 5),
('James', 'Anderson', 'Finance', 65000.00, '2019-07-01', 3000.00, NULL),
('Anna', 'Thomas', 'Finance', 62000.00, '2022-03-15', 2500.00, 9);

INSERT INTO sales (employee_id, sale_date, amount, product_category, region) VALUES
(1, '2024-01-15', 15000.00, 'Electronics', 'North'),
(2, '2024-01-16', 8500.00, 'Furniture', 'South'),
(1, '2024-01-20', 12000.00, 'Electronics', 'North'),
(6, '2024-01-22', 9500.00, 'Software', 'East'),
(2, '2024-02-01', 11000.00, 'Electronics', 'South'),
(1, '2024-02-05', 7500.00, 'Furniture', 'North'),
(6, '2024-02-10', 18000.00, 'Electronics', 'East'),
(2, '2024-02-15', 5500.00, 'Software', 'South'),
(1, '2024-03-01', 22000.00, 'Electronics', 'West'),
(6, '2024-03-05', 14500.00, 'Furniture', 'East');

-- =====================================================
-- 1. COUNT() - Counting Records
-- =====================================================

-- Count all rows
SELECT COUNT(*) AS total_employees FROM employees;

-- Count non-NULL values in a column
SELECT COUNT(commission) AS employees_with_commission FROM employees;

-- Count unique values
SELECT COUNT(DISTINCT department) AS total_departments FROM employees;

-- Count with condition
SELECT COUNT(*) AS sales_employees 
FROM employees 
WHERE department = 'Sales';

-- =====================================================
-- 2. SUM() - Total of Values
-- =====================================================

-- Sum all salaries
SELECT SUM(salary) AS total_salary_expense FROM employees;

-- Sum with condition
SELECT SUM(salary) AS it_salary_expense 
FROM employees 
WHERE department = 'IT';

-- Sum of multiple columns
SELECT 
    SUM(salary) AS total_salary,
    SUM(commission) AS total_commission,
    SUM(salary) + COALESCE(SUM(commission), 0) AS total_compensation
FROM employees;

-- Sum sales by category
SELECT SUM(amount) AS total_sales 
FROM sales 
WHERE product_category = 'Electronics';

-- =====================================================
-- 3. AVG() - Average Value
-- =====================================================

-- Average salary
SELECT AVG(salary) AS average_salary FROM employees;

-- Average with rounding
SELECT ROUND(AVG(salary), 2) AS average_salary FROM employees;

-- Average by department
SELECT AVG(salary) AS avg_it_salary 
FROM employees 
WHERE department = 'IT';

-- Average commission (ignores NULL)
SELECT AVG(commission) AS avg_commission FROM employees;

-- Average including NULL as 0
SELECT AVG(COALESCE(commission, 0)) AS avg_commission_with_zeros 
FROM employees;

-- =====================================================
-- 4. MIN() and MAX() - Minimum and Maximum
-- =====================================================

-- Minimum and maximum salary
SELECT 
    MIN(salary) AS lowest_salary,
    MAX(salary) AS highest_salary
FROM employees;

-- Salary range
SELECT MAX(salary) - MIN(salary) AS salary_range FROM employees;

-- Min/Max with dates
SELECT 
    MIN(hire_date) AS earliest_hire,
    MAX(hire_date) AS latest_hire
FROM employees;

-- Min/Max with strings (alphabetically)
SELECT 
    MIN(first_name) AS first_alphabetically,
    MAX(first_name) AS last_alphabetically
FROM employees;

-- =====================================================
-- 5. COMBINING MULTIPLE AGGREGATES
-- =====================================================

-- Comprehensive statistics
SELECT 
    COUNT(*) AS total_employees,
    SUM(salary) AS total_salary,
    AVG(salary) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    MAX(salary) - MIN(salary) AS salary_spread
FROM employees;

-- Department statistics
SELECT 
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary,
    SUM(salary) AS total_salary
FROM employees 
WHERE department = 'Sales';

-- =====================================================
-- 6. AGGREGATES WITH DISTINCT
-- =====================================================

-- Count unique departments
SELECT COUNT(DISTINCT department) AS unique_departments FROM employees;

-- Sum of unique salaries only (rare use case)
SELECT SUM(DISTINCT salary) AS sum_unique_salaries FROM employees;

-- Average of distinct values
SELECT AVG(DISTINCT salary) AS avg_unique_salaries FROM employees;

-- =====================================================
-- 7. HANDLING NULL VALUES IN AGGREGATES
-- =====================================================

-- Important: Aggregate functions IGNORE NULL values (except COUNT(*))

-- COUNT(*) vs COUNT(column)
SELECT 
    COUNT(*) AS total_rows,
    COUNT(commission) AS non_null_commissions
FROM employees;

-- Using COALESCE with aggregates
SELECT 
    AVG(commission) AS avg_commission_excluding_null,
    AVG(COALESCE(commission, 0)) AS avg_commission_including_null_as_zero
FROM employees;

-- Sum with NULL handling
SELECT 
    SUM(salary) AS salary_sum,
    COALESCE(SUM(commission), 0) AS commission_sum,
    SUM(salary) + COALESCE(SUM(commission), 0) AS total
FROM employees;

-- =====================================================
-- 8. AGGREGATE FUNCTIONS WITH WHERE
-- =====================================================

-- Statistics for high earners
SELECT 
    COUNT(*) AS count,
    AVG(salary) AS avg_salary,
    SUM(salary) AS total_salary
FROM employees 
WHERE salary > 60000;

-- Sales statistics for specific period
SELECT 
    COUNT(*) AS sale_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount
FROM sales 
WHERE sale_date BETWEEN '2024-01-01' AND '2024-01-31';

-- Combined conditions
SELECT 
    COUNT(*) AS count,
    AVG(salary) AS avg_salary
FROM employees 
WHERE department = 'IT' AND hire_date > '2020-01-01';

-- =====================================================
-- 9. VARIANCE AND STANDARD DEVIATION (Advanced)
-- =====================================================

-- Variance (measures spread of data)
SELECT 
    VAR_POP(salary) AS population_variance,
    VAR_SAMP(salary) AS sample_variance
FROM employees;

-- Standard Deviation
SELECT 
    STDDEV_POP(salary) AS population_stddev,
    STDDEV_SAMP(salary) AS sample_stddev
FROM employees;

-- Complete statistical overview
SELECT 
    COUNT(*) AS n,
    ROUND(AVG(salary), 2) AS mean,
    MIN(salary) AS min_val,
    MAX(salary) AS max_val,
    ROUND(STDDEV_SAMP(salary), 2) AS std_dev
FROM employees;

-- =====================================================
-- 10. PRACTICAL EXAMPLES
-- =====================================================

-- Monthly sales summary
SELECT 
    COUNT(*) AS total_transactions,
    SUM(amount) AS total_revenue,
    ROUND(AVG(amount), 2) AS avg_transaction,
    MIN(amount) AS smallest_sale,
    MAX(amount) AS largest_sale
FROM sales;

-- Employee compensation overview
SELECT 
    COUNT(*) AS total_employees,
    SUM(salary + COALESCE(commission, 0)) AS total_compensation,
    ROUND(AVG(salary + COALESCE(commission, 0)), 2) AS avg_compensation,
    COUNT(commission) AS employees_with_commission,
    ROUND(100.0 * COUNT(commission) / COUNT(*), 1) AS pct_with_commission
FROM employees;

-- Department headcount and salary summary
SELECT 
    'IT' AS department,
    COUNT(*) AS headcount,
    SUM(salary) AS total_salary
FROM employees WHERE department = 'IT'
UNION ALL
SELECT 
    'Sales' AS department,
    COUNT(*) AS headcount,
    SUM(salary) AS total_salary
FROM employees WHERE department = 'Sales';

-- =====================================================
-- 11. COMMON MISTAKES
-- =====================================================

-- WRONG: Mixing aggregate and non-aggregate columns without GROUP BY
-- SELECT first_name, AVG(salary) FROM employees;  -- Error!

-- WRONG: Using WHERE with aggregate results
-- SELECT AVG(salary) FROM employees WHERE AVG(salary) > 50000;  -- Error!
-- Use HAVING instead (covered in next lesson)

-- =====================================================
-- PRACTICE EXERCISES
-- =====================================================

-- 1. Find the total number of sales and their total value
-- Your query here...

-- 2. Calculate the average, minimum, and maximum sale amount
-- Your query here...

-- 3. Count how many employees earn more than $60,000
-- Your query here...

-- 4. Find the total commission paid to all employees
-- Your query here...

-- 5. Calculate the average salary of employees hired after 2020
-- Your query here...

-- =====================================================
-- SOLUTIONS
-- =====================================================

-- 1.
SELECT 
    COUNT(*) AS total_sales,
    SUM(amount) AS total_value
FROM sales;

-- 2.
SELECT 
    ROUND(AVG(amount), 2) AS avg_amount,
    MIN(amount) AS min_amount,
    MAX(amount) AS max_amount
FROM sales;

-- 3.
SELECT COUNT(*) AS high_earners 
FROM employees 
WHERE salary > 60000;

-- 4.
SELECT COALESCE(SUM(commission), 0) AS total_commission 
FROM employees;

-- 5.
SELECT ROUND(AVG(salary), 2) AS avg_salary 
FROM employees 
WHERE hire_date > '2020-12-31';

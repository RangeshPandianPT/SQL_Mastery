-- =====================================================
-- SQL Mastery: 08 - GROUP BY and HAVING Clauses
-- =====================================================
-- GROUP BY: Groups rows that have the same values into summary rows
-- HAVING: Filters groups based on aggregate conditions

-- Using tables from previous lessons (employees, sales)

-- =====================================================
-- 1. BASIC GROUP BY
-- =====================================================

-- Count employees per department
SELECT 
    department, 
    COUNT(*) AS employee_count
FROM employees 
GROUP BY department;

-- Total salary by department
SELECT 
    department, 
    SUM(salary) AS total_salary
FROM employees 
GROUP BY department;

-- Average salary by department
SELECT 
    department, 
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees 
GROUP BY department;

-- =====================================================
-- 2. GROUP BY WITH MULTIPLE COLUMNS
-- =====================================================

-- Group by multiple columns
SELECT 
    department, 
    manager_id,
    COUNT(*) AS employee_count,
    AVG(salary) AS avg_salary
FROM employees 
GROUP BY department, manager_id;

-- Sales by region and category
SELECT 
    region, 
    product_category,
    COUNT(*) AS sale_count,
    SUM(amount) AS total_amount
FROM sales 
GROUP BY region, product_category;

-- =====================================================
-- 3. GROUP BY WITH ORDER BY
-- =====================================================

-- Departments sorted by employee count (descending)
SELECT 
    department, 
    COUNT(*) AS employee_count
FROM employees 
GROUP BY department 
ORDER BY employee_count DESC;

-- Top departments by total salary
SELECT 
    department, 
    SUM(salary) AS total_salary
FROM employees 
GROUP BY department 
ORDER BY total_salary DESC;

-- Sort by grouped column
SELECT 
    department, 
    COUNT(*) AS count
FROM employees 
GROUP BY department 
ORDER BY department;

-- =====================================================
-- 4. THE HAVING CLAUSE
-- =====================================================

-- Filter groups with HAVING
-- Departments with more than 2 employees
SELECT 
    department, 
    COUNT(*) AS employee_count
FROM employees 
GROUP BY department 
HAVING COUNT(*) > 2;

-- Departments with average salary > 55000
SELECT 
    department, 
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees 
GROUP BY department 
HAVING AVG(salary) > 55000;

-- =====================================================
-- 5. WHERE vs HAVING
-- =====================================================

-- WHERE filters rows BEFORE grouping
-- HAVING filters groups AFTER aggregation

-- Example: Filter employees first, then group
SELECT 
    department, 
    COUNT(*) AS count,
    AVG(salary) AS avg_salary
FROM employees 
WHERE salary > 50000          -- Filter individual rows first
GROUP BY department 
HAVING COUNT(*) >= 2;         -- Then filter groups

-- Wrong approach (can't use aggregate in WHERE):
-- SELECT department, AVG(salary) 
-- FROM employees 
-- WHERE AVG(salary) > 50000;  -- ERROR!

-- Correct approach:
SELECT 
    department, 
    AVG(salary) AS avg_salary
FROM employees 
GROUP BY department 
HAVING AVG(salary) > 50000;

-- =====================================================
-- 6. COMBINING WHERE AND HAVING
-- =====================================================

-- WHERE + GROUP BY + HAVING + ORDER BY
SELECT 
    department, 
    COUNT(*) AS employee_count,
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees 
WHERE hire_date > '2020-01-01'      -- Filter rows first
GROUP BY department                  -- Group the filtered rows
HAVING COUNT(*) >= 2                 -- Filter groups
ORDER BY avg_salary DESC;            -- Sort result

-- Sales analysis with all clauses
SELECT 
    product_category,
    COUNT(*) AS sale_count,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount
FROM sales 
WHERE sale_date >= '2024-01-01'     -- Only 2024 sales
GROUP BY product_category 
HAVING SUM(amount) > 20000          -- Categories with > 20k total
ORDER BY total_amount DESC;

-- =====================================================
-- 7. MULTIPLE CONDITIONS IN HAVING
-- =====================================================

-- Multiple HAVING conditions with AND
SELECT 
    department, 
    COUNT(*) AS count,
    AVG(salary) AS avg_salary
FROM employees 
GROUP BY department 
HAVING COUNT(*) >= 2 AND AVG(salary) > 50000;

-- Multiple HAVING conditions with OR
SELECT 
    department, 
    COUNT(*) AS count,
    SUM(salary) AS total_salary
FROM employees 
GROUP BY department 
HAVING COUNT(*) > 3 OR SUM(salary) > 150000;

-- =====================================================
-- 8. GROUP BY WITH DATE FUNCTIONS
-- =====================================================

-- Group by year
SELECT 
    YEAR(hire_date) AS hire_year,
    COUNT(*) AS employees_hired
FROM employees 
GROUP BY YEAR(hire_date) 
ORDER BY hire_year;

-- Group by month and year
SELECT 
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    COUNT(*) AS sale_count,
    SUM(amount) AS monthly_total
FROM sales 
GROUP BY YEAR(sale_date), MONTH(sale_date) 
ORDER BY year, month;

-- Group by quarter
SELECT 
    YEAR(sale_date) AS year,
    QUARTER(sale_date) AS quarter,
    SUM(amount) AS quarterly_total
FROM sales 
GROUP BY YEAR(sale_date), QUARTER(sale_date);

-- =====================================================
-- 9. GROUP BY WITH EXPRESSIONS
-- =====================================================

-- Group by salary range
SELECT 
    CASE 
        WHEN salary < 50000 THEN 'Under 50K'
        WHEN salary < 60000 THEN '50K-60K'
        WHEN salary < 70000 THEN '60K-70K'
        ELSE '70K and above'
    END AS salary_range,
    COUNT(*) AS employee_count
FROM employees 
GROUP BY 
    CASE 
        WHEN salary < 50000 THEN 'Under 50K'
        WHEN salary < 60000 THEN '50K-60K'
        WHEN salary < 70000 THEN '60K-70K'
        ELSE '70K and above'
    END
ORDER BY MIN(salary);

-- Group by custom categories
SELECT 
    CASE 
        WHEN amount < 10000 THEN 'Small'
        WHEN amount < 15000 THEN 'Medium'
        ELSE 'Large'
    END AS sale_size,
    COUNT(*) AS count,
    SUM(amount) AS total
FROM sales 
GROUP BY 
    CASE 
        WHEN amount < 10000 THEN 'Small'
        WHEN amount < 15000 THEN 'Medium'
        ELSE 'Large'
    END;

-- =====================================================
-- 10. GROUP BY WITH NULL VALUES
-- =====================================================

-- NULL is treated as a group
SELECT 
    manager_id, 
    COUNT(*) AS employee_count
FROM employees 
GROUP BY manager_id;

-- Handling NULL in grouping
SELECT 
    COALESCE(manager_id, 0) AS manager_id,
    COUNT(*) AS employee_count
FROM employees 
GROUP BY COALESCE(manager_id, 0);

-- =====================================================
-- 11. ROLLUP (Subtotals and Grand Total)
-- =====================================================

-- GROUP BY with ROLLUP (MySQL)
SELECT 
    department, 
    COUNT(*) AS employee_count,
    SUM(salary) AS total_salary
FROM employees 
GROUP BY department WITH ROLLUP;

-- Multi-level ROLLUP
SELECT 
    department,
    YEAR(hire_date) AS hire_year,
    COUNT(*) AS count
FROM employees 
GROUP BY department, YEAR(hire_date) WITH ROLLUP;

-- =====================================================
-- 12. PRACTICAL EXAMPLES
-- =====================================================

-- Department Performance Summary
SELECT 
    department,
    COUNT(*) AS headcount,
    ROUND(AVG(salary), 2) AS avg_salary,
    MIN(salary) AS min_salary,
    MAX(salary) AS max_salary,
    SUM(salary) AS salary_budget
FROM employees 
GROUP BY department 
ORDER BY headcount DESC;

-- Sales Rep Performance
SELECT 
    e.first_name,
    e.last_name,
    COUNT(s.sale_id) AS total_sales,
    SUM(s.amount) AS total_revenue,
    ROUND(AVG(s.amount), 2) AS avg_sale_size
FROM employees e
LEFT JOIN sales s ON e.employee_id = s.employee_id
WHERE e.department = 'Sales'
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY total_revenue DESC;

-- Regional Sales Analysis
SELECT 
    region,
    product_category,
    COUNT(*) AS sale_count,
    SUM(amount) AS total_amount,
    ROUND(AVG(amount), 2) AS avg_amount,
    ROUND(100.0 * SUM(amount) / (SELECT SUM(amount) FROM sales), 2) AS pct_of_total
FROM sales 
GROUP BY region, product_category 
HAVING SUM(amount) > 10000
ORDER BY region, total_amount DESC;

-- =====================================================
-- SQL CLAUSE ORDER (Important!)
-- =====================================================

-- The required order of clauses:
-- 1. SELECT
-- 2. FROM
-- 3. WHERE      (filter rows)
-- 4. GROUP BY   (group rows)
-- 5. HAVING     (filter groups)
-- 6. ORDER BY   (sort result)
-- 7. LIMIT      (limit result)

-- Example with all clauses
SELECT 
    department,
    COUNT(*) AS count,
    AVG(salary) AS avg_salary
FROM employees
WHERE hire_date > '2019-01-01'
GROUP BY department
HAVING COUNT(*) >= 2
ORDER BY avg_salary DESC
LIMIT 5;

-- =====================================================
-- PRACTICE EXERCISES
-- =====================================================

-- 1. Count employees in each department and show only departments 
--    with more than 2 employees
-- Your query here...

-- 2. Find the total sales amount by region, sorted by total descending
-- Your query here...

-- 3. Calculate average salary by department for employees hired after 2020
-- Your query here...

-- 4. Find product categories with average sale amount greater than $10,000
-- Your query here...

-- 5. Show monthly sales totals for 2024, including only months 
--    with total sales > $15,000
-- Your query here...

-- =====================================================
-- SOLUTIONS
-- =====================================================

-- 1.
SELECT 
    department, 
    COUNT(*) AS employee_count
FROM employees 
GROUP BY department 
HAVING COUNT(*) > 2;

-- 2.
SELECT 
    region, 
    SUM(amount) AS total_sales
FROM sales 
GROUP BY region 
ORDER BY total_sales DESC;

-- 3.
SELECT 
    department, 
    ROUND(AVG(salary), 2) AS avg_salary
FROM employees 
WHERE hire_date > '2020-12-31'
GROUP BY department;

-- 4.
SELECT 
    product_category, 
    ROUND(AVG(amount), 2) AS avg_amount
FROM sales 
GROUP BY product_category 
HAVING AVG(amount) > 10000;

-- 5.
SELECT 
    MONTH(sale_date) AS month,
    SUM(amount) AS monthly_total
FROM sales 
WHERE YEAR(sale_date) = 2024
GROUP BY MONTH(sale_date) 
HAVING SUM(amount) > 15000
ORDER BY month;

-- ============================================
-- SQL MASTERY - EXTENDED CHALLENGE SET
-- ============================================
-- Comprehensive practice problems organized by difficulty
-- Tables used: employees, products, orders
-- ============================================

USE school_management;

-- ============================================
-- SECTION A: BEGINNER CHALLENGES (Basic CRUD, WHERE, ORDER BY)
-- ============================================

/*
Challenge A1: Basic SELECT with Filtering
Return all active employees in the 'Sales' department.
Expected columns: employee_id, first_name, last_name, salary
Order by salary descending.
Difficulty: Beginner
*/


/*
Challenge A2: DATE Filtering
Find all orders placed in the year 2024.
Expected columns: order_id, customer_name, order_date, total_amount
Order by order_date ascending.
Difficulty: Beginner
*/


/*
Challenge A3: IN Operator
Get products in categories 'Electronics' or 'Home'.
Expected columns: product_id, product_name, category, price
Order by price descending.
Difficulty: Beginner
*/


/*
Challenge A4: BETWEEN and Logical Operators
Find employees hired between 2022-01-01 and 2023-12-31 
with salary greater than 50000.
Expected columns: first_name, last_name, hire_date, salary
Difficulty: Beginner
*/


/*
Challenge A5: NULL Handling
Find all products where description is NOT NULL and stock_quantity is NULL.
Expected columns: product_id, product_name, description
Difficulty: Beginner
*/


-- ============================================
-- SECTION B: INTERMEDIATE CHALLENGES (Aggregation, JOINs, GROUP BY)
-- ============================================

/*
Challenge B1: Simple Aggregation
Calculate total number of employees, total salary expense, and average salary.
Difficulty: Intermediate
Expected output: One row with columns: total_employees, total_salary, avg_salary
*/


/*
Challenge B2: GROUP BY with Filtering
Show department names and average salary for each department.
Include only departments with 3 or more employees.
Expected columns: department, employee_count, avg_salary
Order by avg_salary descending.
Difficulty: Intermediate
*/


/*
Challenge B3: INNER JOIN
For each order, display order_id, customer_name, product_name, quantity, and total_amount.
Expected columns: order_id, customer_name, product_name, quantity, total_amount
Difficulty: Intermediate
*/


/*
Challenge B4: LEFT JOIN
Show all products and the number of times each has been ordered.
If a product was never ordered, show 0.
Expected columns: product_id, product_name, order_count
Order by order_count descending.
Difficulty: Intermediate
*/


/*
Challenge B5: Multiple JOINs
For each order, show:
- order_id
- customer_name
- product_name
- quantity
- unit_price (from products table)
- computed_total = quantity * unit_price
Expected columns: order_id, customer_name, product_name, quantity, unit_price, computed_total
Difficulty: Intermediate
*/


/*
Challenge B6: CASE Expression with Aggregation
Categorize employees by salary range and count employees in each range:
- 'Entry': salary < 50000
- 'Mid-Level': salary 50000-70000
- 'Senior': salary > 70000
Expected columns: salary_category, employee_count
Difficulty: Intermediate
*/


/*
Challenge B7: GROUP BY with HAVING and Calculation
Find departments where total salary expense is greater than 200000.
Expected columns: department, total_employees, total_salary_expense
Order by total_salary_expense descending.
Difficulty: Intermediate
*/


/*
Challenge B8: Date Functions with Aggregation
Count how many employees were hired in each year.
Expected columns: hire_year, employee_count
Order by hire_year ascending.
Difficulty: Intermediate
*/


/*
Challenge B9: DISTINCT with WHERE
How many unique products are in the 'Electronics' category?
Expected output: One value showing distinct_product_count
Difficulty: Intermediate
*/


/*
Challenge B10: String Functions
Find employees whose first name starts with 'J' and last name is longer than 6 characters.
Expected columns: first_name, last_name, length_of_last_name
Difficulty: Intermediate
*/


-- ============================================
-- SECTION C: ADVANCED CHALLENGES (Subqueries, CTEs, Window Functions)
-- ============================================

/*
Challenge C1: Subquery in WHERE Clause
Find all employees whose salary is above the average salary.
Expected columns: employee_id, first_name, last_name, salary, avg_salary_of_company
Difficulty: Advanced
*/


/*
Challenge C2: Correlated Subquery
For each employee, show their name, salary, and the average salary 
of their department.
Expected columns: first_name, last_name, salary, dept_avg_salary
Difficulty: Advanced
*/


/*
Challenge C3: CTE - Department Statistics
Using a CTE, create department statistics (avg salary, max salary, min salary)
and show employees who earn more than their department's average.
Expected columns: first_name, last_name, department, salary, dept_avg_salary
Difficulty: Advanced
*/


/*
Challenge C4: CTE - Multi-level Aggregation
Using CTEs:
1. Calculate revenue by product
2. Calculate total revenue
3. Show each product with its revenue percentage of total
Expected columns: product_id, product_name, revenue, total_revenue, revenue_percentage
Difficulty: Advanced
*/


/*
Challenge C5: Subquery in FROM Clause
Find the top 5 most ordered products (by quantity).
Use a subquery to calculate total quantity per product first.
Expected columns: product_name, total_quantity_ordered
Difficulty: Advanced
*/


/*
Challenge C6: CASE with Subquery
Classify customers based on total amount spent:
- 'VIP': total spent >= 1000
- 'Loyal': total spent 500-999
- 'Regular': total spent < 500
Expected columns: customer_name, total_spent, customer_tier
Difficulty: Advanced
*/


/*
Challenge C7: Window Function - Row Ranking
Rank employees within each department by salary (highest first).
Expected columns: employee_id, first_name, last_name, department, salary, dept_rank
Difficulty: Advanced
*/


/*
Challenge C8: Window Function - Running Total
Calculate running total of order amounts ordered by order_date.
Expected columns: order_id, order_date, total_amount, running_total
Difficulty: Advanced
*/


/*
Challenge C9: Window Function - Compare to Previous
Show each order with the previous order's total amount (for comparison).
Expected columns: order_id, order_date, total_amount, previous_order_amount
Order by order_date ascending.
Difficulty: Advanced
*/


/*
Challenge C10: Complex CTE with Window Functions
For each department:
1. Calculate rank of employees by salary
2. Calculate cumulative salary by rank
3. Show employee name, department, salary, rank, and cumulative salary
Expected columns: department, first_name, last_name, salary, rank, cumulative_salary
Difficulty: Advanced
*/


-- ============================================
-- SECTION D: REAL-WORLD SCENARIO CHALLENGES
-- ============================================

/*
Challenge D1: Sales Performance Report
Create a sales report showing:
- Department
- Total revenue
- Number of orders
- Average order value
- Top product in that department
Group by department and order by total revenue descending.
Difficulty: Advanced
*/


/*
Challenge D2: Inventory Management
Show products that need restocking:
- Stock is below 50 units
- Product name, current stock, and suggested reorder quantity (stock * 2)
Order by stock ascending.
Difficulty: Intermediate
*/


/*
Challenge D3: Customer Lifetime Value Analysis
Calculate for each customer:
- Total amount spent
- Number of orders
- Average order value
- First order date
- Last order date
- Days as customer (days between first and last order)
Show only customers with 3+ orders and sort by total_amount descending.
Difficulty: Advanced
*/


/*
Challenge D4: Employee Performance Ranking
Create a performance ranking showing:
- Department
- Employee name
- Number of orders they processed (or some metric)
- Salary
- Rank within their department
- Compare to department average
Show top 10 performers.
Difficulty: Advanced
*/


/*
Challenge D5: Time-based Analysis
Show sales by quarter:
- Quarter (Q1, Q2, Q3, Q4)
- Year
- Total revenue
- Number of orders
- Average order size
Group by quarter and year, order by year descending, then quarter descending.
Difficulty: Intermediate
*/


/*
Challenge D6: Product Performance Dashboard
For each product, calculate:
- Total revenue generated
- Total units sold
- Average units per order
- Number of unique customers
- Best performing month (month with highest revenue)
Show only products with revenue > 500.
Difficulty: Advanced
*/


/*
Challenge D7: Churn Risk Analysis
Identify employees who haven't had orders processed recently:
- Last order date is more than 30 days ago
- OR they have 0 orders
Show: employee_id, first_name, last_name, last_order_date, days_since_last_order
Difficulty: Intermediate
*/


/*
Challenge D8: Trend Analysis - YoY Comparison
Compare revenue for each month across different years:
- Month
- 2023 Revenue
- 2024 Revenue
- Revenue change (2024 vs 2023)
- Percentage change
Difficulty: Advanced
*/


/*
Challenge D9: Segment Analysis
Segment products by price ranges and analyze:
- Price segment ('Budget': <50, 'Standard': 50-100, 'Premium': >100)
- Count of products
- Average stock level
- Total revenue from segment
- Total units sold
Difficulty: Intermediate
*/


/*
Challenge D10: Data Quality Check
Find and report data issues:
1. Orders with no matching products
2. Customers with no orders
3. Products with negative stock
4. Orders with invalid dates (future dates)
5. Employees in multiple departments (if applicable)
Expected output: Data quality report with issue types and counts.
Difficulty: Intermediate
*/


-- ============================================
-- SECTION E: OPTIMIZATION CHALLENGES
-- ============================================

/*
Challenge E1: Index Strategy
Analyze the following query and propose indexes:
SELECT e.first_name, e.last_name, o.order_date, o.total_amount
FROM employees e
JOIN orders o ON e.employee_id = o.employee_id
WHERE e.department = 'Sales'
AND o.order_date > '2024-01-01'
ORDER BY o.total_amount DESC;

Create appropriate indexes and verify with SHOW INDEX.
Difficulty: Advanced
*/


/*
Challenge E2: Query Optimization
Rewrite this subquery to use a JOIN instead:
SELECT DISTINCT product_name
FROM products
WHERE product_id NOT IN (SELECT product_id FROM orders);

Which version performs better? Why?
Difficulty: Advanced
*/


/*
Challenge E3: Aggregation Performance
These two queries should return the same result, but with different performance:
Version 1: Using multiple GROUP BY queries
Version 2: Using a single GROUP BY with conditional aggregation
Write both and compare the EXPLAIN output.
Difficulty: Advanced
*/


-- ============================================
-- SECTION F: BONUS CHALLENGES - TRICKY CASES
-- ============================================

/*
Challenge F1: The NULL Trap
Find the average salary, but there's a twist - some salaries might be NULL.
How do you ensure NULLs are handled correctly?
Expected columns: avg_salary, null_count, non_null_count
Difficulty: Intermediate
*/


/*
Challenge F2: Duplicate Data
If there are duplicate orders in the table:
- Identify duplicates (orders with same customer, product, date, amount)
- Count how many times each appears
- Show only duplicates that appear more than once
Expected columns: order_id, customer_name, product_name, duplicate_count
Difficulty: Intermediate
*/


/*
Challenge F3: The Cartesian Product Trap
Rewrite this query that produces too many rows:
SELECT e.first_name, p.product_name, o.order_date
FROM employees e, products p, orders o;

What's the correct way to join these tables?
Difficulty: Intermediate
*/


/*
Challenge F4: Division by Zero
Calculate sales per employee, but some employees may have no sales.
Handle the division by zero case gracefully.
Expected columns: employee_id, first_name, total_orders, total_revenue, revenue_per_order
Difficulty: Intermediate
*/


/*
Challenge F5: Date Range Edge Cases
Find orders in Q2 2024 (April 1 - June 30).
Consider edge cases: what about times? Timezones?
Expected columns: order_id, order_date, total_amount
Difficulty: Intermediate
*/


-- ============================================
-- USAGE INSTRUCTIONS
-- ============================================
/*
How to use this challenge set:

1. BEGINNER (A1-A5):
   - Start here if you're new to SQL
   - Focus on basic SELECT, WHERE, and ORDER BY
   - Practice: 30 minutes per challenge

2. INTERMEDIATE (B1-B10, D2, D5, D7, D9-F5):
   - Prerequisites: Complete Beginner challenges
   - Topics: JOINs, GROUP BY, HAVING, basic aggregation
   - Practice: 45 minutes per challenge

3. ADVANCED (C1-C10, D1, D3, D4, D6, D8, E1-E3):
   - Prerequisites: Complete Intermediate challenges
   - Topics: Subqueries, CTEs, window functions, optimization
   - Practice: 1-2 hours per challenge

4. REAL-WORLD (D1-D10):
   - Practical business scenarios
   - Combine multiple SQL concepts
   - Build portfolio-ready solutions

TIPS:
- Always write SELECT before UPDATE/DELETE
- Test with LIMIT 10 first for large result sets
- Use EXPLAIN to understand query performance
- Check your solution against sample data
- Try different approaches (subquery vs CTE, etc.)
*/

-- ============================================
-- SQL MASTERY - 17 ADVANCED SQL
-- ============================================
-- Topics:
-- 1) CTEs (Common Table Expressions)
-- 2) Window Functions
-- 3) Transactions (BEGIN / COMMIT / ROLLBACK)
-- ============================================

USE school_management;

-- ============================================
-- PART 1: CTEs
-- ============================================

-- Example 1: Revenue by product, then filter high-revenue products.
WITH product_revenue AS (
    SELECT
        o.product_id,
        p.product_name,
        SUM(o.total_amount) AS revenue
    FROM orders o
    JOIN products p ON p.product_id = o.product_id
    GROUP BY o.product_id, p.product_name
)
SELECT product_id, product_name, revenue
FROM product_revenue
WHERE revenue >= 200
ORDER BY revenue DESC;

-- Example 2: Department salary stats and compare each employee to dept average.
WITH department_avg AS (
    SELECT
        department,
        AVG(salary) AS avg_salary
    FROM employees
    WHERE is_active = TRUE
    GROUP BY department
)
SELECT
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department,
    e.salary,
    d.avg_salary,
    ROUND(e.salary - d.avg_salary, 2) AS diff_from_dept_avg
FROM employees e
JOIN department_avg d ON d.department = e.department
WHERE e.is_active = TRUE
ORDER BY e.department, e.salary DESC;

-- ============================================
-- PART 2: WINDOW FUNCTIONS
-- ============================================

-- Example 3: Rank products by price inside each category.
SELECT
    product_id,
    product_name,
    category,
    price,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY price DESC) AS row_num_in_category,
    RANK() OVER (PARTITION BY category ORDER BY price DESC) AS rank_in_category,
    DENSE_RANK() OVER (PARTITION BY category ORDER BY price DESC) AS dense_rank_in_category
FROM products
ORDER BY category, price DESC;

-- Example 4: Running total of revenue by order date.
SELECT
    order_id,
    customer_name,
    DATE(order_date) AS order_day,
    total_amount,
    SUM(total_amount) OVER (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM orders
ORDER BY order_date, order_id;

-- Example 5: Previous and next order amount using LAG and LEAD.
SELECT
    order_id,
    customer_name,
    total_amount,
    LAG(total_amount) OVER (ORDER BY order_date, order_id) AS previous_order_amount,
    LEAD(total_amount) OVER (ORDER BY order_date, order_id) AS next_order_amount
FROM orders
ORDER BY order_date, order_id;

-- ============================================
-- PART 3: TRANSACTIONS
-- ============================================

-- Demo A: Safe update + rollback.
START TRANSACTION;

UPDATE products
SET price = price * 1.10
WHERE category = 'Stationery';

-- Verify changes inside the transaction.
SELECT product_id, product_name, category, price
FROM products
WHERE category = 'Stationery'
ORDER BY product_id;

-- Undo the transaction.
ROLLBACK;

-- Confirm rollback worked.
SELECT product_id, product_name, category, price
FROM products
WHERE category = 'Stationery'
ORDER BY product_id;

-- Demo B: Safe update + commit.
START TRANSACTION;

UPDATE orders
SET status = 'Processing'
WHERE status = 'Pending';

SELECT order_id, customer_name, status
FROM orders
ORDER BY order_id;

COMMIT;

-- ============================================
-- PRACTICE TASKS (Solve before checking reference)
-- ============================================

/*
Task 1 (CTE)
Find the top 2 products by total revenue.
Expected columns: product_id, product_name, revenue
*/

/*
Task 2 (CTE)
Show departments where active employee avg salary is above 65000.
Expected columns: department, avg_salary
*/

/*
Task 3 (Window)
For each order, show a rank by total_amount (highest first).
Expected columns: order_id, customer_name, total_amount, amount_rank
*/

/*
Task 4 (Window)
Show each product with percentage of total inventory value.
Inventory value per row = price * stock_quantity.
Expected columns: product_id, product_name, inventory_value, pct_of_total_value
*/

/*
Task 5 (Transaction)
Create a transaction that:
1) Increases Electronics prices by 5%
2) Shows changed rows
3) Rolls back
*/

-- ============================================
-- REFERENCE SOLUTIONS
-- ============================================

-- Solution 1
WITH product_revenue AS (
    SELECT
        o.product_id,
        p.product_name,
        SUM(o.total_amount) AS revenue
    FROM orders o
    JOIN products p ON p.product_id = o.product_id
    GROUP BY o.product_id, p.product_name
)
SELECT product_id, product_name, revenue
FROM product_revenue
ORDER BY revenue DESC
LIMIT 2;

-- Solution 2
WITH department_avg AS (
    SELECT department, AVG(salary) AS avg_salary
    FROM employees
    WHERE is_active = TRUE
    GROUP BY department
)
SELECT department, avg_salary
FROM department_avg
WHERE avg_salary > 65000
ORDER BY avg_salary DESC;

-- Solution 3
SELECT
    order_id,
    customer_name,
    total_amount,
    RANK() OVER (ORDER BY total_amount DESC) AS amount_rank
FROM orders
ORDER BY total_amount DESC, order_id;

-- Solution 4
WITH inventory AS (
    SELECT
        product_id,
        product_name,
        (price * stock_quantity) AS inventory_value
    FROM products
)
SELECT
    product_id,
    product_name,
    inventory_value,
    ROUND((inventory_value / SUM(inventory_value) OVER ()) * 100, 2) AS pct_of_total_value
FROM inventory
ORDER BY inventory_value DESC;

-- Solution 5
START TRANSACTION;

UPDATE products
SET price = price * 1.05
WHERE category = 'Electronics';

SELECT product_id, product_name, category, price
FROM products
WHERE category = 'Electronics'
ORDER BY product_id;

ROLLBACK;

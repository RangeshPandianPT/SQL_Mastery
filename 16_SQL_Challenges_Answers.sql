-- ============================================
-- SQL MASTERY - CHALLENGE ANSWERS
-- ============================================
USE school_management;

-- Challenge 1
SELECT employee_id, first_name, last_name, department, salary
FROM employees
WHERE is_active = TRUE
ORDER BY salary DESC;

-- Challenge 2
SELECT first_name, last_name, hire_date, salary
FROM employees
WHERE hire_date BETWEEN '2024-01-01' AND '2024-12-31'
  AND salary BETWEEN 60000 AND 80000;

-- Challenge 3
SELECT
    product_name,
    stock_quantity,
    CASE
        WHEN stock_quantity < 50 THEN 'Low'
        WHEN stock_quantity BETWEEN 50 AND 150 THEN 'Medium'
        ELSE 'High'
    END AS stock_label
FROM products;

-- Challenge 4
SELECT status, SUM(total_amount) AS total_revenue
FROM orders
GROUP BY status
ORDER BY total_revenue DESC;

-- Challenge 5
SELECT customer_name, SUM(total_amount) AS total_spent
FROM orders
GROUP BY customer_name
ORDER BY total_spent DESC
LIMIT 3;

-- Challenge 6
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN orders o ON p.product_id = o.product_id
WHERE o.order_id IS NULL;

-- Challenge 7
SELECT department, AVG(salary) AS avg_salary
FROM employees
WHERE department IS NOT NULL
GROUP BY department
HAVING AVG(salary) >= 65000;

-- Challenge 8
SELECT
    o.order_id,
    o.customer_name,
    p.product_name,
    o.quantity,
    o.quantity * p.price AS computed_total
FROM orders o
JOIN products p ON o.product_id = p.product_id;

-- Challenge 9
CREATE OR REPLACE VIEW high_value_orders AS
SELECT *
FROM orders
WHERE total_amount >= 500;

SELECT * FROM high_value_orders;

-- Challenge 10
CREATE INDEX idx_orders_status_date ON orders(status, order_date);
SHOW INDEX FROM orders;

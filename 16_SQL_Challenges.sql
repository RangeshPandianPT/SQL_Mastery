-- ============================================
-- SQL MASTERY - CHALLENGE SET
-- ============================================
-- Difficulty: Beginner to Intermediate
-- Tables used: employees, products, orders
-- ============================================

USE school_management;

/*
Challenge 1
Return all active employees sorted by salary (highest first).
Expected columns: employee_id, first_name, last_name, department, salary
*/


/*
Challenge 2
Return employees hired in 2024 with salary between 60000 and 80000.
Expected columns: first_name, last_name, hire_date, salary
*/


/*
Challenge 3
Show each product with a stock label:
- 'Low' when stock_quantity < 50
- 'Medium' when stock_quantity between 50 and 150
- 'High' when stock_quantity > 150
Expected columns: product_name, stock_quantity, stock_label
*/


/*
Challenge 4
Find total revenue by order status.
Expected columns: status, total_revenue
Order by total_revenue descending.
*/


/*
Challenge 5
Show top 3 customers by total spent.
Expected columns: customer_name, total_spent
*/


/*
Challenge 6
Find products that have never been ordered.
Expected columns: product_id, product_name
Hint: LEFT JOIN orders
*/


/*
Challenge 7
Find average salary by department, but include only departments
where average salary is at least 65000.
Expected columns: department, avg_salary
*/


/*
Challenge 8
For each order, show customer_name, product_name, quantity,
and computed_total = quantity * product price.
Expected columns: order_id, customer_name, product_name, quantity, computed_total
*/


/*
Challenge 9
Create a view named high_value_orders for orders with total_amount >= 500.
Then select all rows from that view.
*/


/*
Challenge 10
Add an index on orders(status, order_date), then verify indexes.
Use SHOW INDEX FROM orders;
*/

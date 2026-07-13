/*
  Lesson 31: Table Partitioning
  Partitioning breaks a very large table into smaller, more manageable pieces 
  called partitions. This can significantly improve query performance and data management.
*/

USE school_management;

-- Example: Partitioning an Orders Table by Date (RANGE Partitioning)
-- First, let's create a new table for partitioned orders
CREATE TABLE partitioned_orders (
    order_id INT NOT NULL,
    customer_name VARCHAR(100),
    product_id INT,
    order_date DATE NOT NULL,
    total_amount DECIMAL(10,2)
)
PARTITION BY RANGE (YEAR(order_date)) (
    PARTITION p_old VALUES LESS THAN (2022),
    PARTITION p_2022 VALUES LESS THAN (2023),
    PARTITION p_2023 VALUES LESS THAN (2024),
    PARTITION p_new VALUES LESS THAN MAXVALUE
);

-- Insert sample data spanning multiple years
INSERT INTO partitioned_orders (order_id, customer_name, product_id, order_date, total_amount)
VALUES 
(1, 'Alice', 101, '2021-05-10', 150.00),
(2, 'Bob', 102, '2022-08-15', 200.00),
(3, 'Charlie', 103, '2023-11-20', 300.00),
(4, 'David', 104, '2024-01-05', 400.00);

-- When you query a specific date range, MySQL only scans the relevant partition (Partition Pruning)
EXPLAIN SELECT * FROM partitioned_orders WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01';

-- You can also query a specific partition directly (MySQL specific syntax)
SELECT * FROM partitioned_orders PARTITION (p_2023);

-- Drop the table when done
DROP TABLE partitioned_orders;

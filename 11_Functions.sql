-- =====================================================
-- SQL Mastery: 11 - String Functions
-- =====================================================

-- LENGTH - Get string length
SELECT product_name, LENGTH(product_name) AS name_length FROM products;

-- UPPER / LOWER - Change case
SELECT UPPER(first_name) AS upper_name, LOWER(email) AS lower_email FROM employees;

-- CONCAT - Combine strings
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employees;

-- SUBSTRING - Extract part of string
SELECT SUBSTRING(product_name, 1, 5) AS short_name FROM products;

-- TRIM - Remove whitespace
SELECT TRIM('  hello  ') AS trimmed;
SELECT LTRIM('  left'), RTRIM('right  ');

-- REPLACE - Replace text
SELECT REPLACE(email, '@email.com', '@company.com') FROM employees;

-- LEFT / RIGHT - Get characters from start/end
SELECT LEFT(product_name, 3), RIGHT(product_name, 3) FROM products;

-- LOCATE / INSTR - Find position of substring
SELECT product_name, LOCATE('Pro', product_name) AS position FROM products;

-- REVERSE - Reverse a string
SELECT REVERSE('Hello') AS reversed;

-- LPAD / RPAD - Pad string to length
SELECT LPAD(employee_id, 5, '0') AS padded_id FROM employees;

-- =====================================================
-- SQL Mastery: 12 - Date Functions
-- =====================================================

-- Current date and time
SELECT CURRENT_DATE(), CURRENT_TIME(), NOW();

-- Extract parts of date
SELECT order_date,
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,
    DAY(order_date) AS day,
    DAYNAME(order_date) AS day_name,
    MONTHNAME(order_date) AS month_name
FROM orders;

-- Date arithmetic
SELECT DATE_ADD(order_date, INTERVAL 30 DAY) AS due_date FROM orders;
SELECT DATE_SUB(NOW(), INTERVAL 1 MONTH) AS last_month;
SELECT DATEDIFF(NOW(), order_date) AS days_ago FROM orders;

-- Format dates
SELECT DATE_FORMAT(order_date, '%M %d, %Y') AS formatted FROM orders;
SELECT DATE_FORMAT(NOW(), '%W, %M %d, %Y at %h:%i %p') AS full_format;

-- =====================================================
-- SQL Mastery: 13 - Numeric Functions
-- =====================================================

-- ROUND, CEIL, FLOOR
SELECT ROUND(123.456, 2), CEIL(123.1), FLOOR(123.9);

-- ABS - Absolute value
SELECT ABS(-50) AS absolute;

-- MOD - Modulo (remainder)
SELECT MOD(10, 3) AS remainder;

-- POWER, SQRT
SELECT POWER(2, 3) AS power, SQRT(16) AS square_root;

-- RAND - Random number
SELECT RAND() AS random_num;

-- =====================================================
-- PRACTICE: Try these functions with your data!
-- =====================================================

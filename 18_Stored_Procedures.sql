-- ============================================
-- SQL MASTERY - 18 STORED PROCEDURES
-- ============================================
-- Topics:
-- 1) Creating and Calling Procedures
-- 2) IN, OUT, and INOUT Parameters
-- 3) Variables and Control Flow (IF/ELSE)
-- ============================================

USE school_management;

-- Note: When defining stored procedures in clients like MySQL CLI,
-- you must change the DELIMITER so the engine doesn't stop at the first semicolon.
-- Example: DELIMITER // ... PROCEDURE ... // DELIMITER ;

-- ============================================
-- PART 1: BASIC PROCEDURES
-- ============================================

-- Drop if exists to avoid errors on recreation
DROP PROCEDURE IF EXISTS GetAllActiveEmployees;

-- Create a simple procedure with no parameters
DELIMITER //

CREATE PROCEDURE GetAllActiveEmployees()
BEGIN
    SELECT employee_id, first_name, last_name, department
    FROM employees
    WHERE is_active = TRUE;
END //

DELIMITER ;

-- Call the procedure
CALL GetAllActiveEmployees();

-- ============================================
-- PART 2: PARAMETERS (IN, OUT)
-- ============================================

DROP PROCEDURE IF EXISTS GetEmployeesByDept;

-- Procedure with an IN parameter
DELIMITER //

CREATE PROCEDURE GetEmployeesByDept(IN dept_name VARCHAR(50))
BEGIN
    SELECT employee_id, first_name, last_name, salary
    FROM employees
    WHERE department = dept_name AND is_active = TRUE;
END //

DELIMITER ;

CALL GetEmployeesByDept('Engineering');


DROP PROCEDURE IF EXISTS GetEmployeeCount;

-- Procedure with an OUT parameter
DELIMITER //

CREATE PROCEDURE GetEmployeeCount(IN dept_name VARCHAR(50), OUT emp_count INT)
BEGIN
    SELECT COUNT(*) INTO emp_count
    FROM employees
    WHERE department = dept_name;
END //

DELIMITER ;

-- Calling a procedure with an OUT parameter
CALL GetEmployeeCount('Sales', @sales_count);
SELECT @sales_count AS sales_department_count;


-- ============================================
-- PART 3: VARIABLES AND CONTROL FLOW
-- ============================================

DROP PROCEDURE IF EXISTS GiveRaise;

DELIMITER //

CREATE PROCEDURE GiveRaise(IN emp_id INT, IN raise_percentage DECIMAL(5,2))
BEGIN
    -- Declare local variable
    DECLARE current_salary DECIMAL(10,2);
    
    -- Get current salary
    SELECT salary INTO current_salary
    FROM employees
    WHERE employee_id = emp_id;
    
    -- IF/ELSE control flow
    IF current_salary IS NULL THEN
        SELECT 'Employee not found' AS status;
    ELSEIF raise_percentage > 20.00 THEN
        SELECT 'Raise percentage too high (Max 20%)' AS status;
    ELSE
        UPDATE employees
        SET salary = salary + (salary * (raise_percentage / 100))
        WHERE employee_id = emp_id;
        
        SELECT 'Raise applied successfully' AS status;
    END IF;
END //

DELIMITER ;

-- Test the procedure
CALL GiveRaise(1, 10.00); -- Valid raise
CALL GiveRaise(2, 25.00); -- Exceeds limit
CALL GiveRaise(999, 10.00); -- Not found

-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Create a stored procedure `GetProductRevenue` that takes a `product_id` (IN) 
and returns the total revenue for that product (OUT).

Task 2:
Create a stored procedure `UpdateProductStock` that takes a `product_id` and a `quantity_change`.
If the resulting stock would drop below 0, do not update and select an error message.
Otherwise, update the stock.
*/

-- ============================================
-- SQL MASTERY - 29 ADVANCED ERROR HANDLING
-- ============================================
-- Topics:
-- 1) DECLARE ... HANDLER FOR SQLEXCEPTION
-- 2) Custom Error Messages (SIGNAL)
-- 3) Cursors for Row-by-Row Processing
-- ============================================

USE school_management;

-- ============================================
-- PART 1: BASIC ERROR HANDLING (HANDLERS)
-- ============================================
-- Handlers allow a stored procedure to fail gracefully instead of crashing.

DROP PROCEDURE IF EXISTS SafeInsertEmployee;

DELIMITER //

CREATE PROCEDURE SafeInsertEmployee(IN p_first_name VARCHAR(50), IN p_email VARCHAR(100))
BEGIN
    -- Declare a variable to check if an error occurred
    DECLARE has_error BOOLEAN DEFAULT FALSE;
    
    -- Declare a handler for any SQL Exception (like unique constraint violation)
    -- CONTINUE handler allows the procedure to keep running after the error.
    -- EXIT handler would immediately exit the BEGIN...END block.
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION 
    BEGIN
        SET has_error = TRUE;
    END;

    -- Attempt to insert
    INSERT INTO employees (first_name, last_name, email, department)
    VALUES (p_first_name, 'Unknown', p_email, 'General');
    
    IF has_error THEN
        SELECT 'Error: Failed to insert employee. Email might already exist.' AS status;
    ELSE
        SELECT 'Success: Employee inserted.' AS status;
    END IF;
END //

DELIMITER ;

-- Test the procedure
CALL SafeInsertEmployee('NewGuy', 'newguy@email.com'); -- Success
CALL SafeInsertEmployee('DuplicateGuy', 'john.doe@email.com'); -- Fails gracefully (john.doe already exists)

-- ============================================
-- PART 2: THROWING ERRORS (SIGNAL)
-- ============================================

DROP PROCEDURE IF EXISTS UpdateProductPrice;

DELIMITER //

CREATE PROCEDURE UpdateProductPrice(IN p_product_id INT, IN p_new_price DECIMAL(10,2))
BEGIN
    IF p_new_price <= 0 THEN
        -- Manually throw an error with a custom message using SIGNAL SQLSTATE '45000'
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Product price must be greater than zero.';
    ELSE
        UPDATE products SET price = p_new_price WHERE product_id = p_product_id;
        SELECT 'Price updated successfully.' AS status;
    END IF;
END //

DELIMITER ;

-- CALL UpdateProductPrice(1, -5.00); -- Will throw a fatal error
CALL UpdateProductPrice(1, 1350.00);  -- Will succeed

-- ============================================
-- PART 3: CURSORS (Row-by-Row Processing)
-- ============================================
-- Cursors allow you to iterate through a result set one row at a time.
-- Use sparingly, as set-based operations (standard UPDATE/INSERT) are usually much faster!

DROP PROCEDURE IF EXISTS GiveBonusToHighPerformers;

DELIMITER //

CREATE PROCEDURE GiveBonusToHighPerformers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE emp_salary DECIMAL(10,2);
    
    -- 1. Declare the cursor
    DECLARE cur_employees CURSOR FOR 
        SELECT employee_id, salary FROM employees WHERE is_active = TRUE;
        
    -- 2. Declare handler to know when we reach the end of the results
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- 3. Open the cursor
    OPEN cur_employees;
    
    -- 4. Loop through rows
    read_loop: LOOP
        FETCH cur_employees INTO emp_id, emp_salary;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Apply logic (e.g., if salary > 70000, print a bonus message)
        IF emp_salary >= 70000 THEN
            -- In reality, we might insert into a bonuses table here.
            SELECT CONCAT('Bonus authorized for Employee ID ', emp_id) AS Action;
        END IF;
    END LOOP;
    
    -- 5. Close the cursor
    CLOSE cur_employees;
END //

DELIMITER ;

CALL GiveBonusToHighPerformers();

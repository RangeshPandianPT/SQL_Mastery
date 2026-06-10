-- ============================================
-- SQL MASTERY - 19 TRIGGERS
-- ============================================
-- Topics:
-- 1) BEFORE / AFTER Triggers
-- 2) INSERT, UPDATE, DELETE Triggers
-- 3) Using OLD and NEW keywords
-- ============================================

USE school_management;

-- ============================================
-- SETUP: Audit Table for Tracking Changes
-- ============================================

-- Create a table to track salary changes
CREATE TABLE IF NOT EXISTS salary_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action_type VARCHAR(50)
);

-- ============================================
-- PART 1: AFTER UPDATE TRIGGER (Audit Log)
-- ============================================

DROP TRIGGER IF EXISTS after_salary_update;

DELIMITER //

CREATE TRIGGER after_salary_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Only log if the salary actually changed
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO salary_audit (employee_id, old_salary, new_salary, action_type)
        VALUES (OLD.employee_id, OLD.salary, NEW.salary, 'UPDATE');
    END IF;
END //

DELIMITER ;

-- Test the trigger
UPDATE employees SET salary = salary + 1000 WHERE employee_id = 3;
SELECT * FROM salary_audit;


-- ============================================
-- PART 2: BEFORE INSERT TRIGGER (Data Validation / Formatting)
-- ============================================

DROP TRIGGER IF EXISTS before_employee_insert;

DELIMITER //

CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    -- Ensure names are properly capitalized (first letter uppercase)
    SET NEW.first_name = CONCAT(UPPER(SUBSTRING(NEW.first_name, 1, 1)), LOWER(SUBSTRING(NEW.first_name, 2)));
    SET NEW.last_name = CONCAT(UPPER(SUBSTRING(NEW.last_name, 1, 1)), LOWER(SUBSTRING(NEW.last_name, 2)));
    
    -- Ensure salary is never negative
    IF NEW.salary < 0 THEN
        SET NEW.salary = 0;
    END IF;
END //

DELIMITER ;

-- Test the trigger
INSERT INTO employees (first_name, last_name, email, department, salary) 
VALUES ('jOhN', 'dOe', 'john.doe@email.com', 'HR', -5000);

-- Check result (Name is capitalized, salary is 0)
SELECT first_name, last_name, salary FROM employees WHERE email = 'john.doe@email.com';


-- ============================================
-- PART 3: BEFORE DELETE TRIGGER (Prevention)
-- ============================================

DROP TRIGGER IF EXISTS before_employee_delete;

DELIMITER //

CREATE TRIGGER before_employee_delete
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    -- Prevent deletion of active employees
    IF OLD.is_active = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete an active employee. Deactivate them first.';
    END IF;
END //

DELIMITER ;

-- Test the trigger (This should fail and throw an error)
-- DELETE FROM employees WHERE employee_id = 1 AND is_active = TRUE;


-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Create a `products_audit` table and an `AFTER DELETE` trigger on the `products` table 
that logs the `product_id`, `product_name`, and `deleted_at` timestamp whenever a product is removed.

Task 2:
Create a `BEFORE UPDATE` trigger on the `orders` table to prevent the `status` 
from being changed to 'Shipped' if the `total_amount` is 0. 
(Use SIGNAL SQLSTATE '45000' to throw an error).
*/

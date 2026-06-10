-- ============================================
-- SQL MASTERY - 21 USER MANAGEMENT (DCL)
-- ============================================
-- Topics:
-- 1) Creating and Dropping Users
-- 2) Granting Privileges
-- 3) Revoking Privileges
-- ============================================

-- Note: You may need root/admin privileges to execute these commands.

-- ============================================
-- PART 1: CREATING USERS
-- ============================================

-- Create a new user who can connect from localhost with a specific password
CREATE USER 'reporting_user'@'localhost' IDENTIFIED BY 'SecurePass123!';

-- Create an app user who can connect from any IP address ('%')
CREATE USER 'app_backend'@'%' IDENTIFIED BY 'AppBackendPass!!';

-- View all users (MySQL specific)
SELECT user, host FROM mysql.user;


-- ============================================
-- PART 2: GRANTING PRIVILEGES
-- ============================================

-- Grant SELECT only (Read-Only access) to a specific database
GRANT SELECT ON school_management.* TO 'reporting_user'@'localhost';

-- Grant CRUD operations for the application backend
GRANT SELECT, INSERT, UPDATE, DELETE ON school_management.* TO 'app_backend'@'%';

-- Grant EXECUTE privileges for stored procedures
GRANT EXECUTE ON school_management.* TO 'app_backend'@'%';

-- Grant ALL privileges (like an admin) to a specific database
-- GRANT ALL PRIVILEGES ON school_management.* TO 'admin_user'@'localhost';

-- Apply the privilege changes immediately
FLUSH PRIVILEGES;

-- Check a user's grants
SHOW GRANTS FOR 'reporting_user'@'localhost';


-- ============================================
-- PART 3: REVOKING PRIVILEGES & DROPPING USERS
-- ============================================

-- Revoke a specific privilege (e.g., prevent the app from deleting data)
REVOKE DELETE ON school_management.* FROM 'app_backend'@'%';

-- Revoke all privileges
REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'reporting_user'@'localhost';

-- Delete the user accounts entirely
DROP USER 'reporting_user'@'localhost';
DROP USER 'app_backend'@'%';

-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Create a user named 'data_entry'@'localhost' with password 'Data123'.

Task 2:
Grant the 'data_entry' user ONLY `INSERT` and `UPDATE` privileges 
on the `school_management.orders` table (not the whole database).

Task 3:
Check the grants for 'data_entry', then drop the user.
*/

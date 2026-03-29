-- ============================================
-- SQL MASTERY - RESET SCRIPT
-- ============================================
-- Purpose: Reset the learning environment quickly.
-- It removes the database and recreates it by sourcing setup script logic.
-- ============================================

DROP DATABASE IF EXISTS school_management;
CREATE DATABASE school_management;
USE school_management;

-- If your SQL client supports SOURCE command (for MySQL CLI), use:
-- SOURCE 00_Setup_Database.sql;

-- If SOURCE is not supported in your client, run:
-- 1) 00_Setup_Database.sql manually after this file.

SELECT 'Database reset complete. Now run 00_Setup_Database.sql' AS message;

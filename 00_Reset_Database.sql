-- ============================================
-- SQL MASTERY - RESET SCRIPT
-- ============================================
-- Purpose: Reset the learning environment quickly.
-- It removes the database and rebuilds the practice schema and seed data.
-- ============================================

DROP DATABASE IF EXISTS school_management;
CREATE DATABASE school_management;
USE school_management;

-- ============================================
-- TABLE: teachers
-- ============================================
CREATE TABLE teachers (
	teacher_id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(50) NOT NULL,
	last_name VARCHAR(50) NOT NULL,
	email VARCHAR(100) UNIQUE,
	subject VARCHAR(50),
	hire_date DATE,
	salary DECIMAL(10, 2),
	department VARCHAR(50)
);

INSERT INTO teachers (first_name, last_name, email, subject, hire_date, salary, department)
VALUES
	('Emma', 'Stone', 'emma.stone@school.com', 'Mathematics', '2021-06-10', 52000.00, 'Science'),
	('Liam', 'Carter', 'liam.carter@school.com', 'History', '2020-08-15', 50000.00, 'Humanities'),
	('Noah', 'Brooks', 'noah.brooks@school.com', 'Physics', '2019-02-20', 56000.00, 'Science');

-- If SOURCE is not supported in your client, run:
-- 1) 00_Setup_Database.sql manually after this file.

SELECT 'Database reset complete. Now run 00_Setup_Database.sql' AS message;

-- ============================================
-- SQL MASTERY - 23 DATABASE DESIGN & NORMALIZATION
-- ============================================
-- Topics:
-- 1) First Normal Form (1NF)
-- 2) Second Normal Form (2NF)
-- 3) Third Normal Form (3NF)
-- 4) Denormalization tradeoffs
-- ============================================

USE school_management;

-- --------------------------------------------
-- INITIAL STATE: Denormalized / "Flat" Data
-- --------------------------------------------
-- Imagine a spreadsheet keeping track of employee projects.
-- This table violates several normalization rules.
CREATE TABLE IF NOT EXISTS flat_employee_projects (
    employee_id INT,
    employee_name VARCHAR(100),
    department VARCHAR(50),
    department_head VARCHAR(100),
    project_id INT,
    project_name VARCHAR(100),
    skills_used VARCHAR(255) -- comma separated skills (Violates 1NF)
);

-- ============================================
-- PART 1: First Normal Form (1NF)
-- ============================================
-- Rule 1: Each column must contain atomic (indivisible) values.
-- Rule 2: Each row must be unique (usually via a Primary Key).

-- The 'skills_used' column above has values like 'Java, SQL, Python'. 
-- This violates 1NF because it's not atomic. We can't easily query "Who knows SQL?".

-- To fix this, we ensure atomic values:
CREATE TABLE IF NOT EXISTS employee_skills_1nf (
    employee_id INT,
    skill VARCHAR(50),
    PRIMARY KEY (employee_id, skill)
);
-- Now 'Java', 'SQL', and 'Python' get their own rows.

-- ============================================
-- PART 2: Second Normal Form (2NF)
-- ============================================
-- Rule: Must be in 1NF AND every non-key column must depend on the ENTIRE primary key.
-- (Only applies when you have a composite primary key).

-- Imagine a table tracking hours worked on projects:
-- PK: (employee_id, project_id)
-- Columns: employee_id, project_id, employee_name, hours_worked
-- employee_name depends ONLY on employee_id, not on project_id. This violates 2NF.

-- To fix 2NF, we separate entities:
-- Table 1: Employees (employee_id, employee_name)
-- Table 2: Project_Assignments (employee_id, project_id, hours_worked)

-- ============================================
-- PART 3: Third Normal Form (3NF)
-- ============================================
-- Rule: Must be in 2NF AND there must be no transitive dependencies.
-- (Non-key columns cannot depend on other non-key columns).

-- Looking back at our flat table:
-- Columns: department, department_head
-- department_head depends on department. department is NOT the primary key.
-- If the department head changes, we have to update multiple rows. This violates 3NF.

-- To fix 3NF, we create a Department table:
CREATE TABLE IF NOT EXISTS departments_3nf (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(50),
    department_head VARCHAR(100)
);

-- And link it to Employees via a Foreign Key:
-- Employees (employee_id, employee_name, department_id)

-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Design a schema for an "E-commerce Order" system in 3NF.
Consider entities: Customers, Orders, Products, and Order_Items.
Write the CREATE TABLE statements with appropriate Primary and Foreign keys.
*/

-- ============================================
-- REFERENCE SOLUTIONS
-- ============================================
/*
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    price DECIMAL(10,2)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE Order_Items (
    order_id INT,
    product_id INT,
    quantity INT,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
*/

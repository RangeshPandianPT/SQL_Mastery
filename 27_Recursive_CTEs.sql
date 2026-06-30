-- ============================================
-- SQL MASTERY - 27 RECURSIVE CTEs
-- ============================================
-- Topics:
-- 1) Hierarchical Data Concepts
-- 2) WITH RECURSIVE Syntax
-- 3) Traversing Org Charts and Trees
-- ============================================

USE school_management;

-- Note: Recursive CTEs are supported in MySQL 8.0+

-- ============================================
-- SETUP: Hierarchical Data (Employees & Managers)
-- ============================================

-- Let's create a temporary org chart table for this lesson
DROP TABLE IF EXISTS org_chart;
CREATE TABLE org_chart (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT NULL
);

INSERT INTO org_chart (emp_id, emp_name, manager_id) VALUES
    (1, 'CEO - Alice', NULL),
    (2, 'VP of Sales - Bob', 1),
    (3, 'VP of Engineering - Charlie', 1),
    (4, 'Sales Manager - Dave', 2),
    (5, 'Sales Rep - Eve', 4),
    (6, 'Engineering Lead - Frank', 3),
    (7, 'Software Engineer - Grace', 6),
    (8, 'Software Engineer - Heidi', 6);


-- ============================================
-- PART 1: BASIC RECURSIVE CTE
-- ============================================

-- Query to find the full hierarchy starting from the CEO
WITH RECURSIVE EmployeeHierarchy AS (
    -- Anchor Member (Base case: find the top level without a manager)
    SELECT 
        emp_id, 
        emp_name, 
        manager_id, 
        1 AS level
    FROM org_chart
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive Member (Join back to the CTE itself)
    SELECT 
        o.emp_id, 
        o.emp_name, 
        o.manager_id, 
        eh.level + 1
    FROM org_chart o
    INNER JOIN EmployeeHierarchy eh ON o.manager_id = eh.emp_id
)
SELECT * FROM EmployeeHierarchy
ORDER BY level, emp_id;

-- ============================================
-- PART 2: PATH TRACKING
-- ============================================

-- Query to show the management chain (path) for every employee
WITH RECURSIVE ManagementChain AS (
    -- Anchor Member
    SELECT 
        emp_id, 
        emp_name, 
        CAST(emp_name AS CHAR(255)) AS management_path
    FROM org_chart
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive Member
    SELECT 
        o.emp_id, 
        o.emp_name, 
        CONCAT(mc.management_path, ' -> ', o.emp_name)
    FROM org_chart o
    INNER JOIN ManagementChain mc ON o.manager_id = mc.emp_id
)
SELECT emp_name, management_path
FROM ManagementChain
ORDER BY management_path;

-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Write a Recursive CTE to find all subordinates under 'VP of Engineering - Charlie' (emp_id = 3).
Show their level relative to Charlie (where Charlie is level 1).
*/

-- ============================================
-- REFERENCE SOLUTION
-- ============================================
/*
WITH RECURSIVE CharlieTeam AS (
    SELECT emp_id, emp_name, manager_id, 1 AS depth
    FROM org_chart
    WHERE emp_id = 3
    
    UNION ALL
    
    SELECT o.emp_id, o.emp_name, o.manager_id, ct.depth + 1
    FROM org_chart o
    INNER JOIN CharlieTeam ct ON o.manager_id = ct.emp_id
)
SELECT emp_name, depth FROM CharlieTeam;
*/

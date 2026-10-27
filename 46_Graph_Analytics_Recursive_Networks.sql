-- ============================================
-- LESSON 46: Graph & Hierarchical Network Analytics
-- ============================================
-- Topics Covered:
-- 1. Relational Modeling of Graph Nodes & Directed Edges (Adjacency Lists)
-- 2. Recursive CTEs for Depth Traversal & Complete Breadcrumb Hierarchy Paths
-- 3. Multi-Level Bill of Materials (BOM) Parts Explosion with Quantity Rollups
-- 4. Infinite Loop & Circular Dependency (Cycle) Detection Guards
-- 5. Shortest Path & Degrees of Separation Traversal in Social/Peer Graphs
-- ============================================

DROP TABLE IF EXISTS dependency_edges;
DROP TABLE IF EXISTS social_edges;
DROP TABLE IF EXISTS bom_edges;
DROP TABLE IF EXISTS bom_parts;
DROP TABLE IF EXISTS org_employees;

-- 1. Setup Practice Schemas

-- Organization Structure (Tree Hierarchy with Parent-Child Pointers)
CREATE TABLE org_employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    title VARCHAR(100) NOT NULL,
    manager_id INT NULL,
    salary DECIMAL(10, 2) NOT NULL,
    department VARCHAR(50) NOT NULL
);

-- Bill of Materials: Assemblies and Raw Physical Components
CREATE TABLE bom_parts (
    part_id INT PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_type VARCHAR(20) NOT NULL, -- 'ASSEMBLY', 'COMPONENT'
    unit_cost DECIMAL(10, 2) NOT NULL
);

CREATE TABLE bom_edges (
    parent_part_id INT NOT NULL,
    child_part_id INT NOT NULL,
    quantity_required INT NOT NULL
);

-- Social / Communication Graph (Directed Network)
CREATE TABLE social_edges (
    source_person VARCHAR(50) NOT NULL,
    target_person VARCHAR(50) NOT NULL
);

-- Package Dependency Graph with an Intentional Circular Dependency
CREATE TABLE dependency_edges (
    package_name VARCHAR(50) NOT NULL,
    depends_on VARCHAR(50) NOT NULL
);

-- 2. Seed Data
INSERT INTO org_employees (emp_id, emp_name, title, manager_id, salary, department) VALUES
(1,  'Victoria Sterling', 'Chief Executive Officer',     NULL, 280000.00, 'Executive'),
(2,  'David Zhao',        'VP of Engineering',           1,    190000.00, 'Engineering'),
(3,  'Sarah Connor',      'VP of Product',               1,    185000.00, 'Product'),
(4,  'Elena Rostova',     'Director of Infrastructure',  2,    155000.00, 'Engineering'),
(5,  'Marcus Brody',      'Director of Application Dev', 2,    150000.00, 'Engineering'),
(6,  'Amara Okafor',      'DevOps Team Lead',            4,    125000.00, 'Engineering'),
(7,  'Chen Wei',          'Lead Frontend Architect',     5,    130000.00, 'Engineering'),
(8,  'Kavita Patel',      'Senior Backend Engineer',     5,    128000.00, 'Engineering'),
(9,  'Lucas Silva',       'Cloud Systems Engineer',      6,     95000.00, 'Engineering'),
(10, 'Zoe Washington',    'Associate Software Engineer', 8,     75000.00, 'Engineering');

INSERT INTO bom_parts (part_id, part_name, part_type, unit_cost) VALUES
(100, 'Autonomous Delivery Drone X4', 'ASSEMBLY',  0.00),
(201, 'Airframe Subassembly',         'ASSEMBLY',  0.00),
(202, 'Propulsion Subassembly',       'ASSEMBLY',  0.00),
(203, 'Avionics Flight Controller Pack','ASSEMBLY',0.00),
(301, 'Carbon Fiber Strut Arm',       'COMPONENT', 25.00),
(302, 'Titanium Fastener Hardware',   'COMPONENT', 12.50),
(303, 'Brushless Motor 2207',         'COMPONENT', 32.00),
(304, 'Composite Propeller 5in',      'COMPONENT',  4.50),
(305, 'Flight Controller MCU Board',  'COMPONENT', 85.00),
(306, 'GPS LiDAR Sensor Pod',         'COMPONENT', 110.00);

INSERT INTO bom_edges (parent_part_id, child_part_id, quantity_required) VALUES
(100, 201, 1), -- 1 Airframe per Drone
(100, 202, 1), -- 1 Propulsion System per Drone
(100, 203, 1), -- 1 Avionics Pack per Drone
(201, 301, 4), -- 4 Carbon Struts per Airframe
(201, 302, 2), -- 2 Fastener Packs per Airframe
(202, 303, 4), -- 4 Motors per Propulsion Unit
(202, 304, 8), -- 8 Propellers per Propulsion Unit (quadcopter + 4 spares)
(203, 305, 1), -- 1 MCU Board per Avionics Pack
(203, 306, 1); -- 1 GPS LiDAR Pod per Avionics Pack

INSERT INTO social_edges (source_person, target_person) VALUES
('Alice', 'Bob'),
('Alice', 'Carol'),
('Bob', 'David'),
('Carol', 'David'),
('David', 'Eve'),
('Eve', 'Frank'),
('Frank', 'Grace'),
('Grace', 'Heidi');

-- Intentional circular dependency: auth -> core -> logging -> auth
INSERT INTO dependency_edges (package_name, depends_on) VALUES
('app_web', 'auth'),
('auth',    'core'),
('core',    'logging'),
('logging', 'auth'),   -- Cycle here!
('core',    'database_driver');

-- ============================================
-- QUERY 1: Management Tree Hierarchy & Breadcrumb Paths
-- ============================================
-- Recursively traverse from top executive downwards, tracking level depth
-- and constructing formatted reporting hierarchy paths.
WITH RECURSIVE OrgTree AS (
    -- Anchor member: Root nodes (no manager)
    SELECT 
        emp_id,
        emp_name,
        title,
        manager_id,
        salary,
        1 AS hierarchy_level,
        CAST(emp_name AS CHAR(255)) AS reporting_chain
    FROM org_employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive member: Direct reports
    SELECT 
        e.emp_id,
        e.emp_name,
        e.title,
        e.manager_id,
        e.salary,
        ot.hierarchy_level + 1,
        CONCAT(ot.reporting_chain, ' -> ', e.emp_name)
    FROM org_employees e
    JOIN OrgTree ot ON e.manager_id = ot.emp_id
)
SELECT 
    emp_id,
    emp_name,
    title,
    hierarchy_level,
    salary,
    reporting_chain
FROM OrgTree
ORDER BY hierarchy_level ASC, emp_id ASC;

-- ============================================
-- QUERY 2: Subordinate Headcount & Total Compensation Rollup
-- ============================================
-- Calculates the total downstream organizational size and payroll under each manager
WITH RECURSIVE SubordinateTree AS (
    -- Anchor: Each manager serves as an initial anchor
    SELECT 
        emp_id AS manager_emp_id,
        emp_name AS manager_name,
        emp_id AS report_emp_id,
        salary AS report_salary,
        0 AS level_distance
    FROM org_employees

    UNION ALL

    -- Recursive: Find all downstream reports under this manager
    SELECT 
        st.manager_emp_id,
        st.manager_name,
        e.emp_id,
        e.salary,
        st.level_distance + 1
    FROM SubordinateTree st
    JOIN org_employees e ON e.manager_id = st.report_emp_id
)
SELECT 
    manager_emp_id,
    manager_name,
    -- Count only direct/indirect reports (excluding self from subordinate count)
    COUNT(CASE WHEN level_distance > 0 THEN 1 END) AS total_downstream_reports,
    SUM(CASE WHEN level_distance > 0 THEN report_salary ELSE 0 END) AS downstream_payroll_cost
FROM SubordinateTree
GROUP BY manager_emp_id, manager_name
HAVING total_downstream_reports > 0
ORDER BY downstream_payroll_cost DESC;

-- ============================================
-- QUERY 3: Multi-Level Bill of Materials (BOM) Parts Explosion
-- ============================================
-- Calculates total component counts and extended costs for manufacturing Drone X4
WITH RECURSIVE BomExplosion AS (
    -- Anchor: Immediate children of the root Drone (part_id = 100)
    SELECT 
        e.parent_part_id,
        e.child_part_id,
        p.part_name,
        p.part_type,
        p.unit_cost,
        e.quantity_required AS total_required_qty,
        1 AS assembly_depth,
        CAST(p.part_name AS CHAR(255)) AS assembly_trail
    FROM bom_edges e
    JOIN bom_parts p ON e.child_part_id = p.part_id
    WHERE e.parent_part_id = 100

    UNION ALL

    -- Recursive Step: Multiply parent required qty by child edge qty
    SELECT 
        child_edge.parent_part_id,
        child_edge.child_part_id,
        child_part.part_name,
        child_part.part_type,
        child_part.unit_cost,
        parent.total_required_qty * child_edge.quantity_required,
        parent.assembly_depth + 1,
        CONCAT(parent.assembly_trail, ' -> ', child_part.part_name)
    FROM BomExplosion parent
    JOIN bom_edges child_edge ON parent.child_part_id = child_edge.parent_part_id
    JOIN bom_parts child_part ON child_edge.child_part_id = child_part.part_id
)
SELECT 
    child_part_id AS part_id,
    part_name,
    part_type,
    assembly_depth,
    total_required_qty,
    unit_cost,
    ROUND(total_required_qty * unit_cost, 2) AS extended_subtotal_cost,
    assembly_trail
FROM BomExplosion
ORDER BY assembly_depth ASC, extended_subtotal_cost DESC;

-- ============================================
-- QUERY 4: Cycle & Circular Dependency Detection Guard
-- ============================================
-- Prevents infinite recursion by tracking visited nodes in a path string delimiter.
-- When a node is encountered that already exists in the path, it is flagged as a cycle.
WITH RECURSIVE DependencyCheck AS (
    -- Anchor: Root package starting search
    SELECT 
        package_name,
        depends_on,
        1 AS depth,
        CONCAT('/', package_name, '/', depends_on, '/') AS visited_path,
        0 AS is_circular_dependency
    FROM dependency_edges
    WHERE package_name = 'app_web'

    UNION ALL

    -- Recursive: Follow dependency chain with loop guard
    SELECT 
        de.package_name,
        de.depends_on,
        dc.depth + 1,
        CONCAT(dc.visited_path, de.depends_on, '/'),
        CASE 
            WHEN INSTR(dc.visited_path, CONCAT('/', de.depends_on, '/')) > 0 THEN 1 
            ELSE 0 
        END AS is_circular_dependency
    FROM DependencyCheck dc
    JOIN dependency_edges de ON dc.depends_on = de.package_name
    WHERE dc.is_circular_dependency = 0 AND dc.depth < 10
)
SELECT 
    package_name,
    depends_on,
    depth,
    visited_path,
    CASE 
        WHEN is_circular_dependency = 1 THEN 'CRITICAL: Circular Dependency Detected!'
        ELSE 'SAFE: Linear Dependency'
    END AS safety_status
FROM DependencyCheck
ORDER BY depth ASC;

-- ============================================
-- QUERY 5: Shortest Path & Degrees of Separation
-- ============================================
-- Discovers the shortest connection chain from Alice to Frank in a social network
WITH RECURSIVE SocialPath AS (
    -- Anchor: Direct friends of Alice
    SELECT 
        source_person,
        target_person,
        1 AS degrees_of_separation,
        CONCAT(source_person, ' -> ', target_person) AS connection_chain
    FROM social_edges
    WHERE source_person = 'Alice'

    UNION ALL

    -- Recursive step: Step through neighboring connections
    SELECT 
        sp.source_person,
        se.target_person,
        sp.degrees_of_separation + 1,
        CONCAT(sp.connection_chain, ' -> ', se.target_person)
    FROM SocialPath sp
    JOIN social_edges se ON sp.target_person = se.source_person
    WHERE sp.degrees_of_separation < 6 -- Max 6 degrees of separation cutoff
)
SELECT 
    source_person AS origin,
    target_person AS destination,
    degrees_of_separation,
    connection_chain
FROM SocialPath
WHERE target_person = 'Frank'
ORDER BY degrees_of_separation ASC
LIMIT 1;

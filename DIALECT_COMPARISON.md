# SQL Dialect Comparison Guide

This document summarizes key differences across the three major relational database dialects supported in **SQL Mastery**: **MySQL**, **PostgreSQL**, and **SQLite**.

---

## 1. Feature & Syntax Matrix

| Feature | MySQL | PostgreSQL | SQLite |
|---|---|---|---|
| **Auto-Increment PK** | `AUTO_INCREMENT` | `SERIAL` or `GENERATED ALWAYS AS IDENTITY` | `INTEGER PRIMARY KEY AUTOINCREMENT` |
| **String Concatenation** | `CONCAT(a, b)` | `a \|\| b` or `CONCAT(a, b)` | `a \|\| b` |
| **Limit / Offset** | `LIMIT n OFFSET m` | `LIMIT n OFFSET m` | `LIMIT n OFFSET m` |
| **Upsert (Insert/Update)** | `ON DUPLICATE KEY UPDATE` | `ON CONFLICT (...) DO UPDATE` | `ON CONFLICT (...) DO UPDATE` or `INSERT OR REPLACE` |
| **Boolean Type** | `TINYINT(1)` (alias `BOOLEAN`) | Native `BOOLEAN` (`TRUE`/`FALSE`) | `INTEGER` (`1`/`0`) |
| **ENUM Types** | Native inline `ENUM('a','b')` | Custom `CREATE TYPE ... AS ENUM` | `CHECK(col IN ('a','b'))` |
| **JSON Support** | `JSON` type, `->`, `->>` | `JSONB` type (indexed), `->`, `->>` | `JSON` type, `json_extract()` |
| **CTE (WITH RECURSIVE)** | Supported (MySQL 8.0+) | Supported | Supported |
| **Window Functions** | Supported (MySQL 8.0+) | Supported | Supported (SQLite 3.25+) |
| **Date Arithmetic (+30 Days)** | `DATE_ADD(d, INTERVAL 30 DAY)` | `d + INTERVAL '30 days'` | `date(d, '+30 days')` |
| **Date Difference (Days)** | `DATEDIFF(d1, d2)` | `d1::DATE - d2::DATE` | `CAST(julianday(d1) - julianday(d2) AS INT)` |
| **Regex Matching** | `val REGEXP 'pattern'` | `val ~ 'pattern'` (or `~*` for case-insensitive) | `val REGEXP 'pattern'` (requires regex hook) |
| **Recursive Cycle Prevention** | Path string concatenation / loop counter | Native `CYCLE` clause (PostgreSQL 14+) | Path string search (`INSTR`) / loop counter |

---

## 2. Practical Code Examples

### A. Auto Increment Primary Key

```sql
-- MySQL
CREATE TABLE tags (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50)
);

-- PostgreSQL
CREATE TABLE tags (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

-- SQLite
CREATE TABLE tags (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
);
```

### B. String Concatenation

```sql
-- MySQL
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM employees;

-- PostgreSQL
SELECT first_name || ' ' || last_name AS full_name FROM employees;

-- SQLite
SELECT first_name || ' ' || last_name AS full_name FROM employees;
```

### C. Pattern Matching & Case Sensitivity

```sql
-- MySQL (Default is case-insensitive depending on collation)
SELECT * FROM products WHERE product_name LIKE '%laptop%';

-- PostgreSQL (LIKE is case-sensitive, ILIKE is case-insensitive)
SELECT * FROM products WHERE product_name ILIKE '%laptop%';

-- SQLite (LIKE is case-insensitive for ASCII characters)
SELECT * FROM products WHERE product_name LIKE '%laptop%';
```

### D. Date Arithmetic & Days Difference

```sql
-- MySQL
SELECT 
    DATE_ADD(order_date, INTERVAL 30 DAY) AS return_deadline,
    DATEDIFF('2024-06-01', order_date) AS days_elapsed
FROM orders;

-- PostgreSQL
SELECT 
    order_date + INTERVAL '30 days' AS return_deadline,
    ('2024-06-01'::DATE - order_date::DATE) AS days_elapsed
FROM orders;

-- SQLite
SELECT 
    date(order_date, '+30 days') AS return_deadline,
    CAST(julianday('2024-06-01') - julianday(order_date) AS INTEGER) AS days_elapsed
FROM orders;
```

### E. Cycle / Loop Guard in Recursive CTEs

```sql
-- MySQL (Tracking visited path with string delimiter)
WITH RECURSIVE Traversal AS (
    SELECT id, parent_id, CONCAT('/', id, '/') AS path, 0 AS is_cycle
    FROM nodes WHERE parent_id IS NULL
    UNION ALL
    SELECT n.id, n.parent_id, CONCAT(t.path, n.id, '/'),
           CASE WHEN INSTR(t.path, CONCAT('/', n.id, '/')) > 0 THEN 1 ELSE 0 END
    FROM nodes n JOIN Traversal t ON n.parent_id = t.id
    WHERE t.is_cycle = 0
)
SELECT * FROM Traversal;

-- PostgreSQL 14+ (Standard ANSI SQL CYCLE clause)
WITH RECURSIVE Traversal AS (
    SELECT id, parent_id FROM nodes WHERE parent_id IS NULL
    UNION ALL
    SELECT n.id, n.parent_id FROM nodes n JOIN Traversal t ON n.parent_id = t.id
)
CYCLE id SET is_cycle USING path
SELECT * FROM Traversal;

-- SQLite (String path tracking via INSTR)
WITH RECURSIVE Traversal AS (
    SELECT id, parent_id, '/' || id || '/' AS path, 0 AS is_cycle
    FROM nodes WHERE parent_id IS NULL
    UNION ALL
    SELECT n.id, n.parent_id, t.path || n.id || '/',
           CASE WHEN INSTR(t.path, '/' || n.id || '/') > 0 THEN 1 ELSE 0 END
    FROM nodes n JOIN Traversal t ON n.parent_id = t.id
    WHERE t.is_cycle = 0
)
SELECT * FROM Traversal;
```

---

## 3. Recommended Dialect Selection

- **Use MySQL** when building traditional web apps (WordPress, PHP, Node.js stacks) or working with legacy enterprise systems.
- **Use PostgreSQL** when building modern cloud applications requiring strict data integrity, spatial data (PostGIS), JSON sub-document indexing, or complex analytics.
- **Use SQLite** for embedded apps, mobile applications (iOS/Android), local development, automated testing, and desktop software.


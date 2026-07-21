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

---

## 3. Recommended Dialect Selection

- **Use MySQL** when building traditional web apps (WordPress, PHP, Node.js stacks) or working with legacy enterprise systems.
- **Use PostgreSQL** when building modern cloud applications requiring strict data integrity, spatial data (PostGIS), JSON sub-document indexing, or complex analytics.
- **Use SQLite** for embedded apps, mobile applications (iOS/Android), local development, automated testing, and desktop software.

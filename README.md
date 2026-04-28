# SQL Mastery

Learn SQL from scratch using a structured, hands-on lesson path.

## Course Contents

| # | Lesson | Topics Covered |
|---|--------|----------------|
| 00 | [Setup Database](00_Setup_Database.sql) | Create clean schema and seed data for practice |
| 01 | [Introduction to SQL](01_Introduction_to_SQL.sql) | Databases, data types, CREATE TABLE, constraints, ALTER TABLE |
| 02 | [INSERT Data](02_INSERT_Data.sql) | Single/multi-row INSERT, INSERT SELECT, UPSERT patterns |
| 03 | [SELECT Queries](03_SELECT_Queries.sql) | SELECT, filtering, aliases, sorting, limits |
| 04 | [UPDATE & DELETE](04_UPDATE_DELETE.sql) | Data modifications, safe patterns, CASE updates |
| 05 | [WHERE Clause](05_WHERE_Clause.sql) | Filtering logic and condition building |
| 06 | [ORDER BY & LIMIT](06_ORDER_BY_LIMIT.sql) | Sorting and pagination |
| 07 | [Aggregate Functions](07_Aggregate_Functions.sql) | COUNT, SUM, AVG, MIN, MAX |
| 08 | [GROUP BY & HAVING](08_GROUP_BY_HAVING.sql) | Grouping rows and filtering grouped data |
| 09 | [JOINS](09_JOINS.sql) | INNER, LEFT, RIGHT, and join techniques |
| 10 | [Subqueries](10_Subqueries.sql) | Nested queries and correlated subqueries |
| 11 | [Functions](11_Functions.sql) | String, numeric, date, and conditional functions |
| 12 | [CASE Expressions](12_CASE_Expressions.sql) | Conditional output and computed categories |
| 13 | [Views](13_Views.sql) | Reusable query abstractions |
| 14 | [Indexes](14_Indexes.sql) | Indexing basics and performance concepts |
| 15 | [Constraints](15_Constraints.sql) | Data integrity rules and enforcement |
| 16 | [SQL Challenges](16_SQL_Challenges.sql) | Practice tasks for interview-style problem solving |
| 16A | [Challenge Answers](16_SQL_Challenges_Answers.sql) | Reference solutions for challenge tasks |
| 16B | [Extended Challenges](16_SQL_Challenges_Extended.sql) | 50+ problems organized by difficulty & real-world scenarios |
| 17 | [Advanced SQL](17_Advanced_SQL.sql) | CTEs, window functions, and transactions |
| 00R | [Reset Database](00_Reset_Database.sql) | Quickly reset environment before rerunning lessons |

## Getting Started

### Prerequisites
- MySQL Server (recommended)
- Any SQL client: MySQL Workbench, DBeaver, VS Code extension, or MySQL CLI

### Suggested Flow
1. Run [00_Setup_Database.sql](00_Setup_Database.sql)
2. Complete lessons in numeric order from [01_Introduction_to_SQL.sql](01_Introduction_to_SQL.sql) to [17_Advanced_SQL.sql](17_Advanced_SQL.sql)
3. Solve [16_SQL_Challenges.sql](16_SQL_Challenges.sql)
4. Check with [16_SQL_Challenges_Answers.sql](16_SQL_Challenges_Answers.sql)
5. Use [00_Reset_Database.sql](00_Reset_Database.sql) whenever you want a fresh start

## What Makes This Repo Useful

- Lesson-by-lesson progression from basics to intermediate SQL
- Practice-first design with exercises and reference solutions
- Re-runnable setup and reset scripts for clean experimentation
- Realistic sample data across employees, products, and orders tables

## Best Practices

1. Always run SELECT before destructive UPDATE/DELETE statements.
2. Use transactions for important data changes.
3. Prefer explicit column lists over SELECT * in production queries.
4. Add indexes only after identifying query bottlenecks.
5. Keep constraints strong to protect data quality.

## Contributing

Contributions are welcome: more exercises, additional datasets, query optimizations, and clearer explanations.

## License

MIT. See [LICENSE](LICENSE).

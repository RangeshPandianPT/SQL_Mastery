#!/usr/bin/env python3
"""
SQL Mastery - Automated Challenge Test Runner
Validates all SQL challenge queries against an in-memory database instance.
"""

import sqlite3
import sys
import os

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, '..'))
SETUP_SQL = os.path.join(REPO_ROOT, '00_Setup_Database_SQLite.sql')

TEST_QUERIES = [
    ("Challenge 1: Active Employees by Salary",
     "SELECT employee_id, first_name, last_name, department, salary FROM employees WHERE is_active = 1 ORDER BY salary DESC;",
     4),
    ("Challenge 2: Hired in 2024 with Salary 60k-80k",
     "SELECT first_name, last_name, hire_date, salary FROM employees WHERE hire_date BETWEEN '2024-01-01' AND '2024-12-31' AND salary BETWEEN 60000 AND 80000;",
     3),
    ("Challenge 3: Product Stock Categorization",
     "SELECT product_name, stock_quantity, CASE WHEN stock_quantity < 50 THEN 'Low' WHEN stock_quantity BETWEEN 50 AND 150 THEN 'Medium' ELSE 'High' END AS stock_label FROM products;",
     8),
    ("Challenge 4: Total Revenue by Order Status",
     "SELECT status, SUM(total_amount) AS total_revenue FROM orders GROUP BY status ORDER BY total_revenue DESC;",
     5),
    ("Challenge 5: Top 3 Spending Customers",
     "SELECT customer_name, SUM(total_amount) AS total_spent FROM orders GROUP BY customer_name ORDER BY total_spent DESC LIMIT 3;",
     3),
    ("Challenge 6: Products Never Ordered",
     "SELECT p.product_id, p.product_name FROM products p LEFT JOIN orders o ON p.product_id = o.product_id WHERE o.order_id IS NULL;",
     1),
    ("Challenge 7: Avg Salary by Department >= 65k",
     "SELECT department, AVG(salary) AS avg_salary FROM employees WHERE department IS NOT NULL GROUP BY department HAVING AVG(salary) >= 65000;",
     2),
    ("Challenge 8: Order Details with Computed Total",
     "SELECT o.order_id, o.customer_name, p.product_name, o.quantity, o.quantity * p.price AS computed_total FROM orders o JOIN products p ON o.product_id = p.product_id;",
     8),
    ("Challenge 9: View High Value Orders",
     "CREATE VIEW IF NOT EXISTS high_value_orders AS SELECT * FROM orders WHERE total_amount >= 500; SELECT * FROM high_value_orders;",
     2),
    ("Challenge 10: Create Table Index",
     "CREATE INDEX IF NOT EXISTS idx_orders_status_date ON orders(status, order_date); SELECT count(*) FROM sqlite_master WHERE type='index' AND name='idx_orders_status_date';",
     1)
]

def run_tests():
    print("=" * 60)
    print("      SQL MASTERY - AUTOMATED CHALLENGE TEST RUNNER")
    print("=" * 60)

    if not os.path.exists(SETUP_SQL):
        print(f"ERROR: Setup script not found at {SETUP_SQL}")
        sys.exit(1)

    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()

    with open(SETUP_SQL, 'r', encoding='utf-8') as f:
        setup_script = f.read()

    try:
        cursor.executescript(setup_script)
        print("[OK] Environment initialized with 00_Setup_Database_SQLite.sql\n")
    except Exception as e:
        print(f"[FAIL] Failed to initialize database: {e}")
        sys.exit(1)

    passed = 0
    failed = 0

    for name, query, expected_min_rows in TEST_QUERIES:
        try:
            statements = [s.strip() for s in query.split(';') if s.strip()]
            rows = []
            for stmt in statements:
                res = cursor.execute(stmt)
                if stmt.upper().startswith("SELECT"):
                    rows = res.fetchall()

            if len(rows) >= expected_min_rows:
                print(f"[PASS] {name} -> Returned {len(rows)} rows (Expected >= {expected_min_rows})")
                passed += 1
            else:
                print(f"[FAIL] {name} -> Returned {len(rows)} rows, expected at least {expected_min_rows}")
                failed += 1
        except Exception as e:
            print(f"[ERROR] {name} failed with error: {e}")
            failed += 1

    print("\n" + "=" * 60)
    print(f"RESULTS: {passed} PASSED, {failed} FAILED out of {len(TEST_QUERIES)} tests.")
    print("=" * 60)

    conn.close()
    if failed > 0:
        sys.exit(1)

if __name__ == '__main__':
    run_tests()

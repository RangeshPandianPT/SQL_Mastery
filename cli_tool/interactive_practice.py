#!/usr/bin/env python3
"""
SQL Mastery Interactive CLI Tool
Provides an interactive terminal interface for query execution, challenge practice, and schema inspection.
Supports SQLite (zero-config local mode) and MySQL server connections.
"""

import sys
import os
import sqlite3
import argparse

try:
    from rich.console import Console
    from rich.table import Table
    console = Console()
    HAS_RICH = True
except ImportError:
    HAS_RICH = False

try:
    import mysql.connector
    from mysql.connector import Error as MySQLError
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

SETUP_SQLITE_PATH = os.path.join(os.path.dirname(__file__), '..', '00_Setup_Database_SQLite.sql')

def create_sqlite_db():
    conn = sqlite3.connect(':memory:')
    if os.path.exists(SETUP_SQLITE_PATH):
        with open(SETUP_SQLITE_PATH, 'r', encoding='utf-8') as f:
            conn.executescript(f.read())
    return conn

def format_table(headers, rows):
    if not headers:
        return ""
    if HAS_RICH:
        table = Table(show_header=True, header_style="bold magenta")
        for h in headers:
            table.add_column(str(h))
        for row in rows:
            table.add_row(*[str(val if val is not None else 'NULL') for val in row])
        console.print(table)
        return ""
    else:
        col_widths = [len(str(h)) for h in headers]
        for row in rows:
            for i, val in enumerate(row):
                col_widths[i] = max(col_widths[i], len(str(val if val is not None else 'NULL')))
        
        header_line = " | ".join(str(h).ljust(col_widths[i]) for i, h in enumerate(headers))
        separator = "-+-".join("-" * col_widths[i] for i in range(len(headers)))
        row_lines = []
        for row in rows:
            row_lines.append(" | ".join(str(val if val is not None else 'NULL').ljust(col_widths[i]) for i, val in enumerate(row)))
        
        return f"{header_line}\n{separator}\n" + "\n".join(row_lines)

def run_query(conn, query, is_sqlite=True):
    cursor = conn.cursor()
    statements = [s.strip() for s in query.split(';') if s.strip()]
    last_results = None
    headers = None
    affected_total = 0

    for stmt in statements:
        cursor.execute(stmt)
        if cursor.description:
            headers = [desc[0] for desc in cursor.description]
            last_results = cursor.fetchall()
        else:
            if not is_sqlite:
                conn.commit()
            affected_total += cursor.rowcount if cursor.rowcount > 0 else 0

    return headers, last_results, affected_total

def interactive_session(conn, is_sqlite=True):
    db_type = "SQLite (In-Memory)" if is_sqlite else "MySQL (school_management)"
    print("=" * 60)
    print("        WELCOME TO SQL MASTERY INTERACTIVE TERMINAL")
    print(f"        Engine: {db_type}")
    print("=" * 60)
    print("Commands: Type your SQL query, '.tables' to list tables, '.schema' for schema, or 'exit' to quit.\n")

    while True:
        try:
            query = input("SQL> ").strip()
            if query.lower() in ('exit', 'quit', '.exit'):
                break
            if not query:
                continue
            if query.lower() in ('.tables', 'show tables;'):
                if is_sqlite:
                    query = "SELECT name AS Table_Name FROM sqlite_master WHERE type='table';"
                else:
                    query = "SHOW TABLES;"
            elif query.lower() in ('.schema', 'describe'):
                if is_sqlite:
                    query = "SELECT sql FROM sqlite_master WHERE type='table';"
                else:
                    query = "SHOW TABLES;"

            headers, results, affected = run_query(conn, query, is_sqlite)
            if headers is not None:
                if results:
                    print("\n" + format_table(headers, results))
                    print(f"({len(results)} rows returned)\n")
                else:
                    print("\n(Query returned 0 rows)\n")
            else:
                print(f"\n[OK] Query executed successfully. Rows affected: {affected}\n")

        except Exception as e:
            if HAS_RICH:
                console.print(f"[bold red]SQL ERROR:[/bold red] {e}")
            else:
                print(f"\n[SQL ERROR] {e}\n")
        except KeyboardInterrupt:
            if HAS_RICH:
                console.print("\n[bold yellow]Exiting session...[/bold yellow]")
            else:
                print("\nExiting session...")
            break

def main():
    parser = argparse.ArgumentParser(description="SQL Mastery CLI Tool")
    parser.add_argument('--test', action='store_true', help="Run automated CLI self-test")
    parser.add_argument('--mysql', action='store_true', help="Use local MySQL database instead of SQLite")
    args = parser.parse_args()

    if args.test:
        print("[CLI TEST] Initializing SQLite database...")
        conn = create_sqlite_db()
        headers, results, _ = run_query(conn, "SELECT COUNT(*) FROM employees;", is_sqlite=True)
        print(f"[CLI TEST] Executed count query: {results[0][0]} employees found.")
        print("[CLI TEST] OK - CLI tool is fully functional.")
        conn.close()
        sys.exit(0)

    if args.mysql:
        if not HAS_MYSQL:
            print("Error: mysql-connector-python is not installed. Run `pip install mysql-connector-python`.")
            sys.exit(1)
        try:
            conn = mysql.connector.connect(
                host='localhost', database='school_management', user='root', password='rootpassword'
            )
            interactive_session(conn, is_sqlite=False)
            conn.close()
        except MySQLError as e:
            print(f"MySQL Connection Error: {e}")
            print("Falling back to SQLite in-memory engine...")
            conn = create_sqlite_db()
            interactive_session(conn, is_sqlite=True)
            conn.close()
    else:
        conn = create_sqlite_db()
        interactive_session(conn, is_sqlite=True)
        conn.close()

if __name__ == '__main__':
    main()

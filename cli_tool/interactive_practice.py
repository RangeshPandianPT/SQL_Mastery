import mysql.connector
from mysql.connector import Error
import sys

def connect():
    try:
        return mysql.connector.connect(
            host='localhost',
            database='school_management',
            user='root',
            password='rootpassword'
        )
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None

def main():
    print("Welcome to the SQL Mastery Interactive CLI!")
    print("Type your SQL query and press Enter to execute. Type 'exit' to quit.\n")
    
    conn = connect()
    if not conn:
        sys.exit(1)
        
    cursor = conn.cursor()
    
    while True:
        try:
            query = input("SQL> ")
            if query.lower().strip() in ('exit', 'quit'):
                break
            if not query.strip():
                continue
                
            cursor.execute(query)
            
            if query.lower().strip().startswith("select") or query.lower().strip().startswith("show"):
                results = cursor.fetchall()
                if cursor.description:
                    columns = [desc[0] for desc in cursor.description]
                    print(" | ".join(columns))
                    print("-" * 50)
                    for row in results:
                        print(" | ".join(str(val) for val in row))
                print(f"({len(results)} rows returned)\n")
            else:
                conn.commit()
                print(f"Query executed successfully. {cursor.rowcount} rows affected.\n")
                
        except Error as e:
            print(f"SQL Error: {e}\n")
        except KeyboardInterrupt:
            print("\nExiting...")
            break
            
    cursor.close()
    conn.close()
    print("Goodbye!")

if __name__ == "__main__":
    main()

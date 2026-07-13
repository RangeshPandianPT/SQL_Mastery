import mysql.connector
from mysql.connector import Error

def create_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database='school_management',
            user='root',
            password='rootpassword'
        )
        if connection.is_connected():
            print("Successfully connected to MySQL database")
            return connection
    except Error as e:
        print(f"Error while connecting to MySQL: {e}")
    return None

def fetch_top_teachers(connection):
    cursor = connection.cursor(dictionary=True)
    try:
        query = "SELECT first_name, last_name, subject, salary FROM teachers ORDER BY salary DESC LIMIT 5;"
        cursor.execute(query)
        records = cursor.fetchall()
        print("\n--- Top 5 Paid Teachers ---")
        for row in records:
            print(f"{row['first_name']} {row['last_name']} ({row['subject']}) - ${row['salary']}")
    except Error as e:
        print(f"Failed to read data from table: {e}")
    finally:
        if cursor:
            cursor.close()

if __name__ == '__main__':
    conn = create_connection()
    if conn:
        fetch_top_teachers(conn)
        conn.close()
        print("\nMySQL connection is closed")

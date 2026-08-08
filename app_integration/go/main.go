package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "github.com/go-sql-driver/mysql"
)

func main() {
	// Connect to MySQL Database
	// Format: username:password@protocol(address)/dbname
	dsn := "root:rootpassword@tcp(127.0.0.1:3306)/school_management"
	
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("Error connecting to database: %v", err)
	}
	defer db.Close()

	// Verify connection
	err = db.Ping()
	if err != nil {
		log.Fatalf("Error pinging database: %v", err)
	}

	fmt.Println("Successfully connected to MySQL database!")

	// Execute a query
	rows, err := db.Query("SELECT employee_id, first_name, last_name FROM employees LIMIT 5")
	if err != nil {
		log.Fatalf("Error executing query: %v", err)
	}
	defer rows.Close()

	fmt.Println("\nEmployee List:")
	fmt.Println("ID | Name")
	fmt.Println("-----------")

	for rows.Next() {
		var id int
		var firstName, lastName string
		
		if err := rows.Scan(&id, &firstName, &lastName); err != nil {
			log.Fatalf("Error scanning row: %v", err)
		}
		
		fmt.Printf("%d | %s %s\n", id, firstName, lastName)
	}

	if err := rows.Err(); err != nil {
		log.Fatalf("Row iteration error: %v", err)
	}
}

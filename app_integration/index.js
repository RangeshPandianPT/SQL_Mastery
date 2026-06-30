/**
 * SQL MASTERY - APPLICATION INTEGRATION DEMO
 * 
 * This file demonstrates how to connect to a MySQL database from a Node.js backend.
 * We use the `mysql2` package for better performance and Promise support.
 */

const mysql = require('mysql2/promise');

// 1. Create a connection pool instead of a single connection.
// Connection pools automatically manage multiple connections, which is essential for web apps.
const pool = mysql.createPool({
    host: 'localhost',
    user: 'root',         // Change to your MySQL username
    password: 'password', // Change to your MySQL password
    database: 'school_management',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

async function main() {
    try {
        console.log('Connecting to the database...\n');

        // ==========================================
        // EXAMPLE 1: Simple SELECT Query
        // ==========================================
        console.log('--- Example 1: Fetching all active employees ---');
        
        // Destructure rows from the result
        const [employees] = await pool.query(
            'SELECT employee_id, first_name, last_name, department FROM employees WHERE is_active = TRUE'
        );
        
        console.table(employees);

        // ==========================================
        // EXAMPLE 2: Parameterized Query (Prevent SQL Injection)
        // ==========================================
        console.log('\n--- Example 2: Parameterized query for products in a category ---');
        
        const categoryFilter = 'Electronics';
        // NEVER concatenate user input into the SQL string. 
        // Always use '?' and pass variables in an array.
        const [products] = await pool.execute(
            'SELECT product_name, price FROM products WHERE category = ?', 
            [categoryFilter]
        );
        
        console.table(products);

        // ==========================================
        // EXAMPLE 3: Executing a Stored Procedure
        // ==========================================
        console.log('\n--- Example 3: Calling a Stored Procedure ---');
        // Requires Lesson 18 to have been executed
        try {
            const [procResult] = await pool.execute('CALL GetEmployeesByDept(?)', ['Engineering']);
            // Stored procedure results are returned as an array of result sets
            console.table(procResult[0]);
        } catch (err) {
            console.log('(Stored procedure GetEmployeesByDept not found. Make sure to run 18_Stored_Procedures.sql)');
        }

    } catch (error) {
        console.error('Database Error:', error);
    } finally {
        // Always close the pool when the application shuts down
        await pool.end();
        console.log('\nDatabase connection closed.');
    }
}

// Run the demo
main();

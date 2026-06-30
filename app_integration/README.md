# Application Integration Demo

This folder contains a simple Node.js script demonstrating how to connect to the `school_management` database from a backend application.

## Prerequisites
- Node.js installed
- MySQL Server running on localhost (or update the credentials in `index.js`)
- The `school_management` database must be created (Run `00_Setup_Database.sql`)

## How to run

1. Open a terminal in this `app_integration` directory.
2. Install the MySQL driver dependency:
   ```bash
   npm install
   ```
3. Open `index.js` and update your database credentials if necessary:
   ```javascript
   user: 'root',         // Change to your MySQL username
   password: 'password', // Change to your MySQL password
   ```
4. Run the demo script:
   ```bash
   npm start
   ```

## What you will learn
- How to create a **connection pool** for better performance.
- How to write **parameterized queries** to prevent SQL Injection.
- How to call **Stored Procedures** from backend code.

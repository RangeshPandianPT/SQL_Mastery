# Java JDBC Integration Example

This example demonstrates how to connect to the `school_management` MySQL database using standard Java JDBC.

## Setup

1. Make sure your MySQL database is running (you can use the docker-compose from the root directory).
2. You need Maven and JDK 11+ installed.
3. Build the project:
   ```bash
   mvn clean compile
   ```
4. Run the app:
   ```bash
   mvn exec:java -Dexec.mainClass="com.sqlmastery.App"
   ```

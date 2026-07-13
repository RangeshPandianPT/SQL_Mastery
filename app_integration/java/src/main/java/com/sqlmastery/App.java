package com.sqlmastery;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;

public class App {
    private static final String URL = "jdbc:mysql://localhost:3306/school_management";
    private static final String USER = "root";
    private static final String PASSWORD = "rootpassword";

    public static void main(String[] args) {
        try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
            System.out.println("Connected to the MySQL server successfully.");
            
            Statement stmt = conn.createStatement();
            String query = "SELECT first_name, last_name, subject, salary FROM teachers ORDER BY salary DESC LIMIT 5";
            ResultSet rs = stmt.executeQuery(query);
            
            System.out.println("\n--- Top 5 Paid Teachers ---");
            while (rs.next()) {
                System.out.printf("%s %s (%s) - $%.2f%n", 
                    rs.getString("first_name"), 
                    rs.getString("last_name"), 
                    rs.getString("subject"), 
                    rs.getDouble("salary"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

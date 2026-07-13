/*
  Lesson 32: Geospatial Data
  Modern databases support spatial data types (Points, Lines, Polygons) and 
  functions to perform geographic calculations, like finding distances between coordinates.
*/

USE school_management;

-- Create a table for store locations using the POINT data type
CREATE TABLE store_locations (
    store_id INT AUTO_INCREMENT PRIMARY KEY,
    store_name VARCHAR(100),
    coordinates POINT NOT NULL SRID 4326, -- SRID 4326 represents GPS coordinates (Longitude, Latitude)
    SPATIAL INDEX(coordinates)
);

-- Insert spatial data using the ST_GeomFromText function
-- Note: Coordinate order is typically (Longitude, Latitude)
INSERT INTO store_locations (store_name, coordinates) VALUES 
('Downtown Store', ST_GeomFromText('POINT(-73.9851 40.7589)', 4326)), -- Times Square, NY
('Uptown Store', ST_GeomFromText('POINT(-73.9654 40.7829)', 4326)),   -- Central Park, NY
('Brooklyn Store', ST_GeomFromText('POINT(-73.9442 40.6782)', 4326));  -- Brooklyn, NY

-- Calculate distance between two stores (Result is in meters if using SRID 4326 correctly in newer MySQL versions)
-- We will calculate the distance from a user's location (e.g., -73.97, 40.76) to all stores
SET @user_location = ST_GeomFromText('POINT(-73.9700 40.7600)', 4326);

SELECT 
    store_name,
    ST_Distance_Sphere(coordinates, @user_location) AS distance_in_meters
FROM 
    store_locations
ORDER BY 
    distance_in_meters ASC;

-- Cleanup
DROP TABLE store_locations;

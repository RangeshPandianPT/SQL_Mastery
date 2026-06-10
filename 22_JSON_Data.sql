-- ============================================
-- SQL MASTERY - 22 JSON DATA
-- ============================================
-- Topics:
-- 1) JSON Data Type
-- 2) Inserting JSON Data
-- 3) Extracting Data from JSON (-> and ->>)
-- 4) Modifying JSON
-- ============================================

USE school_management;

-- ============================================
-- SETUP: Create a Table with a JSON Column
-- ============================================

CREATE TABLE IF NOT EXISTS user_profiles (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    preferences JSON -- The JSON column
);

-- ============================================
-- PART 1: INSERTING JSON DATA
-- ============================================

INSERT INTO user_profiles (username, preferences)
VALUES 
(
    'alice_smith', 
    '{"theme": "dark", "notifications": {"email": true, "sms": false}, "language": "en"}'
),
(
    'bob_jones', 
    '{"theme": "light", "notifications": {"email": false, "sms": true}, "language": "es"}'
);

-- Viewing the raw JSON
SELECT * FROM user_profiles;


-- ============================================
-- PART 2: EXTRACTING JSON DATA
-- ============================================

-- The -> operator extracts the JSON object/value (includes quotes for strings)
-- The ->> operator extracts and unquotes the scalar value

-- Extract top-level properties
SELECT 
    username,
    preferences->>'$.theme' AS theme_preference,
    preferences->>'$.language' AS app_language
FROM user_profiles;

-- Extract nested properties
SELECT 
    username,
    preferences->>'$.notifications.email' AS gets_emails,
    preferences->>'$.notifications.sms' AS gets_sms
FROM user_profiles;

-- Filtering based on JSON values
SELECT username 
FROM user_profiles 
WHERE preferences->>'$.theme' = 'dark';


-- ============================================
-- PART 3: MODIFYING JSON DATA
-- ============================================

-- JSON_SET: Updates existing values or inserts new ones
UPDATE user_profiles
SET preferences = JSON_SET(preferences, '$.theme', 'system', '$.timezone', 'EST')
WHERE username = 'alice_smith';

SELECT preferences FROM user_profiles WHERE username = 'alice_smith';

-- JSON_REPLACE: Only updates existing values (does not insert new ones)
-- JSON_REMOVE: Removes a property from the JSON document
UPDATE user_profiles
SET preferences = JSON_REMOVE(preferences, '$.language')
WHERE username = 'bob_jones';


-- ============================================
-- PRACTICE TASKS
-- ============================================
/*
Task 1:
Insert a new user into `user_profiles` with a JSON object containing an array of "roles": 
{"roles": ["admin", "editor"]}

Task 2:
Write a SELECT query to extract the first role from the roles array for the new user.
(Hint: Use $.roles[0])

Task 3:
Update the new user to change the first role from "admin" to "superadmin" using JSON_SET.
*/

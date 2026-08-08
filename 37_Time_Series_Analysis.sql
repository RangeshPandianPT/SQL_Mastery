/*
  Lesson 37: Time-Series Analysis & Sessionization
  
  Dealing with time-series data often requires grouping events into "sessions"
  based on inactivity thresholds.
*/

-- 1. Setup Sample Data for User Activity Logs
CREATE TABLE IF NOT EXISTS user_activity (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(50),
    timestamp DATETIME
);

INSERT INTO user_activity (user_id, action, timestamp) VALUES
(1, 'login', '2023-12-01 08:00:00'),
(1, 'view_page', '2023-12-01 08:05:00'),
(1, 'click_button', '2023-12-01 08:15:00'),
-- 2 hours later (New Session)
(1, 'view_page', '2023-12-01 10:30:00'), 
(1, 'logout', '2023-12-01 10:35:00'),
(2, 'login', '2023-12-01 09:00:00');

-- 2. Sessionization (Grouping actions into sessions if gap > 30 mins)
WITH TimeDifferences AS (
    SELECT 
        user_id,
        action,
        timestamp,
        LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) as prev_timestamp
    FROM user_activity
),
SessionFlags AS (
    SELECT 
        user_id,
        action,
        timestamp,
        prev_timestamp,
        -- Flag as 1 if new session (gap > 30 mins or first action)
        CASE 
            WHEN prev_timestamp IS NULL THEN 1 
            WHEN TIMESTAMPDIFF(MINUTE, prev_timestamp, timestamp) > 30 THEN 1 
            ELSE 0 
        END as is_new_session
    FROM TimeDifferences
),
SessionIDs AS (
    SELECT 
        user_id,
        action,
        timestamp,
        -- Cumulative sum of flags gives a unique session ID per user
        SUM(is_new_session) OVER (PARTITION BY user_id ORDER BY timestamp) as session_id
    FROM SessionFlags
)
SELECT * FROM SessionIDs;

-- 3. Calculate Session Duration
WITH SessionIDs AS (
    SELECT 
        user_id,
        timestamp,
        SUM(CASE 
            WHEN TIMESTAMPDIFF(MINUTE, 
                LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp), 
                timestamp) > 30 THEN 1 
            WHEN LAG(timestamp) OVER (PARTITION BY user_id ORDER BY timestamp) IS NULL THEN 1 
            ELSE 0 
        END) OVER (PARTITION BY user_id ORDER BY timestamp) as session_id
    FROM user_activity
)
SELECT 
    user_id,
    session_id,
    MIN(timestamp) as session_start,
    MAX(timestamp) as session_end,
    TIMESTAMPDIFF(MINUTE, MIN(timestamp), MAX(timestamp)) as session_duration_minutes
FROM SessionIDs
GROUP BY user_id, session_id;

-- Cleanup
DROP TABLE user_activity;

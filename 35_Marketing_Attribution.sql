/*
  Lesson 35: Marketing Attribution Models
  
  Attribution models help marketers understand which channels (e.g., Email, Ads, Organic) 
  are driving conversions. In SQL, we use Window Functions and subqueries to calculate this.
*/

-- 1. Setup Sample Data for Marketing Touches
CREATE TABLE IF NOT EXISTS marketing_touches (
    touch_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    channel VARCHAR(50),
    touch_date DATETIME,
    is_conversion BOOLEAN
);

INSERT INTO marketing_touches (customer_id, channel, touch_date, is_conversion) VALUES
(1, 'Facebook Ads', '2023-10-01 10:00:00', FALSE),
(1, 'Email Campaign', '2023-10-03 14:00:00', FALSE),
(1, 'Organic Search', '2023-10-05 09:30:00', TRUE),
(2, 'Google Ads', '2023-10-02 11:00:00', FALSE),
(2, 'Google Ads', '2023-10-04 15:00:00', TRUE),
(3, 'Organic Search', '2023-10-01 08:00:00', TRUE);

-- 2. First-Touch Attribution (The first channel the user interacted with gets 100% credit)
WITH RankedTouches AS (
    SELECT 
        customer_id, 
        channel, 
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY touch_date ASC) as touch_rank
    FROM marketing_touches
)
SELECT 
    channel, 
    COUNT(DISTINCT customer_id) as first_touch_conversions
FROM RankedTouches
WHERE touch_rank = 1
GROUP BY channel;

-- 3. Last-Touch Attribution (The last channel before conversion gets 100% credit)
WITH RankedTouches AS (
    SELECT 
        customer_id, 
        channel, 
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY touch_date DESC) as touch_rank
    FROM marketing_touches
)
SELECT 
    channel, 
    COUNT(DISTINCT customer_id) as last_touch_conversions
FROM RankedTouches
WHERE touch_rank = 1
GROUP BY channel;

-- 4. Linear Multi-Touch Attribution (Credit is split evenly across all touches)
WITH CustomerTouches AS (
    SELECT 
        customer_id, 
        COUNT(*) as total_touches
    FROM marketing_touches
    GROUP BY customer_id
),
TouchWeights AS (
    SELECT 
        mt.customer_id, 
        mt.channel, 
        1.0 / ct.total_touches as fractional_credit
    FROM marketing_touches mt
    JOIN CustomerTouches ct ON mt.customer_id = ct.customer_id
)
SELECT 
    channel, 
    SUM(fractional_credit) as linear_attribution_score
FROM TouchWeights
GROUP BY channel;

-- Cleanup
DROP TABLE marketing_touches;

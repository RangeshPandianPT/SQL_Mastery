/*
  Lesson 36: Financial Analytics
  
  SQL is heavily used in finance to calculate moving averages, compound interest, 
  and running totals to analyze revenue, stock prices, or bank balances.
*/

-- 1. Setup Sample Data for Daily Revenue
CREATE TABLE IF NOT EXISTS daily_revenue (
    date DATE PRIMARY KEY,
    revenue DECIMAL(10, 2)
);

INSERT INTO daily_revenue (date, revenue) VALUES
('2023-11-01', 1000.00),
('2023-11-02', 1200.00),
('2023-11-03', 900.00),
('2023-11-04', 1500.00),
('2023-11-05', 1300.00),
('2023-11-06', 1600.00),
('2023-11-07', 1800.00);

-- 2. Calculating a Running Total (Cumulative Revenue)
SELECT 
    date,
    revenue,
    SUM(revenue) OVER (ORDER BY date) AS cumulative_revenue
FROM daily_revenue;

-- 3. Calculating a 3-Day Moving Average
-- Useful for smoothing out volatility in data like stock prices or sales.
SELECT 
    date,
    revenue,
    AVG(revenue) OVER (
        ORDER BY date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS moving_avg_3day
FROM daily_revenue;

-- 4. Calculating Month-over-Month (MoM) or Day-over-Day Growth
WITH PreviousDayData AS (
    SELECT 
        date,
        revenue,
        LAG(revenue) OVER (ORDER BY date) as previous_day_revenue
    FROM daily_revenue
)
SELECT 
    date,
    revenue,
    previous_day_revenue,
    (revenue - previous_day_revenue) / previous_day_revenue * 100 AS growth_percentage
FROM PreviousDayData
WHERE previous_day_revenue IS NOT NULL;

-- Cleanup
DROP TABLE daily_revenue;

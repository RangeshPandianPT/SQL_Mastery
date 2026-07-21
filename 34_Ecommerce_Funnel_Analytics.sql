-- ============================================
-- LESSON 34: E-Commerce Conversion Funnels & Basket Analysis
-- ============================================
-- Topics Covered:
-- 1. Multi-step Conversion Funnel Analysis
-- 2. Checkout Abandonment & Drop-off Rates
-- 3. Market Basket Analysis (Products Frequently Bought Together)
-- 4. Customer Repeat Purchase Rate & Time to Second Purchase
-- ============================================

DROP TABLE IF EXISTS user_events;
DROP TABLE IF EXISTS order_items;

CREATE TABLE user_events (
    event_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    session_id VARCHAR(50) NOT NULL,
    event_type VARCHAR(30) NOT NULL, -- page_view, view_product, add_to_cart, checkout, purchase
    event_time DATETIME NOT NULL
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (order_id, product_id)
);

-- Seed Data
INSERT INTO user_events (user_id, session_id, event_type, event_time) VALUES
(101, 'sess_1', 'page_view', '2024-03-01 10:00:00'),
(101, 'sess_1', 'view_product', '2024-03-01 10:02:00'),
(101, 'sess_1', 'add_to_cart', '2024-03-01 10:05:00'),
(101, 'sess_1', 'checkout', '2024-03-01 10:08:00'),
(101, 'sess_1', 'purchase', '2024-03-01 10:10:00'),

(102, 'sess_2', 'page_view', '2024-03-01 11:00:00'),
(102, 'sess_2', 'view_product', '2024-03-01 11:03:00'),
(102, 'sess_2', 'add_to_cart', '2024-03-01 11:06:00'),
(102, 'sess_2', 'checkout', '2024-03-01 11:09:00'), -- Abandoned checkout

(103, 'sess_3', 'page_view', '2024-03-01 12:00:00'),
(103, 'sess_3', 'view_product', '2024-03-01 12:05:00'), -- Abandoned product view

(104, 'sess_4', 'page_view', '2024-03-01 13:00:00'),
(104, 'sess_4', 'view_product', '2024-03-01 13:02:00'),
(104, 'sess_4', 'add_to_cart', '2024-03-01 13:05:00'),
(104, 'sess_4', 'checkout', '2024-03-01 13:08:00'),
(104, 'sess_4', 'purchase', '2024-03-01 13:12:00');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1299.99), -- Laptop
(1, 2, 1, 29.99),   -- Mouse
(2, 2, 2, 29.99),   -- Mouse
(2, 4, 1, 89.99),   -- Keyboard
(3, 1, 1, 1299.99), -- Laptop
(3, 2, 1, 29.99),   -- Mouse
(3, 3, 1, 49.99);   -- USB-C Hub

-- ============================================
-- QUERY 1: Conversion Funnel Stage Analysis
-- ============================================
WITH FunnelStages AS (
    SELECT
        COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN session_id END) AS step_1_views,
        COUNT(DISTINCT CASE WHEN event_type = 'view_product' THEN session_id END) AS step_2_product_views,
        COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN session_id END) AS step_3_cart_adds,
        COUNT(DISTINCT CASE WHEN event_type = 'checkout' THEN session_id END) AS step_4_checkouts,
        COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN session_id END) AS step_5_purchases
    FROM user_events
)
SELECT 
    step_1_views,
    step_2_product_views,
    ROUND((step_2_product_views * 100.0) / step_1_views, 2) AS view_to_product_pct,
    step_3_cart_adds,
    ROUND((step_3_cart_adds * 100.0) / step_2_product_views, 2) AS product_to_cart_pct,
    step_4_checkouts,
    ROUND((step_4_checkouts * 100.0) / step_3_cart_adds, 2) AS cart_to_checkout_pct,
    step_5_purchases,
    ROUND((step_5_purchases * 100.0) / step_4_checkouts, 2) AS checkout_conversion_pct
FROM FunnelStages;

-- ============================================
-- QUERY 2: Market Basket Analysis (Cross-Selling Pairs)
-- ============================================
-- Find products frequently purchased together in the same order
SELECT 
    p1.product_id AS product_a,
    p2.product_id AS product_b,
    COUNT(*) AS times_bought_together
FROM order_items p1
JOIN order_items p2 ON p1.order_id = p2.order_id AND p1.product_id < p2.product_id
GROUP BY p1.product_id, p2.product_id
ORDER BY times_bought_together DESC;

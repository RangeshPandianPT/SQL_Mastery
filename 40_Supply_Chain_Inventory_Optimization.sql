-- ============================================
-- LESSON 40: Supply Chain Analytics & Inventory Optimization
-- ============================================
-- Topics Covered:
-- 1. Daily Demand Rate & Lead Time Variability
-- 2. Dynamic Safety Stock & Reorder Point (ROP)
-- 3. Economic Order Quantity (EOQ) in SQL
-- 4. ABC Inventory Classification (Pareto 80/20 Rule)
-- 5. Days of Inventory on Hand (DOH) & Stockout Run-Out Projections
-- ============================================

DROP TABLE IF EXISTS inventory_stock;
DROP TABLE IF EXISTS daily_shipments;

-- 1. Setup Practice Schema
CREATE TABLE inventory_stock (
    sku VARCHAR(20) PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    current_on_hand INT NOT NULL,
    unit_cost DECIMAL(10, 2) NOT NULL,
    order_cost DECIMAL(10, 2) NOT NULL,       -- Fixed cost to place one replenishment order (S)
    annual_holding_cost_rate DECIMAL(4, 2) NOT NULL, -- E.g. 0.20 = 20% holding cost per year
    supplier_lead_time_days INT NOT NULL,     -- Average days for supplier delivery (L)
    max_lead_time_days INT NOT NULL           -- Max possible days for supplier delivery
);

CREATE TABLE daily_shipments (
    shipment_id INT PRIMARY KEY AUTO_INCREMENT,
    sku VARCHAR(20) NOT NULL,
    ship_date DATE NOT NULL,
    units_sold INT NOT NULL
);

-- Seed Data
INSERT INTO inventory_stock (sku, product_name, category, current_on_hand, unit_cost, order_cost, annual_holding_cost_rate, supplier_lead_time_days, max_lead_time_days) VALUES
('SKU-101', 'Wireless Noise-Cancelling Headphones', 'Electronics', 120, 80.00,  50.00, 0.20, 7, 10),
('SKU-102', 'Mechanical Ergonomic Keyboard',       'Electronics', 45,  65.00,  40.00, 0.15, 10, 14),
('SKU-103', 'Ultra-Wide 4K Gaming Monitor',        'Electronics', 15,  350.00, 75.00, 0.25, 14, 21),
('SKU-201', 'Bamboo Standing Desk Mat',            'Furniture',   220, 22.00,  30.00, 0.10, 5, 8),
('SKU-202', 'Ergonomic Mesh Task Chair',           'Furniture',   28,  180.00, 60.00, 0.20, 12, 18),
('SKU-301', 'Braided USB-C Cable (3-Pack)',        'Accessories', 850, 4.50,   20.00, 0.05, 4, 6);

INSERT INTO daily_shipments (sku, ship_date, units_sold) VALUES
-- SKU-101 (Demand ~15-20/day)
('SKU-101', '2024-04-01', 18), ('SKU-101', '2024-04-02', 15), ('SKU-101', '2024-04-03', 22),
('SKU-101', '2024-04-04', 19), ('SKU-101', '2024-04-05', 17), ('SKU-101', '2024-04-06', 24),
('SKU-101', '2024-04-07', 16),
-- SKU-102 (Demand ~8-12/day)
('SKU-102', '2024-04-01', 10), ('SKU-102', '2024-04-02', 8),  ('SKU-102', '2024-04-03', 12),
('SKU-102', '2024-04-04', 11), ('SKU-102', '2024-04-05', 9),  ('SKU-102', '2024-04-06', 14),
('SKU-102', '2024-04-07', 10),
-- SKU-103 (Demand ~2-4/day)
('SKU-103', '2024-04-01', 3),  ('SKU-103', '2024-04-02', 2),  ('SKU-103', '2024-04-03', 4),
('SKU-103', '2024-04-04', 1),  ('SKU-103', '2024-04-05', 3),  ('SKU-103', '2024-04-06', 5),
('SKU-103', '2024-04-07', 2),
-- SKU-201 (Demand ~25/day)
('SKU-201', '2024-04-01', 25), ('SKU-201', '2024-04-02', 28), ('SKU-201', '2024-04-03', 22),
('SKU-201', '2024-04-04', 30), ('SKU-201', '2024-04-05', 24), ('SKU-201', '2024-04-06', 26),
('SKU-201', '2024-04-07', 27),
-- SKU-202 (Demand ~3-5/day)
('SKU-202', '2024-04-01', 4),  ('SKU-202', '2024-04-02', 5),  ('SKU-202', '2024-04-03', 3),
('SKU-202', '2024-04-04', 4),  ('SKU-202', '2024-04-05', 6),  ('SKU-202', '2024-04-06', 4),
('SKU-202', '2024-04-07', 5),
-- SKU-301 (Demand ~60-80/day)
('SKU-301', '2024-04-01', 70), ('SKU-301', '2024-04-02', 65), ('SKU-301', '2024-04-03', 80),
('SKU-301', '2024-04-04', 75), ('SKU-301', '2024-04-05', 60), ('SKU-301', '2024-04-06', 85),
('SKU-301', '2024-04-07', 72);

-- ============================================
-- QUERY 1: Daily Demand & Standard Deviation
-- ============================================
SELECT 
    s.sku,
    i.product_name,
    COUNT(s.ship_date) AS days_tracked,
    ROUND(AVG(s.units_sold), 2) AS avg_daily_demand,
    MAX(s.units_sold) AS max_daily_demand,
    ROUND(STDDEV(s.units_sold), 2) AS std_daily_demand
FROM daily_shipments s
JOIN inventory_stock i ON s.sku = i.sku
GROUP BY s.sku, i.product_name;

-- ============================================
-- QUERY 2: Safety Stock & Reorder Point (ROP)
-- ============================================
-- Formula:
-- Safety Stock = (Max Daily Demand * Max Lead Time) - (Avg Daily Demand * Avg Lead Time)
-- Reorder Point (ROP) = (Avg Daily Demand * Avg Lead Time) + Safety Stock
WITH DemandStats AS (
    SELECT 
        s.sku,
        AVG(s.units_sold) AS avg_demand,
        MAX(s.units_sold) AS max_demand
    FROM daily_shipments s
    GROUP BY s.sku
)
SELECT 
    i.sku,
    i.product_name,
    i.current_on_hand,
    ROUND(d.avg_demand, 1) AS avg_daily_demand,
    i.supplier_lead_time_days AS lead_time_days,
    ROUND((d.max_demand * i.max_lead_time_days) - (d.avg_demand * i.supplier_lead_time_days), 0) AS safety_stock,
    ROUND((d.avg_demand * i.supplier_lead_time_days) + 
          ((d.max_demand * i.max_lead_time_days) - (d.avg_demand * i.supplier_lead_time_days)), 0) AS reorder_point,
    CASE 
        WHEN i.current_on_hand <= ((d.avg_demand * i.supplier_lead_time_days) + 
             ((d.max_demand * i.max_lead_time_days) - (d.avg_demand * i.supplier_lead_time_days)))
        THEN 'REORDER NOW (Below ROP)'
        ELSE 'SUFFICIENT STOCK'
    END AS inventory_action
FROM inventory_stock i
JOIN DemandStats d ON i.sku = d.sku
ORDER BY inventory_action DESC, i.current_on_hand ASC;

-- ============================================
-- QUERY 3: Economic Order Quantity (EOQ)
-- ============================================
-- Wilson EOQ Formula: SQRT((2 * Annual_Demand * Order_Cost) / Annual_Holding_Cost_Per_Unit)
-- Holding Cost per Unit = Unit_Cost * Holding_Cost_Rate
WITH AnnualizedDemand AS (
    SELECT 
        s.sku,
        AVG(s.units_sold) * 365 AS annual_demand
    FROM daily_shipments s
    GROUP BY s.sku
)
SELECT 
    i.sku,
    i.product_name,
    ROUND(a.annual_demand, 0) AS projected_annual_demand,
    i.order_cost,
    ROUND(i.unit_cost * i.annual_holding_cost_rate, 2) AS holding_cost_per_unit,
    ROUND(SQRT((2 * a.annual_demand * i.order_cost) / (i.unit_cost * i.annual_holding_cost_rate)), 0) AS optimal_order_quantity_eoq,
    ROUND(a.annual_demand / NULLIF(SQRT((2 * a.annual_demand * i.order_cost) / (i.unit_cost * i.annual_holding_cost_rate)), 0), 1) AS orders_per_year
FROM inventory_stock i
JOIN AnnualizedDemand a ON i.sku = a.sku;

-- ============================================
-- QUERY 4: ABC Inventory Classification (Pareto Analysis)
-- ============================================
-- Class A: Top 80% of total inventory value (Strict control)
-- Class B: Next 15% (80-95%) (Moderate control)
-- Class C: Bottom 5% (95-100%) (Simple control)
WITH InventoryValue AS (
    SELECT 
        sku,
        product_name,
        current_on_hand,
        unit_cost,
        (current_on_hand * unit_cost) AS total_value
    FROM inventory_stock
),
ValueShare AS (
    SELECT 
        sku,
        product_name,
        total_value,
        SUM(total_value) OVER() AS total_portfolio_value,
        ROUND((total_value * 100.0) / SUM(total_value) OVER(), 2) AS pct_of_total_value,
        ROUND(SUM(total_value) OVER(ORDER BY total_value DESC) * 100.0 / SUM(total_value) OVER(), 2) AS cum_pct_value
    FROM InventoryValue
)
SELECT 
    sku,
    product_name,
    total_value,
    pct_of_total_value,
    cum_pct_value,
    CASE 
        WHEN cum_pct_value <= 80.00 THEN 'A (High Value)'
        WHEN cum_pct_value <= 95.00 THEN 'B (Medium Value)'
        ELSE 'C (Low Value)'
    END AS abc_class
FROM ValueShare
ORDER BY total_value DESC;

-- ============================================
-- QUERY 5: Days of Inventory on Hand (DOH) & Run-Out Forecast
-- ============================================
WITH DailyRunRates AS (
    SELECT 
        s.sku,
        AVG(s.units_sold) AS daily_burn_rate
    FROM daily_shipments s
    GROUP BY s.sku
)
SELECT 
    i.sku,
    i.product_name,
    i.current_on_hand,
    ROUND(r.daily_burn_rate, 1) AS daily_burn_rate,
    ROUND(i.current_on_hand / NULLIF(r.daily_burn_rate, 0), 1) AS days_on_hand,
    DATE_ADD(CURRENT_DATE, INTERVAL FLOOR(i.current_on_hand / NULLIF(r.daily_burn_rate, 0)) DAY) AS projected_stockout_date,
    CASE 
        WHEN (i.current_on_hand / NULLIF(r.daily_burn_rate, 0)) <= 7 THEN 'CRITICAL: Stockout in <= 7 days'
        WHEN (i.current_on_hand / NULLIF(r.daily_burn_rate, 0)) <= 14 THEN 'WARNING: Low coverage'
        ELSE 'HEALTHY'
    END AS coverage_health
FROM inventory_stock i
JOIN DailyRunRates r ON i.sku = r.sku
ORDER BY days_on_hand ASC;

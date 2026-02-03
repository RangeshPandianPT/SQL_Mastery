-- =====================================================
-- SQL Mastery: 14 - Indexes
-- =====================================================
-- Indexes speed up data retrieval operations

-- =====================================================
-- 1. CREATING INDEXES
-- =====================================================

-- Single column index
CREATE INDEX idx_customer_name ON customers(customer_name);

-- Composite index (multiple columns)
CREATE INDEX idx_order_date_status ON orders(order_date, status);

-- Unique index
CREATE UNIQUE INDEX idx_email ON customers(email);

-- =====================================================
-- 2. VIEWING INDEXES
-- =====================================================

SHOW INDEX FROM customers;
SHOW INDEX FROM orders;

-- =====================================================
-- 3. DROPPING INDEXES
-- =====================================================

DROP INDEX idx_customer_name ON customers;
ALTER TABLE customers DROP INDEX idx_email;

-- =====================================================
-- 4. WHEN TO USE INDEXES
-- =====================================================
/*
USE indexes on:
- Primary keys (automatic)
- Foreign keys
- Columns in WHERE clauses
- Columns in JOIN conditions
- Columns in ORDER BY

AVOID indexes on:
- Small tables
- Columns with many NULL values
- Frequently updated columns
- Low cardinality columns (few unique values)
*/

-- =====================================================
-- 5. INDEX BEST PRACTICES
-- =====================================================
/*
- Don't over-index (slows down INSERT/UPDATE)
- Place most selective column first in composite index
- Consider covering indexes for common queries
- Regularly analyze and optimize indexes
*/

-- =====================================================
-- PRACTICE: Identify columns that need indexes!
-- =====================================================

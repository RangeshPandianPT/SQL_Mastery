-- ============================================
-- SQL MASTERY - 24 TRANSACTIONS & CONCURRENCY
-- ============================================
-- Topics:
-- 1) ACID Properties Overview
-- 2) Isolation Levels
-- 3) Locking Strategies (Row-level Locks)
-- 4) Deadlocks
-- ============================================

USE school_management;

-- ============================================
-- PART 1: ACID Properties
-- ============================================
-- Atomicity: All or nothing (Transactions)
-- Consistency: Database rules (constraints) remain valid
-- Isolation: Concurrent transactions don't interfere
-- Durability: Committed data is permanently saved

-- ============================================
-- PART 2: Isolation Levels
-- ============================================
-- Defines how database handles concurrent reads/writes.
-- MySQL default is REPEATABLE READ.

-- View current isolation level:
SELECT @@transaction_isolation;

-- 1. READ UNCOMMITTED (Lowest)
-- Allows "Dirty Reads" - seeing uncommitted changes from other transactions.
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 2. READ COMMITTED
-- Fixes Dirty Reads, but allows "Non-repeatable reads" 
-- (data can change if you read the same row twice in one transaction).
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 3. REPEATABLE READ (Default in InnoDB)
-- Fixes Non-repeatable reads. A row will look the same for the entire transaction.
-- Can theoretically allow "Phantom Reads" (new rows matching a WHERE clause appearing), 
-- but InnoDB's next-key locks usually prevent this.
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 4. SERIALIZABLE (Highest)
-- Emulates sequential execution. Transactions wait for each other. Safest but slowest.
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;

-- ============================================
-- PART 3: Explicit Locking
-- ============================================

-- Scenario: Two users try to buy the last item in stock.
-- User A reads stock (it's 1). User B reads stock (it's 1).
-- Both buy it, both set stock = 0. We've sold 2 items when we only had 1!

-- Solution A: FOR UPDATE (Exclusive Lock)
-- Locks the row so nobody else can read or write it until transaction ends.
START TRANSACTION;
SELECT stock_quantity FROM products WHERE product_id = 1 FOR UPDATE;
-- (Application logic: Check if stock > 0)
UPDATE products SET stock_quantity = stock_quantity - 1 WHERE product_id = 1;
COMMIT;

-- Solution B: LOCK IN SHARE MODE (Shared Lock)
-- Allows others to read, but nobody can update until transaction ends.
START TRANSACTION;
SELECT * FROM orders WHERE status = 'Pending' LOCK IN SHARE MODE;
-- Others can read these pending orders, but cannot update their status.
COMMIT;


-- ============================================
-- PART 4: Deadlocks
-- ============================================
-- A Deadlock occurs when Transaction 1 holds Lock A and waits for Lock B,
-- while Transaction 2 holds Lock B and waits for Lock A.
-- MySQL will automatically detect this, kill one transaction (rollback), and let the other finish.
-- Best practice to avoid deadlocks: Always access tables/rows in the same order.

-- ============================================================
-- Experiment 5: Design a Distributed Database for an
-- E-Commerce Platform to Handle Order Processing
-- (Apache Cassandra - CQL)
-- ============================================================

-- -------------------------
-- CREATE KEYSPACE
-- -------------------------
CREATE KEYSPACE IF NOT EXISTS ecommerce
WITH replication = {
    'class'             : 'SimpleStrategy',
    'replication_factor': 1
};

USE ecommerce;

-- -------------------------
-- CREATE TABLES
-- -------------------------

-- Products table
CREATE TABLE IF NOT EXISTS products (
    product_id UUID PRIMARY KEY,
    name       TEXT,
    price      DECIMAL
);

-- Orders table
CREATE TABLE IF NOT EXISTS orders (
    order_id    UUID    PRIMARY KEY,
    product_id  UUID,
    quantity    INT,
    total_price DECIMAL
);

-- Customers table (optional, for full e-commerce schema)
CREATE TABLE IF NOT EXISTS customers (
    customer_id UUID    PRIMARY KEY,
    name        TEXT,
    email       TEXT
);

-- Orders by customer (denormalised for efficient reads)
CREATE TABLE IF NOT EXISTS orders_by_customer (
    customer_id UUID,
    order_id    UUID,
    product_id  UUID,
    quantity    INT,
    total_price DECIMAL,
    order_date  TIMESTAMP,
    PRIMARY KEY (customer_id, order_date, order_id)
) WITH CLUSTERING ORDER BY (order_date DESC);

-- -------------------------
-- INSERT SAMPLE DATA
-- -------------------------

INSERT INTO products (product_id, name, price)
VALUES (uuid(), 'Product A', 19.99);

INSERT INTO products (product_id, name, price)
VALUES (uuid(), 'Product B', 49.99);

-- Insert a sample order (replace UUIDs with real ones after inserting products)
-- INSERT INTO orders (order_id, product_id, quantity, total_price)
-- VALUES (uuid(), <product_uuid>, 2, 39.98);

-- -------------------------
-- SELECT / QUERY DATA
-- -------------------------

-- List all products
SELECT * FROM products;

-- List all orders
SELECT * FROM orders;

-- -------------------------
-- UPDATE DATA
-- -------------------------

-- Update product price (replace <uuid> with actual product UUID)
-- UPDATE products SET price = 24.99 WHERE product_id = <uuid>;

-- -------------------------
-- DELETE DATA
-- -------------------------

-- Delete an order (replace <uuid> with actual order UUID)
-- DELETE FROM orders WHERE order_id = <uuid>;

-- -------------------------
-- DROP TABLES / KEYSPACE (cleanup)
-- -------------------------
-- DROP TABLE IF EXISTS orders;
-- DROP TABLE IF EXISTS products;
-- DROP TABLE IF EXISTS customers;
-- DROP TABLE IF EXISTS orders_by_customer;
-- DROP KEYSPACE IF EXISTS ecommerce;

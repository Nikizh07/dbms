-- ============================================================
-- Experiment 2: Create a Relational Database for E-Commerce
-- Applications with Primary Key, Foreign Key, Check
-- Constraints and Triggers
-- ============================================================

-- -------------------------
-- CREATE DATABASE
-- -------------------------
CREATE DATABASE ecom_db;
USE ecom_db;

-- -------------------------
-- CREATE TABLES
-- -------------------------

-- Customers table (Primary Key + Unique)
CREATE TABLE Customers (
    customer_id  INT          PRIMARY KEY,
    name         VARCHAR(25)  NOT NULL,
    email        VARCHAR(20)  NOT NULL UNIQUE,
    phone_number VARCHAR(20)
);

-- Products table (Primary Key)
CREATE TABLE Products (
    product_id   INT           PRIMARY KEY,
    product_name VARCHAR(25)   NOT NULL,
    price        DECIMAL(10,2) NOT NULL
);

-- Orders table (Primary Key + Foreign Key)
CREATE TABLE Orders (
    order_id     INT           PRIMARY KEY,
    customer_id  INT           NOT NULL,
    order_date   DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

-- -------------------------
-- INSERT SAMPLE DATA
-- -------------------------

INSERT INTO Customers VALUES (101, 'AKASH',   'akash@gmail.com',    9876543210);
INSERT INTO Customers VALUES (102, 'BALA',    'bala13@gmail.com',   9876512345);
INSERT INTO Customers VALUES (103, 'CHARLES', 'charles21@gmail.com',9965243201);

SELECT * FROM Customers;

INSERT INTO Products VALUES (1, 'Mobile',    15000.00);
INSERT INTO Products VALUES (2, 'Laptop',    50000.00);
INSERT INTO Products VALUES (3, 'Bluetooth',  1000.00);

SELECT * FROM Products;

INSERT INTO Orders VALUES (1, 101, '2023-02-24', 1000.50);
INSERT INTO Orders VALUES (2, 102, '2023-01-18', 7000.00);
INSERT INTO Orders VALUES (3, 103, '2023-12-24',10000.50);

SELECT * FROM Orders;

-- -------------------------
-- ADVANCED QUERIES
-- -------------------------

-- Simple query
SELECT * FROM Customers;

-- Subquery: Customers whose orders exceed average order amount
SELECT *
FROM Customers
WHERE customer_id IN (
    SELECT customer_id
    FROM Orders
    WHERE total_amount > (SELECT AVG(total_amount) FROM Orders)
);

-- -------------------------
-- JOIN TYPES (reference)
-- -------------------------
-- INNER JOIN  : rows matching in both tables
-- LEFT JOIN   : all rows from left + matching from right
-- RIGHT JOIN  : all rows from right + matching from left
-- FULL JOIN   : all rows from both tables

-- -------------------------
-- VIEW CREATION
-- -------------------------
CREATE VIEW OrderSummary AS
SELECT
    o.order_id,
    o.order_date,
    c.customer_id,
    c.name        AS customer_name,
    c.email
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id;

SELECT * FROM OrderSummary;

-- -------------------------
-- TRIGGER (PostgreSQL syntax)
-- Updates product quantity after an order detail is inserted
-- -------------------------
CREATE OR REPLACE FUNCTION update_quantity_available()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET price = price - NEW.total_amount   -- placeholder; adapt to your schema
    WHERE product_id = NEW.order_id;       -- adapt to your schema
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_order_placed
AFTER INSERT ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_quantity_available();

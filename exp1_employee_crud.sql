-- ============================================================
-- Experiment 1: Create a Relational Database with Tables for
-- Storing Employee Details and Perform CRUD Operations
-- ============================================================

-- -------------------------
-- CREATE TABLE
-- -------------------------
CREATE TABLE EMPLOYEE (
    empId     INTEGER PRIMARY KEY,
    first_name TEXT    NOT NULL,
    last_name  TEXT    NOT NULL,
    dept       TEXT    NOT NULL,
    hire_date  TEXT    NOT NULL,
    salary     INTEGER NOT NULL
);

-- -------------------------
-- CREATE (INSERT)
-- -------------------------
INSERT INTO EMPLOYEE VALUES (101, 'Clark',   'John',  'Sales',     '2024-02-23', 20000);
INSERT INTO EMPLOYEE VALUES (102, 'Raj',     'Kumar', 'Marketing', '2023-04-23', 30000);
INSERT INTO EMPLOYEE VALUES (103, 'Michael', 'Raj',   'IT',        '2022-06-23', 50000);

-- -------------------------
-- READ (SELECT)
-- -------------------------

-- Select all employees
SELECT * FROM EMPLOYEE;

-- Select specific columns
SELECT first_name, last_name, dept FROM EMPLOYEE;

-- Filter by condition
SELECT * FROM EMPLOYEE WHERE dept = 'Marketing';

-- -------------------------
-- UPDATE
-- -------------------------

-- Update last_name for empId = 101
UPDATE EMPLOYEE
SET last_name = 'Raj'
WHERE empId = 101;

SELECT * FROM EMPLOYEE;

-- -------------------------
-- DELETE
-- -------------------------

-- Remove employee with empID = 102
DELETE FROM EMPLOYEE WHERE empID = 102;
SELECT * FROM EMPLOYEE;

-- Delete based on criteria (hire_date)
DELETE FROM EMPLOYEE WHERE hire_date = '2024-02-23';
SELECT * FROM EMPLOYEE;

-- -------------------------
-- ALTER TABLE (Add column)
-- -------------------------
ALTER TABLE EMPLOYEE ADD DOB INTEGER;

-- Describe / check table structure (MySQL syntax)
DESC EMPLOYEE;

-- -------------------------
-- TRUNCATE TABLE
-- -------------------------
TRUNCATE TABLE EMPLOYEE;

-- -------------------------
-- DROP TABLE
-- -------------------------
DROP TABLE EMPLOYEE;

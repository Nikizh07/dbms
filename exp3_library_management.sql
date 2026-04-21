-- ============================================================
-- Experiment 3: ER Diagram for Library Management System
-- and Implementation of Database Schema in RDBMS
-- ============================================================

-- -------------------------
-- CREATE DATABASE
-- -------------------------
CREATE DATABASE LibraryManagementSystem;
USE LibraryManagementSystem;

-- -------------------------
-- CREATE TABLES
-- -------------------------

-- Author table
CREATE TABLE Author (
    AuthorID   INT          PRIMARY KEY,
    AuthorName VARCHAR(255),
    BirthDate  DATE
);

-- Book table (FK -> Author)
CREATE TABLE Book (
    ISBN     VARCHAR(20)  PRIMARY KEY,
    Title    VARCHAR(255),
    AuthorID INT,
    Genre    VARCHAR(50),
    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
);

-- Member table
CREATE TABLE Member (
    MemberID   INT          PRIMARY KEY,
    MemberName VARCHAR(255),
    Email      VARCHAR(255)
);

-- Transaction table (FK -> Book, Member)
CREATE TABLE Transaction (
    TransactionID INT         PRIMARY KEY,
    BookID        VARCHAR(20),
    MemberID      INT,
    CheckoutDate  DATE,
    ReturnDate    DATE,
    FOREIGN KEY (BookID)   REFERENCES Book(ISBN),
    FOREIGN KEY (MemberID) REFERENCES Member(MemberID)
);

-- -------------------------
-- INSERT SAMPLE DATA
-- -------------------------

INSERT INTO Author (AuthorID, AuthorName, BirthDate)
VALUES
    (1, 'E.Balagurusamy', '1945-01-01'),
    (2, 'Ramesh Babu',    '1960-05-15'),
    (3, 'Naagoor Kani',   '1970-08-20');

SELECT * FROM Author;

INSERT INTO Book (ISBN, Title, AuthorID, Genre)
VALUES ('1234567890', 'Sample Book', 1, 'Fiction');

SELECT * FROM Book;

INSERT INTO Member (MemberID, MemberName, Email)
VALUES (101, 'Alice Smith', 'alice@example.com');

INSERT INTO Member (MemberID, MemberName, Email)
VALUES (102, 'Reema Teraja', 'reema@example.com');

SELECT * FROM Member;

INSERT INTO Transaction (TransactionID, BookID, MemberID, CheckoutDate, ReturnDate)
VALUES (1, '1234567890', 101, '2024-02-28', '2024-03-15');

INSERT INTO Transaction (TransactionID, BookID, MemberID, CheckoutDate, ReturnDate)
VALUES (2, '1234567890', 102, '2024-02-20', '2024-03-08');

SELECT * FROM Transaction;

-- -------------------------
-- QUERIES
-- -------------------------

-- List all books with their author names
SELECT b.ISBN, b.Title, a.AuthorName, b.Genre
FROM Book b
JOIN Author a ON b.AuthorID = a.AuthorID;

-- List all transactions with member and book details
SELECT
    t.TransactionID,
    m.MemberName,
    b.Title,
    t.CheckoutDate,
    t.ReturnDate
FROM Transaction t
JOIN Member m ON t.MemberID = m.MemberID
JOIN Book   b ON t.BookID   = b.ISBN;

-- Find books currently not returned (ReturnDate is NULL or future)
SELECT b.Title, m.MemberName, t.CheckoutDate
FROM Transaction t
JOIN Book   b ON t.BookID   = b.ISBN
JOIN Member m ON t.MemberID = m.MemberID
WHERE t.ReturnDate IS NULL OR t.ReturnDate > CURDATE();

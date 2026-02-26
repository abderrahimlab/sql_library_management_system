-- Active: 1770309306489@@127.0.0.1@5432@Project02
-- Create Tables
DROP TABLE IF EXISTS books;

CREATE TABLE books (
    isbnd VARCHAR(30) PRIMARY KEY,
    book_title VARCHAR(60),
    category VARCHAR(30),
    rental_price FLOAT,
    status BOOLEAN,
    author VARCHAR(30),
    publisher VARCHAR(30)
);

DROP TABLE IF EXISTS branch;

CREATE TABLE branch (
    branch_id VARCHAR(20) PRIMARY KEY,
    manager_id VARCHAR(20) -- FK,
    branch_address VARCHAR(20),
    contact_no VARCHAR(20)
);

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id VARCHAR(20) PRIMARY KEY,
    emp_name VARCHAR(20),
    position VARCHAR(20),
    salary FLOAT,
    branch_id VARCHAR(20) -- FK
);

DROP TABLE IF EXISTS issued_status;

CREATE TABLE issued_status (
    issued_id VARCHAR(20) PRIMARY KEY,
    issued_member_id VARCHAR(20) -- FK,
    issued_book_name FLOAT,
    issued_date DATE,
    issued_book_isbn VARCHAR(30) -- FK,
    issued_emp_id VARCHAR(20) -- FK
);

DROP TABLE IF EXISTS members;

CREATE TABLE members (
    member_id VARCHAR(20) PRIMARY KEY,
    member_name VARCHAR(20),
    member_address VARCHAR(20),
    reg_date DATE
);

DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status (
    return_id VARCHAR(20) PRIMARY KEY,
    issued_id VARCHAR(20) -- FK,
    return_book_name VARCHAR(20),
    return_date DATE,
    return_book_isbn VARCHAR(30)
);

-- 
/*ALL THE TABLES*/
SELECT
    *
FROM
    books;

SELECT
    *
FROM
    branch;

SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    issued_status;

SELECT
    *
FROM
    return_status;

-- Create Foreign Keys
ALTER TABLE
    return_status
ADD
    CONSTRAINT fk_issued_id FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id);

-- 
ALTER TABLE
    issued_status
ADD
    CONSTRAINT fk_issued_member_id FOREIGN KEY (issued_member_id) REFERENCES members(member_id);

-- 
ALTER TABLE
    issued_status
ADD
    CONSTRAINT fk_issued_book_isbn FOREIGN KEY (issued_book_isbn) REFERENCES books(isbnd);

-- 
ALTER TABLE
    issued_status
ADD
    CONSTRAINT fk_issued_emp_id FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id);

--
ALTER TABLE
    employees
ADD
    CONSTRAINT fk_branch_id FOREIGN KEY (branch_id) REFERENCES branch(branch_id);

--
ALTER TABLE
    branch
ADD
    CONSTRAINT fk_manager_id FOREIGN KEY (manager_id) REFERENCES employees(emp_id);

-- Fix / Maintenance Operations
ALTER TABLE
    branch DROP CONSTRAINT fk_manager_id;

ALTER TABLE
    issued_status
ALTER COLUMN
    issued_book_name type VARCHAR(100);

-- ----------------------------------------------------------------------------------
-- 01. Create a New Book Record
INSERT INTO
    books (
        isbnd,
        book_title,
        category,
        rental_price,
        status,
        author,
        publisher
    )
VALUES
    (
        '978-1-60129-456-2',
        'To Kill a Mockingbird',
        'Classic',
        6.00,
        'yes',
        'Harper Lee',
        'J.B. Lippincott & Co.'
    );

SELECT
    *
FROM
    books;

-- 02. Update an Existing Member’s Address
SELECT
    *
FROM
    members;

UPDATE
    members
SET
    member_address = '152 Main St'
WHERE
    member_id = 'C101';

-- 03. Delete a Record from Issued Status
SELECT
    *
FROM
    issued_status;

DELETE FROM
    issued_status
WHERE
    issued_id = 'IS121';

-- 04. Retrieve Books Issued by a Specific Employee
SELECT
    *
FROM
    issued_status;

SELECT
    *
FROM
    issued_status
WHERE
    issued_emp_id = 'E101';

-- 05. List Members Who Issued More Than One Book
SELECT
    *
FROM
    issued_status;

SELECT
    issued_member_id,
    count(*)
FROM
    issued_status
GROUP BY
    issued_member_id
HAVING
    count(*) > 1;

-- 06. CTAS: Create a Summary Table of Book Issue Counts
SELECT
    *
FROM
    issued_status;

SELECT
    *
FROM
    books;

CREATE TABLE book_issued_count AS
SELECT
    DISTINCT b.book_title,
    b.isbnd,
    count(*)
FROM
    books b
    JOIN issued_status ist ON b.isbnd = ist.issued_book_isbn
GROUP BY
    1,
    2;

SELECT
    *
FROM
    book_issued_count;

-- 07. Retrieve All Books in a Specific Category
SELECT
    *
FROM
    books
WHERE
    category = 'Classic';

-- 08. Total Rental Income by Category (based on actual issued books)
SELECT
    b.category,
    sum(b.rental_price),
    count(*)
FROM
    issued_status ist
    JOIN books b ON b.isbnd = ist.issued_book_isbn
GROUP BY
    1;

SELECT
    count(DISTINCT isbnd)
FROM
    books;

SELECT
    count(DISTINCT issued_book_isbn)
FROM
    issued_status;

-- 09. List Members Registered in the Last 180 Days
INSERT INTO
    members (
        member_id,
        member_name,
        member_address,
        reg_date
    )
VALUES
    (
        'C120',
        'alex jonathan',
        '002 downtown St',
        '2026-01-20'
    ),
    (
        'C121',
        'amanda brown',
        '052 downtown St',
        '2026-01-01'
    );

SELECT
    *
FROM
    members
WHERE
    reg_date >= CURRENT_DATE - INTERVAL '180 days';

SELECT
    CURRENT_DATE;

-- 10. List Employees with Their Branch Manager Name + Branch Details
SELECT
    e1.emp_name,
    e1.position,
    e1.salary,
    br.*,
    e2.emp_name
FROM
    employees e1
    JOIN branch br ON br.branch_id = e1.branch_id
    JOIN employees e2 ON br.manager_id = e2.emp_id;

-- 11. Retrieve Books With Rental Price Above a Threshold
SELECT
    *
FROM
    books
WHERE
    rental_price > 7.00;

-- 12. Retrieve Books Not Yet Returned
SELECT
    DISTINCT ist1.issued_book_name
FROM
    issued_status ist1
    LEFT JOIN return_status rts ON ist1.issued_id = rts.issued_id
WHERE
    rts.return_id IS NULL;

-- ----------------------------------------------------------------------
INSERT INTO
    issued_status(
        issued_id,
        issued_member_id,
        issued_book_name,
        issued_date,
        issued_book_isbn,
        issued_emp_id
    )
VALUES
    (
        'IS151',
        'C118',
        'The Catcher in the Rye',
        CURRENT_DATE - INTERVAL '24 days',
        '978-0-553-29698-2',
        'E108'
    ),
    (
        'IS152',
        'C119',
        'The Catcher in the Rye',
        CURRENT_DATE - INTERVAL '13 days',
        '978-0-553-29698-2',
        'E109'
    ),
    (
        'IS153',
        'C106',
        'Pride and Prejudice',
        CURRENT_DATE - INTERVAL '7 days',
        '978-0-14-143951-8',
        'E107'
    ),
    (
        'IS154',
        'C105',
        'The Road',
        CURRENT_DATE - INTERVAL '32 days',
        '978-0-375-50167-0',
        'E101'
    );

ALTER TABLE
    return_status
ADD
    COLUMN book_quality VARCHAR(15) DEFAULT('Good');

UPDATE
    return_status
SET
    book_quality = 'Damaged'
WHERE
    issued_id IN ('IS112', 'IS117', 'IS118');

SELECT
    *
FROM
    return_status;

-- 13. Identify Members with Overdue Books (30-day return period)
SELECT
    mb.member_id,
    mb.member_name,
    ist.issued_book_name AS book_name,
    ist.issued_date,
    CURRENT_DATE - issued_date AS overdues_days
FROM
    issued_status ist
    JOIN members mb ON ist.issued_member_id = mb.member_id
    LEFT JOIN return_status rst ON ist.issued_id = rst.issued_id
WHERE
    return_date IS NULL
    AND (CURRENT_DATE - issued_date) > 30;

-- 14. Update Book Status on Return (Automated with Stored Procedure)
/*ALL THE TABLES*/
SELECT
    *
FROM
    books;

SELECT
    *
FROM
    branch;

SELECT
    *
FROM
    employees;

SELECT
    *
FROM
    issued_status;

SELECT
    *
FROM
    return_status;

-- -----------------
SELECT
    *
FROM
    issued_status
WHERE
    issued_book_isbn = '978-0-307-58837-1';

SELECT
    *
FROM
    books
WHERE
    isbnd = '978-0-307-58837-1';

UPDATE
    books
SET
    status = 'no'
WHERE
    isbnd = '978-0-307-58837-1';

INSERT INTO
    return_status(
        return_id,
        issued_id,
        return_date
    )
VALUES
    ('RS119', 'IS135', CURRENT_DATE);

SELECT
    *
FROM
    return_status;

-- ----------------------
CREATE
OR REPLACE PROCEDURE add_return_records (
    p_return_id VARCHAR(20),
    p_issued_id VARCHAR(20),
    p_book_quality VARCHAR(15)
) LANGUAGE plpgsql AS $ $ DECLARE v_book_name VARCHAR(60);

v_isbn VARCHAR(30);

BEGIN
INSERT INTO
    return_status(
        return_id,
        issued_id,
        return_date,
        book_quality
    )
VALUES
    (
        p_return_id,
        p_issued_id,
        CURRENT_DATE,
        p_book_quality
    );

SELECT
    issued_book_name,
    issued_book_isbn INTO v_book_name,
    v_isbn
FROM
    issued_status
WHERE
    issued_id = p_issued_id;

UPDATE
    books
SET
    status = 'yes'
WHERE
    isbnd = v_isbn;

RAISE NOTICE 'Thank you from returning the book: %',
v_book_name;

END $ $;

CALL add_return_records('RS119', 'IS135', 'Good');

SELECT
    *
FROM
    return_status
WHERE
    return_id = 'RS119';

DELETE FROM
    return_status
WHERE
    return_id = 'RS119';

SELECT
    *
FROM
    books
WHERE
    isbnd = '978-0-307-58837-1';

--  15. Branch Performance Report
SELECT
    e.branch_id,
    count(ist.issued_id) as number_book_issued,
    count(rst.return_id) as number_of_book_return,
    sum(rental_price) as total_revenue
FROM
    issued_status ist
    JOIN employees e ON e.emp_id = ist.issued_emp_id
    JOIN books b ON b.isbnd = ist.issued_book_isbn
    LEFT JOIN return_status rst ON rst.issued_id = ist.issued_id
GROUP BY
    1;

SELECT
    *
FROM
    books;

SELECT
    *
FROM
    employees;

-- 16. CTAS: Create a Table of Active Members (last 2 months)
CREATE TABLE active_members AS
SELECT
    *
FROM
    members
WHERE
    member_id IN(
        SELECT
            issued_member_id
        FROM
            issued_status
        WHERE
            issued_date >= CURRENT_DATE - INTERVAL '2 months'
    );

SELECT
    *
FROM
    active_members;

-- 17. Find Employees with the Most Book Issues Processed (Top 3)
SELECT
    e.emp_name,
    e.branch_id,
    count(ist.issued_id)
FROM
    issued_status ist
    JOIN employees e ON ist.issued_emp_id = e.emp_id
GROUP BY
    1,
    2;

SELECT
    *
FROM
    books;

-- 18. Identify Members Issuing High-Risk (Damaged) Books
UPDATE
    return_status
SET
    book_quality = 'Damaged'
WHERE
    return_id IN ('RS105', 'RS104', 'RS106', 'RS119');

SELECT
    *
FROM
    return_status;

-- -----------------------
SELECT
    *
FROM
    (
        SELECT
            mb.member_name,
            ist.issued_book_name,
            count(mb.member_name) n_return_books
        FROM
            return_status rst
            JOIN issued_status ist ON rst.issued_id = ist.issued_id
            JOIN members mb ON mb.member_id = ist.issued_member_id
        WHERE
            book_quality = 'Damaged'
        GROUP BY
            1,
            2
    )
WHERE
    n_return_books >= 1;

SELECT
    *
FROM
    books;

-- 19. Stored Procedure: Issue Book Only if Available
SELECT
    *
FROM
    books
WHERE
    isbnd = '978-0-7432-4722-4';

INSERT INTO
    issued_status (
        issued_id,
        issued_member_id,
        issued_book_name,
        issued_date,
        issued_book_isbn,
        issued_emp_id
    )
VALUES
    (
        'IS155',
        'C121',
        'The Da Vinci Code',
        CURRENT_DATE,
        '978-0-7432-4722-4',
        'E110'
    );

SELECT
    *
FROM
    issued_status
WHERE
    issued_id = 'IS155';

-- --------------- 
CREATE
OR REPLACE PROCEDURE issue_book (
    p_issued_id VARCHAR(20),
    p_issued_member_id VARCHAR(20),
    p_issued_book_isbn VARCHAR(30),
    p_issued_emp_id VARCHAR(20)
) LANGUAGE plpgsql AS $ $ DECLARE v_book_tital VARCHAR(60);

v_status BOOLEAN;

BEGIN
SELECT
    book_title,
    status INTO v_book_tital,
    v_status
FROM
    books
WHERE
    isbnd = p_issued_book_isbn;

IF v_status = 'yes' THEN
INSERT INTO
    issued_status (
        issued_id,
        issued_member_id,
        issued_book_name,
        issued_date,
        issued_book_isbn,
        issued_emp_id
    )
VALUES
    (
        p_issued_id,
        p_issued_member_id,
        v_book_tital,
        CURRENT_DATE,
        p_issued_book_isbn,
        p_issued_emp_id
    );

UPDATE
    books
SET
    status = 'no'
WHERE
    isbnd = p_issued_book_isbn;

RAISE NOTICE 'Book records added successfully for book isbn : %',
p_issued_book_isbn;

ELSE RAISE NOTICE 'Sorry to inform you the book you have requested is unavailable book_isbn: %',
p_issued_book_isbn;

END IF;

END;

$ $ -- -----------------
CALL issue_book('IS156', 'C119', '978-1-60129-456-2', 'E111');

SELECT
    *
FROM
    books
WHERE
    isbnd = '978-1-60129-456-2';

SELECT
    *
FROM
    issued_status
WHERE
    issued_book_isbn = '978-1-60129-456-2';
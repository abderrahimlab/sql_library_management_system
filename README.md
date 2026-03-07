<img width="2760" height="1504" alt="library_management_system" src="https://github.com/user-attachments/assets/27b576eb-31eb-4de7-90e8-d881f6e4968f" />
# sql_library_management_system

## **1- Project Overview**

This project simulates a **Library Management System** using **PostgreSQL**.  
It covers database design, relationships (**foreign keys**), data insertion, reporting queries, and **PL/pgSQL stored procedures** to automate business logic such as issuing and returning books.

The main objectives are to:
- Design relational tables for a library system
- Build correct relationships using **foreign keys**
- Practice SQL for **CRUD operations** and analysis
- Create reports using **joins, grouping, and time logic**
- Automate workflows using **stored procedures**

---

## **2- Dataset / Tables Information**

This project uses **6 relational tables**:

### **books**
Stores the library book catalog.
- `isbnd` (PK)
- `book_title`
- `category`
- `rental_price`
- `status` (available / not available)
- `author`
- `publisher`

### **branch**
Stores library branches.
- `branch_id` (PK)
- `manager_id` (FK → employees.emp_id)
- `branch_address`
- `contact_no`

### **employees**
Stores employees working in branches.
- `emp_id` (PK)
- `emp_name`
- `position`
- `salary`
- `branch_id` (FK → branch.branch_id)

### **members**
Stores library members.
- `member_id` (PK)
- `member_name`
- `member_address`
- `reg_date`

### **issued_status**
Stores book issuing transactions.
- `issued_id` (PK)
- `issued_member_id` (FK → members.member_id)
- `issued_book_name`
- `issued_date`
- `issued_book_isbn` (FK → books.isbnd)
- `issued_emp_id` (FK → employees.emp_id)

### **return_status**
Stores return transactions.
- `return_id` (PK)
- `issued_id` (FK → issued_status.issued_id)
- `return_book_name`
- `return_date`
- `return_book_isbn`
- `book_quality` (Good / Damaged) *(added later)*

---

## **3- Database Relationships (ERD Logic)**
<img width="1920" height="1032" alt="image" src="https://github.com/user-attachments/assets/77790747-4c68-4f53-86eb-15b1f54941aa" />

This database is relational, meaning tables are connected:

- A **member** can issue many books → `members (1) → issued_status (many)`
- An **employee** can issue many books → `employees (1) → issued_status (many)`
- A **book** can be issued many times → `books (1) → issued_status (many)`
- An **issued record** can have one return record → `issued_status (1) → return_status (0/1)`
- A **branch** has many employees → `branch (1) → employees (many)`
- A **branch** has one manager → `branch.manager_id → employees.emp_id`

---

## **4- Database Setup (DDL)**

### **4.1 Create Tables**
```sql
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
    manager_id VARCHAR(20), -- FK
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
    issued_member_id VARCHAR(20), -- FK
    issued_book_name FLOAT,
    issued_date DATE,
    issued_book_isbn VARCHAR(30), -- FK
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
    issued_id VARCHAR(20), -- FK
    return_book_name VARCHAR(20),
    return_date DATE,
    return_book_isbn VARCHAR(30)
);
````

### **4.2 Create Foreign Keys**

```sql
ALTER TABLE return_status
ADD CONSTRAINT fk_issued_id
FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_member_id
FOREIGN KEY (issued_member_id) REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_book_isbn
FOREIGN KEY (issued_book_isbn) REFERENCES books(isbnd);

ALTER TABLE issued_status
ADD CONSTRAINT fk_issued_emp_id
FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id);

ALTER TABLE employees
ADD CONSTRAINT fk_branch_id
FOREIGN KEY (branch_id) REFERENCES branch(branch_id);

ALTER TABLE branch
ADD CONSTRAINT fk_manager_id
FOREIGN KEY (manager_id) REFERENCES employees(emp_id);
```

### **4.3 Fix / Maintenance Operations**

#### **Drop a wrong constraint (example fix)**

```sql
ALTER TABLE branch
DROP CONSTRAINT fk_manager_id;
```

#### **Fix datatype issue (issued_book_name)**

```sql
ALTER TABLE issued_status
ALTER COLUMN issued_book_name TYPE VARCHAR(100);
```

---

## **5- CRUD & Reporting Tasks (01 → 19)**

This section contains the main tasks and SQL queries used in this project.

---

### **01. Create a New Book Record**

```sql
INSERT INTO books (
    isbnd,
    book_title,
    category,
    rental_price,
    status,
    author,
    publisher
)
VALUES (
    '978-1-60129-456-2',
    'To Kill a Mockingbird',
    'Classic',
    6.00,
    'yes',
    'Harper Lee',
    'J.B. Lippincott & Co.'
);
```

---

### **02. Update an Existing Member’s Address**

```sql
UPDATE members
SET member_address = '152 Main St'
WHERE member_id = 'C101';
```

---

### **03. Delete a Record from Issued Status**

```sql
DELETE FROM issued_status
WHERE issued_id = 'IS121';
```

---

### **04. Retrieve Books Issued by a Specific Employee**

```sql
SELECT *
FROM issued_status
WHERE issued_emp_id = 'E101';
```

---

### **05. List Members Who Issued More Than One Book**

```sql
SELECT issued_member_id, COUNT(*)
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(*) > 1;
```

---

### **06. CTAS: Create a Summary Table of Book Issue Counts**

```sql
CREATE TABLE book_issued_count AS
SELECT
    b.book_title,
    b.isbnd,
    COUNT(*) AS issued_count
FROM books b
JOIN issued_status ist ON b.isbnd = ist.issued_book_isbn
GROUP BY 1, 2;
```

---

### **07. Retrieve All Books in a Specific Category**

```sql
SELECT *
FROM books
WHERE category = 'Classic';
```

---

### **08. Total Rental Income by Category (based on actual issued books)**

```sql
SELECT
    b.category,
    SUM(b.rental_price) AS total_rental_income,
    COUNT(*) AS total_issues
FROM issued_status ist
JOIN books b ON b.isbnd = ist.issued_book_isbn
GROUP BY 1;
```

---

### **09. List Members Registered in the Last 180 Days**

```sql
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

---

### **10. List Employees with Their Branch Manager Name + Branch Details**

```sql
SELECT
    e1.emp_name,
    e1.position,
    e1.salary,
    br.*,
    e2.emp_name AS manager_name
FROM employees e1
JOIN branch br ON br.branch_id = e1.branch_id
JOIN employees e2 ON br.manager_id = e2.emp_id;
```

---

### **11. Retrieve Books With Rental Price Above a Threshold**

```sql
SELECT *
FROM books
WHERE rental_price > 7.00;
```

---

### **12. Retrieve Books Not Yet Returned**

```sql
SELECT
    ist.issued_book_name,
    ist.issued_book_isbn
FROM issued_status ist
LEFT JOIN return_status rts ON ist.issued_id = rts.issued_id
WHERE rts.return_id IS NULL;
```

---

### **13. Identify Members with Overdue Books (30-day return period)**

```sql
SELECT
    mb.member_id,
    mb.member_name,
    ist.issued_book_name AS book_name,
    ist.issued_date,
    CURRENT_DATE - ist.issued_date AS overdue_days
FROM issued_status ist
JOIN members mb ON ist.issued_member_id = mb.member_id
LEFT JOIN return_status rst ON ist.issued_id = rst.issued_id
WHERE rst.return_date IS NULL
  AND (CURRENT_DATE - ist.issued_date) > 30;
```

---

### **14. Update Book Status on Return (Automated with Stored Procedure)**

#### **Add `book_quality` column**

```sql
ALTER TABLE return_status
ADD COLUMN book_quality VARCHAR(15) DEFAULT('Good');
```

#### **Stored Procedure: `add_return_records`**

This procedure:

* Inserts the return record into `return_status`
* Finds the related book ISBN from `issued_status`
* Updates the book status in `books` to available (`yes`)
* Prints a message using `RAISE NOTICE`

```sql
CREATE OR REPLACE PROCEDURE add_return_records (
    p_return_id VARCHAR(20),
    p_issued_id VARCHAR(20),
    p_book_quality VARCHAR(15)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_book_name VARCHAR(60);
    v_isbn VARCHAR(30);
BEGIN
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

    SELECT issued_book_name, issued_book_isbn
    INTO v_book_name, v_isbn
    FROM issued_status
    WHERE issued_id = p_issued_id;

    UPDATE books
    SET status = 'yes'
    WHERE isbnd = v_isbn;

    RAISE NOTICE 'Thank you for returning the book: %', v_book_name;
END;
$$;
```

#### **Call the procedure**

```sql
CALL add_return_records('RS119', 'IS135', 'Good');
```

---

### **15. Branch Performance Report**

```sql
SELECT
    e.branch_id,
    COUNT(ist.issued_id) AS number_books_issued,
    COUNT(rst.return_id) AS number_books_returned,
    SUM(b.rental_price) AS total_revenue
FROM issued_status ist
JOIN employees e ON e.emp_id = ist.issued_emp_id
JOIN books b ON b.isbnd = ist.issued_book_isbn
LEFT JOIN return_status rst ON rst.issued_id = ist.issued_id
GROUP BY 1;
```

---

### **16. CTAS: Create a Table of Active Members (last 2 months)**

```sql
CREATE TABLE active_members AS
SELECT *
FROM members
WHERE member_id IN (
    SELECT issued_member_id
    FROM issued_status
    WHERE issued_date >= CURRENT_DATE - INTERVAL '2 months'
);
```

---

### **17. Find Employees with the Most Book Issues Processed (Top 3)**

```sql
SELECT
    e.emp_name,
    e.branch_id,
    COUNT(ist.issued_id) AS books_processed
FROM issued_status ist
JOIN employees e ON ist.issued_emp_id = e.emp_id
GROUP BY 1, 2
ORDER BY books_processed DESC
LIMIT 3;
```

---

### **18. Identify Members Issuing High-Risk (Damaged) Books**

This query identifies members who returned **damaged books more than twice**.

```sql
SELECT *
FROM (
    SELECT
        mb.member_name,
        ist.issued_book_name,
        COUNT(*) AS damaged_count
    FROM return_status rst
    JOIN issued_status ist ON rst.issued_id = ist.issued_id
    JOIN members mb ON mb.member_id = ist.issued_member_id
    WHERE rst.book_quality = 'Damaged'
    GROUP BY 1, 2
) t
WHERE damaged_count > 2;
```

---

### **19. Stored Procedure: Issue Book Only if Available**

This procedure:

* Checks if the requested book is available (`status = 'yes'`)
* If yes → inserts into `issued_status` + updates `books.status = 'no'`
* If no → prints an “unavailable” message

```sql
CREATE OR REPLACE PROCEDURE issue_book (
    p_issued_id VARCHAR(20),
    p_issued_member_id VARCHAR(20),
    p_issued_book_isbn VARCHAR(30),
    p_issued_emp_id VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_book_title VARCHAR(60);
    v_status BOOLEAN;
BEGIN
    SELECT book_title, status
    INTO v_book_title, v_status
    FROM books
    WHERE isbnd = p_issued_book_isbn;

    IF v_status = 'yes' THEN
        INSERT INTO issued_status (
            issued_id,
            issued_member_id,
            issued_book_name,
            issued_date,
            issued_book_isbn,
            issued_emp_id
        )
        VALUES (
            p_issued_id,
            p_issued_member_id,
            v_book_title,
            CURRENT_DATE,
            p_issued_book_isbn,
            p_issued_emp_id
        );

        UPDATE books
        SET status = 'no'
        WHERE isbnd = p_issued_book_isbn;

        RAISE NOTICE 'Book issued successfully. ISBN: %', p_issued_book_isbn;
    ELSE
        RAISE NOTICE 'Book is unavailable. ISBN: %', p_issued_book_isbn;
    END IF;
END;
$$;
```

#### **Call the procedure**

```sql
CALL issue_book('IS156', 'C119', '978-1-60129-456-2', 'E111');
```

---

## **6- Tools Used**

* PostgreSQL
* pgAdmin 4
* Visual Studio Code (Database Client Extension)
* SQL
* PL/pgSQL (Stored Procedures)

---

## **7- Repository Structure**

```text
├── sqlfile.sql            # Full SQL script (DDL + DML + Tasks + Procedures)
├── books.csv              # Dataset (books)
├── branch.csv             # Dataset (branches)
├── employees.csv          # Dataset (employees)
├── members.csv            # Dataset (members)
├── issued_status.csv      # Dataset (issued records)
├── return_status.csv      # Dataset (returned records)
└── README.md              # Project documentation
```

---

## **8- Key Takeaways**

* Designed a full relational database with correct PK/FK relationships
* Practiced CRUD operations on real tables
* Used **INNER JOIN** and **LEFT JOIN** for reporting and missing-data detection
* Built analytical queries using **GROUP BY**, **HAVING**, and **date intervals**
* Automated business logic using **PL/pgSQL stored procedures**
* Learned how to manage data integrity using **foreign keys**

---

## **9- Author**

**Abderrahim Labdaoui**
**Aspiring Data Analyst | SQL | PostgreSQL**

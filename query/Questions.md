# 📘 SQL Queries & Database Concepts

This repository contains **commonly asked SQL queries and database theory concepts** that are helpful for interviews and revision.

---

## 📑 Table of Contents

- [SQL Queries](#-sql-queries)
  - [Add Multiple Columns](#1-add-multiple-columns-to-a-table)
  - [Delete Multiple Columns](#2-delete-multiple-columns-from-a-table)
  - [Find 2nd Highest Value](#3-find-the-2nd-highest-value-in-a-table)
  - [Find Max Without ORDER BY](#4-find-max-value-without-using-order-by)
  - [Find Managers of Employees](#5-find-managers-of-all-employees)
  - [Use of Wildcards](#6-use-of-wildcards)
  - [If-Else Based Queries](#7-if-else-based-query)
  - [Category-wise Top Value](#8-find-category-wise-top-value)
  - [Find/Delete Duplicates](#9-find-duplicate-records--delete-duplicates)
  - [Joining Tables](#10-joining-tables)
- [Database Theory](#-database-theory)
  - [SQL vs NoSQL](#1-sql-vs-nosql-databases)
  - [Many-to-Many Relationship](#2-tables-required-for-many-to-many-relationship)
  - [Schema Design for Swiggy](#3-schema-design-for-swiggy)
  - [Joins & Union](#4-types-of-joins--union-vs-union-all)
  - [OLAP vs OLTP](#5-olap-vs-oltp)
  - [Database Keys](#6-database-keys)
  - [Normalization](#7-types-of-normalization)
  - [Indexes](#8-indexes-in-databases)
  - [Transactions & ACID](#9-transactions--acid-properties)
  - [Views & Stored Procedures](#10-views--stored-procedures)

---

# 📝 SQL Queries

## 1. Add Multiple Columns to a Table
```sql
ALTER TABLE employees
ADD COLUMN department VARCHAR(50),
ADD COLUMN joining_date DATE,
ADD COLUMN salary DECIMAL(10,2);
```

---

## 2. Delete Multiple Columns from a Table
```sql
ALTER TABLE employees
DROP COLUMN department,
DROP COLUMN joining_date;
```

---

## 3. Find the 2nd Highest Value in a Table
```sql
SELECT MAX(salary) AS second_highest_salary
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);
```

---

## 4. Find Max Value Without Using ORDER BY
```sql
SELECT MAX(salary) AS highest_salary
FROM employees;
```

---

## 5. Find Managers of All Employees
(Assume `employees` has `emp_id`, `name`, `manager_id`)
```sql
SELECT e.name AS employee, m.name AS manager
FROM employees e
LEFT JOIN employees m
ON e.manager_id = m.emp_id;
```

---

## 6. Use of Wildcards
```sql
-- Names starting with 'A'
SELECT * FROM employees WHERE name LIKE 'A%';

-- Names ending with 'n'
SELECT * FROM employees WHERE name LIKE '%n';

-- Names containing 'a'
SELECT * FROM employees WHERE name LIKE '%a%';

-- Names with 5 letters starting with 'R'
SELECT * FROM employees WHERE name LIKE 'R____';
```

---

## 7. IF-Else Based Query
```sql
SELECT name,
       CASE
           WHEN salary > 100000 THEN 'High'
           WHEN salary BETWEEN 50000 AND 100000 THEN 'Medium'
           ELSE 'Low'
       END AS salary_category
FROM employees;
```

---

## 8. Find Category-wise Top Value
(Top salary in each department)
```sql
SELECT department, name, salary
FROM employees e
WHERE salary = (
    SELECT MAX(salary)
    FROM employees
    WHERE department = e.department
);
```

---

## 9. Find Duplicate Records & Delete Duplicates
```sql
-- Find duplicates
SELECT name, COUNT(*) AS count
FROM employees
GROUP BY name
HAVING COUNT(*) > 1;

-- Delete duplicates (keep one)
DELETE e1
FROM employees e1
JOIN employees e2
ON e1.name = e2.name
AND e1.id > e2.id;
```

---

## 10. Joining Tables
```sql
-- Inner Join
SELECT e.name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.id;

-- Left Join
SELECT e.name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id;
```

---

# 📚 Database Theory

## 1. SQL vs NoSQL Databases
- **SQL**: Relational, schema-based, structured data. (e.g., MySQL, PostgreSQL)  
- **NoSQL**: Schema-less, unstructured or semi-structured. (e.g., MongoDB, Cassandra)

---

## 2. Tables Required for Many-to-Many Relationship
👉 Requires a **junction table**.

Example: Students & Courses  
- `students(student_id, name)`  
- `courses(course_id, course_name)`  
- `student_courses(student_id, course_id)`

---

## 3. Schema Design for Swiggy
- **Users(user_id, name, email, address)**  
- **Restaurants(rest_id, name, location, rating)**  
- **MenuItems(item_id, rest_id, name, price)**  
- **Orders(order_id, user_id, rest_id, order_date, status)**  
- **OrderItems(order_item_id, order_id, item_id, quantity, price)**  
- **Delivery(delivery_id, order_id, delivery_person, delivery_status)**  

---

## 4. Types of Joins & Union vs Union All
- **INNER JOIN**: Only matching rows.  
- **LEFT JOIN**: All from left + matching from right.  
- **RIGHT JOIN**: All from right + matching from left.  
- **FULL JOIN**: All from both (NULL where no match).  

👉 **Union vs Union All**  
- `UNION`: Removes duplicates.  
- `UNION ALL`: Keeps duplicates.

---

## 5. OLAP vs OLTP
- **OLTP (Online Transaction Processing)** → Normalized data, supports day-to-day operations (banking systems).  
- **OLAP (Online Analytical Processing)** → Denormalized, optimized for reporting & analytics (data warehouses).  

---

## 6. Database Keys
- **Primary Key**: Uniquely identifies a record.  
- **Foreign Key**: References another table’s primary key.  
- **Candidate Key**: All possible unique keys.  
- **Composite Key**: Combination of columns as a key.  
- **Unique Key**: Ensures unique values but allows NULL.

---

## 7. Types of Normalization
1NF → No repeating groups.  
2NF → No partial dependency.  
3NF → No transitive dependency.  
BCNF → Stronger form of 3NF.  

---

## 8. Indexes in Databases
Indexes speed up queries.  
- **Clustered Index**: Data stored in order of the index (only one per table).  
- **Non-clustered Index**: Separate structure (can have many).  
- **Composite Index**: Multiple columns in one index.  
- **Unique Index**: Ensures uniqueness.

---

## 9. Transactions & ACID Properties
**Transaction** = Group of SQL operations executed as a unit.  

- **A** → Atomicity (all or nothing)  
- **C** → Consistency (DB remains valid)  
- **I** → Isolation (transactions independent)  
- **D** → Durability (changes permanent after commit)  

---

## 10. Views & Stored Procedures
- **Views** → Virtual tables created from queries.  
- **Stored Procedures** → Precompiled SQL code stored in the DB for reuse.  

---

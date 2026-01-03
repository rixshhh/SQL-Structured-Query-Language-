# SQL Interview Questions & Database Concepts

This repository contains **commonly asked SQL queries and database theory concepts** that are helpful for interviews and revision.

---

## 📑 SQL Queries

### 1. Add Multiple Columns to a Table
```sql
ALTER TABLE employees
ADD (department VARCHAR(50), joining_date DATE);
```

### 2. Add/Delete Multiple Columns
```sql
-- Add multiple columns
ALTER TABLE employees
ADD (email VARCHAR(100), phone VARCHAR(20));

-- Delete multiple columns
ALTER TABLE employees
DROP COLUMN email,
DROP COLUMN phone;
```

### 3. Find the 2nd Highest Value
```sql
SELECT MAX(salary) AS second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);
```

### 4. Find Max Value Without Using ORDER BY
**Numeric Column Example:**
```sql
SELECT MAX(salary) AS highest_salary
FROM employees;
```

**If the column is VARCHAR:**  
SQL compares strings lexicographically, so the result may be wrong.
```sql
SELECT MAX(salary) FROM employees;
```
✅ Correct approach (cast to number):
```sql
-- MySQL
SELECT MAX(CAST(salary AS UNSIGNED)) AS highest_salary FROM employees;

-- PostgreSQL
SELECT MAX(CAST(salary AS INTEGER)) AS highest_salary FROM employees;

-- SQL Server
SELECT MAX(CAST(salary AS INT)) AS highest_salary FROM employees;
```

### 5. Find Managers of All Employees
```sql
SELECT e.name AS Employee, m.name AS Manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

### 6. Use of Wildcards
```sql
-- Names starting with 'A'
SELECT * FROM employees WHERE name LIKE 'A%';

-- Names ending with 'n'
SELECT * FROM employees WHERE name LIKE '%n';

-- Names containing 'ar'
SELECT * FROM employees WHERE name LIKE '%ar%';
```

### 7. IF ELSE Based Queries
```sql
SELECT name,
CASE
    WHEN salary > 100000 THEN 'High'
    WHEN salary BETWEEN 50000 AND 100000 THEN 'Medium'
    ELSE 'Low'
END AS salary_category
FROM employees;
```

### 8. Find Category-Wise Top Value
```sql
SELECT department, MAX(salary) AS highest_salary
FROM employees
GROUP BY department;
```

### 9. Find & Delete Duplicate Records (Nested Queries)
```sql
-- Find duplicates
SELECT name, COUNT(*) AS count
FROM employees
GROUP BY name
HAVING COUNT(*) > 1;

-- Delete duplicates (keep record with smallest id)
DELETE FROM employees
WHERE id NOT IN (
    SELECT MIN(id)
    FROM employees
    GROUP BY name
);
```

### 10. Joining Tables
```sql
-- INNER JOIN: only matching rows
SELECT e.name, d.department_name FROM employees e INNER JOIN departments d ON e.department_id = d.id;

-- LEFT JOIN: all rows from left + matches from right
SELECT e.name, d.department_name FROM employees e LEFT JOIN departments d ON e.department_id = d.id;

-- RIGHT JOIN: all rows from right + matches from left
SELECT e.name, d.department_name FROM employees e RIGHT JOIN departments d ON e.department_id = d.id;

-- FULL OUTER JOIN: all rows from both tables
SELECT e.name, d.department_name FROM employees e FULL OUTER JOIN departments d ON e.department_id = d.id;

-- CROSS JOIN: Cartesian product
SELECT e.name, d.department_name FROM employees e CROSS JOIN departments d;

-- SELF JOIN: table joined to itself (employee/manager)
SELECT e1.name AS Employee, e2.name AS Manager FROM employees e1 LEFT JOIN employees e2 ON e1.manager_id = e2.id;
```

---

## 📚 Database Theory

### 1. SQL vs NoSQL
| Feature | SQL (Relational) | NoSQL (Non-relational) |
|---------|-----------------|-----------------------|
| Data Model | Structured tables | Key-value, document, column, graph |
| Schema | Fixed schema | Dynamic / schema-less |
| Scalability | Vertical | Horizontal |
| Transactions | ACID | Some ACID, some BASE |
| Query Language | SQL | MongoDB: BSON, Cassandra: CQL |
| Use Case | Banking, ERP | Big Data, Social Media |

### 2. Many-to-Many Relationship
- Example: Students & Courses
```text
students(student_id, name)
courses(course_id, course_name)
student_courses(student_id, course_id) -- junction table
```
- One student can enroll in multiple courses; one course can have multiple students.

### 3. Schema Design for Swiggy
- Users(user_id, name, email, phone, address)  
- Restaurants(rest_id, name, location, rating)  
- MenuItems(item_id, rest_id, name, price)  
- Orders(order_id, user_id, rest_id, order_date, status)  
- OrderItems(order_item_id, order_id, item_id, quantity, price)  
- Delivery(delivery_id, order_id, delivery_person, status)

### 4. Joins & Union
- INNER JOIN → only matching rows  
- LEFT JOIN → all rows from left + matches from right  
- RIGHT JOIN → all rows from right + matches from left  
- FULL OUTER JOIN → all rows from both tables  
- CROSS JOIN → Cartesian product  
- SELF JOIN → table joined to itself  

**Union vs Union All**  
- `UNION` → combines results, removes duplicates  
- `UNION ALL` → combines results, keeps duplicates  

### 5. OLAP vs OLTP
| Feature | OLTP | OLAP |
|---------|------|------|
| Purpose | Day-to-day transactions | Data analysis & reporting |
| Data Structure | Normalized | Denormalized |
| Query Type | Simple | Complex |
| Examples | Banking, Retail | Data Warehouse, BI |

### 6. Database Keys
- Primary Key → Unique identifier  
- Foreign Key → References another table  
- Candidate Key → Possible primary key  
- Composite Key → Multiple columns as key  
- Unique Key → Unique values (NULL allowed)  

### 7. Normalization
- 1NF → atomic values, no repeating groups  
- 2NF → 1NF + no partial dependency  
- 3NF → 2NF + no transitive dependency  
- BCNF → stronger form of 3NF  

### 8. Indexes
- Clustered → table data stored in order  
- Non-clustered → separate index structure  
- Unique → ensures uniqueness  
- Composite → multiple columns  
- Full-text → optimized text search  

### 9. Transactions & ACID
- Transaction → unit of work  
- ACID: Atomicity, Consistency, Isolation, Durability  

### 10. Views & Stored Procedures
- Views → virtual table from query, simplify queries, enhance security  
- Stored Procedures → precompiled SQL, reusable, can take parameters, improve performance and security  

---

✅ This README covers both **SQL queries** and **Database Theory** for interview preparation and GitHub reference.

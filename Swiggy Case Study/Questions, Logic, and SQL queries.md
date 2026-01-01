# Swiggy Data Analysis Project (PostgreSQL)

This document explains the **questions, logic, and SQL queries** used to analyze the Swiggy dataset using **PostgreSQL** with **data validation**, **deduplication**, and **star schema dimensional modeling**.

---

## 1. Table Creation – Raw Data

**Question:** How do we store raw Swiggy order data?

**Explanation:**
We create a base table `Swiggy_data` to store raw transactional data exactly as received.

```sql
CREATE TABLE Swiggy_data (
    state VARCHAR(100),
    city VARCHAR(100),
    order_date DATE,
    restaurant_name VARCHAR(200),
    location VARCHAR(200),
    category VARCHAR(200),
    dish_name VARCHAR(200),
    price_inr DECIMAL(10, 2),
    rating DECIMAL(2, 1),
    rating_count INT
);
```

---

## 2. Data Validation

### 2.1 Fetch All Records

**Question:** How do we view all records?

```sql
SELECT * FROM Swiggy_data;
```

---

### 2.2 Null Value Check

**Question:** How many NULL values exist in each column?

**Explanation:**
We use conditional aggregation with `CASE` inside `SUM()`.

```sql
SELECT
    SUM(CASE WHEN state IS NULL THEN 1 ELSE 0 END) AS null_state,
    SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN restaurant_name IS NULL THEN 1 ELSE 0 END) AS null_restaurant_name,
    SUM(CASE WHEN location IS NULL THEN 1 ELSE 0 END) AS null_location,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN dish_name IS NULL THEN 1 ELSE 0 END) AS null_dish_name,
    SUM(CASE WHEN price_inr IS NULL THEN 1 ELSE 0 END) AS null_price,
    SUM(CASE WHEN rating IS NULL THEN 1 ELSE 0 END) AS null_rating,
    SUM(CASE WHEN rating_count IS NULL THEN 1 ELSE 0 END) AS null_rating_count
FROM Swiggy_data;
```

---

### 2.3 Blank or Empty Values

**Question:** How do we detect blank strings?

```sql
SELECT state, city
FROM Swiggy_data
WHERE state = '' OR city = '';
```

---

### 2.4 Duplicate Records Detection

**Question:** How do we identify duplicate rows?

```sql
SELECT
    state, city, order_date, restaurant_name, location,
    category, dish_name, price_inr, rating, rating_count,
    COUNT(*) AS count
FROM Swiggy_data
GROUP BY
    state, city, order_date, restaurant_name, location,
    category, dish_name, price_inr, rating, rating_count
HAVING COUNT(*) > 1;
```

---

### 2.5 Remove Duplicate Records

**Question:** How do we delete duplicates while keeping one record?

**Explanation:**
We use `ROW_NUMBER()` with PostgreSQL’s `ctid`.

```sql
WITH cte AS (
    SELECT ctid
    FROM (
        SELECT ctid,
               ROW_NUMBER() OVER (
                   PARTITION BY state, city, order_date, restaurant_name,
                                location, category, dish_name,
                                price_inr, rating, rating_count
                   ORDER BY ctid
               ) AS rn
        FROM Swiggy_data
    ) s
    WHERE rn > 1
)
DELETE FROM Swiggy_data
WHERE ctid IN (SELECT ctid FROM cte);
```

---

## 3. Dimensional Modeling (Star Schema)

### 3.1 Date Dimension

**Question:** How do we create a date dimension?

```sql
CREATE TABLE dim_date (
    date_id SERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    day INT,
    month INT,
    year INT,
    month_name TEXT,
    quarter INT,
    day_of_week INT,
    day_name TEXT
);
```

**Insert values:**

```sql
INSERT INTO dim_date (
    full_date, day, month, month_name, quarter,
    year, day_of_week, day_name
)
SELECT DISTINCT
    order_date,
    EXTRACT(DAY FROM order_date),
    EXTRACT(MONTH FROM order_date),
    TO_CHAR(order_date, 'Month'),
    EXTRACT(QUARTER FROM order_date),
    EXTRACT(YEAR FROM order_date),
    EXTRACT(DOW FROM order_date),
    TO_CHAR(order_date, 'Day')
FROM Swiggy_data
WHERE order_date IS NOT NULL;
```

---

### 3.2 Location Dimension

```sql
CREATE TABLE dim_location (
    location_id SERIAL PRIMARY KEY,
    state TEXT,
    city TEXT,
    location TEXT,
    UNIQUE (state, city, location)
);
```

```sql
INSERT INTO dim_location (state, city, location)
SELECT DISTINCT state, city, location FROM Swiggy_data;
```

---

### 3.3 Restaurant Dimension

```sql
CREATE TABLE dim_restaurant (
    restaurant_id SERIAL PRIMARY KEY,
    restaurant_name TEXT UNIQUE
);
```

```sql
INSERT INTO dim_restaurant (restaurant_name)
SELECT DISTINCT restaurant_name FROM Swiggy_data;
```

---

### 3.4 Dish Dimension

```sql
CREATE TABLE dim_dish (
    dish_key SERIAL PRIMARY KEY,
    dish_name TEXT,
    category TEXT,
    UNIQUE (dish_name, category)
);
```

```sql
INSERT INTO dim_dish (dish_name, category)
SELECT DISTINCT dish_name, category FROM Swiggy_data;
```

---

## 4. Fact Table

**Question:** How do we store measurable metrics?

```sql
CREATE TABLE fact_orders (
    order_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dim_date(date_id),
    location_key INT REFERENCES dim_location(location_id),
    restaurant_key INT REFERENCES dim_restaurant(restaurant_id),
    dish_key INT REFERENCES dim_dish(dish_key),
    price_inr NUMERIC,
    rating NUMERIC,
    rating_count INT
);
```

**Insert data:**

```sql
INSERT INTO fact_orders (
    date_key, location_key, restaurant_key, dish_key,
    price_inr, rating, rating_count
)
SELECT
    d.date_id, l.location_id, r.restaurant_id, di.dish_key,
    s.price_inr, s.rating, s.rating_count
FROM Swiggy_data s
JOIN dim_date d ON d.full_date = s.order_date
JOIN dim_location l ON l.state = s.state AND l.city = s.city AND l.location = s.location
JOIN dim_restaurant r ON r.restaurant_name = s.restaurant_name
JOIN dim_dish di ON di.dish_name = s.dish_name AND di.category = s.category;
```

---

## 5. KPIs & Business Questions

### Total Orders

```sql
SELECT COUNT(order_id) AS total_number_of_orders FROM fact_orders;
```

### Total Revenue (INR Million)

```sql
SELECT
    format('%s INR Million',
           TO_CHAR(SUM(price_inr) / 1000000, 'FM999,999,990.00'))
FROM fact_orders;
```

### Average Dish Price

```sql
SELECT
    format('%s INR', TO_CHAR(AVG(price_inr), 'FM999,999,990.00'))
FROM fact_orders;
```

### Average Rating

```sql
SELECT ROUND(AVG(rating), 2) FROM fact_orders;
```

---

## 6. Trend Analysis

### Monthly Trend

```sql
SELECT d.year, d.month, d.month_name,
       format('%s INR Million', TO_CHAR(SUM(f.price_inr)/1000000,'FM999,999,990.00')),
       COUNT(*)
FROM fact_orders f
JOIN dim_date d ON d.date_id = f.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
```

### Quarterly Trend

```sql
SELECT d.year, d.quarter,
       format('%s INR Million', TO_CHAR(SUM(f.price_inr)/1000000,'FM999,999,990.00')),
       COUNT(*)
FROM fact_orders f
JOIN dim_date d ON d.date_id = f.date_key
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;
```

---

## 7. Distribution Analysis

### Orders by Day of Week

```sql
SELECT d.day_of_week, d.day_name,
       TO_CHAR(SUM(f.price_inr)/1000000,'FM999,999,990.00') || ' INR Million',
       COUNT(*)
FROM fact_orders f
JOIN dim_date d ON d.date_id = f.date_key
GROUP BY d.day_of_week, d.day_name
ORDER BY d.day_of_week;
```

### Orders by Price Range

```sql
SELECT
    CASE
        WHEN price_inr < 100 THEN 'Under 100'
        WHEN price_inr BETWEEN 100 AND 199 THEN '100–199'
        WHEN price_inr BETWEEN 200 AND 299 THEN '200–299'
        WHEN price_inr BETWEEN 300 AND 499 THEN '300–499'
        ELSE '500+'
    END AS price_range,
    COUNT(*)
FROM fact_orders
GROUP BY price_range
ORDER BY COUNT(*) DESC;
```

---

## ✅ Summary

* Cleaned and validated raw Swiggy data
* Removed duplicates safely
* Built a **Star Schema**
* Created business KPIs
* Performed trend & distribution analysis

This structure is **analytics-ready** and suitable for **BI tools** like Power BI or Tableau.

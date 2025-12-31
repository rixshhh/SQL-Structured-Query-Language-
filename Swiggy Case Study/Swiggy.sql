CREATE TABLE Swiggy_data
(
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

-- TO Fetch all the Columns
Select *
from Swiggy_data;

-- Data Validation

-- How to check Null value
Select
    SUM(
        CASE
            WHEN state IS NULL THEN 1
            ELSE 0
        END
    ) AS null_state,
    SUM(
        CASE
            WHEN city IS NULL THEN 1
            ELSE 0
        END
    ) AS null_city,
    SUM(
        CASE
            WHEN order_date IS NULL THEN 1
            ELSE 0
        END
    ) AS null_order_date,
    SUM(
        CASE
            WHEN restaurant_name IS NULL THEN 1
            ELSE 0
        END
    ) AS null_restaurant_name,
    SUM(
        CASE
            WHEN location IS NULL THEN 1
            ELSE 0
        END
    ) AS null_location,
    SUM(
        CASE
            WHEN category IS NULL THEN 1
            ELSE 0
        END
    ) AS null_category,
    SUM(
        CASE
            WHEN dish_name IS NULL THEN 1
            ELSE 0
        END
    ) AS null_dish_name,
    SUM(
        CASE
            WHEN price_inr IS NULL THEN 1
            ELSE 0
        END
    ) AS null_price,
    SUM(
        CASE
            WHEN rating IS NULL THEN 1
            ELSE 0
        END
    ) AS null_rating,
    SUM(
        CASE
            WHEN rating_count IS NULL THEN 1
            ELSE 0
        END
    ) AS null_rating_count
from Swiggy_data;

-- Blank or Empty String
SELECT state, city
FROM Swiggy_data
WHERE state = '' or city = '';

-- Duplicate Records
SELECT
    state,
    city,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
    price_inr,
    rating,
    rating_count,
    COUNT(*) AS count
FROM Swiggy_data
GROUP BY
    state,
    city,
    order_date,
    restaurant_name,
    location,
    category,
    dish_name,
    price_inr,
    rating,
    rating_count
HAVING
    COUNT(*) > 1;

-- DELETE THE DUPLICATE RECORDS
WITH
    cte
    AS
    (
        SELECT ctid
        FROM (
                SELECT ctid, ROW_NUMBER() OVER (
                        PARTITION BY
                            state, city, order_date, restaurant_name, location, category, dish_name, price_inr, rating, rating_count
                        ORDER BY ctid
                    ) AS rn
            FROM Swiggy_data
            ) s
        WHERE
            rn > 1
    )
DELETE FROM Swiggy_data
WHERE
    ctid IN (
        SELECT ctid
FROM cte
    );

-- DIMENSIONAL MODELLING (STAR SCHEMA)

-- STEP 1 -> CREATE TABLE
CREATE TABLE dim_date
(
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

SELECT *
FROM dim_date;

-- STEP 2 -> INSERT THE VALUES
INSERT INTO dim_date
    (
    full_date, day, month, month_name, quarter, year, day_of_week, day_name
    )
SELECT DISTINCT
    order_date::DATE,
    EXTRACT(DAY FROM order_date::DATE),
    EXTRACT(MONTH FROM order_date::DATE),
    TO_CHAR(order_date::DATE, 'Month'),
    EXTRACT(QUARTER FROM order_date::DATE),
    EXTRACT(YEAR FROM order_date::DATE),
    EXTRACT(DOW FROM order_date::DATE),
    TO_CHAR(order_date::DATE, 'Day')
FROM Swiggy_data
WHERE order_date IS NOT NULL;

-- LOCATION DIMENSION
CREATE TABLE dim_location
(
    location_id SERIAL PRIMARY KEY,
    state TEXT,
    city TEXT,
    location TEXT,
    UNIQUE (state, city, location)
);

-- INSERT VALUES IN LOCATION_DIMENSION
INSERT INTO
    dim_location
    (state, city, location)
SELECT DISTINCT
    state,
    city,
    location
FROM Swiggy_data;

SELECT *
FROM dim_location;

-- RESTAURANT DIMENSION
CREATE TABLE dim_restaurant
(
    restaurant_id SERIAL PRIMARY KEY,
    restaurant_name TEXT UNIQUE
);

INSERT INTO
    dim_restaurant
    (restaurant_name)
SELECT DISTINCT
    restaurant_name
FROM Swiggy_data;

SELECT *
FROM dim_restaurant;

-- DISH DIMENSION
CREATE TABLE dim_dish
(
    dish_key SERIAL PRIMARY KEY,
    dish_name TEXT,
    category TEXT,
    UNIQUE (dish_name, category)
);

-- INSERT VALUE INTO DISH DIMENSION
INSERT INTO
    dim_dish
    (dish_name, category)
SELECT DISTINCT
    dish_name,
    category
FROM Swiggy_data;

SELECT *
FROM dim_dish;

-- FACT TABLE
CREATE TABLE fact_orders
(
    order_id SERIAL PRIMARY KEY,
    date_key INT REFERENCES dim_date (date_id),
    location_key INT REFERENCES dim_location (location_id),
    restaurant_key INT REFERENCES dim_restaurant (restaurant_id),
    dish_key INT REFERENCES dim_dish (dish_key),
    price_inr NUMERIC,
    rating NUMERIC,
    rating_count INT
);

INSERT INTO fact_orders
    (
    date_key, location_key, restaurant_key, dish_key,
    price_inr, rating, rating_count
    )
SELECT
    d.date_id,
    l.location_id,
    r.restaurant_id,
    di.dish_key,
    s.price_inr::NUMERIC,
    s.rating::NUMERIC,
    s.rating_count::INT
FROM Swiggy_data s
    JOIN dim_date d ON d.full_date = s.order_date::DATE
    JOIN dim_location l
    ON l.state = s.state
        AND l.city = s.city
        AND l.location = s.location
    JOIN dim_restaurant r
    ON r.restaurant_name = s.restaurant_name
    JOIN dim_dish di
    ON di.dish_name = s.dish_name
        AND di.category = s.category;

SELECT *
FROM fact_orders;

--KPI's

-- TOTAL NUMBER OF ORDERS
SELECT COUNT(order_id) AS Total_number_of_orders
FROM fact_orders;

-- TOTAL REVENUE (INR MILLIONS)
SELECT
    format(
        '%s INR Million',
        TO_CHAR(SUM(price_inr::NUMERIC) / 1000000, 'FM999,999,990.00')
    ) AS total_revenue
FROM fact_orders;

--AVERAGE DISH PRICE
SELECT
    format(
        '%s INR ',
        TO_CHAR(AVG(price_inr::NUMERIC), 'FM999,999,990.00')
    ) AS average_dish_price
FROM fact_orders;

-- AVERAGE RATING
SELECT ROUND(AVG(rating), 2) as average_rating
FROM fact_orders;

-- MONTHLY ORDER TRENDS
SELECT *
FROM dim_date;

SELECT
    d.month , d.month_name , d.year,
    format(
        '%s INR Million',
        TO_CHAR(SUM(price_inr::NUMERIC) / 1000000, 'FM999,999,990.00')
    ) AS total_revenue,
    COUNT(*) AS Total_count
from fact_orders f
    JOIN dim_date d on d.date_id = f.date_key
GROUP BY d.month ,d.month_name , d.year;

-- QUATERLY TREND
SELECT
    d.year,
    d.quarter,
    format(
        '%s INR Million',
        TO_CHAR(SUM(f.price_inr::NUMERIC) / 1000000, 'FM999,999,990.00')
    ) AS total_revenue,
    COUNT(*) AS total_count
FROM fact_orders f
    JOIN dim_date d
    ON d.date_id = f.date_key
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- YEARLY TREND
SELECT
    d.year,
    format(
        '%s INR Million',
        TO_CHAR(SUM(f.price_inr::NUMERIC) / 1000000, 'FM999,999,990.00')
    ) AS total_revenue,
    COUNT(*) AS total_count
FROM fact_orders f
    JOIN dim_date d
    ON d.date_id = f.date_key
GROUP BY d.year;

--ORDERS BY DAY OF WEEK [SUN-MON]
SELECT
    d.day_of_week,
    d.day_name,
    TO_CHAR(
        SUM(f.price_inr::NUMERIC) / 1000000,
        'FM999,999,990.00'
    ) || ' INR Million' AS total_revenue,
    COUNT(*) AS total_orders
FROM fact_orders f
    JOIN dim_date d
    ON d.date_id = f.date_key
GROUP BY d.day_of_week, d.day_name
ORDER BY d.day_of_week;

--TOP 10 CITIES BY ORDER VOLUMN
SELECT
    l.city,
    TO_CHAR(
        SUM(f.price_inr::NUMERIC) / 1000000,
        'FM999,999,990.00'
    ) || ' INR Million' AS total_revenue,
    COUNT(*) AS total_orders
FROM fact_orders f
    JOIN dim_location l on l.location_id = f.location_key
GROUP BY l.city
ORDER BY COUNT(*) DESC LIMIT 10;

--REVENUE CONTRIBUTION BY STATES
SELECT 
l.state,
TO_CHAR
(
        SUM
(f.price_inr::NUMERIC) / 1000000,
        'FM999,999,990.00'
    ) || ' INR Million' AS total_revenue,
COUNT(*) AS total_orders
FROM fact_orders f
JOIN dim_location l on l.location_id = f.location_key
GROUP BY l.state;

--TOP 10 RESTAURANT BY ORDERS
SELECT r.restaurant_name, COUNT(*) AS total_orders
FROM
    fact_orders f
    JOIN dim_restaurant r on r.restaurant_id = f.restaurant_key
GROUP BY
    r.restaurant_name
ORDER BY SUM(f.price_inr) DESC
LIMIT 10;

-- TOP CATEGORIES BY ORDER VALUES
SELECT 
di.category, COUNT
(*) AS total_orders
FROM fact_orders f
    JOIN dim_dish di on di.dish_key = f.dish_key
GROUP BY
    di.category
ORDER BY SUM
(f.price_inr) DESC
LIMIT 10;

--
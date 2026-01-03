# 🍔 Swiggy Sales Analytics – Power BI Project

## 📌 Project Overview

This project presents an end-to-end **Sales Analytics Dashboard** built using **PostgreSQL** as the backend database and **Power BI** for visualization. The dashboard analyzes Swiggy food order data to uncover insights related to **revenue, orders, locations, restaurants, categories, customer behavior, and pricing patterns**.



The project follows **industry best practices** including:

* Data cleaning & validation
* Star schema dimensional modeling
* KPI-driven dashboard design
* Business-focused storytelling


🔗 **Live Dashboard:** - [https://app.powerbi.com/view?r=eyJrIjoiZGJhMDZlZGUtZGYzZC00NTYzLTllYjQtOWUyYzY4YWIwYjZhIiwidCI6ImZiYmU2ZGI5LWE4YjItNGZhZi05MWEwLTQxNDUzYmQ3OWM2ZCJ9](https://app.powerbi.com/view?r=eyJrIjoiZGJhMDZlZGUtZGYzZC00NTYzLTllYjQtOWUyYzY4YWIwYjZhIiwidCI6ImZiYmU2ZGI5LWE4YjItNGZhZi05MWEwLTQxNDUzYmQ3OWM2ZCJ9
)

---

## 🧱 Data Architecture

### 🔹 Source

* CSV dataset containing Swiggy order-level data

### 🔹 Backend

* **PostgreSQL**
* Tables created:

  * `Swiggy_data` (raw table)
  * `dim_date`
  * `dim_location`
  * `dim_restaurant`
  * `dim_dish`
  * `fact_orders`

### 🔹 Modeling

* **Star Schema**
* Fact table linked to multiple dimensions using surrogate keys

---

## 📊 Power BI Dashboard Structure

The Power BI report contains **4 main pages**, each answering specific business questions.

---

## 📄 Page 1: Executive Overview

### 🎯 Objective

Provide a high-level snapshot of overall business performance.

### ✅ KPIs (Cards)

* **Total Orders**
* **Total Revenue (INR Million)**
* **Average Dish Price**
* **Average Rating**

### 📈 Visuals

* **Line Chart** – Monthly Revenue Trend
* **Column Chart** – Orders by Day of Week
* **Donut Chart** – Revenue by State (Top states)

### 🎛 Filters

* Year
* State
* Category

---

## 📄 Page 2: Location Insights

### 🎯 Objective

Understand geographical performance and city-level contribution.

### 📊 Visuals

* **Bar Chart** – Top 10 Cities by Orders
* **Table** – City-wise Orders & Revenue
* **Bar Chart** – Total Orders by Day Type (Weekday vs Weekend)

### 📍 Fields Used

* `dim_location[state]`
* `dim_location[city]`

> Note: Filled map visuals were restricted due to tenant settings, so alternative visuals were used.

---

## 📄 Page 3: Restaurants & Category Insights

### 🎯 Objective

Identify top-performing restaurants and food categories.

### 📊 Visuals

* **Bar Chart** – Top 10 Restaurants by Orders
* **Donut Chart** – Category Revenue Contribution
* **Bar Chart** – Orders by Category

### 🔍 Key Insights

* Major restaurant chains dominate order volume
* Recommended & Main Course categories contribute the highest revenue

---

## 📄 Page 4: Customer & Pricing Insights

### 🎯 Objective

Analyze customer behavior based on pricing and ratings.

### 📊 Visuals

* **Bar Chart** – Orders by Price Range
* **Donut Chart** – Revenue Contribution by Price Range
* **Column Chart** – Orders by Rating

### 💡 Insights

* Mid-range price bands (₹100–₹299) generate the highest demand
* Orders peak at rating **4.5**, indicating value-for-money preference

---

## 🧮 Key DAX Measures (KPIs)

```DAX
Total Orders = COUNT(fact_orders[order_id])

Total Revenue = SUM(fact_orders[price_inr])

Average Dish Price = AVERAGE(fact_orders[price_inr])

Average Rating = AVERAGE(fact_orders[rating])
```

---

## 🛠 Tools & Technologies

* **SQL** – Data cleaning, deduplication & aggregation
* **PostgreSQL** – Data storage & transformation
* **DAX** – KPI calculations & business logic
* **Power BI** – Data modeling & visualization

---

## 🎯 Business Value

This dashboard helps stakeholders:

* Track overall performance at a glance
* Identify high-performing locations, restaurants & categories
* Understand customer preferences based on price & ratings
* Support data-driven pricing and expansion strategies

---

## 📌 Conclusion

This project demonstrates a **complete analytics workflow** from raw data ingestion to executive-level dashboards. It reflects strong skills in **SQL, data modeling, Power BI visualization, and business analytics storytelling**.

---



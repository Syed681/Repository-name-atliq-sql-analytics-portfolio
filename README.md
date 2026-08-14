# AtliQ Hardware SQL Analytics Portfolio

A practical SQL analytics portfolio built using the **AtliQ Hardware dataset** in **MySQL Workbench**.

This repository demonstrates intermediate SQL and analytical SQL skills through business-focused problems involving sales, customers, products, forecasting, pricing, manufacturing costs, freight, and deductions.

The objective is not simply to collect solved SQL exercises. The project demonstrates how SQL can be used to **query, analyze, and derive insights from realistic business data**.

---

## Project Overview

The AtliQ Hardware database follows a **star-schema-style analytical structure** containing dimension tables and fact tables.

The portfolio progresses from core relational analysis to more advanced analytical and business problems.

### Database Structure

#### Dimension Tables

* `dim_customer`
* `dim_product`
* `dim_date`
* `dim_fiscal_year`

#### Fact Tables

* `fact_sales_monthly`
* `fact_forecast_monthly`
* `fact_gross_price`
* `fact_manufacturing_cost`
* `fact_freight_cost`
* `fact_pre_invoice_deductions`
* `fact_post_invoice_deductions`

#### Existing Analytical Views

* `fact_sales_monthly_fyear`
* `sales_preinv_discount`
* `sales_postinv_discount`
* `net_sales`
* `gross_sales`

---

## SQL Skills Demonstrated

### Relational Querying

* `SELECT`
* `WHERE`
* `ORDER BY`
* `LIMIT`
* `CASE WHEN`

### Joins & Aggregation

* `INNER JOIN`
* `LEFT JOIN`
* `GROUP BY`
* `HAVING`
* Aggregate functions
* Multi-table analysis

### CTEs & Subqueries

* Common Table Expressions
* Nested queries
* Multi-step analytical queries
* Multi-level aggregation

### Window Functions

* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`
* `PARTITION BY`
* `LAG()`
* Running totals
* Moving averages
* Window frames

### Time-Series Analysis

* Monthly analysis
* Month-over-month growth
* Year-over-year growth
* Previous-period comparison
* Customer-level time-series analysis

### Advanced Analytical SQL

* Top-N analysis
* Top-N within groups
* Percentage of total
* Latest-record analysis
* Customer activity analysis
* Ranking and comparative analysis

### Fact-Table Analysis

* Understanding table grain
* Fact-to-fact joins
* Actual vs forecast analysis
* Business KPI calculations

### Performance Awareness

* Query execution concepts
* `EXPLAIN`
* Index fundamentals
* Query optimization

---

## Important Analytical Concept: Fact Table Grain

A key part of this project is understanding **grain** before joining or aggregating data.

For example, `fact_sales_monthly` is approximately at the following grain:

```text
date + product_code + customer_code
```

with:

```text
sold_quantity
```

as the main measure.

`fact_forecast_monthly` is approximately at:

```text
date + fiscal_year + product_code + customer_code
```

with:

```text
forecast_quantity
```

as the measure.

Understanding grain helps prevent incorrect joins, duplicated rows, and incorrect business calculations when working with multiple fact tables.

---

## Repository Structure

```text
atliq-sql-analytics-portfolio/
│
├── README.md
│
├── 00_database/
│   ├── er_diagram.png
│   └── database_documentation.md
│
├── 01_joins_and_aggregation/
│   └── queries.sql
│
├── 02_ctes_and_subqueries/
│   └── queries.sql
│
├── 03_window_functions/
│   └── queries.sql
│
├── 04_time_series_analysis/
│   └── queries.sql
│
├── 05_advanced_analytical_sql/
│   └── queries.sql
│
├── 06_fact_table_analysis/
│   └── queries.sql
│
└── 07_business_analysis/
    ├── analysis.sql
    └── insights.md
```

---

## Portfolio Progression

```text
SQL Fundamentals
        ↓
Joins & Aggregation
        ↓
CTEs & Subqueries
        ↓
Window Functions
        ↓
Time-Series Analysis
        ↓
Advanced Analytical SQL
        ↓
Fact-Table Analysis
        ↓
Business Analysis & Insights
```

---

## Example Business Problems

The portfolio includes analytical questions such as:

* Which customers have the highest sales quantity?
* Who are the top 3 customers within each region?
* Which products contribute the most to total sales?
* What is the monthly sales growth?
* How does sales performance compare with the previous year?
* What is the running sales total?
* What is the three-month moving average?
* What is the latest sales record for each customer-product combination?
* How accurate is the sales forecast?
* Which products or customers demonstrate significant business performance?

---

## Analytical Approach

Each major analysis follows a simple structure:

```text
Business Question
        ↓
Analytical Approach
        ↓
SQL Query
        ↓
Result
        ↓
Business Insight
```

The focus is on writing SQL that solves realistic analytical problems rather than demonstrating syntax in isolation.

---

## Tools

* **MySQL**
* **MySQL Workbench**
* **GitHub**
* SQL

---

## Purpose

This project is part of my development toward **Data Analyst, BI, and Supply Chain Analytics roles**.

It demonstrates my ability to work with relational business data, perform analytical SQL, understand fact-table grain, calculate business metrics, and translate business questions into SQL-based analysis.

---

## Author

**Syed Aleem**

SQL Analytics Portfolio
Data Analytics | Business Intelligence | Supply Chain Analytics

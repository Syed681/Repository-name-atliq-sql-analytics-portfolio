````markdown
# AtliQ Hardware SQL Analytics Portfolio

A practical SQL analytics portfolio built using the **AtliQ Hardware dataset** in **MySQL Workbench**.

This repository demonstrates how SQL can be used to work with realistic business data, perform analytical calculations, and answer business questions across sales, customers, products, forecasting, pricing, costs, and supply-chain operations.

The project focuses on **intermediate SQL and analytical SQL**, with emphasis on:

- Joins and aggregation
- CTEs and subqueries
- Window functions
- Time-series analysis
- Advanced analytical SQL
- Fact-table analysis
- Business-focused analysis and insights

---

## Project Objective

The objective of this portfolio is to demonstrate practical SQL ability rather than simply collecting tutorial exercises.

The analysis progresses from relational querying to more advanced analytical problems and finally to business interpretation.

The project demonstrates how SQL can be used to:

- Combine fact and dimension data
- Calculate business metrics
- Compare performance over time
- Rank customers and products
- Analyze contribution and growth
- Compare actual sales with forecasts
- Analyze costs and deductions
- Translate business requirements into SQL
- Communicate analytical results in a business context

---

## Database

The project uses the **AtliQ Hardware database** in MySQL Workbench.

The database follows a **star-schema-style analytical structure** containing dimension tables, fact tables, and analytical views.

### Dimension Tables

- `dim_customer`
- `dim_product`
- `dim_date`
- `dim_fiscal_year`

### Fact Tables

- `fact_sales_monthly`
- `fact_forecast_monthly`
- `fact_gross_price`
- `fact_manufacturing_cost`
- `fact_freight_cost`
- `fact_pre_invoice_deductions`
- `fact_post_invoice_deductions`

### Analytical Views

- `fact_sales_monthly_fyear`
- `sales_preinv_discount`
- `sales_postinv_discount`
- `net_sales`
- `gross_sales`

---

## Database Grain

Understanding **table grain** is an important part of the analysis.

For example, `fact_sales_monthly` is approximately at the grain of:

```text
date + product_code + customer_code
````

with:

```text
sold_quantity
```

as the primary measure.

`fact_forecast_monthly` is approximately at:

```text
date + fiscal_year + product_code + customer_code
```

with:

```text
forecast_quantity
```

as the primary measure.

Understanding grain is important before joining fact tables because incorrect joins can create duplicated rows and incorrect business calculations.

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

# SQL Analysis Sections

## 01 — Joins & Aggregation

Focuses on combining fact and dimension tables and calculating business-level measures.

Topics include:

* INNER JOIN
* Multiple-table joins
* GROUP BY
* Aggregation
* Customer analysis
* Product analysis
* Regional analysis
* Gross sales calculations
* Deduction analysis

Example business questions:

* Which regions have the highest sales volume?
* Which customers generate the highest sales?
* Which products have the highest sales quantity?
* What is gross sales by market?

---

## 02 — CTEs & Subqueries

Focuses on breaking complex analytical problems into logical steps.

Topics include:

* Common Table Expressions
* Scalar subqueries
* Multi-step CTEs
* Aggregate-vs-aggregate analysis
* Customer and product comparisons
* Contribution calculations

Example business questions:

* Which products perform above average?
* Which customers generate above-average sales?
* What percentage of total sales comes from each product?
* Which products generate the highest net sales?

---

## 03 — Window Functions

Focuses on analytical calculations performed across related rows without collapsing the result set.

Topics include:

* `ROW_NUMBER()`
* `RANK()`
* `DENSE_RANK()`
* `PARTITION BY`
* `LAG()`
* `SUM() OVER()`
* `AVG() OVER()`
* Window frames
* Running totals
* Moving averages
* Latest-record analysis
* Percentage contribution

Example business questions:

* Who are the top 3 customers in each region?
* Which products rank highest within each division?
* What percentage of sales comes from each customer?
* What is the three-month moving average?
* What is the latest sales record for each customer-product combination?

---

## 04 — Time-Series Analysis

Focuses on understanding business performance over time.

Topics include:

* Monthly aggregation
* Previous-period comparison
* Month-over-month analysis
* Year-over-year analysis
* Customer-level trends
* Running sales
* Moving averages

Example business questions:

* How did sales change from the previous month?
* How did sales compare with the same month in the previous year?
* Which customers increased sales month over month?
* What is the short-term sales trend?

---

## 05 — Advanced Analytical SQL

Focuses on combining multiple SQL concepts to solve more complex business problems.

Topics include:

* Top-N analysis
* Top-N within groups
* Regional rankings
* Contribution analysis
* `NTILE()`
* Analytical CTEs
* Business-focused ranking

Example business questions:

* What are the top 3 products within each division?
* What are the top markets within each region?
* Which customers contribute the most to regional sales?
* Which customers belong to the highest sales segment?

---

## 06 — Fact-Table Analysis

Focuses on analyzing and safely combining business fact tables.

Topics include:

* Fact-table grain
* Fact-to-fact joins
* Actual vs forecast
* Gross sales
* Manufacturing cost
* Freight cost
* Pre-invoice deductions
* Post-invoice deductions
* Business KPI calculations

Example business questions:

* How accurate is the sales forecast?
* What is the variance between actual and forecast?
* Which products have higher manufacturing costs?
* Which markets have higher freight costs?
* What is gross sales by fiscal year or market?

---

## 07 — Business Analysis

The final section translates technical SQL analysis into business-oriented interpretation.

Business areas include:

* Regional sales performance
* Customer performance
* Product performance
* Forecast accuracy
* Market performance
* Manufacturing cost
* Freight cost
* Customer concentration

This section demonstrates the progression from:

```text
Business Question
        ↓
Analytical Approach
        ↓
SQL Query
        ↓
Business Metric
        ↓
Business Interpretation
```

The accompanying `insights.md` file documents the business relevance of the analysis.

---

# Key Analytical Concepts Demonstrated

### SQL

* SELECT
* WHERE
* CASE WHEN
* GROUP BY
* HAVING
* ORDER BY
* LIMIT
* INNER JOIN
* LEFT JOIN
* CTEs
* Subqueries
* Aggregate functions

### Analytical SQL

* Ranking
* Partitioning
* Running totals
* Moving averages
* Previous-period analysis
* Percentage contribution
* Top-N analysis
* Time-series analysis
* Latest-record analysis
* Fact-table analysis

### Business Analysis

* Sales performance
* Customer contribution
* Product performance
* Regional analysis
* Forecast accuracy
* Cost analysis
* Supply-chain analysis

---

# Business Context

The analysis is intentionally connected to business and operational use cases such as:

* Demand planning
* Supply planning
* Inventory planning
* Regional performance
* Customer concentration
* Product prioritization
* Logistics cost monitoring
* Forecast evaluation

This helps demonstrate SQL as an **analytical business tool**, rather than only a programming language.

---

# Tools

* **MySQL**
* **MySQL Workbench**
* **GitHub**
* **SQL**

---

# Portfolio Progression

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

# About This Portfolio

This project represents my progression from SQL querying to practical analytical SQL using a realistic business dataset.

The focus is on demonstrating the ability to:

* Query relational business data
* Join fact and dimension tables
* Aggregate business metrics
* Build multi-step analytical queries
* Use window functions
* Perform time-series analysis
* Understand fact-table grain
* Compare actual and forecast data
* Analyze business performance
* Translate business questions into SQL
* Communicate analytical findings

---

## Author

**Syed Aleem**

Data Analytics | Business Intelligence | Supply Chain Analytics

GitHub: [Syed681](https://github.com/Syed681)

```
```

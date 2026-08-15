# Database Schema

## Dimension Tables

### 1. `dim_customer`

Contains customer master information.

| Column | Description |
|---|---|
| `customer_code` | Unique customer identifier |
| `customer` | Customer name |
| `platform` | Customer platform/channel |
| `channel` | Sales/distribution channel |
| `market` | Customer market |
| `sub_zone` | Customer sub-zone |
| `region` | Customer region |

---

### 2. `dim_product`

Contains product master information.

| Column | Description |
|---|---|
| `product_code` | Unique product identifier |
| `division` | Product division |
| `segment` | Product segment |
| `category` | Product category |
| `product` | Product name |
| `variant` | Product variant |

---

### 3. `dim_date`

Contains calendar and fiscal-date information.

| Column | Description |
|---|---|
| `calender_date` | Calendar date |
| `fiscal_year` | Fiscal year associated with the date |

---

### 4. `dim_fiscal_year`

Contains fiscal-year mapping information.

| Column | Description |
|---|---|
| `calender_date` | Calendar date stored in the fiscal-year mapping |
| `fiscal_year` | Corresponding fiscal year |

---

# Fact Tables

## 5. `fact_sales_monthly`

Contains actual sales quantity.

Approximate grain:

```text
date + product_code + customer_code
````

| Column          | Description          |
| --------------- | -------------------- |
| `date`          | Sales date/month     |
| `product_code`  | Product identifier   |
| `customer_code` | Customer identifier  |
| `sold_quantity` | Actual quantity sold |

This is one of the primary analytical fact tables used throughout the portfolio.

---

## 6. `fact_forecast_monthly`

Contains forecasted sales quantity.

Approximate grain:

```text
date + fiscal_year + product_code + customer_code
```

| Column              | Description         |
| ------------------- | ------------------- |
| `date`              | Forecast date/month |
| `fiscal_year`       | Fiscal year         |
| `product_code`      | Product identifier  |
| `customer_code`     | Customer identifier |
| `forecast_quantity` | Forecasted quantity |

Used for actual-versus-forecast analysis.

---

## 7. `fact_gross_price`

Contains product gross pricing by fiscal year.

| Column         | Description          |
| -------------- | -------------------- |
| `product_code` | Product identifier   |
| `fiscal_year`  | Fiscal year          |
| `gross_price`  | Gross price per item |

Used to calculate gross sales.

Example:

```text
gross_sales =
sold_quantity × gross_price
```

---

## 8. `fact_manufacturing_cost`

Contains manufacturing cost information.

| Column               | Description        |
| -------------------- | ------------------ |
| `product_code`       | Product identifier |
| `cost_year`          | Cost year          |
| `manufacturing_cost` | Manufacturing cost |

Used for product cost analysis.

---

## 9. `fact_freight_cost`

Contains freight and other operational cost percentages.

| Column           | Description                       |
| ---------------- | --------------------------------- |
| `market`         | Market                            |
| `fiscal_year`    | Fiscal year                       |
| `freight_pct`    | Freight cost percentage           |
| `other_cost_pct` | Other operational cost percentage |

Used for logistics and market-level cost analysis.

---

## 10. `fact_pre_invoice_deductions`

Contains pre-invoice deduction information.

| Column                     | Description                     |
| -------------------------- | ------------------------------- |
| `customer_code`            | Customer identifier             |
| `fiscal_year`              | Fiscal year                     |
| `pre_invoice_discount_pct` | Pre-invoice discount percentage |

Used in pre-invoice discount analysis.

---

## 11. `fact_post_invoice_deductions`

Contains post-invoice deduction information.

| Column                 | Description                |
| ---------------------- | -------------------------- |
| `customer_code`        | Customer identifier        |
| `product_code`         | Product identifier         |
| `date`                 | Deduction date             |
| `discounts_pct`        | Discount percentage        |
| `other_deductions_pct` | Other deduction percentage |

Used in post-invoice deduction and net-sales analysis.

---

# Analytical Views

The database also contains the following analytical views:

### `fact_sales_monthly_fyear`

A sales-related analytical view containing fiscal-year information for sales analysis.

### `sales_preinv_discount`

Used for pre-invoice discount analysis.

### `sales_postinv_discount`

Used for post-invoice discount analysis.

### `net_sales`

Used for net-sales analysis after applicable deductions.

### `gross_sales`

Used for gross-sales analysis.

The `gross_sales` analysis combines sales, customer, product, and gross-price information.

---

# Important Relationships

The main analytical relationships follow the structure below:

```text
dim_customer
      │
      │ customer_code
      ▼
fact_sales_monthly
      │
      │ product_code
      ▼
dim_product
```

Sales can also be analysed with:

```text
fact_sales_monthly
        │
        ├──────── fact_gross_price
        │
        ├──────── fact_forecast_monthly
        │
        ├──────── fact_pre_invoice_deductions
        │
        └──────── fact_post_invoice_deductions
```

Additional cost analysis uses:

```text
dim_product
      │
      ├── fact_manufacturing_cost
      │
      └── fact_gross_price

dim_customer
      │
      └── fact_freight_cost
```

---

# Fact Table Grain

Understanding **grain** is critical when joining fact tables.

For example:

`fact_sales_monthly`

```text
date
+
product_code
+
customer_code
```

represents the level at which actual sales quantity is stored.

`fact_forecast_monthly` contains:

```text
date
+
fiscal_year
+
product_code
+
customer_code
```

When comparing actual sales with forecast data, the common analytical matching keys are:

```text
date
product_code
customer_code
```

This prevents duplicated rows and incorrect aggregation when combining fact tables.

---

# Key Business Measures

The database supports calculations such as:

```text
Total Sales Quantity
Gross Sales
Net Sales
Forecast Quantity
Forecast Variance
Forecast Accuracy
Manufacturing Cost
Freight Cost
Pre-Invoice Discounts
Post-Invoice Deductions
```

---

# Analytical Areas

The schema supports analysis across:

* Sales performance
* Customer performance
* Product performance
* Market performance
* Regional performance
* Forecast accuracy
* Gross sales
* Net sales
* Manufacturing costs
* Freight costs
* Discounts and deductions
* Supply-chain analysis

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
Business Analysis
```

---

# Tools

* MySQL
* MySQL Workbench
* GitHub
* SQL

````


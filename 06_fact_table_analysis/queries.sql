/*
==========================================================
06 - FACT TABLE ANALYSIS
AtliQ Hardware SQL Analytics Portfolio
==========================================================

Focus:
- Fact table grain
- Fact-to-fact joins
- Actual vs forecast
- Gross sales
- Manufacturing cost
- Freight cost
- Deduction analysis
- Business KPI calculations

Important:
Always understand the grain of each fact table before
joining multiple fact tables.
==========================================================
*/


/*
----------------------------------------------------------
Q01 - Understand Sales Fact Grain

Business Question:
What is the approximate number of records and unique
date-product-customer combinations in the sales fact?

Grain:
date + product_code + customer_code
----------------------------------------------------------
*/

SELECT
    COUNT(*) AS total_rows,
    COUNT(
        DISTINCT CONCAT(
            date, '|',
            product_code, '|',
            customer_code
        )
    ) AS unique_grain_combinations
FROM fact_sales_monthly;


/*
----------------------------------------------------------
Q02 - Actual Sales vs Forecast by Month

Business Question:
How did actual sales compare with forecast sales
for each month?

Important:
Both fact tables must first be aligned at the same grain:
date + product_code + customer_code.
----------------------------------------------------------
*/

WITH fact_comparison AS (
    SELECT
        s.date,
        s.product_code,
        s.customer_code,
        SUM(s.sold_quantity) AS actual_quantity,
        SUM(f.forecast_quantity) AS forecast_quantity
    FROM fact_sales_monthly AS s
    JOIN fact_forecast_monthly AS f
        ON s.date = f.date
        AND s.product_code = f.product_code
        AND s.customer_code = f.customer_code
    GROUP BY
        s.date,
        s.product_code,
        s.customer_code
),

monthly_comparison AS (
    SELECT
        YEAR(date) AS sales_year,
        MONTH(date) AS sales_month,
        SUM(actual_quantity) AS actual_quantity,
        SUM(forecast_quantity) AS forecast_quantity
    FROM fact_comparison
    GROUP BY
        YEAR(date),
        MONTH(date)
)

SELECT
    sales_year,
    sales_month,
    actual_quantity,
    forecast_quantity,
    actual_quantity - forecast_quantity AS variance,
    ROUND(
        100.0 *
        (actual_quantity - forecast_quantity)
        / NULLIF(forecast_quantity, 0),
        2
    ) AS variance_pct
FROM monthly_comparison
ORDER BY
    sales_year,
    sales_month;


/*
----------------------------------------------------------
Q03 - Forecast Accuracy by Month

Business Question:
What was the forecast accuracy for each month?

Formula:
Forecast Accuracy =
[1 - ABS(Actual - Forecast) / Forecast] × 100

A forecast value of zero is handled safely.
----------------------------------------------------------
*/

WITH fact_comparison AS (
    SELECT
        s.date,
        s.product_code,
        s.customer_code,
        SUM(s.sold_quantity) AS actual_quantity,
        SUM(f.forecast_quantity) AS forecast_quantity
    FROM fact_sales_monthly AS s
    JOIN fact_forecast_monthly AS f
        ON s.date = f.date
        AND s.product_code = f.product_code
        AND s.customer_code = f.customer_code
    GROUP BY
        s.date,
        s.product_code,
        s.customer_code
),

monthly_comparison AS (
    SELECT
        YEAR(date) AS sales_year,
        MONTH(date) AS sales_month,
        SUM(actual_quantity) AS actual_quantity,
        SUM(forecast_quantity) AS forecast_quantity
    FROM fact_comparison
    GROUP BY
        YEAR(date),
        MONTH(date)
)

SELECT
    sales_year,
    sales_month,
    actual_quantity,
    forecast_quantity,
    ABS(
        actual_quantity - forecast_quantity
    ) AS absolute_variance,
    ROUND(
        100.0 *
        (
            1 -
            ABS(actual_quantity - forecast_quantity)
            / NULLIF(forecast_quantity, 0)
        ),
        2
    ) AS forecast_accuracy_pct
FROM monthly_comparison
ORDER BY
    sales_year,
    sales_month;


/*
----------------------------------------------------------
Q04 - Gross Sales by Fiscal Year

Business Question:
What was the gross sales value generated in each
fiscal year?

Gross Sales =
sold_quantity × gross_price
----------------------------------------------------------
*/

SELECT
    s.fiscal_year,
    ROUND(
        SUM(
            s.sold_quantity * g.gross_price
        ) / 1000000,
        2
    ) AS gross_sales_mln
FROM fact_sales_monthly AS s
JOIN fact_gross_price AS g
    ON g.fiscal_year = s.fiscal_year
    AND g.product_code = s.product_code
GROUP BY s.fiscal_year
ORDER BY s.fiscal_year;


/*
----------------------------------------------------------
Q05 - Gross Sales by Market and Fiscal Year

Business Question:
Which markets generated the highest gross sales
in each fiscal year?

----------------------------------------------------------
*/

SELECT
    s.fiscal_year,
    c.market,
    ROUND(
        SUM(
            s.sold_quantity * g.gross_price
        ) / 1000000,
        2
    ) AS gross_sales_mln
FROM fact_sales_monthly AS s
JOIN fact_gross_price AS g
    ON g.fiscal_year = s.fiscal_year
    AND g.product_code = s.product_code
JOIN dim_customer AS c
    ON s.customer_code = c.customer_code
GROUP BY
    s.fiscal_year,
    c.market
ORDER BY
    s.fiscal_year,
    gross_sales_mln DESC;


/*
----------------------------------------------------------
Q06 - Manufacturing Cost by Product

Business Question:
What is the manufacturing cost associated with each
product and fiscal year?

SQL Concepts:
- Fact table aggregation
- Dimension lookup
----------------------------------------------------------
*/

SELECT
    p.product,
    m.cost_year,
    ROUND(
        AVG(m.manufacturing_cost),
        2
    ) AS manufacturing_cost
FROM fact_manufacturing_cost AS m
JOIN dim_product AS p
    ON m.product_code = p.product_code
GROUP BY
    p.product,
    m.cost_year
ORDER BY
    m.cost_year,
    manufacturing_cost DESC;


/*
----------------------------------------------------------
Q07 - Freight Cost by Market

Business Question:
How does freight cost percentage vary by market?

----------------------------------------------------------
*/

SELECT
    market,
    fiscal_year,
    freight_pct,
    other_cost_pct
FROM fact_freight_cost
ORDER BY
    fiscal_year,
    freight_pct DESC;


/*
----------------------------------------------------------
Q08 - Pre-Invoice Deduction Analysis

Business Question:
What is the average pre-invoice deduction percentage
for each customer and fiscal year?

----------------------------------------------------------
*/

SELECT
    customer_code,
    fiscal_year,
    ROUND(
        AVG(pre_invoice_discount_pct),
        2
    ) AS avg_pre_invoice_discount_pct
FROM fact_pre_invoice_deductions
GROUP BY
    customer_code,
    fiscal_year
ORDER BY
    fiscal_year,
    avg_pre_invoice_discount_pct DESC;


/*
----------------------------------------------------------
Q09 - Actual vs Forecast by Product

Business Question:
Which products have the largest difference between
actual sales and forecast quantity?

----------------------------------------------------------
*/

WITH product_comparison AS (
    SELECT
        s.product_code,
        SUM(s.sold_quantity) AS actual_quantity,
        SUM(f.forecast_quantity) AS forecast_quantity
    FROM fact_sales_monthly AS s
    JOIN fact_forecast_monthly AS f
        ON s.date = f.date
        AND s.product_code = f.product_code
        AND s.customer_code = f.customer_code
    GROUP BY s.product_code
)

SELECT
    product_code,
    actual_quantity,
    forecast_quantity,
    actual_quantity - forecast_quantity AS variance,
    ABS(
        actual_quantity - forecast_quantity
    ) AS absolute_variance
FROM product_comparison
ORDER BY absolute_variance DESC;


/*
----------------------------------------------------------
Q10 - Sales and Gross Sales by Customer

Business Question:
How much sales quantity and gross sales value does
each customer generate?

----------------------------------------------------------
*/

SELECT
    c.customer_code,
    c.customer,
    SUM(s.sold_quantity) AS total_sold_quantity,
    ROUND(
        SUM(
            s.sold_quantity * g.gross_price
        ) / 1000000,
        2
    ) AS gross_sales_mln
FROM fact_sales_monthly AS s
JOIN dim_customer AS c
    ON s.customer_code = c.customer_code
JOIN fact_gross_price AS g
    ON g.fiscal_year = s.fiscal_year
    AND g.product_code = s.product_code
GROUP BY
    c.customer_code,
    c.customer
ORDER BY gross_sales_mln DESC;

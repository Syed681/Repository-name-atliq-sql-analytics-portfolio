/*
==========================================================
04 - TIME-SERIES ANALYSIS
AtliQ Hardware SQL Analytics Portfolio
==========================================================

Focus:
- Monthly aggregation
- Previous-period comparison
- MoM analysis
- YoY analysis
- Growth calculations
- Customer-level time-series analysis
- Running performance trends
==========================================================
*/


/*
----------------------------------------------------------
Q01 - Monthly Sales

Business Question:
What is the total sales quantity for each month?

SQL Concepts:
- Date formatting
- GROUP BY
- SUM()
----------------------------------------------------------
*/

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS monthly_sales
    FROM fact_sales_monthly
    GROUP BY DATE_FORMAT(date, '%Y-%m-01')
)

SELECT
    sales_month,
    monthly_sales
FROM monthly_sales
ORDER BY sales_month;


/*
----------------------------------------------------------
Q02 - Month-over-Month Sales Growth

Business Question:
How did sales change compared with the previous month?

Formula:
MoM Change = Current Month Sales - Previous Month Sales

MoM Growth % =
(Current Month Sales - Previous Month Sales)
/
Previous Month Sales × 100
----------------------------------------------------------
*/

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS current_month_sales
    FROM fact_sales_monthly
    GROUP BY DATE_FORMAT(date, '%Y-%m-01')
),

monthly_comparison AS (
    SELECT
        sales_month,
        current_month_sales,
        LAG(current_month_sales) OVER (
            ORDER BY sales_month
        ) AS previous_month_sales
    FROM monthly_sales
)

SELECT
    sales_month,
    current_month_sales,
    previous_month_sales,
    current_month_sales - previous_month_sales AS mom_change,
    ROUND(
        100.0 *
        (current_month_sales - previous_month_sales)
        / NULLIF(previous_month_sales, 0),
        2
    ) AS mom_growth_pct
FROM monthly_comparison
ORDER BY sales_month;


/*
----------------------------------------------------------
Q03 - Year-over-Year Sales Growth

Business Question:
How did each month perform compared with the same
month in the previous year?

SQL Concepts:
- LAG(..., 12)
- Time-series ordering
----------------------------------------------------------
*/

WITH monthly_sales AS (
    SELECT
        YEAR(date) AS sales_year,
        MONTH(date) AS sales_month,
        DATE_FORMAT(date, '%Y-%m-01') AS month_key,
        SUM(sold_quantity) AS current_sales
    FROM fact_sales_monthly
    GROUP BY
        YEAR(date),
        MONTH(date),
        DATE_FORMAT(date, '%Y-%m-01')
),

year_comparison AS (
    SELECT
        sales_year,
        sales_month,
        month_key,
        current_sales,
        LAG(current_sales, 12) OVER (
            ORDER BY month_key
        ) AS previous_year_sales
    FROM monthly_sales
)

SELECT
    sales_year,
    sales_month,
    current_sales,
    previous_year_sales,
    current_sales - previous_year_sales AS yoy_change,
    ROUND(
        100.0 *
        (current_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0),
        2
    ) AS yoy_growth_pct
FROM year_comparison
ORDER BY month_key;


/*
----------------------------------------------------------
Q04 - Customer Month-over-Month Growth

Business Question:
Which customers increased their sales compared with
their previous active month?

SQL Concepts:
- GROUP BY
- LAG()
- PARTITION BY
- MoM comparison
----------------------------------------------------------
*/

WITH customer_monthly_sales AS (
    SELECT
        customer_code,
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS current_sales
    FROM fact_sales_monthly
    GROUP BY
        customer_code,
        DATE_FORMAT(date, '%Y-%m-01')
),

customer_comparison AS (
    SELECT
        customer_code,
        sales_month,
        current_sales,
        LAG(current_sales) OVER (
            PARTITION BY customer_code
            ORDER BY sales_month
        ) AS previous_sales
    FROM customer_monthly_sales
)

SELECT
    customer_code,
    sales_month,
    current_sales,
    previous_sales,
    ROUND(
        100.0 *
        (current_sales - previous_sales)
        / NULLIF(previous_sales, 0),
        2
    ) AS growth_pct
FROM customer_comparison
WHERE current_sales > previous_sales
ORDER BY
    customer_code,
    sales_month;


/*
----------------------------------------------------------
Q05 - Monthly Running Sales

Business Question:
How has cumulative sales quantity grown over time?

SQL Concepts:
- CTE
- SUM() OVER()
- Window frame
----------------------------------------------------------
*/

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS monthly_sales
    FROM fact_sales_monthly
    GROUP BY DATE_FORMAT(date, '%Y-%m-01')
)

SELECT
    sales_month,
    monthly_sales,
    SUM(monthly_sales) OVER (
        ORDER BY sales_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_sales
FROM monthly_sales
ORDER BY sales_month;


/*
----------------------------------------------------------
Q06 - Three-Month Moving Average

Business Question:
What is the short-term sales trend based on a
three-month moving average?

SQL Concepts:
- AVG() OVER()
- Window frame
----------------------------------------------------------
*/

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS monthly_sales
    FROM fact_sales_monthly
    GROUP BY DATE_FORMAT(date, '%Y-%m-01')
)

SELECT
    sales_month,
    monthly_sales,
    ROUND(
        AVG(monthly_sales) OVER (
            ORDER BY sales_month
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) AS three_month_moving_average
FROM monthly_sales
ORDER BY sales_month;


/*
----------------------------------------------------------
Q07 - Customer Sales Trend

Business Question:
How does each customer's monthly sales trend over time?

SQL Concepts:
- Date aggregation
- PARTITION BY
- LAG()
----------------------------------------------------------
*/

WITH customer_monthly_sales AS (
    SELECT
        customer_code,
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS monthly_sales
    FROM fact_sales_monthly
    GROUP BY
        customer_code,
        DATE_FORMAT(date, '%Y-%m-01')
)

SELECT
    customer_code,
    sales_month,
    monthly_sales,
    LAG(monthly_sales) OVER (
        PARTITION BY customer_code
        ORDER BY sales_month
    ) AS previous_month_sales
FROM customer_monthly_sales
ORDER BY
    customer_code,
    sales_month;


/*
----------------------------------------------------------
Q08 - Sales Growth by Year

Business Question:
How did total annual sales change from year to year?

SQL Concepts:
- Year-level aggregation
- LAG()
- Growth calculation
----------------------------------------------------------
*/

WITH yearly_sales AS (
    SELECT
        YEAR(date) AS sales_year,
        SUM(sold_quantity) AS annual_sales
    FROM fact_sales_monthly
    GROUP BY YEAR(date)
),

year_comparison AS (
    SELECT
        sales_year,
        annual_sales,
        LAG(annual_sales) OVER (
            ORDER BY sales_year
        ) AS previous_year_sales
    FROM yearly_sales
)

SELECT
    sales_year,
    annual_sales,
    previous_year_sales,
    annual_sales - previous_year_sales AS yoy_change,
    ROUND(
        100.0 *
        (annual_sales - previous_year_sales)
        / NULLIF(previous_year_sales, 0),
        2
    ) AS yoy_growth_pct
FROM year_comparison
ORDER BY sales_year;

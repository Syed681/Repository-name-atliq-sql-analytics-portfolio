/*
==========================================================
07 - BUSINESS ANALYSIS
AtliQ Hardware SQL Analytics Portfolio
==========================================================

Purpose:
Translate SQL analysis into business-focused questions.

Business Areas:
- Sales performance
- Customer performance
- Product performance
- Forecast accuracy
- Regional performance
- Cost and operational analysis
==========================================================
*/


/*
----------------------------------------------------------
Q01 - Regional Sales Performance

Business Question:
Which regions generate the highest sales quantity?

Business Use:
Helps management identify high-volume regions.
----------------------------------------------------------
*/

SELECT
    c.region,
    SUM(s.sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly AS s
JOIN dim_customer AS c
    ON s.customer_code = c.customer_code
GROUP BY c.region
ORDER BY total_sold_quantity DESC;


/*
----------------------------------------------------------
Q02 - Top Customers by Net Sales

Business Question:
Which customers contribute the most net sales?

Business Use:
Helps identify strategically important customers.
----------------------------------------------------------
*/

SELECT
    c.customer_code,
    c.customer,
    ROUND(
        SUM(n.net_sales) / 1000000,
        2
    ) AS net_sales_mln
FROM net_sales AS n
JOIN dim_customer AS c
    ON n.customer_code = c.customer_code
GROUP BY
    c.customer_code,
    c.customer
ORDER BY net_sales_mln DESC
LIMIT 10;


/*
----------------------------------------------------------
Q03 - Top Products by Net Sales

Business Question:
Which products generate the highest net sales?

Business Use:
Supports product prioritization and portfolio decisions.
----------------------------------------------------------
*/

SELECT
    product,
    ROUND(
        SUM(net_sales) / 1000000,
        2
    ) AS net_sales_mln
FROM net_sales
GROUP BY product
ORDER BY net_sales_mln DESC
LIMIT 10;


/*
----------------------------------------------------------
Q04 - Monthly Sales Performance

Business Question:
How has sales quantity changed month by month?

Business Use:
Supports trend monitoring and demand planning.
----------------------------------------------------------
*/

SELECT
    DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
    SUM(sold_quantity) AS monthly_sales
FROM fact_sales_monthly
GROUP BY DATE_FORMAT(date, '%Y-%m-01')
ORDER BY sales_month;


/*
----------------------------------------------------------
Q05 - Forecast Accuracy

Business Question:
How accurately does the forecast predict actual sales?

Business Use:
Helps evaluate forecasting performance and planning quality.
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
Q06 - Market Gross Sales

Business Question:
Which markets generate the highest gross sales?

Business Use:
Supports regional market prioritization.
----------------------------------------------------------
*/

SELECT
    c.market,
    ROUND(
        SUM(gs.gross_price_total) / 1000000,
        2
    ) AS gross_sales_mln
FROM gross_sales AS gs
JOIN dim_customer AS c
    ON gs.customer_code = c.customer_code
GROUP BY c.market
ORDER BY gross_sales_mln DESC;


/*
----------------------------------------------------------
Q07 - Manufacturing Cost by Product

Business Question:
Which products have the highest manufacturing cost?

Business Use:
Supports product cost and margin analysis.
----------------------------------------------------------
*/

SELECT
    p.product_code,
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
    p.product_code,
    p.product,
    m.cost_year
ORDER BY
    m.cost_year,
    manufacturing_cost DESC;


/*
----------------------------------------------------------
Q08 - Freight Cost by Market

Business Question:
Which markets have the highest freight cost percentage?

Business Use:
Supports logistics cost monitoring and operational planning.
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
Q09 - Regional Customer Concentration

Business Question:
How concentrated is net sales across customers within
each region?

Business Use:
Helps identify dependency on key customers.
----------------------------------------------------------
*/

WITH customer_sales AS (
    SELECT
        c.region,
        c.customer,
        ROUND(
            SUM(n.net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales AS n
    JOIN dim_customer AS c
        ON n.customer_code = c.customer_code
    GROUP BY
        c.region,
        c.customer
)

SELECT
    region,
    customer,
    net_sales_mln,
    ROUND(
        100.0 * net_sales_mln /
        SUM(net_sales_mln) OVER (
            PARTITION BY region
        ),
        2
    ) AS regional_sales_share_pct
FROM customer_sales
ORDER BY
    region,
    regional_sales_share_pct DESC;


/*
----------------------------------------------------------
Q10 - Business Performance Summary

Business Question:
What are the main sales KPIs across the business?

----------------------------------------------------------
*/

SELECT
    COUNT(DISTINCT customer_code) AS customers,
    COUNT(DISTINCT product_code) AS products,
    SUM(sold_quantity) AS total_units_sold,
    ROUND(
        SUM(sold_quantity * g.gross_price) / 1000000,
        2
    ) AS gross_sales_mln
FROM fact_sales_monthly AS s
JOIN fact_gross_price AS g
    ON g.fiscal_year = s.fiscal_year
    AND g.product_code = s.product_code;

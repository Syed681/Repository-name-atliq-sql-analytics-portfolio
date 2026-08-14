/*
==========================================================
02 - CTEs AND SUBQUERIES
AtliQ Hardware SQL Analytics Portfolio
==========================================================

Focus:
- Subqueries
- Correlated subqueries
- CTEs
- Multi-step analytical queries
- Aggregate vs aggregate comparisons
- Business-oriented analysis
==========================================================
*/


/*
----------------------------------------------------------
Q01 - Products Above Average Sales

Business Question:
Which products have total sales quantity above the
average product-level sales quantity?

Approach:
1. Aggregate sales by product.
2. Calculate the average of those product totals.
3. Compare each product against the average.

SQL Concepts:
- CTE
- Aggregate functions
- CROSS JOIN
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        product_code,
        SUM(sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly
    GROUP BY product_code
),

average_product_sales AS (
    SELECT
        AVG(total_sold_quantity) AS avg_product_sales
    FROM product_sales
)

SELECT
    p.product_code,
    p.total_sold_quantity,
    ROUND(a.avg_product_sales, 2) AS average_product_sales
FROM product_sales AS p
CROSS JOIN average_product_sales AS a
WHERE p.total_sold_quantity > a.avg_product_sales
ORDER BY p.total_sold_quantity DESC;


/*
----------------------------------------------------------
Q02 - Product Contribution to Total Sales

Business Question:
What percentage of total sales quantity does each product
contribute?

SQL Concepts:
- CTE
- Scalar subquery
- Aggregate comparison
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        product_code,
        SUM(sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly
    GROUP BY product_code
)

SELECT
    product_code,
    total_sold_quantity,
    ROUND(
        100.0 * total_sold_quantity /
        (
            SELECT SUM(total_sold_quantity)
            FROM product_sales
        ),
        2
    ) AS percentage_of_total
FROM product_sales
ORDER BY percentage_of_total DESC;


/*
----------------------------------------------------------
Q03 - Customers Above Average Sales

Business Question:
Which customers have total sales quantity above the
average customer-level sales quantity?

Approach:
1. Aggregate sales by customer.
2. Calculate average customer sales.
3. Filter customers above that average.
----------------------------------------------------------
*/

WITH customer_sales AS (
    SELECT
        customer_code,
        SUM(sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly
    GROUP BY customer_code
)

SELECT
    customer_code,
    total_sold_quantity
FROM customer_sales
WHERE total_sold_quantity > (
    SELECT AVG(total_sold_quantity)
    FROM customer_sales
)
ORDER BY total_sold_quantity DESC;


/*
----------------------------------------------------------
Q04 - Customer First and Latest Purchase

Business Question:
What are the first and latest sales dates for each customer?

SQL Concepts:
- GROUP BY
- MIN()
- MAX()
----------------------------------------------------------
*/

SELECT
    customer_code,
    MIN(date) AS first_purchase_date,
    MAX(date) AS latest_purchase_date
FROM fact_sales_monthly
GROUP BY customer_code
ORDER BY customer_code;


/*
----------------------------------------------------------
Q05 - Customers Active in Multiple Months

Business Question:
Which customers have sales activity across at least
three different months?

SQL Concepts:
- CTE
- COUNT(DISTINCT)
- HAVING
----------------------------------------------------------
*/

WITH customer_activity AS (
    SELECT
        customer_code,
        COUNT(DISTINCT DATE_FORMAT(date, '%Y-%m')) AS active_months
    FROM fact_sales_monthly
    GROUP BY customer_code
)

SELECT
    customer_code,
    active_months
FROM customer_activity
WHERE active_months >= 3
ORDER BY active_months DESC;


/*
----------------------------------------------------------
Q06 - Top Products by Net Sales for a Fiscal Year

Business Question:
Which products generate the highest net sales
for a selected fiscal year?

SQL Concepts:
- CTE
- Aggregation
- Business metric analysis

Note:
This query uses the existing net_sales analytical view.
----------------------------------------------------------
*/

WITH product_net_sales AS (
    SELECT
        product,
        ROUND(
            SUM(net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales
    WHERE fiscal_year = 2021
    GROUP BY product
)

SELECT
    product,
    net_sales_mln
FROM product_net_sales
ORDER BY net_sales_mln DESC
LIMIT 10;


/*
----------------------------------------------------------
Q07 - Top Customers by Net Sales for a Market

Business Question:
Which customers generate the highest net sales in a
specific market and fiscal year?

Parameters used in this example:
- Market: India
- Fiscal Year: 2021
----------------------------------------------------------
*/

WITH customer_net_sales AS (
    SELECT
        c.customer,
        s.market,
        s.fiscal_year,
        ROUND(
            SUM(s.net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales AS s
    JOIN dim_customer AS c
        ON s.customer_code = c.customer_code
    WHERE s.market = 'India'
      AND s.fiscal_year = 2021
    GROUP BY
        c.customer,
        s.market,
        s.fiscal_year
)

SELECT
    customer,
    market,
    fiscal_year,
    net_sales_mln
FROM customer_net_sales
ORDER BY net_sales_mln DESC
LIMIT 10;


/*
----------------------------------------------------------
Q08 - High-Profit Products with Below-Average Pricing

Business Question:
Which products generate high profit while remaining
below the average gross price?

Approach:
1. Calculate product-level gross sales and price.
2. Calculate the average product price.
3. Filter products above the selected profit threshold
   and below average price.

SQL Concepts:
- Multiple CTEs
- Aggregate calculations
- Subquery
----------------------------------------------------------
*/

WITH product_metrics AS (
    SELECT
        s.product_code,
        p.product,
        SUM(s.sold_quantity) AS total_quantity,
        AVG(g.gross_price) AS avg_gross_price,
        SUM(s.sold_quantity * g.gross_price) AS gross_sales
    FROM fact_sales_monthly AS s
    JOIN dim_product AS p
        ON s.product_code = p.product_code
    JOIN fact_gross_price AS g
        ON g.product_code = s.product_code
        AND g.fiscal_year = s.fiscal_year
    GROUP BY
        s.product_code,
        p.product
),

average_price AS (
    SELECT
        AVG(avg_gross_price) AS overall_avg_price
    FROM product_metrics
)

SELECT
    pm.product_code,
    pm.product,
    pm.total_quantity,
    ROUND(pm.avg_gross_price, 2) AS avg_gross_price,
    ROUND(pm.gross_sales, 2) AS gross_sales
FROM product_metrics AS pm
CROSS JOIN average_price AS ap
WHERE pm.avg_gross_price < ap.overall_avg_price
ORDER BY pm.gross_sales DESC;


/*
----------------------------------------------------------
Q09 - Top Products Above Average Sales

Business Question:
Which products are both among the strongest sellers
and above the average product-level sales quantity?

Approach:
1. Calculate total sales by product.
2. Calculate the average product sales.
3. Rank the products.
4. Keep products above the average.
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        product_code,
        SUM(sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly
    GROUP BY product_code
),

ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY total_sold_quantity DESC
        ) AS sales_rank
    FROM product_sales
)

SELECT
    rp.product_code,
    rp.total_sold_quantity,
    rp.sales_rank
FROM ranked_products AS rp
WHERE rp.total_sold_quantity > (
    SELECT AVG(total_sold_quantity)
    FROM product_sales
)
ORDER BY rp.sales_rank;


/*
----------------------------------------------------------
Q10 - High-Growth Business Candidates

Business Question:
Which products have sales above the product average
and belong to the top 20% of product sales?

SQL Concepts:
- Multiple CTEs
- Aggregate calculation
- NTILE()
- Subquery
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        product_code,
        SUM(sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly
    GROUP BY product_code
),

ranked_products AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY total_sold_quantity DESC
        ) AS sales_quintile
    FROM product_sales
)

SELECT
    product_code,
    total_sold_quantity,
    sales_quintile
FROM ranked_products
WHERE sales_quintile = 1
  AND total_sold_quantity > (
      SELECT AVG(total_sold_quantity)
      FROM product_sales
  )
ORDER BY total_sold_quantity DESC;

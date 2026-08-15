/*
==========================================================
05 - ADVANCED ANALYTICAL SQL
AtliQ Hardware SQL Analytics Portfolio
==========================================================

Focus:
- Top-N analysis
- Top-N within groups
- Regional rankings
- Percentage contribution
- Multi-step analytical CTEs
- Business-focused ranking
==========================================================
*/


/*
----------------------------------------------------------
Q01 - Top 3 Products per Division

Business Question:
Which three products have the highest sales quantity
within each division for FY2021?

SQL Concepts:
- CTE
- DENSE_RANK()
- PARTITION BY
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        p.division,
        p.product_code,
        p.product,
        SUM(s.sold_quantity) AS total_quantity
    FROM fact_sales_monthly AS s
    JOIN dim_product AS p
        ON s.product_code = p.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY
        p.division,
        p.product_code,
        p.product
),

ranked_products AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY division
            ORDER BY total_quantity DESC
        ) AS product_rank
    FROM product_sales
)

SELECT
    division,
    product_code,
    product,
    total_quantity,
    product_rank
FROM ranked_products
WHERE product_rank <= 3
ORDER BY
    division,
    product_rank;


/*
----------------------------------------------------------
Q02 - Top 2 Markets per Region by Gross Sales

Business Question:
Which two markets generate the highest gross sales
within each region for FY2021?

SQL Concepts:
- CTE
- Aggregation
- DENSE_RANK()
- PARTITION BY
----------------------------------------------------------
*/

WITH market_sales AS (
    SELECT
        c.region,
        c.market,
        ROUND(
            SUM(gs.gross_price_total) / 1000000,
            2
        ) AS gross_sales_mln
    FROM gross_sales AS gs
    JOIN dim_customer AS c
        ON gs.customer_code = c.customer_code
    WHERE gs.fiscal_year = 2021
    GROUP BY
        c.region,
        c.market
),

ranked_markets AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY gross_sales_mln DESC
        ) AS market_rank
    FROM market_sales
)

SELECT
    region,
    market,
    gross_sales_mln,
    market_rank
FROM ranked_markets
WHERE market_rank <= 2
ORDER BY
    region,
    market_rank;


/*
----------------------------------------------------------
Q03 - Customer Net Sales Contribution

Business Question:
What percentage of total FY2021 net sales is contributed
by each customer?

SQL Concepts:
- CTE
- Window aggregate
- Percentage of total
----------------------------------------------------------
*/

WITH customer_sales AS (
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
    WHERE n.fiscal_year = 2021
    GROUP BY
        c.customer_code,
        c.customer
)

SELECT
    customer_code,
    customer,
    net_sales_mln,
    ROUND(
        100 * net_sales_mln /
        SUM(net_sales_mln) OVER (),
        2
    ) AS pct_of_total_net_sales
FROM customer_sales
ORDER BY pct_of_total_net_sales DESC;


/*
----------------------------------------------------------
Q04 - Customer Net Sales Contribution by Region

Business Question:
What percentage of each region's FY2021 net sales is
contributed by each customer?

SQL Concepts:
- PARTITION BY
- Window aggregate
- Percentage contribution
----------------------------------------------------------
*/

WITH customer_region_sales AS (
    SELECT
        c.region,
        c.customer_code,
        c.customer,
        ROUND(
            SUM(n.net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales AS n
    JOIN dim_customer AS c
        ON n.customer_code = c.customer_code
    WHERE n.fiscal_year = 2021
    GROUP BY
        c.region,
        c.customer_code,
        c.customer
)

SELECT
    region,
    customer_code,
    customer,
    net_sales_mln,
    ROUND(
        100 * net_sales_mln /
        SUM(net_sales_mln) OVER (
            PARTITION BY region
        ),
        2
    ) AS pct_share_region
FROM customer_region_sales
ORDER BY
    region,
    pct_share_region DESC;


/*
----------------------------------------------------------
Q05 - Top 10 Customers by Net Sales

Business Question:
Who are the top 10 customers by net sales for FY2021?

SQL Concepts:
- CTE
- Aggregation
- Ranking
----------------------------------------------------------
*/

WITH customer_sales AS (
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
    WHERE n.fiscal_year = 2021
    GROUP BY
        c.customer_code,
        c.customer
),

ranked_customers AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY net_sales_mln DESC
        ) AS customer_rank
    FROM customer_sales
)

SELECT
    customer_code,
    customer,
    net_sales_mln,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 10
ORDER BY customer_rank;


/*
----------------------------------------------------------
Q06 - Top Products by Net Sales

Business Question:
Which products generated the highest net sales
during FY2021?

SQL Concepts:
- CTE
- Aggregation
- Ranking
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        product,
        ROUND(
            SUM(net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales
    WHERE fiscal_year = 2021
    GROUP BY product
),

ranked_products AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY net_sales_mln DESC
        ) AS product_rank
    FROM product_sales
)

SELECT
    product,
    net_sales_mln,
    product_rank
FROM ranked_products
WHERE product_rank <= 10
ORDER BY product_rank;


/*
----------------------------------------------------------
Q07 - Top Markets by Net Sales

Business Question:
Which markets generated the highest net sales
during FY2021?

SQL Concepts:
- Aggregation
- Ranking
----------------------------------------------------------
*/

WITH market_sales AS (
    SELECT
        market,
        ROUND(
            SUM(net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales
    WHERE fiscal_year = 2021
    GROUP BY market
),

ranked_markets AS (
    SELECT
        *,
        RANK() OVER (
            ORDER BY net_sales_mln DESC
        ) AS market_rank
    FROM market_sales
)

SELECT
    market,
    net_sales_mln,
    market_rank
FROM ranked_markets
WHERE market_rank <= 10
ORDER BY market_rank;


/*
----------------------------------------------------------
Q08 - Top Customer per Region

Business Question:
Who is the highest-selling customer within each region
for FY2021?

SQL Concepts:
- CTE
- DENSE_RANK()
- PARTITION BY
----------------------------------------------------------
*/

WITH customer_sales AS (
    SELECT
        c.region,
        c.customer_code,
        c.customer,
        ROUND(
            SUM(n.net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales AS n
    JOIN dim_customer AS c
        ON n.customer_code = c.customer_code
    WHERE n.fiscal_year = 2021
    GROUP BY
        c.region,
        c.customer_code,
        c.customer
),

ranked_customers AS (
    SELECT
        *,
        DENSE_RANK() OVER (
            PARTITION BY region
            ORDER BY net_sales_mln DESC
        ) AS customer_rank
    FROM customer_sales
)

SELECT
    region,
    customer_code,
    customer,
    net_sales_mln,
    customer_rank
FROM ranked_customers
WHERE customer_rank = 1
ORDER BY region;


/*
----------------------------------------------------------
Q09 - Product Contribution Within Division

Business Question:
What percentage of each division's sales quantity
comes from each product?

SQL Concepts:
- CTE
- SUM() OVER(PARTITION BY)
- Contribution analysis
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        p.division,
        p.product_code,
        p.product,
        SUM(s.sold_quantity) AS total_quantity
    FROM fact_sales_monthly AS s
    JOIN dim_product AS p
        ON s.product_code = p.product_code
    GROUP BY
        p.division,
        p.product_code,
        p.product
)

SELECT
    division,
    product_code,
    product,
    total_quantity,
    ROUND(
        100.0 * total_quantity /
        SUM(total_quantity) OVER (
            PARTITION BY division
        ),
        2
    ) AS pct_of_division_sales
FROM product_sales
ORDER BY
    division,
    pct_of_division_sales DESC;


/*
----------------------------------------------------------
Q10 - Top 20% Customers by Net Sales

Business Question:
Which customers belong to the highest sales quintile
for FY2021?

SQL Concepts:
- NTILE()
- Window functions
- CTE
----------------------------------------------------------
*/

WITH customer_sales AS (
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
    WHERE n.fiscal_year = 2021
    GROUP BY
        c.customer_code,
        c.customer
),

customer_quintiles AS (
    SELECT
        *,
        NTILE(5) OVER (
            ORDER BY net_sales_mln DESC
        ) AS sales_quintile
    FROM customer_sales
)

SELECT
    customer_code,
    customer,
    net_sales_mln,
    sales_quintile
FROM customer_quintiles
WHERE sales_quintile = 1
ORDER BY net_sales_mln DESC;

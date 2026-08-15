/*
==========================================================
03 - WINDOW FUNCTIONS
AtliQ Hardware SQL Analytics Portfolio
==========================================================

Focus:
- RANK()
- DENSE_RANK()
- ROW_NUMBER()
- PARTITION BY
- Percentage of total
- Percentage contribution by region
- Running totals
- Moving averages
- Latest-record analysis
==========================================================
*/


/*
----------------------------------------------------------
Q01 - Top 5 Customers Overall

Business Question:
Who are the top five customers by total sales quantity?

SQL Concepts:
- Aggregation
- RANK()
- Window ordering
----------------------------------------------------------
*/

WITH customer_sales AS (
    SELECT
        customer_code,
        SUM(sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly
    GROUP BY customer_code
),

ranked_customers AS 
  (SELECT
    customer_code,
    total_sold_quantity,
    RANK() OVER (
        ORDER BY total_sold_quantity DESC
    ) AS customer_rank
  
FROM customer_sales)
  SELECT
    customer_code,
    total_sold_quantity,
    customer_rank 
  from ranked_customers
  where customer_rank <=5
  order by total_sold_quantity DESC ;


/*
----------------------------------------------------------
Q02 - Top 3 Customers per Region

Business Question:
Who are the top three customers within each region?

Tie handling:
Customers with the same sales quantity receive the same rank.

SQL Concepts:
- JOIN
- GROUP BY
- DENSE_RANK()
- PARTITION BY
----------------------------------------------------------
*/

WITH customer_sales AS (
    SELECT
        c.region,
        c.customer_code,
        c.customer,
        SUM(s.sold_quantity) AS total_sold_quantity
    FROM fact_sales_monthly AS s
    JOIN dim_customer AS c
        ON s.customer_code = c.customer_code
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
            ORDER BY total_sold_quantity DESC
        ) AS customer_rank
    FROM customer_sales
)

SELECT
    region,
    customer_code,
    customer,
    total_sold_quantity,
    customer_rank
FROM ranked_customers
WHERE customer_rank <= 3
ORDER BY
    region,
    customer_rank;


/*
----------------------------------------------------------
Q03 - Top 3 Products per Division

Business Question:
Which three products have the highest sales quantity
within each division for FY2021?

SQL Concepts:
- JOIN
- CTE
- DENSE_RANK()
- PARTITION BY
----------------------------------------------------------
*/

WITH product_sales AS (
    SELECT
        p.division,
        p.product,
        SUM(s.sold_quantity) AS total_quantity
    FROM fact_sales_monthly AS s
    JOIN dim_product AS p
        ON s.product_code = p.product_code
    WHERE s.fiscal_year = 2021
    GROUP BY
        p.division,
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
Q04 - Customer Percentage Contribution

Business Question:
What percentage of total FY2021 net sales is contributed
by each customer?

SQL Concepts:
- CTE
- SUM() OVER()
- Percentage of total
----------------------------------------------------------
*/

WITH customer_sales AS (
    SELECT
        c.customer,
        ROUND(
            SUM(n.net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales AS n
    JOIN dim_customer AS c
        ON n.customer_code = c.customer_code
    WHERE n.fiscal_year = 2021
    GROUP BY c.customer
)

SELECT
    customer,
    net_sales_mln,
    ROUND(
        100 * net_sales_mln /
        SUM(net_sales_mln) OVER (),
        2
    ) AS pct_net_sales
FROM customer_sales
ORDER BY net_sales_mln DESC;


/*
----------------------------------------------------------
Q05 - Customer Sales Distribution by Region

Business Question:
What percentage of each region's FY2021 net sales
comes from each customer?

SQL Concepts:
- CTE
- PARTITION BY
- Percentage contribution
----------------------------------------------------------
*/

WITH customer_sales AS (
    SELECT
        c.customer,
        c.region,
        ROUND(
            SUM(n.net_sales) / 1000000,
            2
        ) AS net_sales_mln
    FROM net_sales AS n
    JOIN dim_customer AS c
        ON n.customer_code = c.customer_code
    WHERE n.fiscal_year = 2021
    GROUP BY
        c.customer,
        c.region
)

SELECT
    customer,
    region,
    net_sales_mln,
    ROUND(
        100 * net_sales_mln /
        SUM(net_sales_mln) OVER (
            PARTITION BY region
        ),
        2
    ) AS pct_share_region
FROM customer_sales
ORDER BY
    region,
    pct_share_region DESC;


/*
----------------------------------------------------------
Q06 - Running Sales Total

Business Question:
What is the cumulative sales quantity over time?

SQL Concepts:
- SUM() OVER()
- ORDER BY
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
    ) AS running_total
FROM monthly_sales
ORDER BY sales_month;


/*
----------------------------------------------------------
Q07 - Three-Month Moving Average

Business Question:
What is the three-month moving average of total sales?

SQL Concepts:
- AVG() OVER()
- ORDER BY
- ROWS BETWEEN
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
Q08 - Latest Sales Record per Customer/Product

Business Question:
What is the latest sales record for each
customer-product combination?

SQL Concepts:
- ROW_NUMBER()
- PARTITION BY
- ORDER BY
----------------------------------------------------------
*/

WITH ranked_sales AS (
    SELECT
        customer_code,
        product_code,
        date,
        sold_quantity,
        ROW_NUMBER() OVER (
            PARTITION BY
                customer_code,
                product_code
            ORDER BY date DESC
        ) AS rn
    FROM fact_sales_monthly
)

SELECT
    customer_code,
    product_code,
    date,
    sold_quantity
FROM ranked_sales
WHERE rn = 1;


/*
----------------------------------------------------------
Q09 - Monthly Previous Sales

Business Question:
How did monthly sales compare with the previous month?

SQL Concepts:
- LAG()
- Time-series ordering
----------------------------------------------------------
*/

WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS current_month_sales
    FROM fact_sales_monthly
    GROUP BY DATE_FORMAT(date, '%Y-%m-01')
)

SELECT
    sales_month,
    current_month_sales,
    LAG(current_month_sales) OVER (
        ORDER BY sales_month
    ) AS previous_month_sales
FROM monthly_sales
ORDER BY sales_month;


/*
----------------------------------------------------------
Q10 - Customer Month-over-Month Comparison

Business Question:
How does each customer's sales compare with their
previous active month?

SQL Concepts:
- LAG()
- PARTITION BY
- Time-series analysis
----------------------------------------------------------
*/

WITH customer_monthly_sales AS (
    SELECT
        customer_code,
        DATE_FORMAT(date, '%Y-%m-01') AS sales_month,
        SUM(sold_quantity) AS current_month_sales
    FROM fact_sales_monthly
    GROUP BY
        customer_code,
        DATE_FORMAT(date, '%Y-%m-01')
)

SELECT
    customer_code,
    sales_month,
    current_month_sales,
    LAG(current_month_sales) OVER (
        PARTITION BY customer_code
        ORDER BY sales_month
    ) AS previous_month_sales
FROM customer_monthly_sales
ORDER BY
    customer_code,
    sales_month;

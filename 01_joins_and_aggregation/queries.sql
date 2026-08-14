/*
==========================================================
01 - JOINS AND AGGREGATION
AtliQ Hardware SQL Analytics Portfolio
==========================================================
*/

/*
Q01 - Customers by Market

Business Question:
Which customers belong to the India market?
*/

SELECT
    customer_code,
    customer,
    market,
    region
FROM dim_customer
WHERE market = 'India';


/*
Q02 - Accessories Products

Business Question:
Which products belong to the Accessories segment?
*/

SELECT
    product_code,
    product,
    category
FROM dim_product
WHERE segment = 'Accessories';


/*
Q03 - Total Sold Quantity

Business Question:
What is the total quantity sold across the business?
*/

SELECT
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly;


/*
Q04 - Sales by Product

Business Question:
How many units were sold for each product?
*/

SELECT
    product_code,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
GROUP BY product_code;


/*
Q05 - Top 10 Products

Business Question:
Which 10 products have the highest sales quantity?
*/

SELECT
    product_code,
    SUM(sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly
GROUP BY product_code
ORDER BY total_sold_quantity DESC
LIMIT 10;


/*
Q06 - Sales by Division

Business Question:
Which product divisions generate the highest sales volume?
*/

SELECT
    p.division,
    SUM(s.sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly AS s
JOIN dim_product AS p
    ON s.product_code = p.product_code
GROUP BY p.division;


/*
Q07 - Top 5 Customers

Business Question:
Which five customers have the highest sales quantity?
*/

SELECT
    c.customer_code,
    c.customer,
    SUM(s.sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly AS s
JOIN dim_customer AS c
    ON s.customer_code = c.customer_code
GROUP BY
    c.customer_code,
    c.customer
ORDER BY total_sold_quantity DESC
LIMIT 5;


/*
Q08 - Sales by Region

Business Question:
How much quantity was sold in each region?
*/

SELECT
    c.region,
    SUM(s.sold_quantity) AS total_sold_quantity
FROM fact_sales_monthly AS s
JOIN dim_customer AS c
    ON s.customer_code = c.customer_code
GROUP BY c.region;

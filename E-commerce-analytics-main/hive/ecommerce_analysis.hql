-- E-Commerce Customer Purchase Analytics
-- HiveQL source code
-- Database and staging structure

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- Main transaction staging table
CREATE TABLE IF NOT EXISTS transactions_staging (
    order_id STRING,
    customer_id STRING,
    purchase_date STRING,
    product_id STRING,
    product_name STRING,
    category STRING,
    quantity INT,
    unit_price DOUBLE,
    discount_pct DOUBLE,
    total_amount DOUBLE,
    city STRING,
    payment_method STRING,
    customer_segment STRING
);

-- Example: monthly purchase trend
SELECT
    SUBSTR(purchase_date, 1, 7) AS month,
    ROUND(SUM(total_amount), 2) AS total_sales,
    COUNT(*) AS transactions
FROM transactions_staging
GROUP BY SUBSTR(purchase_date, 1, 7)
ORDER BY month;

-- Top cities by sales
SELECT
    city,
    ROUND(SUM(total_amount), 2) AS total_sales
FROM transactions_staging
GROUP BY city
ORDER BY total_sales DESC
LIMIT 5;

-- Payment method analysis
SELECT
    payment_method,
    COUNT(*) AS transactions,
    ROUND(SUM(total_amount), 2) AS total_sales
FROM transactions_staging
GROUP BY payment_method
ORDER BY total_sales DESC;

-- Category performance
SELECT
    category,
    COUNT(*) AS transactions,
    ROUND(SUM(total_amount), 2) AS total_sales
FROM transactions_staging
GROUP BY category
ORDER BY total_sales DESC;

-- Frequently bought together
-- Pair products within the same order and count occurrences.
SELECT
    a.product_id AS product_1,
    b.product_id AS product_2,
    COUNT(*) AS frequency
FROM transactions_staging a
JOIN transactions_staging b
  ON a.order_id = b.order_id
 AND a.product_id < b.product_id
GROUP BY a.product_id, b.product_id
ORDER BY frequency DESC;

-- Customer segmentation summary
SELECT
    customer_segment,
    COUNT(DISTINCT customer_id) AS customers,
    COUNT(*) AS transactions,
    SUM(quantity) AS quantity,
    ROUND(SUM(total_amount), 2) AS total_sales
FROM transactions_staging
GROUP BY customer_segment
ORDER BY total_sales DESC;

-- Customer behavior by city
SELECT
    city,
    ROUND(SUM(total_amount), 2) AS total_sales
FROM transactions_staging
GROUP BY city
ORDER BY total_sales DESC;

-- Recommendation evaluation:
-- Target product P004; compare recommended products with target-order
-- co-purchase relationships and calculate Top-5 hit rate.

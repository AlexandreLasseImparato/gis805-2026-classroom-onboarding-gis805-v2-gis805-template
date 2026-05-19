CREATE OR REPLACE TABLE fact_sales AS
SELECT
    order_number AS order_key,
    product_id AS product_key,
    customer_id AS customer_key,
    store_id AS store_key,
    channel_id AS channel_key,
    order_date AS date_key,
    order_number,
    sale_line_id,
    line_total
FROM raw_fact_sales;
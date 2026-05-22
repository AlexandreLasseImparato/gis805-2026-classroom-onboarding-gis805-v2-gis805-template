CREATE OR REPLACE TABLE dim_customer AS
SELECT
    customer_id AS customer_key,
    first_name || ' ' || last_name AS name,
    loyalty_segment AS segment,
    city,
    province AS region
FROM raw_dim_customer;
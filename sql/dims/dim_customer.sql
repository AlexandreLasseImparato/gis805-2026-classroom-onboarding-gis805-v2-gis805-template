CREATE OR REPLACE TABLE dim_customer AS
SELECT customer_id AS customer_key,
    customer_id,
    first_name || ' ' || last_name AS name,
    loyalty_segment AS segment,
    city,
    province AS region,
    TRUE AS is_current
FROM raw_dim_customer;
CREATE OR REPLACE TABLE dim_product AS
SELECT
    product_id AS product_id,
    product_name AS name,
    category,
    subcategory,
    brand
FROM raw_dim_product;
CREATE OR REPLACE TABLE dim_store AS
SELECT
    split_part(store_id, '-', 2) AS store_key,
    store_id,
    store_name AS name,
    city,
    region,
    province,
    DATE '2025-01-01' AS effective,
    NULL::DATE AS end,
    TRUE AS is_current
FROM raw_dim_store;

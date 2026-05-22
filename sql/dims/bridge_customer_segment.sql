CREATE OR REPLACE TABLE bridge_customer_segment AS
SELECT
    bridge_id,
    customer_id AS customer_key,
    segment,
    weight,
    effective_date,
    is_primary
FROM raw_bridge_customer_segment;
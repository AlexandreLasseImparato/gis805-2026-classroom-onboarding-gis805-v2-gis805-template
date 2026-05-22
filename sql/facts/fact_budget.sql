CREATE OR REPLACE TABLE fact_budget AS
SELECT
    budget_id,
    budget_month,
    category,
    store_id AS store_key,
    target_revenue,
    target_units
FROM raw_fact_budget;
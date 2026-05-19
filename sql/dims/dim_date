CREATE OR REPLACE TABLE dim_date AS
SELECT
    CAST(date_key AS VARCHAR) AS date_key,
    date_key AS date,
    month,
    quarter,
    year
FROM raw_dim_date;
CREATE OR REPLACE TABLE dim_channel AS
SELECT
    channel_id, dim_channel
    channel_name,
    channel_type
FROM raw_dim_channel;
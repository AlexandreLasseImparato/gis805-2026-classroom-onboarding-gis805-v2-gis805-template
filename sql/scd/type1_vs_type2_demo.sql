--Type1
--UPDATE dim_store
--SET region = 'Québec'
--WHERE store_id = 'STR-004';


--Type2
BEGIN TRANSACTION;
CREATE TEMP TABLE store_to_change AS
SELECT *
FROM dim_store
WHERE store_id = 'STR-004'
    AND is_current = TRUE;
UPDATE dim_store
SET "end" = DATE '2026-02-28',
    is_current = FALSE
WHERE store_id = 'STR-004'
    AND is_current = TRUE;
INSERT INTO dim_store (
        store_key,
        store_id,
        name,
        city,
        region,
        province,
        effective,
        "end",
        is_current
    )
SELECT lpad(
        CAST(
            (
                SELECT MAX(CAST(store_key AS INTEGER)) + 1
                FROM dim_store
            ) AS VARCHAR
        ),
        3,
        '0'
    ) AS store_key,
    store_id,
    name,
    city,
    'Québec' AS region,
    province,
    DATE '2026-03-01' AS effective,
    NULL::DATE AS "end",
    TRUE AS is_current
FROM store_to_change;
DROP TABLE store_to_change;
COMMIT;
Quels changements dans notre dimensions doivent garder la vérité historique et lesquels peuvent être écrasés?

Pour que le changement soit possible, le type2, la table dim_store doit être restructurée avec des nouveaux champs et aura la configuration suivante :

store_key    VARCHAR
store_id     VARCHAR
name         VARCHAR
city         VARCHAR
region       VARCHAR
province     VARCHAR
effective    DATE
end          DATE
is_current   BOOLEAN

soit la requete de creation:

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

Les champs nécessaires pour créer l’historique en fonction d’un filtre de date sont :
effectiveDate - date
endDate - date
Is_Current - boolean

À chaque changement de statut de la table, les modifications par colonne sont:

store_key: type2 clé unique, ajoute nouvelle clé
store_id : type2 ID associé au nome
name : Type 2 – changement doivent garder les noms passés
city : Type 2 – le magasin peut être relocalisé dans une autre ville et le changement doit être historisé
region : Type 2 – la région doit suivre la migration de segmentation
province : Type 2 – le magasin peut être relocalisé dans une autre province et le changement doit être historisé
effectiveDate : type 1 – represente la valeur de l'insertion de la donnée.
endDate : Type 1 – uniquement correction. Doit être modifiée lorsqu’il y a un changement dans la ligne et représente la dernière date de modification de la ligne.
Is_Current: Type 1 - indication si la valeur de la ligne est active. Valeur boolean: true | false

À chaque changement type1 le nouvelle valeur va écrasér la valeur actuel.
À chaque changement Type2:
La novelle valeur va remplacer l'ancient selon le champ necessaire en utilisant une nouvelle ligne.
EndDate va avoir la date du changement type2
Is_currence recevra la valeur False poir indiquer une novelle ligne sera crée
Une nouvelle ligne sera créé

TEST TYPE 1

UPDATE dim_store
SET region = 'Québec'
WHERE store_id = 'STR-004';

store_key store_id  name               city      region  province effective   end  is_current
004       STR-004   NexaMart Gatineau  Gatineau  Québec  QC       2025-01-01  NaT  True


REQUETE TEST POUR LES VENTES JANVIER ET MAGASIN NEXAMART GATINEAU

SELECT
    f.order_number,
    f.sale_line_id,
    f.date_key,
    f.store_key,
    d.store_id,
    d.name,
    d.region,
    d.effective,
    d."end",
    f.line_total
FROM fact_sales f
JOIN dim_store d
  ON f.store_key = d.store_key
 AND f.date_key >= d.effective
 AND (d."end" IS NULL OR f.date_key <= d."end")
WHERE f.date_key >= DATE '2025-01-01'
  AND f.date_key < DATE '2025-02-01'
  AND d.name = 'NexaMart Gatineau'
ORDER BY f.date_key, f.order_number, f.sale_line_id;

LE RESULTAT TYPE 1

order_number  sale_line_id  date_key    store_key  store_id  name               region  effective   end  line_total
ORD-000324    1032          2025-01-09  004        STR-004   NexaMart Gatineau  Québec  2025-01-01  NaT  147.57

CONCLUSION¸

C’est exactement le comportement d’un SCD Type 1 : l’historique est écrasé. Les ventes passées montrent maintenant la nouvelle région.
--------


TEST TYPE 2

TRIGGER TYPE2


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

LE RESULTAT DU CHANGEMENT

store_key store_id  name               city      region     province effective   end         is_current
004       STR-004   NexaMart Gatineau  Gatineau  Outaouais  QC       2025-01-01  2026-02-28  False
011       STR-004   NexaMart Gatineau  Gatineau  Québec     QC       2026-03-01  NaT         True

REQUETE TEST POUR LES VENTES JANVIER ET MAGASIN NEXAMART GATINEAU

SELECT
    f.order_number,
    f.sale_line_id,
    f.date_key,
    f.store_key,
    d.store_id,
    d.name,
    d.region,
    d.effective,
    d."end",
    f.line_total
FROM fact_sales f
JOIN dim_store d
  ON f.store_key = d.store_key
 AND f.date_key >= d.effective
 AND (d."end" IS NULL OR f.date_key <= d."end")
WHERE f.date_key >= DATE '2025-01-01'
  AND f.date_key < DATE '2025-02-01'
  AND d.name = 'NexaMart Gatineau'
ORDER BY f.date_key, f.order_number, f.sale_line_id;

LE RESULTAT DE LA REQUETE

order_number  sale_line_id  date_key    store_key  store_id  name               region     effective   end         line_total
ORD-000324    1032          2025-01-09  004        STR-004   NexaMart Gatineau  Outaouais  2025-01-01  2026-02-28  147.57
ORD-000324    1033          2025-01-09  004        STR-004   NexaMart Gatineau  Outaouais  2025-01-01  2026-02-28  64.38
ORD-000324    1034          2025-01-09  004        STR-004   NexaMart Gatineau  Outaouais  2025-01-01  2026-02-28  84.64

Conclusion : pour janvier 2025, NexaMart Gatineau est bien rattaché à la région historique Outaouais, car la nouvelle version Québec commence seulement le 2026-03-01.
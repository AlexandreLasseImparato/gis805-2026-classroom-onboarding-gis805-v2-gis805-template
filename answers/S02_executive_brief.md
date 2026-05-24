Granularité - Grain statement
La granularité dépend surtout des tables de faits, Fact_sales et elle est construit par ligne d'enregistrement, qui contient une ligne de vente dasn une commande, donc chaque ligne représente un produit vendu dans une commande, avec son montant line_total. La nité de cet activité peut être analisé de cet facon au niveau unitaire de la ligne de vente:
1 ligne = 1 ligne de commande vendue, analysable par produit, client, date, magasin et canal
Une preuve est le montant de vente avec ces dimention est composé par plusieurs lignes, le champ Sale_line_id sert à identifier chaque ligne individuellement de vente
Pour valider la granuralité
SELECT
    order_number,
    sale_line_id,
    COUNT(*) AS nb_lignes
FROM fact_sales
GROUP BY order_number, sale_line_id
ORDER BY nb_lignes DESC
LIMIT 10;

le resultat
order_number  sale_line_id  nb_lignes
ORD-000001    2             1
ORD-000002    6             1
ORD-000003    8             1
ORD-000003    9             1
ORD-000004    13            1
ORD-000004    14            1
ORD-000006    23            1
ORD-000008    26            1
ORD-000008    28            1
ORD-000009    30            1
1 ligne = 1 combinaison unique order_number + sale_line_id

--------
SQL preuve

La requete pour repondre la question
SELECT
    p.category,
    s.region,
    d.quarter,
    SUM(f.line_total) AS total_revenue,
    COUNT(*) AS nb_lignes
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_id
JOIN dim_store   s ON f.store_key   = s.store_key
JOIN dim_date    d ON f.date_key    = d.date_key
GROUP BY p.category, s.region, d.quarter
ORDER BY total_revenue DESC
LIMIT 10;

category          region  quarter  total_revenue  nb_lignes
Pet Supplies      Québec  3        17463.45       44
Pet Supplies      Québec  4        14412.87       38
Pet Supplies      Québec  2        14330.36       33
Toys & Games      Québec  1        13026.77       41
Beauty & Health   Québec  1        12015.02       40
Toys & Games      Québec  3        11653.13       40
Books & Media     Québec  3        11597.80       31
Pet Supplies      Québec  1        11508.89       33
Books & Media     Québec  2        10544.54       36
Automotive        Québec  4        10137.06       22

Pour expliquer le resultat

SELECT
    c.channel_name,
    c.channel_type,
    SUM(CASE WHEN d.quarter = 3 THEN f.line_total ELSE 0 END) AS revenue_q3,
    SUM(CASE WHEN d.quarter = 4 THEN f.line_total ELSE 0 END) AS revenue_q4,
    SUM(CASE WHEN d.quarter = 4 THEN f.line_total ELSE 0 END)
      - SUM(CASE WHEN d.quarter = 3 THEN f.line_total ELSE 0 END) AS variation,
    ROUND(
        (
            SUM(CASE WHEN d.quarter = 4 THEN f.line_total ELSE 0 END)
            - SUM(CASE WHEN d.quarter = 3 THEN f.line_total ELSE 0 END)
        )
        / NULLIF(SUM(CASE WHEN d.quarter = 3 THEN f.line_total ELSE 0 END), 0)
        * 100,
        2
    ) AS variation_pct
FROM fact_sales f
JOIN dim_product p ON f.product_key = p.product_id
JOIN dim_store s ON f.store_key = s.store_key
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_channel c ON f.channel_key = c.channel_id
WHERE p.category = 'Pet Supplies'
  AND s.region = 'Québec'
  AND d.quarter IN (3, 4)
GROUP BY c.channel_name, c.channel_type
HAVING
    SUM(CASE WHEN d.quarter = 4 THEN f.line_total ELSE 0 END)
    < SUM(CASE WHEN d.quarter = 3 THEN f.line_total ELSE 0 END)
ORDER BY variation ASC;

Cette requête affiche seulement les channels où le revenu de Q4 est plus bas que Q3 selon la category 'Pet Supplies'.

channel_name    channel_type  revenue_q3  revenue_q4  variation  variation_pct
E-Commerce Web  online        3903.19     718.16      -3185.03   -81.60
Mobile App      online        3777.30     2625.34     -1151.96   -30.50
In-Store        physical      3917.70     2822.15     -1095.55   -27.96

Le channel avec le plus gros déclin est E-Commerce Web, avec une baisse de 3185.03, soit -81.60 %.


Maintenent il y a une base des données qui peut repondre aux besoins d'information avec la modèlisation étoile.

------------
Étoile:

Visualisation du modèle étoile dans le fichier schema-va.png

![alt text](image-1.png)
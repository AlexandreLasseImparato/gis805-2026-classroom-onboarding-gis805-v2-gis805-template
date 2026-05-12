# Trace d'usage IA — GIS805

> Chaque interaction significative avec un outil IA doit être documentée ici.
> Ce fichier est **obligatoire** et évalué à chaque remise.

## Format par entrée

```
### YYYY-MM-DD — Séance SXX
- **Modèle :** (ChatGPT-4o, Claude, Copilot, etc.)
- **Prompt :** (copier-coller exact)
- **Résultat :** (résumé de ce que l'IA a produit)
- **Validation :** (comment vous avez vérifié/modifié le résultat)
- **Justification :** (pourquoi cette interaction était nécessaire)
```

---

### 2026-01-XX — Séance S00 *(exemple — supprimez cette entrée quand vous ajoutez les vôtres)*
- **Modèle :** GitHub Copilot Chat
- **Prompt :** « Qu'est-ce qui se trouve dans mon dépôt ? Explique-moi la structure du projet. »
- **Résultat :** Copilot a listé les dossiers principaux (sql/, answers/, data/, docs/) et expliqué le rôle de chacun dans le contexte d'un entrepôt dimensionnel.
- **Validation :** J'ai comparé la réponse avec le README.md et le contenu réel des dossiers — tout correspondait.
- **Justification :** Première prise de contact avec le dépôt ; je voulais comprendre l'organisation avant de lancer les commandes.

<!-- Ajoutez vos entrées ci-dessous -->
2026-01-09 — Séance S02

nem des tables les 24 du jeux des données
0 h 49
Worked for 1m 18s
Voici les 24 fichiers/tables du jeu de données NexaMart :
1.	dim_channel
2.	dim_customer
3.	dim_date
4.	dim_product
5.	dim_store
6.	fact_sales — version S02
7.	customer_changes
8.	store_changes
9.	order_lines
10.	orders
11.	fact_budget
12.	fact_inventory_snapshot
13.	fact_returns
14.	fact_sales — version S06
15.	customer_profile_bands
16.	dim_geography
17.	fact_shipment
18.	bridge_campaign_allocation
19.	bridge_customer_segment
20.	customer_scd3_history
21.	dim_segment_outrigger
22.	fact_daily_inventory
23.	fact_order_pipeline
24.	fact_orders_transaction
25.	fact_promo_exposure
Petite nuance : le dictionnaire liste 25 entrées, mais il y a deux fact_sales.csv dans deux séances différentes (s02 et s06). Dans DuckDB, avec le préfixe raw_, ça peut devenir une seule table raw_fact_sales si une version remplace l’autre. Donc tu peux dire : 24 tables uniques attendues environ, selon le chargement, ou 25 fichiers CSV listés dans le dictionnaire.
0 h 50
est-ce que tu est capable d'utiliser duckdb?
0 h 50
Oui, je peux utiliser DuckDB dans ce projet.
Par exemple, je peux lancer des requêtes sur db/nexamart.duckdb pour lister les tables, compter les lignes, afficher les colonnes, ou vérifier une requête SQL. La commande type serait :
quelle table peut donner la dimention de caterorie pour ces ventes?
0 h 53
La table qui donne la dimension de catégorie pour les ventes est :
dim_product
Dans fact_sales, tu as seulement :
product_id
Pour obtenir la catégorie du produit vendu, il faut faire une jointure avec dim_product :
SELECT
    fs.sale_line_id,
    fs.order_number,
    fs.product_id,
    dp.product_name,
    dp.category,
    fs.quantity,
    fs.line_total
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id;
Si tu travailles avec les tables brutes chargées par DuckDB, utilise plutôt :
FROM raw_fact_sales fs
JOIN raw_dim_product dp
    ON fs.product_id = dp.product_id
0 h 53
quelle est la table peux donner la dimention des regions pour ces ventes
0 h 54
La table qui donne la dimension des régions pour les ventes est :
dim_store
Dans fact_sales, tu as seulement :
store_id
Pour obtenir la région de la vente, il faut joindre fact_sales avec dim_store :
SELECT
    fs.sale_line_id,
    fs.order_number,
    fs.store_id,
    ds.store_name,
    ds.city,
    ds.region,
    fs.quantity,
    fs.line_total
FROM fact_sales fs
JOIN dim_store ds
    ON fs.store_id = ds.store_id;
Si tu utilises les tables brutes dans DuckDB :
FROM raw_fact_sales fs
JOIN raw_dim_store ds
    ON fs.store_id = ds.store_id
0 h 54
fact_sales, dim_product et dim_store. avec ces trois tables j'ai ventes par categorie et region?
0 h 56
Oui, exactement.
Avec ces trois tables :
fact_sales
dim_product
dim_store
tu peux obtenir les ventes par catégorie et par région.
Rôle de chaque table :
fact_sales   = montants des ventes
dim_product  = catégorie du produit
dim_store    = région du magasin
Requête SQL possible :
SELECT
    dp.category,
    ds.region,
    SUM(fs.line_total) AS total_ventes
FROM fact_sales fs
JOIN dim_product dp
    ON fs.product_id = dp.product_id
JOIN dim_store ds
    ON fs.store_id = ds.store_id
GROUP BY
    dp.category,
    ds.region
ORDER BY
    dp.category,
    ds.region;
Si tes tables sont en version brute DuckDB, utilise :
SELECT
    dp.category,
    ds.region,
    SUM(fs.line_total) AS total_ventes
FROM raw_fact_sales fs
JOIN raw_dim_product dp
    ON fs.product_id = dp.product_id
JOIN raw_dim_store ds
    ON fs.store_id = ds.store_id
GROUP BY
    dp.category,
    ds.region
ORDER BY
    dp.category,
    ds.region;
Fait une analyse pourquoi les categories declinent en utilisant DIM Channel
1 h 12
Worked for 38s
Oui. En ajoutant dim_channel, on voit dans quels canaux la baisse se produit entre novembre 2025 et décembre 2025.
Les plus grosses baisses par catégorie + type de canal sont :
category             channel_type   nov_2025   dec_2025   variation
Automotive           online          7,237.02   2,566.53  -4,670.49
Pet Supplies         phone           5,952.90   3,161.06  -2,791.84
Beauty & Health      online          6,206.82   3,717.51  -2,489.31
Books & Media        online          5,960.00   3,571.97  -2,388.03
Beauty & Health      physical        2,166.02     393.01  -1,773.01
Toys & Games         phone           1,842.35     117.97  -1,724.38
Pet Supplies         online          7,458.96   5,818.11  -1,640.85
Toys & Games         online          3,830.44   2,223.71  -1,606.73
Home & Garden        phone           1,425.79     191.85  -1,233.94
Sports & Outdoors    online          2,226.67   1,198.38  -1,028.29
Analyse courte :
Le déclin semble surtout venir du canal online. Plusieurs catégories importantes baissent fortement en ligne : Automotive, Beauty & Health, Books & Media, Pet Supplies, Toys & Games, Sports & Outdoors.
Le canal phone explique aussi une partie importante du déclin, surtout pour Pet Supplies, Toys & Games et Home & Garden.
Le canal physical est moins généralisé, mais il est très marqué pour Beauty & Health, qui passe de 2,166.02 à 393.01, soit une baisse de -81.9%.
Donc, avec dim_channel, l’hypothèse la plus forte est :
Les catégories déclinent principalement à cause d’une baisse des ventes dans les canaux online, puis phone.
1 h 13
Quelles catégories de produits déclinent, dans quelles régions, et pourquoi Quelle est le channel ? utilise la periode des deux dernier mois
1 h 15
Worked for 33s
J’ai utilisé les deux derniers mois disponibles dans la BD : novembre 2025 et décembre 2025.
Voici les principaux déclins, avec le channel qui explique le plus la baisse :
Catégorie          Région      Channel             Type       Nov       Dec       Baisse
Beauty & Health   Québec      In-Store            physical   2062.60    113.80  -1948.80
Automotive        Estrie      Mobile App          online     1753.39      0.00  -1753.39
Pet Supplies      Estrie      Telephone Orders    phone      2149.69    466.65  -1683.04
Pet Supplies      Québec      Telephone Orders    phone      1915.45    366.00  -1549.45
Automotive        Québec      E-Commerce Web      online     1426.28      0.00  -1426.28
Pet Supplies      Outaouais   Marketplace 3P      online     1087.62      0.00  -1087.62
Toys & Games      Québec      E-Commerce Web      online     1075.76      0.00  -1075.76
Books & Media     Estrie      Marketplace 3P      online     1124.92    136.29   -988.63
Beauty & Health   Ontario     Telephone Orders    phone       988.40      0.00   -988.40
Books & Media     Québec      In-Store            physical   1378.62    405.17   -973.45
Analyse : les catégories déclinent surtout parce que certains channels chutent fortement entre novembre et décembre.
Le problème semble principalement venir de :
online   → E-Commerce Web, Mobile App, Marketplace 3P
phone    → Telephone Orders
physical → In-Store, mais surtout pour Beauty & Health au Québec
Donc la réponse courte :
Les déclins les plus importants sont liés surtout aux channels online et phone. Par exemple, Automotive décline en Estrie à cause de Mobile App, Pet Supplies décline en Estrie et Québec à cause de Telephone Orders, et Toys & Games décline en Québec à cause de E-Commerce Web.
1 h 15
quelle est la requete sql utilisé pour le dernier resultat
1 h 16
Voici la requête SQL utilisée pour le dernier résultat :
WITH months AS (
    SELECT DISTINCT
        date_trunc('month', CAST(order_date AS DATE)) AS mois
    FROM raw_fact_sales
    ORDER BY mois DESC
    LIMIT 2
),

bounds AS (
    SELECT
        MIN(mois) AS prev_month,
        MAX(mois) AS last_month
    FROM months
),

sales AS (
    SELECT
        dp.category,
        ds.region,
        dc.channel_name,
        dc.channel_type,
        date_trunc('month', CAST(fs.order_date AS DATE)) AS mois,
        SUM(fs.line_total) AS ventes
    FROM raw_fact_sales fs
    JOIN raw_dim_product dp
        ON fs.product_id = dp.product_id
    JOIN raw_dim_store ds
        ON fs.store_id = ds.store_id
    JOIN raw_dim_channel dc
        ON fs.channel_id = dc.channel_id
    CROSS JOIN bounds b
    WHERE date_trunc('month', CAST(fs.order_date AS DATE)) IN (
        b.prev_month,
        b.last_month
    )
    GROUP BY
        dp.category,
        ds.region,
        dc.channel_name,
        dc.channel_type,
        date_trunc('month', CAST(fs.order_date AS DATE))
),

pivoted AS (
    SELECT
        category,
        region,
        channel_name,
        channel_type,
        SUM(CASE WHEN mois = (SELECT prev_month FROM bounds) THEN ventes ELSE 0 END) AS mois_avant,
        SUM(CASE WHEN mois = (SELECT last_month FROM bounds) THEN ventes ELSE 0 END) AS dernier_mois
    FROM sales
    GROUP BY
        category,
        region,
        channel_name,
        channel_type
),

declines AS (
    SELECT
        *,
        dernier_mois - mois_avant AS variation
    FROM pivoted
    WHERE dernier_mois < mois_avant
),

ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY category, region
            ORDER BY variation ASC
        ) AS rn
    FROM declines
)

SELECT
    category,
    region,
    channel_name,
    channel_type,
    ROUND(mois_avant, 2) AS mois_avant,
    ROUND(dernier_mois, 2) AS dernier_mois,
    ROUND(variation, 2) AS baisse,
    ROUND(
        100 * variation / NULLIF(mois_avant, 0),
        1
    ) AS baisse_pct
FROM ranked
WHERE rn = 1
ORDER BY baisse ASC
LIMIT 25;
Cette requête prend automatiquement les 2 derniers mois présents dans raw_fact_sales, puis trouve le channel qui explique le plus la baisse pour chaque combinaison category + region.
1 h 16
donne moi le même resultat mais utilise 4 mois dernier, entre septembre et decembre
1 h 17
Worked for 36s
Voici le même résultat, mais sur les 4 derniers mois, en comparant septembre 2025 à décembre 2025. Le tableau montre, pour chaque catégorie/région, le channel qui explique le plus la baisse.
Catégorie            Région      Channel             Type       Sep       Dec       Baisse
Pet Supplies         Québec      Mobile App          online     3093.74   1268.60  -1825.14
Beauty & Health      Ontario     E-Commerce Web      online     1520.61      0.00  -1520.61
Automotive           Ontario     E-Commerce Web      online     1389.78      0.00  -1389.78
Toys & Games         Québec      Telephone Orders    phone      1269.48      0.00  -1269.48
Pet Supplies         Estrie      Mobile App          online     1193.57      0.00  -1193.57
Toys & Games         Ontario     E-Commerce Web      online     1174.01      0.00  -1174.01
Books & Media        Alberta     Marketplace 3P      online      960.95      0.00   -960.95
Books & Media        BC          Mobile App          online      876.97      0.00   -876.97
Home & Garden        Québec      E-Commerce Web      online      968.53    170.40   -798.13
Automotive           Alberta     Telephone Orders    phone       778.85      0.00   -778.85
Beauty & Health      Alberta     Marketplace 3P      online      743.94      0.00   -743.94
Pet Supplies         Ontario     Mobile App          online      711.24      0.00   -711.24
Pet Supplies         Alberta     In-Store            physical    682.56      0.00   -682.56
Automotive           Outaouais   In-Store            physical    655.88      0.00   -655.88
Toys & Games         Alberta     Marketplace 3P      online      951.92    310.50   -641.42
Conclusion : sur septembre à décembre, le déclin est surtout expliqué par le channel online (Mobile App, E-Commerce Web, Marketplace 3P). Le channel phone apparaît aussi pour certaines catégories comme Toys & Games et Automotive, mais il est moins dominant que le online.
1 h 17
pour valider, Pour avoir la periode different, la requete sql est la même il y a le changement juste dans le parametre - periode?
1 h 20
Oui, exactement.
La logique de la requête reste la même. Ce qui change principalement, c’est la période dans le WHERE et les mois utilisés dans le CASE WHEN.
Par exemple, pour septembre à décembre 2025, tu as :
WHERE CAST(fs.order_date AS DATE) >= DATE '2025-09-01'
  AND CAST(fs.order_date AS DATE) < DATE '2026-01-01'
Et dans le pivot :
SUM(CASE WHEN mois = DATE '2025-09-01' THEN ventes ELSE 0 END) AS sep_2025,
SUM(CASE WHEN mois = DATE '2025-12-01' THEN ventes ELSE 0 END) AS dec_2025
Si tu veux comparer novembre à décembre 2025, tu changes pour :
WHERE CAST(fs.order_date AS DATE) >= DATE '2025-11-01'
  AND CAST(fs.order_date AS DATE) < DATE '2026-01-01'
Et :
SUM(CASE WHEN mois = DATE '2025-11-01' THEN ventes ELSE 0 END) AS nov_2025,
SUM(CASE WHEN mois = DATE '2025-12-01' THEN ventes ELSE 0 END) AS dec_2025
Donc oui : même requête, mais paramètres de période différents. Il faut seulement faire attention que le mois de début et le mois de fin soient aussi changés dans les CASE WHEN.
1 h 20
fait un grafique de barre horizontal avec le dernier resultat
1 h 21
Worked for 42s
J’ai créé le graphique en barres horizontales ici :
declins_categories_regions_channels_sep_dec_2025.png
Il montre les plus fortes baisses entre septembre 2025 et décembre 2025, avec l’étiquette :
Catégorie | Région | Channel
et la valeur de baisse des ventes sur chaque barre.
declins_categories_regions_channels_sep_dec_2025.pngImage · PNG
Open
1 h 22
ouvre le contenu
1 h 22
Worked for 10s
Voici le graphique ouvert. Il montre les 15 plus fortes baisses entre septembre 2025 et décembre 2025.
La plus grande baisse est :
Pet Supplies | Québec | Mobile App : -1,825
Ensuite :
Beauty & Health | Ontario | E-Commerce Web : -1,521
Automotive | Ontario | E-Commerce Web : -1,390
Toys & Games | Québec | Telephone Orders : -1,269


dans fact_sales Champ : order_number combient des valeurs distincts il y a?
1 h 45
Worked for 13s
Dans raw_fact_sales, le champ order_number contient :
881 valeurs distinctes
Requête utilisée :
SELECT COUNT(DISTINCT order_number) AS nb_order_number_distincts
FROM raw_fact_sales;
1 h 46
dans fact_sales combient de lignes existe?
1 h 46
Worked for 13s
Dans raw_fact_sales, il y a :
2 805 lignes
Requête utilisée :
SELECT COUNT(*) AS nb_lignes
FROM raw_fact_sales;
1 h 47
une commande contient plusieurs lignes?
1 h 47
Oui, exactement.
Dans fact_sales, une commande est identifiée par :
order_number
Mais la table est au grain ligne de vente, donc une même commande peut apparaître plusieurs fois.
Pourquoi? Parce qu’une commande peut contenir plusieurs produits.
Exemple logique :
order_number   product_id   quantity
ORD-000001     PRD-0005     1
ORD-000001     PRD-0012     2
ORD-000001     PRD-0044     1
Ici, la commande ORD-000001 contient 3 lignes.
Dans tes données :
2 805 lignes dans fact_sales
881 commandes distinctes
Donc en moyenne :
2 805 / 881 ≈ 3.18 lignes par commande
Oui : une commande contient souvent plusieurs lignes dans fact_sales.
1 h 47
est-ce que il y a une description dans la table de fait pour produit de facon a n'ai pas avoir besoin d'un table dim pour traduite les IDs?
1 h 49
Non. Dans fact_sales, il n’y a pas de description complète du produit.
La table de fait contient surtout l’ID du produit :
product_id
Elle ne contient pas directement :
product_name
category
subcategory
brand
Ces descriptions sont dans la table dimension :
dim_product
Donc pour “traduire” les IDs produits, il faut faire une jointure :
SELECT
    fs.order_number,
    fs.product_id,
    dp.product_name,
    dp.category,
    dp.subcategory,
    dp.brand,
    fs.quantity,
    fs.line_total
FROM raw_fact_sales fs
JOIN raw_dim_product dp
    ON fs.product_id = dp.product_id;
Conclusion : oui, tu as besoin de dim_product pour comprendre ce que représente chaque product_id.
1 h 49
est-ce que en utilisant ces requetes il y a une possibilité d'erreur à cause des requete SQL complexes?
1 h 51
Oui, il y a une possibilité d’erreur, surtout quand les requêtes deviennent plus complexes avec plusieurs jointures.
Les risques principaux sont :
1.	Mauvaise jointure
Exemple : joindre sur le mauvais champ peut créer des résultats faux.
Correct :
fs.product_id = dp.product_id
Incorrect :
fs.product_id = ds.store_id
2.	Duplication de lignes
Si une dimension contient plusieurs lignes pour le même ID, une vente peut être dupliquée après la jointure. Résultat : les ventes semblent plus grandes qu’en réalité.
3.	Perte de lignes
Avec un INNER JOIN, si un product_id existe dans fact_sales mais pas dans dim_product, la vente disparaît du résultat.
4.	Mauvais grain
fact_sales est au grain ligne de commande. Si on agrège sans comprendre ce grain, on peut compter trop ou mal les commandes.
5.	Période mal filtrée
Par exemple, oublier que décembre doit être filtré comme :
order_date >= DATE '2025-12-01'
AND order_date < DATE '2026-01-01'
C’est plus sûr que month = 12, car month = 12 peut mélanger plusieurs années.
Donc oui : plus la requête SQL est complexe, plus il y a de risque d’erreur. C’est pour ça qu’on valide souvent les étapes avec des petits COUNT(*), des totaux simples, et des jointures vérifiées une par une.



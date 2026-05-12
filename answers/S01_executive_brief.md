# Board Brief — S01

Utilisation de CODEX dans VSCode
## Question du CEO
Quelle categorie de produit déclinent, dans quelle region et pourquoi

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

La requête SQL pour le résultat

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



## Réponse exécutive
Le jeux des données présent correspond à des tables transactionneles, la granuralité est par ligne de trasaction, il n'y a pas d'aggregation dans les tables.
La table de fait contien just des ID comme PRD-0097 qui ne permet pas identifier le contenu de façon descritive. Pour y arriver à des description c'est necessaire de fair jointure entre les tables.
Il y a des jointures que peuvent être complexes et passer par plusieurs tables, une fois qu'il y a des table Bridge dedans.
Chaque jour c'est necessaire de refaire tous les questions
Nous ne pouvons pas repondre à la question maintenant

## Décisions de modélisation
Develloper le  data wharehouse pour avoir les données validés, structurés et netoyées.
Création d'un entrepôt avec une structure aggréegé et les datamarts specifiques, pour repondre à des questions specifiques, par exemple le datamart Sales.
Dans le data wharehouse repliquer les tables des dimention conforme de facon à possibiliter les reponses par des perception different avec des titres compreensibles, au lieu d'avoir juste les CodeID

## Preuve
Les 5 premiers éléments de la colonne fact_sales[product_id] sont :
SELECT TOP 5 product_id
FROM fact_sales
ORDER BY sale_line_id;
PRD-0097
PRD-0100
PRD-0006
PRD-0035

Pour y arriver à reponse il n'est pas possible en regardant juste la table de fait, il faut avoir la jointure:
SELECT
    p.category,
    g.region,
    SUM(f.line_total) AS Revenue
FROM fact_sales f
INNER JOIN dim_product p ON f.product_id = p.productid
INNER JOIN dim_geography g ON f.store_id = g.store_id  -- ou via customer_id
GROUP BY p.category, g.region
ORDER BY Revenue DESC;

De facon que les reponses sont dependent des informations qui viens d'autres tables que la table de fait

SELECT DISTINCT product_id FROM raw_fact_sales;
SELECT COUNT(product_id) FROM raw_fact_sales;

Pour demontrer la granuralité:

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

Conclusion qui les données ne sont pas agrégées


## Validation
Identifier:
Quantités des tables dans le jeux des données
Identification de la table de fait
identification de quantités des lignes et distincits pour valider la granuralité
Identification du contenu du champ Product et demanter un exemple pour savoir il n'est pas possible de visualiser san la jointure.
Execution d'un jointure pour pour prouver que c'Est necessaire d'y aller vers d'autres tables pour arriver au resultat
Le resultat viens seulement avec des jointure entre les tables des dimention et fact


## Risques / limites

À chaque besoin, il faut refaire les requêtes.
Sachant qu'il y a des jointures plus complexes et tables des pont, il y a un risque de dans une même requête avoir des resultat differents.
En utilisant des tables du modèle transactionnel, il n'y a pas de traitement dans les tables qui pourra avoir des inconvenient dans les requêtes futures.
Il faut faire des extractions des données selon la peridiocité necessaire, dans le cas de saboir les résultats de façon journalier, sera necessaire de faire des extractions tous les jours.
Il y a une possibilité d’erreur, surtout quand les requêtes deviennent plus complexes avec plusieurs jointures.


## Prochaine recommandation
Création d'un entrepôt des données, de façon à avoir le contenu replique automatiquement, avec la netoyage, aggregation, régles d'affaire standarisé. Le modèle Kimbal peut repondre au besoin d'un modelisation dimentional.


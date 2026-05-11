# Board Brief — S01

## Question du CEO
Quelle categorie de produit déclinent, dans quelle region et pourquoi


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

SELECT COUNT(DISTINCT ordernumber) AS nb_commandes_uniques
FROM fact_sales;
Table : fact_sales.csv (5339 lignes au total).

Champ : order_number (2347 valeurs distinctes).

Interprétation : Chaque commande génère plusieurs lignes de ventes, mais il y a 2347 ordres uniques.

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
Limite
À chaque besoin, il faut refaire les requêtes.
Sachant qu'il y a des jointures plus complexes et tables des pont, il y a un risque de dans une même requête avoir des resultat differents.
En utilisant des tables du modèle transactionnel, il n'y a pas de traitement dans les tables qui pourra avoir des inconvenient dans les requêtes futures.
Il faut faire des extractions des données selon la peridiocité necessaire, dans le cas de saboir les résultats de façon journalier, sera necessaire de faire des extractions tous les jours


## Prochaine recommandation
Création d'un entrepôt des données, de façon à avoir le contenu replique automatiquement, avec la netoyage, aggregation, régles d'affaire standarisé. Le mod`le Kimbal peut repondre au besoin d'un modelisation dimentional.

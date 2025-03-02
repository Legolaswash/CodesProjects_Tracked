# SkiTour Analytics: Analyse Multivariée des Randonnées à Ski dans le Massif Alpin Vanoise

## À Propos du Projet
Ce projet s'inscrit dans le cadre de la SAE 4.02 "Reporting d'une analyse multivariée" et propose une analyse statistique des pratiques de randonnées à ski dans le massif de la Vanoise. L'application permet d'explorer les tendances et préférences des skieurs via une interface interactive développée avec R Shiny.

## Objectifs d'Analyse
- **Comprendre les comportements spatio-temporels** des randonneurs à ski dans le massif de la Vanoise
- **Identifier les facteurs d'influence** sur la fréquentation (jours de semaine vs. week-end, jours fériés)
- **Évaluer l'impact** des conditions contextuelles (météo, risque d'avalanche) sur les pratiques de ski
- **Visualiser les relations complexes** entre variables via diverses méthodes d'analyse multivariée

## Organisation de l'Application

### Onglet 1: Présentation des Données
- **Vue d'ensemble**
  - Explication du rôle et de la signification de chaque variable
  - Présentation de la source des données
- **Caractéristiques des variables**
  - Types de variables (quantitatives/qualitatives)
  - Modalités et distributions générales
- **Cartographie introductive**
  - Visualisation initiale des sommets du massif de la Vanoise
  - Présentation du territoire d'étude

### Onglet 2: Analyses Univariées
- **Sélection de variables**
  - Menu déroulant pour choisir une variable à analyser
- **Visualisations**
  - Variables quantitatives: Histogrammes, courbes de densité, boîtes à moustaches
  - Variables qualitatives: Diagrammes en barres, diagrammes circulaires
- **Statistiques descriptives**
  - Variables quantitatives: Moyennes, médianes, quartiles, écart-types, min/max
  - Variables qualitatives: Effectifs, fréquences, modalités les plus fréquentes

### Onglet 3: Analyses Bivariées
- **Sélection des variables**
  - Choix de deux variables via menus déroulants
  - Options de couples prédéfinis pertinents
- **Visualisations**
  - Quanti-Quanti: Nuages de points, droites de régression
  - Quali-Quali: Barres empilées, mosaïques
  - Quanti-Quali: Boîtes à moustaches parallèles, barres d'erreurs
- **Statistiques de croisement**
  - Quanti-Quanti: Corrélations, covariances, R²
  - Quali-Quali: Khi², degrés de liberté, Phi², V² de Cramer, tables de contingence
  - Quanti-Quali: Moyennes par groupe, ANOVA, variances intra/inter-classes

### Onglet 4: Cartographie
- **Exploration géographique**
  - Carte interactive du massif de la Vanoise
  - Sélection des sommets par clic ou menu déroulant
- **Analyses temporelles**
  - Évolution de la fréquentation annuelle par sommet
  - Comparaison multi-années
- **Informations détaillées**
  - Tableau des données: Orientation, niveau de difficulté, dénivelé, altitudes, coordonnées
  - Fiches techniques des sommets sélectionnés

### Onglet 5: Analyses Factorielles

#### Sous-onglet 5.1: ACP (Analyse en Composantes Principales)
- **Paramétrage de l'analyse**
  - Sélection des variables actives et illustratives
  - Options de standardisation des données
- **Visualisations**
  - Graphiques 2D/3D des individus sur les composantes principales
  - Cercles de corrélation des variables
  - Graphiques des 3 premiers plans factoriels (dimensions 1-2, 1-3, 2-3)
  - Contributions des dimensions à la variance expliquée
- **Résultats statistiques**
  - Paramètres d'appel, valeurs propres, pourcentages de variance expliquée
  - Coordonnées, contributions et cosinus carrés des variables et individus
  - Informations sur les variables supplémentaires

#### Sous-onglet 5.2: CAH (Classification Ascendante Hiérarchique)
- **Paramétrage du clustering**
  - Choix du nombre de classes (2 à 10)
  - Sélection des méthodes de distances et d'agrégation
- **Visualisations**
  - Dendrogrammes 2D et 3D
  - Projection des clusters sur le plan factoriel de l'ACP
  - Représentation des individus par cluster
- **Résultats statistiques**
  - Tests du chi² pour relation clusters/variables
  - Caractérisation des clusters par variables (v.test, Cla/Mod, Mod/Cla)
  - Individus typiques/atypiques par cluster
  - Métriques d'inertie intra/inter-classes

#### Sous-onglet 5.3: AFC (Analyse Factorielle des Correspondances)
- **Paramétrage de l'analyse**
  - Visualisation du tableau de contingence entre "Alpi" et "Ski"
  - Options pour les lignes/colonnes supplémentaires
- **Visualisations**
  - Graphique 2D des modalités sur les premières dimensions
  - Représentation simultanée des lignes et colonnes
  - Diagramme des valeurs propres
- **Résultats statistiques**
  - Test d'indépendance du chi², p-value
  - Valeurs propres et pourcentages de variance expliquée par dimension
  - Coordonnées, contributions et cosinus carrés des modalités
  - Informations sur les modalités supplémentaires

## Utilisation

### Lancer l'Application

Pour lancer l'application Shiny, suivez les étapes suivantes :

1. Ouvrez RStudio ou votre environnement R préféré.
2. Assurez-vous que votre répertoire de travail est défini sur le dossier contenant `app.R`.
3. Exécutez le script `app.R` en utilisant la commande suivante dans la console R :

```R
source("app/app.R")
```

4. L'application Shiny devrait s'ouvrir automatiquement dans votre navigateur par défaut.

## Structure du Projet

Voici l'organisation des fichiers et répertoires du projet, avec leur fonction respective :

```
app/
├── app.R
├── data/
│   ├── Vanoise.geojson
│   └── data_skitour_Vanoise__0__6588.csv
├── server/
│   ├── server_bivarie.R
│   ├── server_factorielles.R
│   ├── server_map.R
│   ├── server_presentation.R
│   └── server_univarie.R
├── ui/
│   ├── ui_bivarie.R
│   ├── ui_factorielles.R
│   ├── ui_map.R
│   ├── ui_presentation.R
│   └── ui_univarie.R
├── www/
│   ├── custom.css
│   └── Logo_IUT2_STID.png
├── SujetUGA - PresentationSAE4-02_2024.pdf
└── Soutenance SAE 4.02.pdf
```

### Description des composants :

- *app.R* : Script principal de l'application Shiny
- **Dossier data/** : Répertoire contenant les données d'analyse
  - *Vanoise.geojson* : Données géographiques délimitant la zone d'étude
  - *data_skitour_Vanoise__0__6588.csv* : Données principales des randonnées
- **Dossier server/** : Scripts de logique serveur par section
  - *server_bivarie.R* : Traitement des analyses bivariées
  - *server_factorielles.R* : Traitement des analyses factorielles (ACP, CAH, AFC)
  - *server_map.R* : Gestion de la cartographie interactive
  - *server_presentation.R* : Logique pour l'onglet de présentation
  - *server_univarie.R* : Traitement des analyses univariées
- **Dossier ui/** : Composants de l'interface utilisateur par section
  - *ui_bivarie.R* : Interface des analyses bivariées
  - *ui_factorielles.R* : Interface des analyses factorielles
  - *ui_map.R* : Interface de la cartographie
  - *ui_presentation.R* : Interface de présentation des données
  - *ui_univarie.R* : Interface des analyses univariées
- **Dossier www/** : Ressources statiques pour l'application
  - *custom.css* : Styles personnalisés pour l'interface
  - *Logo_IUT2_STID.png* : Logo institutionnel
- *SujetUGA - PresentationSAE4-02_2024.pdf* : Sujet original du projet
- *Soutenance SAE 4.02.pdf* : Support de présentation du projet

Cette architecture modulaire facilite la maintenance et le développement de l'application en séparant clairement les composants UI, la logique serveur et les données. Chaque fonctionnalité analytique (univariée, bivariée, factorielle, cartographique) dispose de ses propres fichiers UI et serveur, ce qui permet une meilleure organisation du code.

## Prérequis Techniques
- R (version 4.0+)
- Packages R :
    - Shiny (interface interactive)
    - Plotly (visualisations avancées)
    - FactoMineR (analyse multivariée)
    - Dplyr (manipulation de données)
    - Leaflet (cartographie interactive)
    - DT (tableaux interactifs)
    - Shinyjs (améliorations de l'interface)
    - Shinydashboard (tableaux de bord)
    - Sf (données géospatiales)
    - Factoextra (visualisation des analyses factorielles)
    - GridExtra (agencement des graphiques)
    - Ggcorrplot (visualisation des matrices de corrélation)
    - Ggrepel (éviter le chevauchement des étiquettes)

## Auteurs
- Dorian Relave
- Ian Peysson
- Romain Troillard
- Valentin Berger

<!-- ([GitHub](https://github.com/xxxxxxxxxx)) -->

# 🌍 Simulation de Fourmilière

## ✨ Projet de Programmation Orientée Objet
**BUT SD - Science des données - IUT2 - Université Grenoble Alpes**

---

## 📃 Description
Ce programme simule le fonctionnement d'une fourmilière en prenant en compte divers paramètres environnementaux et démographiques. Il permet d'observer l'évolution d'une colonie de fourmis sur plusieurs années, en suivant les cycles saisonniers et leurs impacts sur la population et les ressources.

---

## 🔍 Règles du jeu
La fourmilière est composée de trois types de fourmis, chacune ayant un rôle spécifique :
- 🛡️ **Gardes** : Protègent la fourmilière contre les attaques extérieures.
- 🌾 **Récolteuses** : Collectent les ressources dans l'environnement.
- 🫂 **Puéricultrices** : Élèvent les nouvelles fourmis.

La simulation intègre plusieurs mécanismes :
- ⏳ Cycle de vie d'un an pour chaque fourmi.
- ⛄️🌞 Variations saisonnières des ressources naturelles.
- ⚔️ Attaques aléatoires contre la fourmilière.
- 🌟 Gestion de la consommation des ressources.
- 💋 Dynamique de reproduction.

---

## Organisation des fichiers

### 📂 Fichiers principaux
- **POO_Fourmis.py** : Programme principal contenant l'implémentation des classes et la logique de simulation.
- **FourmisTest.py** : Suite de tests unitaires avec `pytest` pour valider le programme.

### 📖 Documentation
- **README.md** : Ce document.
- **Rapport_Projet_POO_Fourmiliere.pdf** : Rapport détaillé expliquant l'architecture du code, les choix d'implémentation et l'analyse des résultats.
- **Consigne_projets_POO.pdf** : Énoncé original du projet.
- **Sujet_III_Fourmis_projets_POO.pdf** : Description du sujet "Fourmilière".

---

## 🔧 Prérequis

### Environnement Python
Le programme a été développé et testé avec **Python 3.8+**.

### Installation des dépendances
```bash
pip install random pandas matplotlib numpy datetime tqdm pytest
```

---

## 🔄 Utilisation du programme

### Exécution de la simulation
```bash
python POO_Fourmis.py
```

### Lancer les tests
```bash
pytest FourmisTest.py
```

---

## 🛠️ Configuration de la simulation
L'utilisateur peut choisir entre :

### **Méthode 1 : Configuration interactive**
Définir via des entrées utilisateur les parametres de la fourmiliere via la console. 

### **Méthode 2 : Configuration en dur**
Pour une exécution plus rapide, utiliser les parametre définis par défaut, en dur dans le programme, et les modifié directement dans le code si demandé : 

### Paramètres principaux
1. **Nombre initial de fourmis**: Population de départ de la fourmilière
2. **Ressources initiales dans la nature**: Quantité de nourriture disponible dans l'environnement
3. **Proportion de gardes**: Pourcentage de la population dédiée à la défense (0-1)
4. **Proportion de récolteuses**: Pourcentage de la population dédiée à la collecte (0-1)
5. **Proportion de puéricultrices**: Pourcentage de la population dédiée à l'élevage (0-1)
6. **Facteur d'attaques**: Détermine l'intensité des attaques (plus le facteur est élevé, moins il y a d'attaques)
7. **Capacité maximale de fourmis**: Limite supérieure de la population
8. **Capacité maximale de ressources dans la nature**: Limite supérieure des ressources environnementales
9. **Capacité maximale de ressources en stock**: Limite supérieure du stockage dans la fourmilière

### Paramètres de la simulation
- **Nombre d'années**: Durée totale de la simulation
- **Affichage**: Active ou désactive les informations détaillées pour chaque saison

#### ✅ Configuration stable (recommandée pour simulations longues)
```python
liste_parametre = [1000, 5000, 0.2, 0.4, 0.4, 3, 6000, 100000, 60000]
nb_annee = 30
affichage = False
simulation(nb_annee, Fourmiliere(*liste_parametre), affichage)
```

#### ⚡ Configuration dynamique (moins stable)
```python
liste_parametre = [500, 10000, 0.25, 0.4, 0.25, 3, 6000, 100000, 60000]
nb_annee = 30
affichage = False
simulation(nb_annee, Fourmiliere(*liste_parametre), affichage)
```

---

## 🎨 Sorties et résultats
La simulation génère plusieurs visualisations :

1. **🐜 Évolution de la population** : Nombre total et répartition par rôle.
2. **⚔️ Statistiques d'attaques** : Nombre d'attaques et pertes.
3. **🌿 Dynamique des ressources** : Quantités disponibles et consommées.
4. **📈 Tableau récapitulatif saisonnier** : Données de population, ressources et attaques.

---

## 🌟 Performance et recommandations

- **Durée de simulation** : Privilégiez < 100 ans pour une exécution raisonnable.
- **Simulation stable** : Configuration 1 recommandée.
- **Simulation dynamique** : Configuration 2 pour tester la survie de la fourmilière.
- **Désactiver l'affichage** (`affichage=False`) pour accélérer les simulations longues.

---

## 💡 Notes techniques
- Les résultats varient en raison des événements aléatoires.
- Les proportions des types de fourmis doivent totaliser 1.0.
- Le **Rapport_Projet_POO_Fourmiliere.pdf** contient une analyse plus détaillée.

Pour toute question ou problème, consultez le rapport détaillé qui explique les mécanismes internes de la simulation.

---

## Auteurs du projet
- **Dorian RELAVE**
- **Loïc BOURGAREL**
- **Mathieu LAHARIE**


import sys
import time
import random
import pandas as pd
from tqdm import tqdm
import matplotlib.pyplot as plt
from datetime import timedelta


# Définition de la classe Fourmi, une fourmi = un individu seul.
class Fourmi:
    """
    Classe représentant une fourmi individuelle.
    
    Attributes:
        age (int): Âge de la fourmi en saisons
        role (str): Rôle de la fourmi dans la colonie
    """
    def __init__(self, age, role):
        self.age = age
        self.role = role

    def get_age(self):
        return self.age

    def get_role(self):
        return self.role

    def vieillir(self):
        self.age += 1


# Des sous-classes pour chaque rôle, héritant des méthodes de Fourmi.
class Garde(Fourmi):
    """Classe représentant une fourmi garde, spécialisée dans la défense."""
    def __init__(self, age):
        super().__init__(age, "garde")


class Recolteuse(Fourmi):
    """Classe représentant une fourmi récolteuse, spécialisée dans la collecte de ressources."""
    def __init__(self, age):
        super().__init__(age, "recolteuse")


class Puericultrice(Fourmi):
    """Classe représentant une fourmi puéricultrice, spécialisée dans l'élevage des larves."""
    def __init__(self, age):
        super().__init__(age, "puericultrice")


# Classe Fourmilière : créer un ensemble de plusieurs Fourmis, avec des
# méthodes simulant son comportement.
class Fourmiliere:
    """
    Classe représentant une fourmilière complète.
    
    Attributes:
        ressources_nature (int): Quantité de ressources disponibles dans la nature
        prop_garde (float): Proportion de gardes dans la colonie
        prop_recolteuse (float): Proportion de récolteuses
        prop_puericultrice (float): Proportion de puéricultrices
        facteur_attaques (float): Facteur influençant la fréquence des attaques
        cap_fourmis (int): Capacité maximale de fourmis
        cap_res_nature (int): Capacité maximale de ressources dans la nature
        cap_res_stock (int): Capacité maximale de ressources en stock
    """
    def __init__(self, nombre_initial_fourmis: int,
                 ressources_nature: int, prop_garde: float,
                 prop_recolteuse: float, prop_puericultrice: float,
                 facteur_attaques: float, cap_fourmis: int,
                 cap_res_nature: int, cap_res_stock: int):

        self.ressources_nature = ressources_nature
        self.prop_garde = prop_garde
        self.prop_recolteuse = prop_recolteuse
        self.prop_puericultrice = prop_puericultrice
        self.facteur_attaques = facteur_attaques
        self.cap_fourmis = cap_fourmis
        self.cap_res_nature = cap_res_nature
        self.cap_res_stock = cap_res_stock

        self.fourmis = []
        self.nouvelles_fourmis = 0
        self.ressources_stock = 0

        # Attribution des rôles, en prenant en compte les proportions,
        # mais en ajoutant de l'aléatoire.
        self.probas_roles = {
            "garde": self.prop_garde,
            "recolteuse": self.prop_recolteuse,
            "puericultrice": self.prop_puericultrice
            }
        for _ in range(nombre_initial_fourmis):
            role = random.choices(
                list(self.probas_roles.keys()),
                weights=list(self.probas_roles.values()))[0]
            if role == "garde":
                self.fourmis.append(Garde(0))
            elif role == "recolteuse":
                self.fourmis.append(Recolteuse(0))
            elif role == "puericultrice":
                self.fourmis.append(Puericultrice(0))

    # Quelques méthodes pour aller récupérer des informations :
    def get_ressources_stock(self):
        return self.ressources_stock

    def get_ressources_nature(self):
        return self.ressources_nature

    def get_nombre_fourmis(self):
        return len(self.fourmis)

    # ----- GET répartition des fourmis -----
    def get_nombre_gardes(self):
        return sum(1 for fourmi in self.fourmis if fourmi.role == "garde")

    def get_nombre_recolteuses(self):
        return sum(1 for fourmi in self.fourmis if fourmi.role == "recolteuse")

    def get_nombre_puericultrices(self):
        return sum(1 for fourmi in self.fourmis if fourmi.role ==
                   "puericultrice")

    def get_nombre_nouvelle_fourmis(self):
        return self.nouvelles_fourmis

    # ---------- BLOC RESSOURCES: ----------
    # Quelques méthodes utilisées ensuite dans l'actualisation des ressources :
    def facteur_recolte(self):
        """
        Calcule le facteur de récolte basé sur la composition de la colonie.
        
        Returns:
            float: Facteur multiplicateur pour la récolte
        """
        facteur_recolte = round((self.prop_garde*3 +
                                 self.prop_recolteuse*2 +
                                 1.5*self.prop_puericultrice)
                                / self.prop_recolteuse)
        return facteur_recolte

    def sum_conso(self):
        sum_conso = (3*(self.get_nombre_gardes()) +
                     2*(self.get_nombre_recolteuses()) +
                     1.5*(self.get_nombre_puericultrices()))
        return sum_conso

    def cap_res(self):
        if self.ressources_nature > self.cap_res_nature:
            self.ressources_nature = self.cap_res_nature
        if self.ressources_stock > self.cap_res_stock:
            self.ressources_stock = self.cap_res_stock

    def maj_ressources(self):
        """
        Met à jour les ressources de la fourmilière.
        
        Returns:
            tuple: (consommation_totale, nb_gardes_mortes, nb_recolteuses_mortes, nb_puericultrices_mortes)
        """
        self.cap_res()
        lim = 50+(self.ressources_nature/10)
        sum_conso = self.sum_conso()
        # Consommation des puéricultrices incluant celle des juvéniles, 0.5

        # ---------- BLOC RÉCOLTE: ----------
        # Limitation de la récolte, pour toujours laisser au moins quelques
        # ressources
        if self.ressources_nature >= (self.get_nombre_recolteuses() *
                                      (self.facteur_recolte()) + lim):
            recolte = self.get_nombre_recolteuses()*(self.facteur_recolte())
            self.ressources_stock += recolte
            self.ressources_nature -= recolte
        elif self.ressources_nature > lim:
            recolte = (self.ressources_nature - lim)
            self.ressources_stock = self.ressources_nature - lim
            self.ressources_nature = lim

        # ---------- BLOC CONSOMMATION: ----------
        if self.ressources_stock > sum_conso:
            self.ressources_stock -= sum_conso
            nb_garde_kill = 0
            nb_recolteuse_kill = 0
            nb_puericultrice_kill = 0
        # Mort de fourmis par "famine"/manque de ressources :
        else:
            self.ressources_stock = 0
            compteur = 0
            manque = sum_conso - self.ressources_stock
            for g in self.fourmis:
                if g.get_role() == "garde" and compteur < round(manque/9):
                    self.fourmis.remove(g)
                    compteur += 1
            nb_garde_kill = compteur
            compteur = 0
            for g in self.fourmis:
                if g.get_role() == "recolteuse" and compteur < round(manque/6):
                    self.fourmis.remove(g)
                    compteur += 1
            nb_recolteuse_kill = compteur
            compteur = 0
            for g in self.fourmis:
                if (g.get_role() == "puericultrice"
                        and compteur < round(manque/3)):
                    self.fourmis.remove(g)
                    compteur += 1
            nb_puericultrice_kill = compteur
            compteur = 0
        return (sum_conso, nb_garde_kill,
                nb_recolteuse_kill, nb_puericultrice_kill)

    # ---------- BLOC ATTAQUES: ----------
    def get_nb_attaques(self):
        """
        Détermine le nombre d'attaques.
        
        Returns:
            int: Nombre d'attaques
        """
        attaques = random.randint(0, int(self.get_nombre_fourmis() /
                                         self.facteur_attaques))
        return attaques

    def gerer_attaques(self):
        """
        Simule les attaques contre la fourmilière.
        
        Returns:
            list: [nombre_attaquants, nombre_morts]
        """
        infos_attaques = [0, 0]
        attaques = self.get_nb_attaques()
        nb_garde = self.get_nombre_gardes()
        gap = attaques - nb_garde
        infos_attaques[0] = attaques
        if gap < 0:
            infos_attaques[1] = 0
        else:
            infos_attaques[1] = gap
        if attaques > nb_garde:
            indices_a_supprimer = random.sample(range(len(self.fourmis)), gap)
            indices_a_supprimer.sort(reverse=True)
            for _ in indices_a_supprimer:
                self.fourmis.pop()
        return infos_attaques

    # ---------- BLOC NAISSANCES: ----------
    def nouvelle_fourmis(self):
        ''' À chaque saison, il y a autant de fourmis juvéniles créées que de
        puéricultrices. '''
        new = [0, 0, 0]
        nb_new_garde = 0
        nb_new_recolteuse = 0
        nb_new_puericultrice = 0
        self.nouvelles_fourmis = 0

        for _ in range(0, self.get_nombre_puericultrices()):
            role = random.choices(
                list(self.probas_roles.keys()),
                weights=list(self.probas_roles.values()))[0]
            if self.get_nombre_fourmis() < self.cap_fourmis:
                if role == "garde":
                    self.fourmis.append(Garde(0))
                    nb_new_garde += 1
                    new[0] = nb_new_garde
                elif role == "recolteuse":
                    self.fourmis.append(Recolteuse(0))
                    nb_new_recolteuse += 1
                    new[1] = nb_new_recolteuse
            if role == "puericultrice":
                self.fourmis.append(Puericultrice(0))
                nb_new_puericultrice += 1
                new[2] = nb_new_puericultrice
        self.nouvelles_fourmis = new[0] + new[1] + new[2]
        return (new)

    # ----- Viellissement -----
    def envieillir(self):
        ''' Vieilli les fourmis adultes. '''
        for fourmi in self.fourmis:
            fourmi.vieillir()

    def tuer_anciens(self):
        ''' Tue les fourmis trop âgées en évitant la modification de la liste en cours d'itération. '''
        self.fourmis = [fourmi for fourmi in self.fourmis if fourmi.get_age() <= 4]

    # ----- SAISONS -----
    ''' Définition des facteurs saisons impactant la quantité de ressources
        disponible dans la nature. '''

    def saison_printemps(self):
        self.ressources_nature *= 2
        self.ressources_nature = round(self.ressources_nature, 2)

    def saison_ete(self):
        self.ressources_nature *= 1.5
        self.ressources_nature = round(self.ressources_nature, 2)

    def saison_hiver(self):
        self.ressources_nature *= 0.75
        self.ressources_nature = round(self.ressources_nature, 2)

    def saison_automne(self):
        self.ressources_nature *= 1
        self.ressources_nature = round(self.ressources_nature, 2)

    def saison(self, nom_saison):
        if nom_saison == "printemps":
            self.saison_printemps()
        elif nom_saison == "ete":
            self.saison_ete()
        elif nom_saison == "hiver":
            self.saison_hiver()
        elif nom_saison == "automne":
            self.saison_automne()

    # ----- SIMULATION -----
    def simuler_saison(self, saison):
        """
        Simule une saison complète.
        
        Args:
            saison (str): Nom de la saison ('printemps', 'ete', 'automne', 'hiver')
        
        Returns:
            tuple: (infos_attaques, nouvelles_fourmis)
        """
        """ ----- SIMULATION -----
            1 - Application des saisons sur les ressources dans la nature
            2 - Viellissement des fourmis
            3 - Mort des fourmis trop agées
            4 - Création de nouvelles fourmis
            5 - Attaques sur la fourmilière
            6 - Mises à jours des ressources, Récoltes et Consommation
        """
        self.saison(saison)
        self.envieillir()  # Donne une saison à toutes les fourmis
        self.tuer_anciens()  # Tue les fourmis trop vieilles
        new = self.nouvelle_fourmis()  # Crée de nouvelles fourmis
        infos_attaques = self.gerer_attaques()  # Tue potentiellement
        self.maj_ressources()
        return infos_attaques, new

# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------


def simulation(nb_annee_sim, fourmiliere, affichage):
    """
    Simule l'évolution d'une fourmilière sur plusieurs années.
    
    Args:
        nb_annee_sim (int): Nombre d'années à simuler
        fourmiliere (Fourmiliere): Instance de la fourmilière
        affichage (bool): Active/désactive l'affichage des résultats
    
    Returns:
        pandas.DataFrame: Historique complet de la simulation
    """
    tdem = time.time()
    
    if affichage:
        print("\n===== AVANT SIMULATION =====")
        print(f"Ressources STOCK: {fourmiliere.get_ressources_stock()}")
        print(f"Ressources NATURE: {fourmiliere.get_ressources_nature()}")
        print(f"Nombre total de fourmis: {fourmiliere.get_nombre_fourmis()}")
        print(f"Gardes: {fourmiliere.get_nombre_gardes()} - Récolteuses: {fourmiliere.get_nombre_recolteuses()} - Puéricultrices: {fourmiliere.get_nombre_puericultrices()}\n")
    
    # Initialisation du DataFrame
    df_histo = pd.DataFrame(columns=["Année", "Saison", "Nb_Fourmis", "Nb_Gardes", "Nb_Recolteuses", "Nb_Puericultrices", 
                                      "Nb_New_Gardes", "Nb_New_Recolteuses", "Nb_New_Puericultrices", "Res_Stock", "Res_Nature", 
                                      "Nb_Attaquants", "Nb_morts_attaques"])
    
    for annee in tqdm(range(1, nb_annee_sim + 1), desc="Simulation en cours", unit="year"):
        for saison in ["printemps", "ete", "automne", "hiver"]:
            infos_attaques, new_fourmis = fourmiliere.simuler_saison(saison)
            
            # Ajout des données au DataFrame
            df_histo = pd.concat([df_histo, pd.DataFrame([{
                "Année": annee,
                "Saison": saison.title(),
                "Nb_Fourmis": fourmiliere.get_nombre_fourmis(),
                "Nb_Gardes": fourmiliere.get_nombre_gardes(),
                "Nb_Recolteuses": fourmiliere.get_nombre_recolteuses(),
                "Nb_Puericultrices": fourmiliere.get_nombre_puericultrices(),
                "Nb_New_Gardes": new_fourmis[0],
                "Nb_New_Recolteuses": new_fourmis[1],
                "Nb_New_Puericultrices": new_fourmis[2],
                "Res_Stock": fourmiliere.get_ressources_stock(),
                "Res_Nature": fourmiliere.get_ressources_nature(),
                "Nb_Attaquants": infos_attaques[0],
                "Nb_morts_attaques": infos_attaques[1]
            }])], ignore_index=True)
            
            if affichage:
                print(f"\n===== {saison.upper()} - Année {annee} =====")
                print(f"Attaques: {infos_attaques[0]} - Morts: {infos_attaques[1]}")
                print(f"Naissances -> Gardes: {new_fourmis[0]}, Récolteuses: {new_fourmis[1]}, Puéricultrices: {new_fourmis[2]}")
                print(f"Stock: {fourmiliere.get_ressources_stock()} - Nature: {fourmiliere.get_ressources_nature()}")
                print(f"Total Fourmis: {fourmiliere.get_nombre_fourmis()} (G: {fourmiliere.get_nombre_gardes()}, R: {fourmiliere.get_nombre_recolteuses()}, P: {fourmiliere.get_nombre_puericultrices()})\n")
    
    # Affichage final
    if affichage:
        print(f"\n===== FIN DE SIMULATION =====")
        print(f"Total Fourmis: {fourmiliere.get_nombre_fourmis()}")
    
    # Tracer des graphiques
    df_histo["Period"] = df_histo["Année"].astype(str) + "-" + df_histo["Saison"]
    plot_simulation_results(df_histo)
    
    # Temps d'exécution
    exec_time = round(time.time() - tdem, 2)
    print(f'\nTemps d\'exécution: {exec_time} secondes ({str(timedelta(seconds=exec_time))})\n')
    
    return df_histo

def plot_simulation_results(df):
    """Affiche les graphiques de simulation."""
    max_ticks = 50
    step = max(1, len(df["Period"]) // max_ticks)
    
    plt.figure(figsize=(15, 6))
    plt.plot(df["Period"], df["Nb_Fourmis"], marker='o', linewidth=2, alpha=0.7, label="Total Fourmis")
    plt.plot(df["Period"], df["Nb_Gardes"], marker='o', alpha=0.7, label="Gardes")
    plt.plot(df["Period"], df["Nb_Recolteuses"], marker='o', alpha=0.7, label="Récolteuses")
    plt.plot(df["Period"], df["Nb_Puericultrices"], marker='o', alpha=0.7, label="Puéricultrices")
    plt.legend()
    plt.xticks(df["Period"][::step], rotation=90)
    plt.title("Évolution du nombre de fourmis")
    plt.show()
    
    plt.figure(figsize=(15, 6))
    plt.plot(df["Period"], df["Nb_morts_attaques"], marker='o', label="Morts Attaques")
    plt.plot(df["Period"], df["Nb_Attaquants"], marker='o', label="Nombre Attaquants")
    plt.legend()
    plt.xticks(df["Period"][::step], rotation=90)
    plt.title("Évolution des attaques et pertes")
    plt.show()
    
    plt.figure(figsize=(15, 6))
    plt.plot(df["Period"], df["Res_Stock"], marker='o', label="Ressources Stock")
    plt.plot(df["Period"], df["Res_Nature"], marker='o', label="Ressources Nature")
    plt.legend()
    plt.xticks(df["Period"][::step], rotation=90)
    plt.title("Évolution des ressources")
    plt.show()
    
    plt.figure(figsize=(15, 6))
    plt.plot(df["Period"], df["Nb_New_Gardes"], marker='o', alpha=0.7, label="Nouveaux Gardes")
    plt.plot(df["Period"], df["Nb_New_Recolteuses"], marker='o', alpha=0.7, label="Nouvelles Récolteuses")
    plt.plot(df["Period"], df["Nb_New_Puericultrices"], marker='o', alpha=0.7, label="Nouvelles Puéricultrices")
    plt.legend()
    plt.xticks(df["Period"][::step], rotation=90)
    plt.title("Naissances par saison")
    plt.show()

def get_user_input():
    """
    Récupère les paramètres de la fourmilière auprès de l'utilisateur.
    
    Returns:
        list: Liste des paramètres de la fourmilière
    """
    print("---- Au départ ----")
    nb_fourmis = int(input("Nombre de fourmis initial dans la fourmilière : "))
    res_nature = int(input("Nombre d'unité de ressources initial dans la nature : "))
    
    print("---- Proportion au format : 0.xx (Sera appliqué dans la reproduction) ----")
    prop_garde = float(input("Proportion de gardes : "))
    prop_recolteuse = float(input("Proportion de récolteuse : "))
    prop_puericultrice = float(input("Proportion de puéricultrices : "))
    
    print("---- Limites (seuils, garde la durée de simulation et les ordre de grandeur acceptable) ----")
    cap_fourmis = int(input("Nombre de fourmis maximal : "))
    cap_res_nature = int(input("Unités de ressources max dans la nature : "))
    cap_res_stock = int(input("Unités de ressources max dans le stock : "))
    
    print("---- Autres ----")
    facteur_attaques = float(input("Facteur attaques (diminue le nombre d'attaquants) : "))
    
    return [nb_fourmis, res_nature, prop_garde, prop_recolteuse, prop_puericultrice, facteur_attaques, cap_fourmis, cap_res_nature, cap_res_stock]

    # # Exemple, Récupération des paramètres de la fourmilière
    # liste_parametre = get_user_input()
    # print(liste_parametre)

if __name__ == "__main__":
    # Demander à l'utilisateur s'il souhaite utiliser les paramètres par défaut ou les définir manuellement
    use_default = input("Voulez-vous utiliser les paramètres par défaut ? (o/n) : ").strip().lower()

    if use_default == "o":
        # Paramètres en dur dans le code :
        # Configuration 1 - stable
        liste_parametre = [500,
                        10000,
                        0.25, 0.4, 0.25,
                        3,
                        6000, 100000, 60000]

        # Configuration 2 - instable
        # liste_parametre = [400,
        #                    30000,
        #                    0.2, 0.5, 0.3,
        #                    3,
        #                    6000, 100000, 60000]
    else:
        # Récupération des paramètres de la fourmilière auprès de l'utilisateur
        liste_parametre = get_user_input()

    fourmiliere = Fourmiliere(liste_parametre[0], liste_parametre[1],
                              liste_parametre[2], liste_parametre[3],
                              liste_parametre[4], liste_parametre[5],
                              liste_parametre[6], liste_parametre[7],
                              liste_parametre[8])

    # Lancement de la simulation :
    df_histo = simulation(100, fourmiliere, False)
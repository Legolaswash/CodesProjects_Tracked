import sys
import pytest
import pandas as pd
from io import StringIO
from POO_Fourmis import Fourmi, Garde, Recolteuse, Puericultrice, Fourmiliere, simulation, get_user_input
import matplotlib.pyplot as plt

# Tests pour la classe Fourmi
def test_fourmi_initialization():
    """Vérifie l'initialisation correcte d'une fourmi."""
    fourmi = Fourmi(age=1, role="garde")
    assert fourmi.get_age() == 1
    assert fourmi.get_role() == "garde"

def test_fourmi_vieillir():
    fourmi = Fourmi(age=1, role="garde")
    fourmi.vieillir()
    assert fourmi.get_age() == 2

# Tests pour la classe Garde
def test_garde_initialization():
    garde = Garde(age=2)
    assert garde.get_age() == 2
    assert garde.get_role() == "garde"

# Tests pour la classe Recolteuse
def test_recolteuse_initialization():
    recolteuse = Recolteuse(age=3)
    assert recolteuse.get_age() == 3
    assert recolteuse.get_role() == "recolteuse"

# Tests pour la classe Puericultrice
def test_puericultrice_initialization():
    puericultrice = Puericultrice(age=4)
    assert puericultrice.get_age() == 4
    assert puericultrice.get_role() == "puericultrice"

# Tests pour la classe Fourmiliere
def test_fourmiliere_initialization():
    """Vérifie l'initialisation correcte d'une fourmilière."""
    fourmiliere = Fourmiliere(
        nombre_initial_fourmis=100,
        ressources_nature=1000,
        prop_garde=0.25,
        prop_recolteuse=0.4,
        prop_puericultrice=0.35,
        facteur_attaques=3,
        cap_fourmis=1000,
        cap_res_nature=10000,
        cap_res_stock=5000
    )
    assert fourmiliere.get_nombre_fourmis() == 100
    assert fourmiliere.get_ressources_nature() == 1000
    assert fourmiliere.get_ressources_stock() == 0

def test_fourmiliere_maj_ressources():
    """Vérifie la mise à jour des ressources."""
    fourmiliere = Fourmiliere(
        nombre_initial_fourmis=100,
        ressources_nature=1000,
        prop_garde=0.25,
        prop_recolteuse=0.4,
        prop_puericultrice=0.35,
        facteur_attaques=3,
        cap_fourmis=1000,
        cap_res_nature=10000,
        cap_res_stock=5000
    )
    sum_conso, nb_garde_kill, nb_recolteuse_kill, nb_puericultrice_kill = fourmiliere.maj_ressources()
    assert isinstance(sum_conso, float)
    assert isinstance(nb_garde_kill, int)
    assert isinstance(nb_recolteuse_kill, int)
    assert isinstance(nb_puericultrice_kill, int)

def test_fourmiliere_gerer_attaques():
    """Vérifie la gestion des attaques."""
    fourmiliere = Fourmiliere(
        nombre_initial_fourmis=100,
        ressources_nature=1000,
        prop_garde=0.25,
        prop_recolteuse=0.4,
        prop_puericultrice=0.35,
        facteur_attaques=3,
        cap_fourmis=1000,
        cap_res_nature=10000,
        cap_res_stock=5000
    )
    infos_attaques = fourmiliere.gerer_attaques()
    assert isinstance(infos_attaques, list)
    assert len(infos_attaques) == 2

def test_fourmiliere_nouvelle_fourmis():
    fourmiliere = Fourmiliere(
        nombre_initial_fourmis=100,
        ressources_nature=1000,
        prop_garde=0.25,
        prop_recolteuse=0.4,
        prop_puericultrice=0.35,
        facteur_attaques=3,
        cap_fourmis=1000,
        cap_res_nature=10000,
        cap_res_stock=5000
    )
    new = fourmiliere.nouvelle_fourmis()
    assert isinstance(new, list)
    assert len(new) == 3
    assert all(isinstance(n, int) and n >= 0 for n in new) 

    nb_puericultrices = fourmiliere.get_nombre_puericultrices()
    assert sum(new) <= nb_puericultrices


def test_fourmiliere_simuler_saison():
    """Vérifie la simulation d'une saison complète."""
    fourmiliere = Fourmiliere(
        nombre_initial_fourmis=100,
        ressources_nature=1000,
        prop_garde=0.25,
        prop_recolteuse=0.4,
        prop_puericultrice=0.35,
        facteur_attaques=3,
        cap_fourmis=1000,
        cap_res_nature=10000,
        cap_res_stock=5000
    )
    infos_attaques, new = fourmiliere.simuler_saison("printemps")
    assert isinstance(infos_attaques, list)
    assert isinstance(new, list)
    assert len(infos_attaques) == 2
    assert len(new) == 3


# Tests pour la fonction simulation
def test_simulation():
    """Vérifie le fonctionnement global de la simulation."""
    
    # Désactive les plots
    plt.switch_backend('Agg')  # 'Agg' est un backend non interactif

    # Rediriger les sorties standard et erreurs vers StringIO
    captured_output = StringIO()
    sys.stdout = captured_output
    sys.stderr = captured_output

    fourmiliere = Fourmiliere(
        nombre_initial_fourmis=100,
        ressources_nature=1000,
        prop_garde=0.25,
        prop_recolteuse=0.4,
        prop_puericultrice=0.35,
        facteur_attaques=3,
        cap_fourmis=1000,
        cap_res_nature=10000,
        cap_res_stock=5000
    )
    
    df_histo = simulation(1, fourmiliere, False)
    
    assert isinstance(df_histo, pd.DataFrame)
    assert not df_histo.empty

    # Réinitialiser les sorties
    sys.stdout = sys.__stdout__
    sys.stderr = sys.__stderr__

def test_get_user_input(monkeypatch):
    inputs = iter(['100', '200', '0.1', '0.2', '0.3', '500', '1000', '1500', '1.5'])
    
    monkeypatch.setattr('builtins.input', lambda _: next(inputs))
    
    expected = [100, 200, 0.1, 0.2, 0.3, 1.5, 500, 1000, 1500]
    assert get_user_input() == expected

# Exécution des tests
if __name__ == "__main__":
    pytest.main()

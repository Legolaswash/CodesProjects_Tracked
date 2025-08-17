#!/usr/bin/env python3
"""
Lanceur pour l'interface graphique du simulateur de fourmilière.
Assurez-vous d'avoir installé les dépendances nécessaires :

pip install ttkbootstrap pandas matplotlib numpy tqdm

Usage:
    python run_gui.py
"""

import sys
import os

# Ajouter le répertoire courant au path pour l'import des modules
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

try:
    # Import et lancement de l'interface graphique
    from fourmiliere_gui import main
    
    if __name__ == "__main__":
        print("Démarrage de l'interface graphique du simulateur de fourmilière...")
        main()
        
except ImportError as e:
    print(f"Erreur d'import: {e}")
    print("\nVeuillez installer les dépendances manquantes:")
    print("pip install ttkbootstrap pandas matplotlib numpy tqdm")
    sys.exit(1)
    
except Exception as e:
    print(f"Erreur lors du démarrage: {e}")
    sys.exit(1)

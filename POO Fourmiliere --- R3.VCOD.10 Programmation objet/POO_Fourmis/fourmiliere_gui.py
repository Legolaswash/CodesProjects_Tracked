import tkinter as tk
from tkinter import ttk, messagebox
import ttkbootstrap as ttkb
from ttkbootstrap.constants import *
import threading
import time
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
from matplotlib.figure import Figure
import numpy as np
from POO_Fourmis import Fourmiliere


class FourmiSimulatorGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Simulateur de Fourmilière")
        self.root.geometry("1200x800")
        self.style = ttkb.Style("superhero")
        
        # Variables de simulation
        self.fourmiliere = None
        self.simulation_running = False
        self.simulation_thread = None
        self.df_results = None
        
        # Définition des paramètres
        self.setup_variables()
        
        # Interface utilisateur
        self.setup_ui()
        
    def setup_variables(self):
        """Initialisation des paramètres."""
        # Quantités initiales
        self.nb_fourmis_var = tk.IntVar(value=500)
        self.res_nature_var = tk.IntVar(value=10000)
        self.nb_annees_var = tk.IntVar(value=50)
        
        # Proportions
        self.prop_garde_var = tk.DoubleVar(value=0.275)
        self.prop_recolteuse_var = tk.DoubleVar(value=0.45)
        self.prop_puericultrice_var = tk.DoubleVar(value=0.275)
        
        # Capacités
        self.cap_fourmis_var = tk.IntVar(value=6000)
        self.cap_res_nature_var = tk.IntVar(value=100000)
        self.cap_res_stock_var = tk.IntVar(value=60000)
        
        # Facteur attaques
        self.facteur_attaques_var = tk.DoubleVar(value=3.0)
        
        # Variables d'état
        self.progress_var = tk.DoubleVar()
        self.status_var = tk.StringVar(value="Prêt à simuler")
        
        # Ajustement dynamique des proportions
        self.prop_garde_var.trace_add("write", self.adjust_proportions)
        self.prop_recolteuse_var.trace_add("write", self.adjust_proportions)
        self.prop_puericultrice_var.trace_add("write", self.adjust_proportions)

    def adjust_proportions(self, *args):
        """Ajuste dynamiquement les proportions pour que leur somme reste égale à 1."""
        # Si on charge une configuration, on skip l'ajustement automatique
        if getattr(self, 'loading_config', False):
            return
        
        total = (self.prop_garde_var.get() + 
                 self.prop_recolteuse_var.get() + 
                 self.prop_puericultrice_var.get())
        
        if total == 0:
            # Évite la division par zéro
            self.prop_garde_var.set(0.33)
            self.prop_recolteuse_var.set(0.33)
            self.prop_puericultrice_var.set(0.34)
            return
        
        # Ajuste les proportions pour maintenir la somme à 1
        factor = 1.0 / total
        self.prop_garde_var.set(round(self.prop_garde_var.get() * factor, 3))
        self.prop_recolteuse_var.set(round(self.prop_recolteuse_var.get() * factor, 3))
        self.prop_puericultrice_var.set(round(self.prop_puericultrice_var.get() * factor, 3))

    def setup_ui(self):
        """Config interface utilisateur."""
        # Frame principal
        main_frame = ttkb.Frame(self.root)
        main_frame.pack(fill=BOTH, expand=True, padx=10, pady=10)
        
        # Onglets via Notebook
        notebook = ttkb.Notebook(main_frame)
        notebook.pack(fill=BOTH, expand=True)
        
        # Onglet Configuration
        config_frame = ttkb.Frame(notebook)
        notebook.add(config_frame, text="Configuration")
        self.setup_config_tab(config_frame)
        
        # Onglet Simulation
        sim_frame = ttkb.Frame(notebook)
        notebook.add(sim_frame, text="Simulation")
        self.setup_simulation_tab(sim_frame)
        
        # Onglet Résultats
        results_frame = ttkb.Frame(notebook)
        notebook.add(results_frame, text="Résultats")
        self.setup_results_tab(results_frame)
        
    def setup_config_tab(self, parent):
        """Config onglet de paramétrage."""
        # Frame de défilement
        canvas = tk.Canvas(parent)
        scrollbar = ttkb.Scrollbar(parent, orient="vertical", command=canvas.yview)
        scrollable_frame = ttkb.Frame(canvas)
        
        scrollable_frame.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )
        
        canvas.create_window((0, 0), window=scrollable_frame, anchor="nw")
        canvas.configure(yscrollcommand=scrollbar.set)
        
        # Paramètres initiaux
        initial_group = ttkb.LabelFrame(scrollable_frame, text="Paramètres initiaux", bootstyle="primary")
        initial_group.pack(fill=X, padx=10, pady=5)
        
        self.create_param_row(initial_group, "Nombre de fourmis initial:", self.nb_fourmis_var, 1, 10000)
        self.create_param_row(initial_group, "Ressources nature initiales:", self.res_nature_var, 1000, 50000)
        self.create_param_row(initial_group, "Nombre d'années:", self.nb_annees_var, 1, 200)
        
        # Proportions
        prop_group = ttkb.LabelFrame(scrollable_frame, text="Proportions des rôles", bootstyle="success")
        prop_group.pack(fill=X, padx=10, pady=5)
        
        self.create_param_row(prop_group, "Proportion de gardes:", self.prop_garde_var, 0, 1, is_float=True)
        self.create_param_row(prop_group, "Proportion de récolteuses:", self.prop_recolteuse_var, 0, 1, is_float=True)
        self.create_param_row(prop_group, "Proportion de puéricultrices:", self.prop_puericultrice_var, 0, 1, is_float=True)

        # Capacités
        cap_group = ttkb.LabelFrame(scrollable_frame, text="Capacités maximales", bootstyle="info")
        cap_group.pack(fill=X, padx=10, pady=5)
        
        self.create_param_row(cap_group, "Capacité max fourmis:", self.cap_fourmis_var, 1, 200000)
        self.create_param_row(cap_group, "Capacité max ressources nature:", self.cap_res_nature_var, 1000, 200000)
        self.create_param_row(cap_group, "Capacité max stock:", self.cap_res_stock_var, 1000, 200000)
        
        # Autres paramètres
        other_group = ttkb.LabelFrame(scrollable_frame, text="Autres paramètres", bootstyle="secondary")
        other_group.pack(fill=X, padx=10, pady=5)
        
        self.create_param_row(other_group, "Facteur d'attaques:", self.facteur_attaques_var, 1.0, 10.0, is_float=True)
        
        # Boutons de configuration prédéfinie
        preset_group = ttkb.LabelFrame(scrollable_frame, text="Configurations prédéfinies", bootstyle="dark")
        preset_group.pack(fill=X, padx=10, pady=5)
        
        preset_frame = ttkb.Frame(preset_group)
        preset_frame.pack(fill=X, padx=5, pady=5)
        
        ttkb.Button(preset_frame, text="Configuration Stable", 
                   command=self.load_stable_config, bootstyle="success").pack(side=LEFT, padx=5)
        ttkb.Button(preset_frame, text="Configuration Instable", 
                   command=self.load_unstable_config, bootstyle="danger").pack(side=LEFT, padx=5)
        ttkb.Button(preset_frame, text="Réinitialiser", 
                   command=self.reset_config, bootstyle="secondary").pack(side=LEFT, padx=5)
        
        # Pack canvas et scrollbar
        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")
        
    def create_param_row(self, parent, label, var, min_val, max_val, is_float=False):
        """Crée une ligne de paramètre avec label, scale et spinbox."""
        frame = ttkb.Frame(parent)
        frame.pack(fill=X, padx=5, pady=2)
        
        # Label
        ttkb.Label(frame, text=label, width=25).pack(side=LEFT)
        
        # Scale
        if is_float:
            scale = ttkb.Scale(frame, from_=min_val, to=max_val, orient=HORIZONTAL, 
                              variable=var, length=200)
            scale.pack(side=LEFT, padx=5)
            # Spinbox pour valeurs décimales
            spinbox = ttkb.Spinbox(frame, from_=min_val, to=max_val, increment=0.01,
                                  textvariable=var, width=8, format="%.2f",
                                  command=lambda: self.adjust_proportions())
        else:
            scale = ttkb.Scale(frame, from_=min_val, to=max_val, orient=HORIZONTAL,
                              variable=var, length=200)
            scale.pack(side=LEFT, padx=5)
            # Spinbox pour valeurs entières
            spinbox = ttkb.Spinbox(frame, from_=min_val, to=max_val, increment=1,
                                  textvariable=var, width=8,
                                  command=lambda: self.adjust_proportions())
        
        spinbox.pack(side=LEFT, padx=5)
        
    def setup_simulation_tab(self, parent):
        """Configure l'onglet de simulation."""
        # Frame de contrôle
        control_frame = ttkb.LabelFrame(parent, text="Contrôles de simulation", bootstyle="primary")
        control_frame.pack(fill=X, padx=10, pady=5)
        
        button_frame = ttkb.Frame(control_frame)
        button_frame.pack(fill=X, padx=5, pady=5)
        
        self.start_btn = ttkb.Button(button_frame, text="Démarrer Simulation", 
                                    command=self.start_simulation, bootstyle="success", width=20)
        self.start_btn.pack(side=LEFT, padx=5)
        
        self.stop_btn = ttkb.Button(button_frame, text="Arrêter", 
                                   command=self.stop_simulation, bootstyle="danger", 
                                   width=15, state=DISABLED)
        self.stop_btn.pack(side=LEFT, padx=5)
        
        # Barre de progression
        progress_frame = ttkb.LabelFrame(parent, text="Progression", bootstyle="info")
        progress_frame.pack(fill=X, padx=10, pady=5)
        
        self.progress_bar = ttkb.Progressbar(progress_frame, variable=self.progress_var,
                                            bootstyle="success-striped", length=400)
        self.progress_bar.pack(pady=5)
        
        self.status_label = ttkb.Label(progress_frame, textvariable=self.status_var)
        self.status_label.pack(pady=5)
        
        # Zone d'informations en temps réel
        info_frame = ttkb.LabelFrame(parent, text="Informations en temps réel", bootstyle="secondary")
        info_frame.pack(fill=BOTH, expand=True, padx=10, pady=5)
        
        # Text widget avec scrollbar pour les logs
        text_frame = ttkb.Frame(info_frame)
        text_frame.pack(fill=BOTH, expand=True, padx=5, pady=5)
        
        self.info_text = tk.Text(text_frame, height=15, wrap=tk.WORD)
        info_scrollbar = ttkb.Scrollbar(text_frame, orient="vertical", command=self.info_text.yview)
        self.info_text.configure(yscrollcommand=info_scrollbar.set)
        
        self.info_text.pack(side="left", fill="both", expand=True)
        info_scrollbar.pack(side="right", fill="y")
        
    def setup_results_tab(self, parent):
        """Configure l'onglet des résultats."""
        # Frame pour les boutons
        button_frame = ttkb.Frame(parent)
        button_frame.pack(fill=X, padx=10, pady=5)
        
        ttkb.Button(button_frame, text="Actualiser Graphiques", 
                   command=self.update_plots, bootstyle="info").pack(side=LEFT, padx=5)
        ttkb.Button(button_frame, text="Exporter Données", 
                   command=self.export_data, bootstyle="secondary").pack(side=LEFT, padx=5)
        
        # Notebook pour les différents graphiques
        self.plot_notebook = ttkb.Notebook(parent)
        self.plot_notebook.pack(fill=BOTH, expand=True, padx=10, pady=5)
        
        # Création d'onglets pour chaque type de graphique
        self.create_plot_tabs()
        
    def create_plot_tabs(self):
        """Crée les onglets pour les différents graphiques."""
        # Graphique population
        self.pop_frame = ttkb.Frame(self.plot_notebook)
        self.plot_notebook.add(self.pop_frame, text="Population")
        
        # Graphique ressources
        self.res_frame = ttkb.Frame(self.plot_notebook)
        self.plot_notebook.add(self.res_frame, text="Ressources")
        
        # Graphique attaques
        self.att_frame = ttkb.Frame(self.plot_notebook)
        self.plot_notebook.add(self.att_frame, text="Attaques")
        
        # Graphique naissances
        self.birth_frame = ttkb.Frame(self.plot_notebook)
        self.plot_notebook.add(self.birth_frame, text="Naissances")
        
        # Onglet pour afficher tous les graphiques
        self.all_plots_frame = ttkb.Frame(self.plot_notebook)
        self.plot_notebook.add(self.all_plots_frame, text="Tous les Graphiques")
    
    def load_stable_config(self):
        """Charge la configuration stable."""
        self.loading_config = True  # Désactive l'ajustement automatique

        self.nb_fourmis_var.set(500)
        self.res_nature_var.set(10000)
        self.prop_garde_var.set(0.275)
        self.prop_recolteuse_var.set(0.45)
        self.prop_puericultrice_var.set(0.275)
        self.facteur_attaques_var.set(3.0)
        self.cap_fourmis_var.set(6000)
        self.cap_res_nature_var.set(100000)
        self.cap_res_stock_var.set(60000)
        
        self.loading_config = False  # Réactive
        
    def load_unstable_config(self):
        """Charge la configuration instable."""
        self.loading_config = True  # Désactive l'ajustement automatique

        self.nb_fourmis_var.set(400)
        self.res_nature_var.set(30000)
        self.prop_garde_var.set(0.20)
        self.prop_recolteuse_var.set(0.50)
        self.prop_puericultrice_var.set(0.30)
        self.facteur_attaques_var.set(3.0)
        self.cap_fourmis_var.set(6000)
        self.cap_res_nature_var.set(100000)
        self.cap_res_stock_var.set(60000)

        self.loading_config = False  # Réactive
        
    def reset_config(self):
        """Remet les valeurs par défaut."""
        self.load_stable_config()
        
    def start_simulation(self):
        """Démarre la simulation dans un thread séparé."""
        if self.simulation_running:
            return
            
        # Validation des paramètres
        if not self.validate_parameters():
            return
            
        # Création de la fourmilière
        self.fourmiliere = Fourmiliere(
            self.nb_fourmis_var.get(),
            self.res_nature_var.get(),
            self.prop_garde_var.get(),
            self.prop_recolteuse_var.get(),
            self.prop_puericultrice_var.get(),
            self.facteur_attaques_var.get(),
            self.cap_fourmis_var.get(),
            self.cap_res_nature_var.get(),
            self.cap_res_stock_var.get()
        )
        
        # Mise à jour de l'interface
        self.simulation_running = True
        self.start_btn.config(state=DISABLED)
        self.stop_btn.config(state=NORMAL)
        self.progress_var.set(0)
        self.info_text.delete(1.0, tk.END)
        
        # Démarrage du thread de simulation
        self.simulation_thread = threading.Thread(target=self.run_simulation, daemon=True)
        self.simulation_thread.start()
        
    def validate_parameters(self):
        """Valide les paramètres avant de démarrer la simulation."""
        total_prop = (self.prop_garde_var.get() + 
                     self.prop_recolteuse_var.get() + 
                     self.prop_puericultrice_var.get())
        
        if abs(total_prop - 1.0) > 0.01:
            messagebox.showerror("Erreur", "La somme des proportions doit faire 1.0")
            return False
            
        if self.nb_fourmis_var.get() <= 0:
            messagebox.showerror("Erreur", "Le nombre de fourmis doit être positif")
            return False
            
        return True
        
    def run_simulation(self):
        """Exécute la simulation."""
        try:
            nb_annees = self.nb_annees_var.get()
            
            # Initialisation du DataFrame
            self.df_results = pd.DataFrame()
            
            # Log initial
            self.log_info("=== DÉBUT DE LA SIMULATION ===")
            self.log_info(f"Fourmis initiales: {self.fourmiliere.get_nombre_fourmis()}")
            self.log_info(f"Ressources nature: {self.fourmiliere.get_ressources_nature()}")
            
            total_seasons = nb_annees * 4
            current_season = 0
            
            for annee in range(1, nb_annees + 1):
                if not self.simulation_running:
                    break
                    
                for saison in ["printemps", "ete", "automne", "hiver"]:
                    if not self.simulation_running:
                        break
                        
                    current_season += 1
                    
                    # Simulation de la saison
                    infos_attaques, new_fourmis = self.fourmiliere.simuler_saison(saison)
                    
                    # Enregistrement des données
                    data_row = {
                        "Année": annee,
                        "Saison": saison.title(),
                        "Nb_Fourmis": self.fourmiliere.get_nombre_fourmis(),
                        "Nb_Gardes": self.fourmiliere.get_nombre_gardes(),
                        "Nb_Recolteuses": self.fourmiliere.get_nombre_recolteuses(),
                        "Nb_Puericultrices": self.fourmiliere.get_nombre_puericultrices(),
                        "Nb_New_Gardes": new_fourmis[0],
                        "Nb_New_Recolteuses": new_fourmis[1],
                        "Nb_New_Puericultrices": new_fourmis[2],
                        "Res_Stock": self.fourmiliere.get_ressources_stock(),
                        "Res_Nature": self.fourmiliere.get_ressources_nature(),
                        "Nb_Attaquants": infos_attaques[0],
                        "Nb_morts_attaques": infos_attaques[1]
                    }
                    
                    self.df_results = pd.concat([self.df_results, pd.DataFrame([data_row])], 
                                              ignore_index=True)
                    
                    # Mise à jour de la progression
                    progress = (current_season / total_seasons) * 100
                    self.progress_var.set(progress)
                    self.status_var.set(f"Année {annee} - {saison.title()} ({current_season}/{total_seasons})")
                    
                    # Log de l'avancement de la simulation
                    if current_season % 4 == 0:  # Chaque année
                        self.log_info(f"Année {annee} terminée - Population: {self.fourmiliere.get_nombre_fourmis()}")
                    
                    # Pause pour permettre l'arrêt
                    time.sleep(0.01)
                    
            if self.simulation_running:
                self.log_info("=== SIMULATION TERMINÉE ===")
                self.log_info(f"Population finale: {self.fourmiliere.get_nombre_fourmis()}")
                self.status_var.set("Simulation terminée avec succès")
                # Auto-update des graphiques
                self.root.after(100, self.update_plots)
            else:
                self.log_info("=== SIMULATION ARRÊTÉE ===")
                self.status_var.set("Simulation arrêtée par l'utilisateur")
                
        except Exception as e:
            self.log_info(f"ERREUR: {str(e)}")
            self.status_var.set("Erreur lors de la simulation")
            messagebox.showerror("Erreur", f"Erreur lors de la simulation:\n{str(e)}")
        finally:
            self.simulation_running = False
            self.start_btn.config(state=NORMAL)
            self.stop_btn.config(state=DISABLED)
            
    def stop_simulation(self):
        """Arrête la simulation."""
        self.simulation_running = False
        self.stop_btn.config(state=DISABLED)
        
    def log_info(self, message):
        """Ajoute un message dans la zone de log."""
        def update_text():
            self.info_text.insert(tk.END, f"{time.strftime('%H:%M:%S')} - {message}\n")
            self.info_text.see(tk.END)
        
        self.root.after(0, update_text)
        
    def update_plots(self):
        """Met à jour tous les graphiques."""
        if self.df_results is None or self.df_results.empty:
            messagebox.showwarning("Aucune donnée", "Aucune donnée de simulation disponible")
            return
            
        try:
            # Préparation des données
            self.df_results["Period"] = self.df_results["Année"].astype(str) + "-" + self.df_results["Saison"]
            
            # Nettoyage des anciens graphiques
            for frame in [self.pop_frame, self.res_frame, self.att_frame, self.birth_frame]:
                for widget in frame.winfo_children():
                    widget.destroy()
            
            # Graphique population
            self.create_population_plot()
            
            # Graphique ressources  
            self.create_resources_plot()
            
            # Graphique attaques
            self.create_attacks_plot()
            
            # Graphique naissances
            self.create_births_plot()
            
            # Graphique tous les graphiques
            self.create_all_plots_tab()
            
            messagebox.showinfo("Mise à jour", "Graphiques mis à jour avec succès!")
            
        except Exception as e:
            messagebox.showerror("Erreur", f"Erreur lors de la mise à jour des graphiques:\n{str(e)}")
            
    def create_population_plot(self, fig=None, ax=None, parent_frame=None, compact=False):
        """Crée le graphique d'évolution de la population."""
        if fig is None:
            fig = Figure(figsize=(12, 6), dpi=80)
            ax = fig.add_subplot(111)
            parent_frame = self.pop_frame
        
        # Calcul du pas pour l'affichage des étiquettes
        max_ticks = 15 if compact else 20
        step = max(1, len(self.df_results) // max_ticks)
        
        ax.plot(self.df_results.index, self.df_results["Nb_Fourmis"], 
                linewidth=2, label="Total Fourmis", color='blue')
        ax.plot(self.df_results.index, self.df_results["Nb_Gardes"], 
                label="Gardes", color='red', alpha=0.7)
        ax.plot(self.df_results.index, self.df_results["Nb_Recolteuses"], 
                label="Récolteuses", color='green', alpha=0.7)
        ax.plot(self.df_results.index, self.df_results["Nb_Puericultrices"], 
                label="Puéricultrices", color='orange', alpha=0.7)
        
        ax.set_xlabel("Période")
        ax.set_ylabel("Nombre de fourmis")
        ax.set_title("Évolution de la population")
        ax.legend(fontsize=8 if compact else None)
        ax.grid(True, alpha=0.3)
        
        # Configuration des étiquettes x
        ax.set_xticks(range(0, len(self.df_results), step))
        ax.set_xticklabels([self.df_results.iloc[i]["Period"] for i in range(0, len(self.df_results), step)], 
                          rotation=45, ha='right', fontsize=8 if compact else None)
        
        # Si c'est un graphique standalone, créer le canvas
        if parent_frame is not None:
            fig.tight_layout()
            canvas = FigureCanvasTkAgg(fig, parent_frame)
            canvas.draw()
            canvas.get_tk_widget().pack(fill=BOTH, expand=True)
        
    def create_resources_plot(self, fig=None, ax=None, parent_frame=None, compact=False):
        """Crée le graphique d'évolution des ressources."""
        if fig is None:
            fig = Figure(figsize=(12, 6), dpi=80)
            ax = fig.add_subplot(111)
            parent_frame = self.res_frame
        
        max_ticks = 15 if compact else 20
        step = max(1, len(self.df_results) // max_ticks)
        
        ax.plot(self.df_results.index, self.df_results["Res_Stock"], 
                label="Ressources Stock", color='blue', linewidth=2)
        ax.plot(self.df_results.index, self.df_results["Res_Nature"], 
                label="Ressources Nature", color='green', linewidth=2)
        
        ax.set_xlabel("Période")
        ax.set_ylabel("Quantité de ressources")
        ax.set_title("Évolution des ressources")
        ax.legend(fontsize=8 if compact else None)
        ax.grid(True, alpha=0.3)
        
        ax.set_xticks(range(0, len(self.df_results), step))
        ax.set_xticklabels([self.df_results.iloc[i]["Period"] for i in range(0, len(self.df_results), step)], 
                          rotation=45, ha='right', fontsize=8 if compact else None)
        
        # Si c'est un graphique standalone, créer le canvas
        if parent_frame is not None:
            fig.tight_layout()
            canvas = FigureCanvasTkAgg(fig, parent_frame)
            canvas.draw()
            canvas.get_tk_widget().pack(fill=BOTH, expand=True)
        
    def create_attacks_plot(self, fig=None, ax=None, parent_frame=None, compact=False):
        """Crée le graphique des attaques."""
        if fig is None:
            fig = Figure(figsize=(12, 6), dpi=80)
            ax = fig.add_subplot(111)
            parent_frame = self.att_frame
        
        max_ticks = 15 if compact else 20
        step = max(1, len(self.df_results) // max_ticks)
        marker_size = 3 if compact else 6
        
        ax.plot(self.df_results.index, self.df_results["Nb_Attaquants"], 
                label="Nombre d'attaquants", color='red', marker='o', alpha=0.7, markersize=marker_size)
        ax.plot(self.df_results.index, self.df_results["Nb_morts_attaques"], 
                label="Morts par attaques", color='black', marker='s', alpha=0.7, markersize=marker_size)
        
        ax.set_xlabel("Période")
        ax.set_ylabel("Nombre")
        ax.set_title("Évolution des attaques et pertes")
        ax.legend(fontsize=8 if compact else None)
        ax.grid(True, alpha=0.3)
        
        ax.set_xticks(range(0, len(self.df_results), step))
        ax.set_xticklabels([self.df_results.iloc[i]["Period"] for i in range(0, len(self.df_results), step)], 
                          rotation=45, ha='right', fontsize=8 if compact else None)
        
        # Si c'est un graphique standalone, créer le canvas
        if parent_frame is not None:
            fig.tight_layout()
            canvas = FigureCanvasTkAgg(fig, parent_frame)
            canvas.draw()
            canvas.get_tk_widget().pack(fill=BOTH, expand=True)
        
    def create_births_plot(self, fig=None, ax=None, parent_frame=None, compact=False):
        """Crée le graphique des naissances."""
        if fig is None:
            fig = Figure(figsize=(12, 6), dpi=80)
            ax = fig.add_subplot(111)
            parent_frame = self.birth_frame
        
        max_ticks = 15 if compact else 20
        step = max(1, len(self.df_results) // max_ticks)
        marker_size = 3 if compact else 6
        
        ax.plot(self.df_results.index, self.df_results["Nb_New_Gardes"], 
                label="Nouveaux Gardes", color='red', alpha=0.7, marker='o', markersize=marker_size)
        ax.plot(self.df_results.index, self.df_results["Nb_New_Recolteuses"], 
                label="Nouvelles Récolteuses", color='green', alpha=0.7, marker='s', markersize=marker_size)
        ax.plot(self.df_results.index, self.df_results["Nb_New_Puericultrices"], 
                label="Nouvelles Puéricultrices", color='orange', alpha=0.7, marker='^', markersize=marker_size)
        
        ax.set_xlabel("Période")
        ax.set_ylabel("Nombre de naissances")
        ax.set_title("Naissances par saison et par rôle")
        ax.legend(fontsize=8 if compact else None)
        ax.grid(True, alpha=0.3)
        
        ax.set_xticks(range(0, len(self.df_results), step))
        ax.set_xticklabels([self.df_results.iloc[i]["Period"] for i in range(0, len(self.df_results), step)], 
                          rotation=45, ha='right', fontsize=8 if compact else None)
        
        # Si c'est un graphique standalone, créer le canvas
        if parent_frame is not None:
            fig.tight_layout()
            canvas = FigureCanvasTkAgg(fig, parent_frame)
            canvas.draw()
            canvas.get_tk_widget().pack(fill=BOTH, expand=True)
        
    def create_all_plots_tab(self):
        """Affiche tous les graphiques dans une grille 2x2 en réutilisant les fonctions modulaires."""
        for widget in self.all_plots_frame.winfo_children():
            widget.destroy()
        
        # Création de la figure principale avec sous-graphiques
        fig = Figure(figsize=(16, 12), dpi=80)
        fig.suptitle("Vue d'ensemble - Tous les graphiques", fontsize=16, fontweight='bold')
        
        # Création des sous-graphiques
        ax1 = fig.add_subplot(2, 2, 1)  # Population (haut gauche)
        ax2 = fig.add_subplot(2, 2, 2)  # Ressources (haut droite)
        ax3 = fig.add_subplot(2, 2, 3)  # Attaques (bas gauche)
        ax4 = fig.add_subplot(2, 2, 4)  # Naissances (bas droite)

        # Réutilisation des fonctions existantes avec les paramètres pour mode compact
        self.create_population_plot(fig=fig, ax=ax1, parent_frame=None, compact=True)
        self.create_resources_plot(fig=fig, ax=ax2, parent_frame=None, compact=True)
        self.create_attacks_plot(fig=fig, ax=ax3, parent_frame=None, compact=True)
        self.create_births_plot(fig=fig, ax=ax4, parent_frame=None, compact=True)
        
        # Ajustement de la mise en page
        fig.tight_layout(pad=3.0)
        
        # Création du canvas pour affichage
        canvas = FigureCanvasTkAgg(fig, self.all_plots_frame)
        canvas.draw()
        canvas.get_tk_widget().pack(fill=BOTH, expand=True)
        
    def export_data(self):
        """Exporte les données de simulation vers un fichier CSV."""
        if self.df_results is None or self.df_results.empty:
            messagebox.showwarning("Aucune donnée", "Aucune donnée de simulation à exporter")
            return
            
        try:
            from tkinter import filedialog
            filename = filedialog.asksaveasfilename(
                defaultextension=".csv",
                filetypes=[("Fichiers CSV", "*.csv"), ("Tous les fichiers", "*.*")],
                title="Sauvegarder les données de simulation"
            )
            
            if filename:
                self.df_results.to_csv(filename, index=False, encoding='utf-8')
                messagebox.showinfo("Export réussi", f"Données exportées vers:\n{filename}")
                
        except Exception as e:
            messagebox.showerror("Erreur d'export", f"Erreur lors de l'export:\n{str(e)}")


def main():
    """Fonction principale pour lancer l'application."""
    root = ttkb.Window(themename="superhero")
    app = FourmiSimulatorGUI(root)
    
    # Configuration de la fermeture de l'application
    def on_closing():
        if app.simulation_running:
            if messagebox.askokcancel("Quitter", "Une simulation est en cours. Voulez-vous vraiment quitter ?"):
                app.stop_simulation()
                root.destroy()
        else:
            root.destroy()
    
    root.protocol("WM_DELETE_WINDOW", on_closing)
    
    # Démarrage de l'application
    root.mainloop()


if __name__ == "__main__":
    main()
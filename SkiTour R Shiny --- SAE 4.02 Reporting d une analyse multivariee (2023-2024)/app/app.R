# Bibliotheques
library(shiny)
library(leaflet)
library(DT)
library(shinyjs)
library(shinydashboard)
library(plotly)
library(sf)
library(FactoMineR)
library(factoextra)
library(gridExtra)
library(ggcorrplot)
library(ggrepel) # Pour éviter le chevauchement des étiquettes

# Chargement des données

# DONNEES GLOBAL
donnees_skitour = read.csv("data/data_skitour_Vanoise__0__6588.csv", sep=";", dec=",")
donnees_skitour$Id = factor(donnees_skitour$Id)
donnees_skitour$Nom = factor(donnees_skitour$Nom)
donnees_skitour$Orientation = factor(donnees_skitour$Orientation, levels = c("N", "NE", "E", "SE", "S", "SW", "W", "NW", "T"))
donnees_skitour$Alpi = factor(donnees_skitour$Alpi, levels = c("R", "F", "PD-", "PD", "PD+", "AD-", "AD", "AD+", "D-", "D"))
donnees_skitour$Ski = factor(donnees_skitour$Ski, levels = c("1.1", "1.2", "1.3", "2.1", "2.2", "2.3", "3.1", "3.2", "3.3", "4.1", "4.2", "4.3", "5.1", "5.2", "5.3"), ordered = TRUE)
donnees_skitour$Depart.id = factor(donnees_skitour$Depart.id)
donnees_skitour$Sommet.id  = factor(donnees_skitour$Sommet.id)
donnees_skitour$Sommet.nom = factor(donnees_skitour$Sommet.nom)
donnees_skitour$Freq.total = rowSums(donnees_skitour[,26:ncol(donnees_skitour)])
donnees_skitour[124, "Sommet.longitude"] = 6.61
donnees_skitour[124, "Sommet.latitude"] = 45.38


# DONNEES PRESENTATION
carte_vanoise = st_read("data/Vanoise.geojson")
points_sf = st_as_sf(donnees_skitour, 
                     coords = c("Sommet.longitude", "Sommet.latitude"), 
                     crs = 4326)

# DONNEES UNIVARIE
donnees_univarie = subset(donnees_skitour, select = -c(Id, Nom, Depart.id, Sommet.id, Sommet.nom, Sommet.longitude, Sommet.latitude))

# DONNEES MAP
data_map = donnees_skitour[0:13] # Ne prend pas les fréquentations
color_palette <- colorNumeric(palette = "viridis", domain = data_map$Sommet.altitude, reverse=TRUE)# palette de couleurs basée sur l'altitude des sommets
color_palette_legende <- colorNumeric(palette = "viridis", domain = data_map$Sommet.altitude) # palette pour la legende

# DONNEES FACTORIELLES
donnees_factorielles = donnees_skitour
row.names(donnees_factorielles) = donnees_factorielles$Nom
donnees_factorielles$Sommet.longitude = factor(donnees_factorielles$Sommet.longitude)
donnees_factorielles$Sommet.latitude = factor(donnees_factorielles$Sommet.latitude)


# Importe les uis
source("ui/ui_presentation.R")
source("ui/ui_bivarie.R")
source("ui/ui_map.R")
source("ui/ui_factorielle.R")
source("ui/ui_univarie.R")


# UI de l'application Shiny
ui <- dashboardPage(

  # SIDEBARMENU
  dashboardHeader(
    title = span(
      img(src = "Logo_IUT2_STID.png", height = 35),
      "SAE-SKITOUR"
    )
  ),
  
  sidebar <- dashboardSidebar(
    sidebarMenu(
      menuItem("Présentation",
        tabName = "pres", icon = icon("dashboard")
      ),
      menuItem("Analyses Univariées",
        tabName = "An_univar", icon = icon("th")
      ),
      menuItem("Analyses Bivariées",
        tabName = "An_bivar", icon = icon("dashboard")
      ),
      menuItem("Cartographie",
        tabName = "Map", icon = icon("th")
      ),
      menuItem("Analyses factorielles",
        tabName = "ACP_CAH", icon = icon("th")
      )
    )
  ),
  
  body <- dashboardBody(
    
    tabItems(
      
      # UI-PRESENTATION
      ui_presentation(donnees_skitour),
      
      # UI-UNIVARIE
      ui_univarie(),
      
      # UI-BIVARIE
      ui_bivarie(),
      
      # UI-MAP
      ui_map(),
      
      # UI-FACTORIELLE
      ui_factorielle()
      
    )
  ),
  dashboardPage(
    dashboardHeader(title = "Simple tabs"),
    sidebar,
    body
  )
)

# SERVER
server <- function(input, output, session) {
  
  # SERVER-PRESENTATION
  source("server/server_presentation.R", local=TRUE)
  
  # SERVER-UNIVARIE               
  source("server/server_univarie.R", local=TRUE)

  # SERVER-BIVARIE
  source("server/server_bivarie.R", local=TRUE)
  
  # SERVER-MAP
  source("server/server_map.R", local=TRUE)
  
  # SERVER-FACTORIELLE
  source("server/server_factorielles.R", local=TRUE)
  
}


# Lancer l'application Shiny
shinyApp(ui = ui, server = server)

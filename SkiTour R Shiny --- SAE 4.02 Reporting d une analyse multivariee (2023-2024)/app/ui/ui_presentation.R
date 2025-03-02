ui_presentation = function(donnees_skitour){
  return(
    tabItem(
      tabName = "pres",
      tags$head(
        tags$style(HTML("
            .container {
              margin:auto;
              font-family: DejaVu Sans Mono, 'Courier New';
              
            }
          
            .center {
                align-item: center;
            }
            h2 {
              text-align: center;
            }
            .sous_ligne{
              text-decoration: underline;
            }
            .animatedNumber {
              font-size: 42px;
              font-weight: bold;
            }
            
        ")),
        tags$script(
          HTML("
  document.addEventListener('DOMContentLoaded', function(event) {
    var animatedNumbers = document.querySelectorAll('.animatedNumber');

    var animationDuration = 800;
    var refreshRate = 20;
    
    animatedNumbers.forEach(function(element) {
      var finalValue = parseInt(element.textContent);
      var increment = finalValue / (animationDuration / refreshRate);
      var currentValue = 0;
    
      function updateNumberDisplay(value) {
        element.textContent = Math.round(value);
      }
    
      function animateNumber() {
        var interval = setInterval(function() {
          currentValue += increment;
          updateNumberDisplay(currentValue);
          if (currentValue >= finalValue) {
            clearInterval(interval);
            updateNumberDisplay(finalValue);
          }
        }, refreshRate);
      }
    
      animateNumber();
    });
    

});
      
    ")
        )
      ),
      
          div(class = "container", titlePanel("SAE 4.02 : Analyser les pratiques de la randonnée à ski grâce aux données issues du forum Skitour"),
          h3("Introduction"),
          p("Dans le domaine des activités sportives et de loisirs en pleine nature, l'analyse des médias sociaux offre une opportunité unique d'évaluer la fréquentation des espaces naturels. Notre projet se concentre sur l'utilisation des données provenant du forum Skitour pour évaluer l'importance de la pratique de la randonnée à ski dans le massif de la Vanoise, situé dans les Alpes françaises. L'analyse de la fréquentation des randonnées à ski dans le massif de la Vanoise offre une opportunité pour élaborer des stratégies de préservation de la faune."),
          
          tabsetPanel(
            
            tabPanel("Présentation",
            h3("Quelques statistiques"),
                     
                     fluidRow(
                       column(4, tags$p("Nombre de sommets : ", class="sous_ligne")),
                       column(4, tags$p(tags$span(nrow(donnees_skitour), class = "animatedNumber"))),
                     ),
                     
                     fluidRow(
                       column(4, p("Sommet le plus bas : ", class="sous_ligne")),
                       column(8, tags$p(tags$span(min(donnees_skitour$Sommet.altitude), class="animatedNumber"), "mètres d'altitude : ", actionLink("point_bas" ,donnees_skitour[which.min(donnees_skitour$Sommet.altitude),]$Sommet.nom))),
                       br(),
                     ),
                     
                     fluidRow(
                       column(4, p("Sommet le plus haut : ", class="sous_ligne")),
                       column(8, tags$p(tags$span(max(donnees_skitour$Sommet.altitude), class="animatedNumber"), "mètres d'altitude : ", actionLink("point_haut",donnees_skitour[which.max(donnees_skitour$Sommet.altitude),]$Sommet.nom))),
                       br(),
                     ),
                     
                     fluidRow(
                       column(4, tags$p("Sorties enregistées :", class= "sous_ligne")),
                       column(4, tags$p(tags$span(sum(donnees_skitour$S2019.2020), class="animatedNumber"), "en 2019-2020")),
                     ),
                     
                     fluidRow(
                       column(4),
                       column(4, tags$p(tags$span(sum(donnees_skitour$S2020.2021), class="animatedNumber"), "en 2020-2021")),
                     ),
                     
                     fluidRow(
                       column(4, tags$p("Randonnée la plus courte : ", class="sous_ligne")),
                       column(8, tags$p(tags$span(min(donnees_skitour$Deniv.plus), class = "animatedNumber"), "mètres de dénivelé positif : ", actionLink("denivelé_min",donnees_skitour[which.min(donnees_skitour$Deniv.plus),]$Sommet.nom))),
                     ),
                     
                     fluidRow(
                       column(4, tags$p("Randonnée la plus longue : ", class="sous_ligne")),
                       column(8, tags$p(tags$span(max(donnees_skitour$Deniv.plus), class = "animatedNumber"), "mètres de dénivelé positif : ",actionLink("denivelé_max",donnees_skitour[which.max(donnees_skitour$Deniv.plus),]$Sommet.nom))),
                     )),
            
            tabPanel("Les variables",
            h3("Présentation des variables"),
                     
                     fluidRow(
                       column(3, tags$p("Orientation"), class = "sous_ligne"),
                       column(2, tags$p("Qualitatif nominale")),
                       column(3, tags$p("Orientation de la randonnée")),
                       column(4, tags$p("T=toutes orientations"), tags$p("N=nord"), tags$p("S=sud"), tags$p("E=est"), tags$p("O=ouest")),
                     ),
                     br(),
                     fluidRow(
                       column(3, tags$p("Alpi"), class = "sous_ligne"),
                       column(2, tags$p("Qualitatif ordinale")),
                       column(3, tags$p("Difficulté de la montée")),
                       column(4, tags$p("R=randonnée"), tags$p("F=facile"), tags$p("PD=peu difficile"), tags$p("AD=assez difficile"), tags$p("D=difficile")),
                     ),
                     br(),
                     fluidRow(
                       column(3, tags$p("Ski"), class = "sous_ligne"),
                       column(2, tags$p("Qualitatif ordinale")),
                       column(3, tags$p("Difficulté de la descente à ski")),
                       column(4, tags$p("Echelle de 1 à 5 mais 3 niveau intermédiaire, exemple : 1.1 < 1.2 < 1.3")),
                     ),
                     br(),
                     fluidRow(
                       column(3, tags$p("Deniv.plus"), class = "sous_ligne"),
                       column(2, tags$p("Quantitatif continu")),
                       column(3, tags$p("Dénivelé positif de la randonnée")),
                     ),
                     br(),
                     fluidRow(
                       column(3, tags$p("Depart.altitude"), class = "sous_ligne"),
                       column(2, tags$p("Quantitatif continu")),
                       column(3, tags$p("Altitude de départ de la randonnée")),
                     ),
                     br(),
                     fluidRow(
                       column(3, tags$p("Sommet.altitude"), class = "sous_ligne"),
                       column(2, tags$p("Quantitatif continu")),
                       column(3, tags$p("Altitude du sommet")),
                     ),
                     br(),
                     fluidRow(
                       column(3, tags$p("de M01 à M12"), class = "sous_ligne"),
                       column(2, tags$p("Quantitatif continu")),
                       column(3, tags$p("fréquentation par mois")),
                     ),
                     br(),
                     fluidRow(
                       column(3, tags$p("de S1999-2000 à S2020-2021"), class = "sous_ligne"),
                       column(2, tags$p("Quantitatif continu")),
                       column(3, tags$p("fréquentation par saison")),
                     ),
                     br()
            ),
          ),
          
          actionButton("reset_carte", "Réinitialiser la carte", class = "center"),
          br(),
          leafletOutput("carte"),
          br(),
      ),
      br()
    )
  )
}
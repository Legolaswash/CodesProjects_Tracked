ui_map = function(){
  return(
    tabItem(
      tabName = "Map",
      
      # CSS et Script de la page
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
        tags$script("
            $(function() {
              $('li a').on('click', function() {
                var val = $(this).attr('data-value');
                Shiny.setInputValue('currentTab', val);
              });
              // trigger click on the first item
              setTimeout(function(){
                $('li a').first().trigger('click');
              }, 10);
            });
          ")
      ),
      
      # Utilisation de shinyjs
      shinyjs::useShinyjs(),
      theme = shinythemes::shinytheme("paper"),
      
      fluidRow(
        
        # MAP
        box(
          width = 6,
          leafletOutput("map", height = "50vh")
        ),
        
        # GRAPHIQUE
        box(
          width = 6,
          plotlyOutput("frequency_plot", height = "50vh")
        ) 
      ),
      
      # Bouton reset
      fluidRow(
        column(
          width = 12, align = "center",
          div(
            style = "margin-top: 5px; margin-bottom: 0px;",
            actionButton("reset_button", "Réinitialiser le filtre",
                         icon = icon("repeat", lib = "glyphicon")
            )
          ),
        )
      ),
      
      # Premier tableau
      h3("Données du Point Sélectionné"),
      p("Ce tableau affiche les données du point sélectionné sur la carte."),
      DTOutput("filtered_table_map", width = "100%"),
      
      br(),
      
      # Deuxième tableau
      h3("Données Sélectionnées"),
      p("Ce tableau affiche toutes les données et sert à filtrer sur la carte en cliquant sur les lignes."),
      DTOutput("table", width = "100%")
    )
  )
}
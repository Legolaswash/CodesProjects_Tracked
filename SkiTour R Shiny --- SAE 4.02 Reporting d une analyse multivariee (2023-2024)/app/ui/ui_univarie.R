ui_univarie = function(){
  return(
    tabItem(
      tabName = "An_univar",
      titlePanel("Visualisation de données"),
      sidebarLayout(
        sidebarPanel(
          selectInput("variable1", "Sélectionnez la variable", choices = NULL)
        ),
        mainPanel(
          verbatimTextOutput("summary_stats"), # Résumé
          plotlyOutput("plot1"), # Graphique principal
          plotlyOutput("plot_radar")  # Graphique Radar
        )
      )
    )
  )
}
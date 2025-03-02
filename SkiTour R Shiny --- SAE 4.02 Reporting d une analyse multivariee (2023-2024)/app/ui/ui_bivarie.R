ui_bivarie = function(){
  return(
    tabItem(
      tabName = "An_bivar",

      titlePanel("Croisement de deux variables"),
      
      sidebarLayout(
        
        sidebarPanel(
          
          h3("Croisement prédéfini"),
          uiOutput(outputId = "croisement_variables"),
          br(),
          br(),
          br(),
          
          
          h3("Croisement libre"),
          uiOutput(outputId = "premiere_variable"),
          
          br(),
          
          uiOutput(outputId = "deuxieme_variable"),
          
          br(),
          
          actionButton("switch_variables", "Echanger les variables")
          
          
        ),
        
        mainPanel(
          
          tabsetPanel(type = "tabs",
                      tabPanel("Graphique", plotlyOutput("plot")),
                      tabPanel("Résumé", verbatimTextOutput("summary")),
                      tabPanel("Table", tableOutput("table_I"))
          )
          
        )
      )
    )
  )
}
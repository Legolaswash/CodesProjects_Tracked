ui_factorielle = function(){
  return(
    tabItem(
      tabName = "ACP_CAH",
      
      fluidPage(
        tags$style("
                  .value-box {
                      display: inline-block;
                      width: 200px;
                      height: 150px;
                      margin: 10px;
                      padding: 10px;
                      text-align: center;
                      border-radius: 5px;
                      color: white; /* Ajout de la couleur du texte */
                    }

                  .value-box-icon {
                    font-size: 48px;
                    margin-bottom: 10px;
                  }

                  .value-box-value {
                    font-size: 24px;
                    font-weight: bold;
                  }

                  .value-box-description {
                    font-size: 16px;
                  }"),
        
        useShinyjs(),
        
        titlePanel("Analyses factorielles"),
        fluidRow(
          column(
            width = 9,
            tabsetPanel(
              id = "tabset",
              

              ############################# ACP ############################
              tabPanel(
                "ACP",
                sidebarLayout(
                  # PANNNEAU GAUCHE - INFOS ACP
                  sidebarPanel(
                    h3("Paramètres de l'ACP"),
                    wellPanel(
                      # verbatimTextOutput("pca_parameters")
                      htmlOutput("pca_parameters")
                    ),
                    
                    h3("Variables Quantitatives"),
                    wellPanel(
                      h4("Variables Quanti Illustratives"),
                      selectInput("illustrative_vars_quant", "Sélectionnez les variables illustratives (Quanti):",
                                  choices = NULL, multiple = TRUE
                      )
                    ),

                    h3("Variables Qualitatives"),
                    wellPanel(
                      h4("Variables Quali (illustratives)"),
                      selectInput("illustrative_vars_quali", "Sélectionnez les variables qualitatives (illustratives):",
                                  choices = NULL, multiple = TRUE
                      )
                    ),
                  ),
                  
                  # GRAPHIQUES
                  mainPanel(
                    tabsetPanel(
                      tabPanel("Graphique Individus", plotOutput("plot_acp_ind", height = "800px")),
                      tabPanel("Données Visualisation 3D", plotlyOutput("data.plot.3d", height = "800px")),
                      tabPanel("Selection Dimensions", plotOutput("facto.vars_dim", height = "800px")),
                      tabPanel("Cercle des Corrélations, Dim 1-2, Dim 2-3", 
                               plotOutput("plot_acp_var1", height = "800px"),
                               plotOutput("plot_acp_var2", height = "800px")),
                      tabPanel("Contr. Variables", 
                               plotlyOutput("facto.contr.var1", height = "800px"), 
                               plotlyOutput("facto.contr.var2", height = "800px")),
                      tabPanel("Contr. Individus", 
                               plotlyOutput("facto.contr.ind1", height = "800px"),
                               plotlyOutput("facto.contr.ind2", height = "800px")),
                      tabPanel("Contr. Individus, sur les 3 Dimensions", plotOutput("corrplot.var", width = 800, height = 1200)),
                      tabPanel(
                        "Description des Axes",
                        fluidRow(
                          tags$style(HTML("
                                                  .axis-table {
                                                     border: 3px solid #ff0000;
                                                     border-radius: 10px;
                                                     margin-bottom: 20px;
                                                     padding: 15px;
                                                   }
                                                   .axis-table-title {
                                                     padding: 10px;
                                                     border-top-left-radius: 10px;
                                                     border-top-right-radius: 10px;
                                                     margin-bottom: 0;
                                                     font-weight: bold;
                                                   }")),
                          box(
                            width = 12, title = div("1st. Dimension"),
                            DT::dataTableOutput("table.pca.interpret.dim1"), status = "primary", class = "axis-table"
                          ),
                          box(
                            width = 12, title = div("2nd. Dimension"),
                            DT::dataTableOutput("table.pca.interpret.dim2"), status = "success", class = "axis-table"
                          ),
                          box(
                            width = 12, title = div("3rd. Dimension"),
                            DT::dataTableOutput("table.pca.interpret.dim3"), status = "danger", class = "axis-table"
                          )
                        )
                      ),
                      tabPanel(
                        "PCA 2D plots",
                        div(
                          class = "divider",
                          tags$hr(style = "border-top: 3px solid #ccc;"),
                          plotlyOutput("plot1_ACP", height = "800px"),
                          tags$hr(style = "border-top: 3px solid #ccc;"),
                          tags$hr(style = "border-top: 3px solid #ccc;"),
                          plotlyOutput("plot2_ACP", height = "800px"),
                          tags$hr(style = "border-top: 3px solid #ccc;"),
                          tags$hr(style = "border-top: 3px solid #ccc;"),
                          plotlyOutput("plot3_ACP", height = "800px"),
                          tags$hr(style = "border-top: 3px solid #ccc;")
                        )
                      ),
                      tabPanel("Résumé", verbatimTextOutput("pca_summary"))
                    )
                  )
                )
              ),
              

              ############################# CAH ############################
              tabPanel(
                "CAH",
                sidebarLayout(
                  
                  # PANNNEAU GAUCHE - INFOS CAH
                  sidebarPanel(
                    h3("Paramètres de la CAH"),
                    sliderInput("nb_clust", "Nombre de groupes:",
                                min = 2, max = 10, value = 3
                    )
                  ),
                  mainPanel(
                    tabsetPanel(
                      tabPanel("Dendrogramme 3D", plotOutput("plot_hcpc_3d_clust", height = "800px")),
                      tabPanel("Dendrogramme 2D", plotOutput("facto.plot.hcpc.tree", height = "800px")),
                      tabPanel("Individus Cluster", plotOutput("plot_hcpc_ind_clust", height = "800px")),
                      tabPanel("Individus Symbologie", plotOutput("plot_hcpc_ind", height = "800px")),
                      tabPanel("Résumé", verbatimTextOutput("hcpc_results"))
                    )
                  )
                )
              ),
              
              ############################# AFC ############################
              tabPanel("AFC", 
                       titlePanel("Analyse Factorielle des Correspondances (AFC)"),
                       sidebarLayout(
                         sidebarPanel(
                           htmlOutput("afc_parameters")
            
                         ),
                         mainPanel(
                           tabsetPanel(
                             tabPanel("Graphique des variables - modalitées", plotOutput("afc_var_plot")),
                             tabPanel("Dimensions", plotlyOutput("afc_barplot")),
                             tabPanel("Résumé", verbatimTextOutput("afc_summary"))
                             
                           )
                         )
                       )
              )
            )
          ),
          
          # PANNNEAU DROIT - STATS GENERAL
          column(
            width = 3,
            tabBox(
              width = 10,
              tabPanel(
                "Général",
                h3("Analyse Factorielle"),
                h5("L'analyse factorielle est une méthode statistique qui vise à réduire la dimensionnalité des données en identifiant les relations sous-jacentes entre les variables observées. Elle permet de découvrir des structures cachées dans les données et de visualiser les similitudes et les différences entre les individus ou les variables."),
                h5("L'ACP (Analyse en Composantes Principales) est une technique couramment utilisée dans l'analyse factorielle pour transformer les variables originales en un ensemble de nouvelles variables, appelées composantes principales."),
                h5("Le Clustering Hiérarchique sur les Composantes Principales (HCPC) est une extension de l'ACP qui combine l'ACP avec une analyse de clustering hiérarchique pour identifier des groupes homogènes d'individus ou de variables dans les données projetées sur les composantes principales."),
                h5("L'Analyse Factorielle des Correspondances (AFC) est une méthode d'analyse multivariée utilisée pour explorer les relations entre les variables catégorielles."),
                valueBoxOutput("individual.count", width = "100%"),
                valueBoxOutput("raw.data.count", width = "100%"),
                valueBoxOutput("pca.data.count", width = "100%")
              )
            )
          )
        )
      )
    )
  )
}
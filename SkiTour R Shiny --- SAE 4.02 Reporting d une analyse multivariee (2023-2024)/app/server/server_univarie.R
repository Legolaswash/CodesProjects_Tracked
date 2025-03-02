
# Mettre à jour les choix du selectInput en fonction des colonnes du dataframe
observe({
  var_names <- colnames(donnees_univarie)
  var_types <- sapply(donnees_univarie, function(x) ifelse(is.numeric(x), " <123>", " <abc>"))
  choices <- paste0(var_names, var_types)
  updateSelectInput(session, "variable1", choices = choices)
})

# Observer pour mettre à jour le type de variable en fonction de la variable sélectionnée
get_variable_type <- function(variable) {
  if (is.factor(donnees_univarie[[variable]]) || is.character(donnees_univarie[[variable]])) {
    return("qualitative")
  } else {
    return("quantitative")
  }
}

strip_variable = function(variable){
  return(strsplit(variable, " ")[[1]][1])
}

# Observer pour afficher les statistiques élémentaires en fonction de la variable sélectionnée
output$summary_stats <- renderPrint({
  variable <- strip_variable(input$variable1)
  variable_type <- get_variable_type(variable)
  cat("\n")
  cat("Statistiques élémentaire de :", variable, "\n")
  cat("--------------------------------------------------\n")
  print(summary(donnees_univarie[[variable]]))
})

# Afficher le premier graphique en fonction de la première variable sélectionnée
output$plot1 <- renderPlotly({
  variable <- strip_variable(input$variable1)
  variable_type <- get_variable_type(variable)
  
  if (variable_type == "qualitative") {
    variable_values <- donnees_univarie[[variable]]
    variable_count <- table(variable_values)
    variable_df <- data.frame(names(variable_count), as.numeric(variable_count))
    names(variable_df) <- c("Category", "Count")
    variable_df <- variable_df[order(variable_df$Category), ]
    
    plot_ly(data = variable_df, x = ~Category, y = ~Count, type = "bar", marker = list(color = "#f3b77f")) %>%
      layout(
        title = paste("Répartition de", variable),
        xaxis = list(
          title = variable,
          categoryorder = "array",
          categoryarray = levels(variable_values)
        ),
        yaxis = list(title = "Count")
      ) %>%
      config(displayModeBar = FALSE)
  } else {
    variable_values <- donnees_univarie[[variable]]
    plot_ly(
      x = ~variable_values, type = "histogram", marker = list(color = "#85c2da"),
      name = paste("Distribution de", variable),
      xaxis = list(title = variable)
    ) %>%
      layout(
        title = paste("Distribution de", variable),
        xaxis = list(title = variable)
      ) %>%
      config(displayModeBar = FALSE)
  }
})

# Afficher le graphique radar pour la colonne "Orientation"
output$plot_radar <- renderPlotly({
  
  # Vérifier si la variable sélectionnée est "Orientation"
  if (strip_variable(input$variable1) == "Orientation") {
    
    orientation_counts <- table(donnees_univarie$Orientation)
    orientation_counts <- orientation_counts[-which(names(orientation_counts) == "T")]
    orientation_counts_df <- data.frame(Orientation = names(orientation_counts), Count = as.numeric(orientation_counts))
    orientation_counts_df <- orientation_counts_df[order(match(orientation_counts_df$Orientation, c("N", "NE", "E", "SE", "S", "SW", "W", "NW"))), ]
    orientations_radians <- seq(0, 2 * pi, length.out = length(orientation_counts_df$Orientation) + 1)
    orientations_radians <- orientations_radians[-length(orientations_radians)]
    label_angles <- seq(0, 2*pi, length.out = length(orientation_counts_df$Orientation) + 1) * 180 / pi
    
    # Tracer le graphique radar
    plot_ly(
      data = orientation_counts_df,
      type = "scatterpolar",
      r = ~c(Count, Count[1]),  # Ajouter la première valeur à la fin pour fermer le tracé
      theta = ~c(Orientation, Orientation[1]),  # Ajouter la première modalité à la fin pour fermer le tracé
      fill = "toself",
      mode = "lines+markers",
      marker = list(symbol = "circle", size = 10, line = list(color = "#4B0082", width = 2)),
      line = list(color = "#4B0082", width = 2)
    ) %>%
      layout(
        title = "Répartition des orientations",
        polar = list(
          radialaxis = list(visible = TRUE, range = c(0, max(orientation_counts_df$Count) + 5)),
          angularaxis = list(
            direction = "clockwise",
            rotation = 90
          )
        )
      ) %>%
      config(displayModeBar = FALSE)%>%
      layout(margin = list(t = 100))
  }
})


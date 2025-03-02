# Observer to execute actions when page1 tab is loaded
observeEvent(input$currentTab,
             {
               if (input$currentTab == "Map") {
                 # Perform actions specific to widgets_1 tab
                 shinyjs::runjs("$('#reset_button').click();")
               }
             },
             ignoreInit = TRUE
)


# TABLEAU FILTRE VIA LA CARTE

# Affichage du premier tableau (filtrage par la carte)
output$filtered_table_map <- DT::renderDataTable({
  # Affichage des données filtrées dans le tableau
  DT::datatable(filtered_data_from_map())
})

# Fonction pour filtrer les données en fonction du clic sur la carte
filtered_data_from_map <- reactive({
  if (!is.null(input$map_marker_click)) {
    event <- input$map_marker_click
    clicked_lat <- event$lat
    clicked_lng <- event$lng
    clicked_row <- which(data_map$Sommet.latitude == clicked_lat & data_map$Sommet.longitude == clicked_lng)
    return(data_map[clicked_row, ])
  } else {
    # Retourne une ligne vide si aucun point n'est sélectionné sur la carte
    return(data_map[0, ])
  }
})

# Affichage de la carte
output$map <- renderLeaflet({
  leaflet() %>%
    addTiles() %>%
    addCircleMarkers(
      data = filtered_data_from_map(),
      lng = ~Sommet.longitude,
      lat = ~Sommet.latitude,
      popup = ~Sommet.nom,
      color = ~ color_palette(Sommet.altitude),
      fillOpacity = 0.8,
      radius = 7
    ) %>%
    fitBounds(
      lng1 = min(data_map$Sommet.longitude),
      lat1 = min(data_map$Sommet.latitude),
      lng2 = max(data_map$Sommet.longitude),
      lat2 = max(data_map$Sommet.latitude)
    ) %>%
    addEasyButton(easyButton(
      icon = "fa-crosshairs", # icône de recentrage
      title = "Recentrer la carte", # Titre
      onClick = JS(
        "function(btn, map){map.setView([",
        mean(data_map$Sommet.latitude), ",",
        mean(data_map$Sommet.longitude), "], 10);}"
      )
    )) %>% # Fonction de recentrage
    addLegend(position = "bottomleft", 
              pal = color_palette_legende, 
              values = data_map$Sommet.altitude, 
              title = "Altitude (m)",
              labFormat = labelFormat(transform = function(x) sort(x, decreasing = TRUE)))
})

# Graphique des frequentations

# Fonction pour filtrer les données complètes en fonction du clic sur la carte
filtered_data_full <- reactive({
  if (!is.null(input$map_marker_click)) {
    event <- input$map_marker_click
    clicked_lat <- event$lat
    clicked_lng <- event$lng
    clicked_row <- which(data_map$Sommet.latitude == clicked_lat & data_map$Sommet.longitude == clicked_lng)
    return(donnees_skitour[clicked_row, ])
  } else {
    # Retourne une ligne vide si aucun point n'est sélectionné sur la carte
    return(NULL)
  }
})

# Affichage du graphique de fréquentation par année pour les données complètes
output$frequency_plot <- renderPlotly({
  req(filtered_data_full()) 
  plot_data <- filtered_data_full()

  
  # Vérifier si plot_data contient des données
  if (nrow(plot_data) == 0) {
    print("Aucune donnée trouvée.")
    return(NULL) # Quitte la fonction si aucune donnée n'est disponible
  }
  
  # Extraction des années
  years <- as.numeric(substring(names(plot_data)[26:47], 2))
  
  # Extraction des fréquentations par année pour l'individu sélectionné
  frequencies <- unlist(plot_data[, 26:47])
  
  # Création d'un dataframe pour les données du graphique
  freq_df <- data.frame(
    year = rep(years, each = nrow(plot_data)),
    frequency = frequencies
  )
  
  # Suppression des valeurs nulles
  freq_df <- freq_df[!is.na(freq_df$frequency), ]
  
  # Obtention du nom du point sélectionné
  selected_point_name <- plot_data$Sommet.nom
  plot_title <- paste("Fréquentation par année -", selected_point_name)
  
  plot_ly(freq_df,
          x = ~year, y = ~frequency, type = "scatter", mode = "lines+markers",
          marker = list(size = 10),
          line = list(color = "rgb(22, 96, 167)")
  ) %>%
    layout(
      title = plot_title,
      xaxis = list(title = "Année"),
      yaxis = list(title = "Fréquentation")
    ) %>%
    config(displayModeBar = FALSE) # Désactiver la barre de mode d'affichage
  
})

# TABLEAU FILTRE VIA LE TABLEAU

# Affichage du deuxième tableau (filtrage par le tableau principal)
output$table <- DT::renderDataTable({
  # Affichage des données filtrées dans le tableau
  DT::datatable(filtered_data_from_table())
})

# Fonction pour filtrer les données en fonction de la sélection dans le tableau
filtered_data_from_table <- reactive({
  if (!is.null(input$table_rows_selected)) {
    selected_rows <- input$table_rows_selected
    return(data_map[selected_rows, ])
  } else {
    # Retourne toutes les données si aucune ligne n'est sélectionnée dans le tableau
    return(data_map)
  }
})

# Mise en surbrillance temporaire du point correspondant lorsqu'une ligne est sélectionnée dans le tableau
observeEvent(input$table_rows_selected, {
  selected_row <- input$table_rows_selected
  if (!is.null(selected_row)) {
    selected_data <- data_map[selected_row, ]
    leafletProxy("map") %>%
      clearMarkers() %>%
      addCircleMarkers(
        data = selected_data,
        lng = ~Sommet.longitude,
        lat = ~Sommet.latitude,
        popup = ~Sommet.nom,
        color = "red",
        fillOpacity = 0.8,
        radius = 10
      )
  } else {
    leafletProxy("map") %>%
      clearMarkers() %>%
      addCircleMarkers(
        data = filtered_data_from_map(),
        lng = ~Sommet.longitude,
        lat = ~Sommet.latitude,
        popup = ~Sommet.nom,
        color = ~ color_palette(Sommet.altitude),
        fillOpacity = 0.8,
        radius = 7
      )
  }
})


# Réinitialisation du filtre 

observeEvent(input$reset_button, {
  leafletProxy("map") %>%
    clearMarkers() %>%
    clearShapes() %>%
    addCircleMarkers(
      data = data_map,
      lng = ~Sommet.longitude,
      lat = ~Sommet.latitude,
      popup = ~Sommet.nom,
      color = ~ color_palette(Sommet.altitude),
      fillOpacity = 0.8,
      radius = 7
    ) %>%
    fitBounds(
      lng1 = min(data_map$Sommet.longitude),
      lat1 = min(data_map$Sommet.latitude),
      lng2 = max(data_map$Sommet.longitude),
      lat2 = max(data_map$Sommet.latitude)
    )
  
  # Effacer le graphique de fréquentation par année
  plotlyProxy("frequency_plot") %>%
    plotly::plotlyProxyInvoke("relayout", list(title = "")) %>%
    plotly::plotlyProxyInvoke("restyle", list(x = list(NULL), y = list(NULL))) %>%
    plotly::plotlyProxyInvoke("addTraces", list(x = 0, y = 0, mode = "markers", marker = list(color = "rgba(0,0,0,0)")))
  
  
  output$table <- DT::renderDataTable({
    # Affichage des données complètes dans le tableau
    DT::datatable(data_map)
  })
})
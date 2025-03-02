
zoomToPoint <- function(point_name) {
  point_coords <- donnees_skitour[donnees_skitour$Sommet.nom == point_name, c("Sommet.longitude", "Sommet.latitude")]
  print(point_coords)
  print(class(point_coords$Sommet.longitude))
  
  
  if (nrow(point_coords) > 0) {
    leafletProxy("carte") %>%
      setView(lng = as.numeric(gsub(",", ".", point_coords$Sommet.longitude)), 
              lat = as.numeric(gsub(",", ".", point_coords$Sommet.latitude)), 
              zoom = 15)
  } else {
    showModal(modalDialog(
      title = "Erreur",
      paste("Le point", point_name, "n'a pas été trouvé.")
    ))
  }
}

Recover_Map <- function() {
  leafletProxy("carte") %>%
    setView(lng = 6.673, lat = 45.41, zoom = 9)
}

output$carte <- renderLeaflet({
  carte <- leaflet() %>%
    addTiles() %>%
    addPolygons(data = carte_vanoise) %>%
    addMarkers(data = points_sf, label = ~paste(Sommet.nom, " - ", Sommet.altitude, "mètres"))
  carte
})

observeEvent(input$point_bas, {
  point_name <- donnees_skitour[which.min(donnees_skitour$Sommet.altitude), "Sommet.nom"]
  zoomToPoint(point_name)
})

observeEvent(input$point_haut, {
  point_name <- donnees_skitour[which.max(donnees_skitour$Sommet.altitude), "Sommet.nom"]
  zoomToPoint(point_name)
})

observeEvent(input$point_haut, {
  point_name <- donnees_skitour[which.max(donnees_skitour$Sommet.altitude), "Sommet.nom"]
  zoomToPoint(point_name)
})

observeEvent(input$denivelé_min, {
  point_name <- donnees_skitour[which.min(donnees_skitour$Deniv.plus), "Sommet.nom"]
  zoomToPoint(point_name)
})

observeEvent(input$denivelé_max, {
  point_name <- donnees_skitour[which.max(donnees_skitour$Deniv.plus), "Sommet.nom"]
  print(point_name)
  zoomToPoint(point_name)
})

observeEvent(input$reset_carte, {
  paste("Bouton de réinitialisation cliqué !")
  Recover_Map()
})

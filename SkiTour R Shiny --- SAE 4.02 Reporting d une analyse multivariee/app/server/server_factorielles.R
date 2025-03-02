
# Récupère le nom des variables
quant_vars <- names(donnees_factorielles)[sapply(donnees_factorielles, is.numeric)]
quali_vars <- names(donnees_factorielles)[sapply(donnees_factorielles, is.factor)]

# ---------------------------- STATISTIQUE GENERALES
output$individual.count <- renderUI({
  div(
    class = "value-box",
    style = "background-color: lightblue;",
    icon("users", class = "value-box-icon"),
    div(nrow(donnees_factorielles), class = "value-box-value"),
    div("Nombre d'individus", class = "value-box-description")
  )
})

output$raw.data.count <- renderUI({
  div(
    class = "value-box",
    style = "background-color: orange;",
    icon("table", class = "value-box-icon"),
    div(ncol(donnees_factorielles), class = "value-box-value"),
    div("Nombre de variables brutes", class = "value-box-description")
  )
})

output$pca.data.count <- renderUI({
  div(
    class = "value-box",
    style = "background-color: black;",
    icon("area-chart", class = "value-box-icon"),
    div(length(row.names(pca_result()$quanti.sup$coord)), class = "value-box-value"),
    div("Nombre de variables utilisées pour l'ACP", class = "value-box-description")
  )
})


# ---------------------------------------------------------------------------
# ----------------------------------- ACP -----------------------------------
# ---------------------------------------------------------------------------

# ---------------------------- DESCRIPTION DES AXES
output$table.pca.interpret.dim1 <- renderDataTable({
  dat <- data.frame(correlation = pca_result()$var$cor[, "Dim.1"], p_value = pca_result()$var$cos2[, "Dim.1"])
  dat[, 1] <- round(dat[, 1], digits = 3)
  dat[, 2] <- format.pval(dat[, 2])
  datatable(dat)
})

output$table.pca.interpret.dim2 <- renderDataTable({
  dat <- data.frame(correlation = pca_result()$var$cor[, "Dim.2"], p_value = pca_result()$var$cos2[, "Dim.2"])
  dat[, 1] <- round(dat[, 1], digits = 3)
  dat[, 2] <- format.pval(dat[, 2])
  datatable(dat)
})

output$table.pca.interpret.dim3 <- renderDataTable({
  dat <- data.frame(correlation = pca_result()$var$cor[, "Dim.3"], p_value = pca_result()$var$cos2[, "Dim.3"])
  dat[, 1] <- round(dat[, 1], digits = 3)
  dat[, 2] <- format.pval(dat[, 2])
  datatable(dat)
})

# ---------------------------- CUSTOM COULEURS
custom_cols <- reactive({
  # Définir les couleurs personnalisées
  custom_palette <- palette("Set1")
  # Convertir les clusters en facteurs pour utiliser la palette de couleurs
  cluster_factor <- as.factor(cah_result()$data.clust$clust)
  
  # Créer une palette de couleurs avec la fonction colorFactor()
  color_palette <- custom_palette[cluster_factor]
  return(color_palette)
})

# ---------------------------- PLOT - ACP - 3D DATA
output$data.plot.3d <- renderPlotly({
  req(pca_result())
  # Créer un tracé 3D avec plot_ly
  plotly3d.facto.plot <- plot_ly(
    data = as.data.frame(pca_result()$ind$coord), # Utiliser les coordonnées des individus
    x = ~Dim.1,
    y = ~Dim.2,
    z = ~Dim.3,
    type = "scatter3d", # Type de tracé 3D
    mode = "markers", # Mode de tracé
    marker = list(size = 5, color = custom_cols()), # Couleur des points en fonction des clusters dans la CAH
    text = row.names(pca_result()$ind$coord) # Les noms des points à afficher dans la fenêtre d'info
  ) %>%
    layout(
      title = "PCA (individuals coordinates)", # Titre du tracé
      scene = list(
        xaxis = list(title = "1st PC"), # Titre de l'axe X
        yaxis = list(title = "2nd PC"), # Titre de l'axe Y
        zaxis = list(title = "3rd PC") # Titre de l'axe Z
      )
    )
  plotly3d.facto.plot
})

# ---------------------------- PARAMETRES ACP
output$pca_parameters <- renderUI({
  HTML(
    paste("- Nombre de composantes \n principales (ncp) :", pca_result()$call$ncp, "<br>",
          "- Proportion de la variance expliquée \n par le 1er plan :", round(pca_result()$eig[, 3][2], 2), "%", "<br>",
          "- Nombre de Variables Actives :", length(row.names(pca_result()$var$coord)), "<br>",
          "- Nombre de Variables Illustratives :", length(row.names(pca_result()$quanti.sup$coord)), "<br>")
  )
})

# -------------- SELECTEURS
# Quanti 
observe({
  updateSelectInput(session, "illustrative_vars_quant", choices = quant_vars, selected = quant_vars[c(4:length(quant_vars))])
})

# Quali
observe({
  updateSelectInput(session, "illustrative_vars_quali", choices = quali_vars, selected = quali_vars)
})

# -------------- ACP --------------
pca_data <- reactive({
  donnees_factorielles
})
pca_result <- reactive({
  res <- PCA(pca_data(),
             scale.unit = TRUE, graph = FALSE,
             quanti.sup = input$illustrative_vars_quant, quali.sup = input$illustrative_vars_quali
  )
  res
})

# ----------------------------GRAPHIQUE - ACP - INDIVIDUS (purple)
output$plot_acp_ind <- renderPlot({
  plot.PCA(pca_result(),
           axes = c(1, 2), choix = "ind", habillage = "none",
           col.ind = "purple", col.ind.sup = "blue", col.quali = "magenta",
           label = c("ind", "ind.sup", "quali"), new.plot = TRUE, autoLab = "yes",
           invisible = c("quali")
  )
})

# ---------------------------- GRAPHIQUE - ACP - VAR (cercle des corrélations)
output$plot_acp_var1 <- renderPlot({
  plot.PCA(pca_result(),
           axes = c(1, 2), choix = "var", new.plot = TRUE,
           col.var = "black", col.quanti.sup = "blue", label = c("var", "quanti.sup"),
           lim.cos2.var = 0, autoLab = "yes"
  )
})

output$plot_acp_var2 <- renderPlot({
  plot.PCA(pca_result(),
           axes = c(2, 3), choix = "var", new.plot = TRUE,
           col.var = "black", col.quanti.sup = "blue", label = c("var", "quanti.sup"),
           lim.cos2.var = 0, autoLab = "yes"
  )
})

# ---------------------------- GRAPHIQUE - ACP - Variance expliqué DIM
output$facto.vars_dim <- renderPlot({
  fviz_screeplot(pca_result(), addlabels = TRUE, ylim = c(0, 50))
})

 
output$facto.contr.var1 <- renderPlotly({
  pca_result <- pca_result()  # Obtenir le résultat de l'ACP

  # Créer un dataframe des contributions individuelles
  contrib_df <- data.frame(
    Individus = rownames(pca_result$var$contrib),
    Contribution = pca_result$var$contrib[, 1]
  )

  # Trier les contributions par ordre décroissant
  contrib_df <- contrib_df[order(contrib_df$Contribution, decreasing = TRUE), ]

  # Calculer la moyenne des contributions
  mean_contrib <- mean(contrib_df$Contribution)

  # Plotly plot
  plot_ly(data = contrib_df, x = ~Individus, y = ~Contribution, type = "bar") %>%
    add_trace(y = ~rep(mean_contrib, nrow(contrib_df)), type = "scatter", mode = "lines", line = list(color = "red"), name = "Moyenne") %>%
    layout(
      title = "Barplot des Contributions des Variables à l'ACP (Axe 1)",
      xaxis = list(title = "Variables", categoryorder = "array", categoryarray = ~Individus),
      yaxis = list(title = "Contribution à l'Axe 1")
    ) %>%
    config(displayModeBar = FALSE)
})

output$facto.contr.var2 <- renderPlotly({
  pca_result <- pca_result()  # Obtenir le résultat de l'ACP
  
  # Créer un dataframe des contributions individuelles
  contrib_df <- data.frame(
    Individus = rownames(pca_result$var$contrib),
    Contribution = pca_result$var$contrib[, 2]
  )
  
  # Trier les contributions par ordre décroissant
  contrib_df <- contrib_df[order(contrib_df$Contribution, decreasing = TRUE), ]
  
  # Calculer la moyenne des contributions
  mean_contrib <- mean(contrib_df$Contribution)
  
  # Plotly plot
  plot_ly(data = contrib_df, x = ~Individus, y = ~Contribution, type = "bar") %>%
    add_trace(y = ~rep(mean_contrib, nrow(contrib_df)), type = "scatter", mode = "lines", line = list(color = "red"), name = "Moyenne") %>%
    layout(
      title = "Barplot des Contributions des Variables à l'ACP (Axe 2)",
      xaxis = list(title = "Variables", categoryorder = "array", categoryarray = ~Individus),
      yaxis = list(title = "Contribution à l'Axe 1")
    ) %>%
    config(displayModeBar = FALSE)
})

# ---------------------------- GRAPHIQUE - ACP - CONTRIB INDIVIDUS

output$facto.contr.ind1 <- renderPlotly({
  pca_result <- pca_result()  # Obtenir le résultat de l'ACP
  # Créer un dataframe des contributions individuelles
  contrib_df <- data.frame(
    Individus = rownames(pca_result$ind$contrib),
    Contribution = pca_result$ind$contrib[, 1]
  )
  # Trier les contributions par ordre décroissant
  contrib_df <- contrib_df[order(contrib_df$Contribution, decreasing = TRUE), ]
  # Calculer la moyenne des contributions
  mean_contrib <- mean(contrib_df$Contribution)
  # Plotly plot
  plot_ly(data = contrib_df, x = ~Individus, y = ~Contribution, type = "bar") %>%
    add_trace(y = ~rep(mean_contrib, nrow(contrib_df)), type = "scatter", mode = "lines", line = list(color = "red"), name = "Moyenne") %>%
    layout(
      title = "Barplot des Contributions Individuelles à l'ACP (Axe 1)",
      xaxis = list(title = "Variables", categoryorder = "array", categoryarray = ~Individus),
      yaxis = list(title = "Contribution à l'Axe 1")
    ) %>%
    config(displayModeBar = FALSE)
})

output$facto.contr.ind2 <- renderPlotly({
  pca_result <- pca_result()  # Obtenir le résultat de l'ACP
  # Créer un dataframe des contributions individuelles
  contrib_df <- data.frame(
    Individus = rownames(pca_result$ind$contrib),
    Contribution = pca_result$ind$contrib[, 2]
  )
  # Trier les contributions par ordre décroissant
  contrib_df <- contrib_df[order(contrib_df$Contribution, decreasing = TRUE), ]
  # Calculer la moyenne des contributions
  mean_contrib <- mean(contrib_df$Contribution)
  # Plotly plot
  plot_ly(data = contrib_df, x = ~Individus, y = ~Contribution, type = "bar") %>%
    add_trace(y = ~rep(mean_contrib, nrow(contrib_df)), type = "scatter", mode = "lines", line = list(color = "red"), name = "Moyenne") %>%
    layout(
      title = "Barplot des Contributions Individuelles à l'ACP (Axe 2)",
      xaxis = list(title = "Variables", categoryorder = "array", categoryarray = ~Individus),
      yaxis = list(title = "Contribution à l'Axe 2")
    ) %>%
    config(displayModeBar = FALSE)
})

# ---------------------------- GRAPHIQUE - ACP - 2D DIMS
output$plot1_ACP <- renderPlotly({
  req(pca_result())
  req(cah_result())
  plot_ly(
    data = as.data.frame(pca_result()$ind$coord),
    x = ~Dim.1,
    y = ~Dim.2,
    type = "scatter",
    mode = "markers",
    marker = list(size = 8, color = custom_cols()),
    text = row.names(pca_result()$ind$coord),
    hoverinfo = "text",
    showlegend = FALSE
  ) %>% layout(title = "PCA: PC1 vs PC2")
})

output$plot2_ACP <- renderPlotly({
  req(pca_result())
  req(cah_result())
  plot_ly(
    data = as.data.frame(pca_result()$ind$coord),
    x = ~Dim.1,
    y = ~Dim.3,
    type = "scatter",
    mode = "markers",
    marker = list(size = 8, color = custom_cols()),
    text = row.names(pca_result()$ind$coord),
    hoverinfo = "text",
    showlegend = FALSE
  ) %>% layout(title = "PCA: PC1 vs PC3")
})

output$plot3_ACP <- renderPlotly({
  req(pca_result())
  req(cah_result())
  plot_ly(
    data = as.data.frame(pca_result()$ind$coord),
    x = ~Dim.2,
    y = ~Dim.3,
    type = "scatter",
    mode = "markers",
    marker = list(size = 8, color = custom_cols()),
    text = row.names(pca_result()$ind$coord),
    hoverinfo = "text",
    showlegend = FALSE
  ) %>% layout(title = "PCA: PC2 vs PC3")
})

# ---------------------------- GRAPHIQUE - ACP - RESUME ACP
# Print PCA summary
output$pca_summary <- renderPrint({
  summary(pca_result(), nb.dec = 3, nbelements = 10, nbind = 10, file = "")
})

# ---------------------------- GRAPHIQUE - ACP - MATRIX CONTRIB INDS
# Remplacez la sortie pour corrplot.var
output$corrplot.var <- renderPlot({
  req(pca_result())
  
  # Sélectionnez les contributions pour toutes les dimensions
  contri <- pca_result()$ind$contrib[, 1:3] # pour les trois premières dimensions
  
  # Contribution moyenne de chaque individu sur toutes les dimensions
  contri_mean <- rowMeans(contri)
  
  # Trier les individus par leur contribution moyenne
  top_contributors <- order(contri_mean, decreasing = TRUE)
  
  # Selection 20 meilleurs contributeurs
  top_individuals <- top_contributors[1:20]
  contri_df <- as.data.frame(contri[top_individuals, ])
  
  ggcorrplot(t(contri_df),
             method = "circle", colors = rev(c("orangered", "steelblue", "grey")),
             legend.title = "contribution"
  ) +
    labs(title = "Contribution plot of individuals", y = "", x = "")
})


# ---------------------------------------------------------------------------
# ----------------------------------- CAH -----------------------------------
# ---------------------------------------------------------------------------

cah_result <- reactive({
  # Exclure les variables "Id" et "Sommet.id" de l'ACP
  variables_a_exclure <- c("Id", "Sommet.id", "Depart.id")
  
  # Sélectionner seulement les variables qui ne sont pas dans la liste à exclure
  pca_data_filtered <- pca_data()[ , !names(pca_data()) %in% variables_a_exclure]
  
  # Exécuter l'ACP
  pca_result <- PCA(pca_data_filtered,
                    scale.unit = TRUE,
                    graph = FALSE,
                    quanti.sup = input$illustrative_vars_quant,
                    quali.sup = input$illustrative_vars_quali)
  
  # Exécuter la CAH sur les résultats de l'ACP
  HCPC(pca_result, metric = "euclidean", method = "ward", graph = FALSE, 
       nb.clust = input$nb_clust, consol = TRUE)
})

# ---------------------------- GRAPHIQUE - CAH - DENDROGRAMME 3D
# Plot HCPC
output$plot_hcpc_3d_clust <- renderPlot({
  plot.HCPC(cah_result(), choice = "3D.map")
})

# ---------------------------- GRAPHIQUE - CAH - PLOT INDIVIDUS CLUSTERS (symbologie)
output$plot_hcpc_ind <- renderPlot({
  plot(cah_result(), choice = "map", draw.tree = F, autoLab = "yes")
})

# ---------------------------- GRAPHIQUE - CAH - DENDROGRAMME 2D
# Render HCPC tree plot
output$facto.plot.hcpc.tree <- renderPlot({
  plot.HCPC(cah_result(), choice = "tree")
})

# ---------------------------- GRAPHIQUE - CAH - PLOT INDIVIDUS CLUSTERS (formes)
output$plot_hcpc_ind_clust <- renderPlot({
  fviz_cluster(cah_result(),
               repel = TRUE, 
               show.clust.cent = TRUE, 
               palette = "Set1", 
               ggtheme = theme_minimal(),
               main = "Factor map"
  )
})

# ---------------------------- GRAPHIQUE - CAH - RESUME CAH
# Display HCPC results
output$hcpc_results <- renderPrint({
  cat("#########################################\nDescription des variables:\n")
  print(cah_result()$desc.var)
  cat("#########################################\nDescription des axes:\n")
  print(cah_result()$desc.axes)
  cat("#########################################\nDescription des individus:\n")
  print(cah_result()$desc.ind)
  cat("#########################################\nCall:\n")
  print(cah_result()$call)
})


# ---------------------------------------------------------------------------
# ----------------------------------- AFC -----------------------------------
# ---------------------------------------------------------------------------

afc_data <- reactive({
  # Création du tableau de contingence pour l'AFC
  TC_1 <- table(donnees_factorielles$Ski, donnees_factorielles$Alpi)
  TC_2 <- table(donnees_factorielles$Ski, donnees_factorielles$Orientation)
  TC_AFC <- as.data.frame.array(t(cbind(TC_1, TC_2)))
  return(TC_AFC)  
})

# Réalisation de l'AFC
afc_result <- reactive({
  req(afc_data())
  res_AFC <- CA(afc_data(), row.sup = c(10:length(row.names(afc_data()))), col.sup = NULL, graph = FALSE)
  return(res_AFC)  # Retourner les résultats de l'analyse AFC
})

# ---------------------------- PARAMETRES AFC
output$afc_parameters <- renderUI({
  HTML(
    paste("Les variables de l'AFC sont : Ski et Alpi.", 
          "2 manieres  d'evaluer la difficultés d'une randonnées.", 
          "A la monté (Alpi) et à la descente (Ski).", 
          sep="<br>")
  )
})

# Barplot dimension
output$afc_barplot <- renderPlotly({
  req(afc_result())
  plot_ly(x = rownames(afc_result()$eig), y = afc_result()$eig[, 2], type = "bar") %>%
    layout(title = "Barplot des Dimensions", xaxis = list(title = "Dimensions"), yaxis = list(title = "Valeurs Propres"))
})

# Résumé
output$afc_summary <- renderPrint({
  summary(afc_result())
})

# Graphique variables
output$afc_var_plot <- renderPlot({
  req(afc_result())
  plot(afc_result(), axes = c(1, 2), col.var = "cos2", label = c("row", "row.sup"), cex = 1.2, pch = 16)
})


# Render les menus déroulants pour le choix des variables
output$premiere_variable <- renderUI({
  var_names <- colnames(donnees_skitour)
  var_types <- sapply(donnees_skitour, function(x) ifelse(is.numeric(x), " <123>", " <abc>"))
  choices <- paste0(var_names, var_types)
  selectInput(inputId = "sel_premiere_variable", label = "Première variable :", choices = choices, selected = choices[3])
})

output$deuxieme_variable <- renderUI({
  var_names <- colnames(donnees_skitour)
  var_types <- sapply(donnees_skitour, function(x) ifelse(is.numeric(x), " <123>", " <abc>"))
  choices <- paste0(var_names, var_types)
  selectInput(inputId = "sel_deuxieme_variable", label = "Deuxième variable :", choices = choices, selected = choices[5])
})


# Swap les variables
observeEvent(input$switch_variables, {
  temp <- input$sel_premiere_variable
  updateSelectInput(session, "sel_premiere_variable", selected = input$sel_deuxieme_variable)
  updateSelectInput(session, "sel_deuxieme_variable", selected = temp)
})


# Logique serveur pour générer les options de croisements de variables
output$croisement_variables <- renderUI({
  choices <- c("Alpi/Ski", "Alpi/Freq.total", "Ski/Freq.total", "Deniv.plus/Sommet.altitude")
  selectInput(inputId = "sel_croisement_variables", label = "Croisement de variables :", choices = choices, selected = choices[1])
})


# Observer pour détecter les changements dans l'input de croisement de variables
observeEvent(input$sel_croisement_variables, {
  
  # Récupérer le choix de croisement
  croisement <- input$sel_croisement_variables
  var1 = strsplit(croisement, "/")[[1]][1]
  var2 = strsplit(croisement, "/")[[1]][2]
  var1_type = ifelse(is.numeric(donnees_skitour[[var1]]), " <123>", " <abc>")
  var2_type = ifelse(is.numeric(donnees_skitour[[var2]]), " <123>", " <abc>")
  var1t = paste0(var1, var1_type)
  var2t = paste0(var2, var2_type)
  
  # Mettre à jour les valeurs des inputs
  updateSelectInput(session, "sel_premiere_variable", selected = var1t)
  updateSelectInput(session, "sel_deuxieme_variable", selected = var2t)
})


# GRAPHIQUE
output$plot <- renderPlotly({
  req(input$sel_premiere_variable)
  req(input$sel_deuxieme_variable)
  
  premiere_variable <- strsplit(input$sel_premiere_variable, " ")[[1]][1]
  deuxieme_variable <- strsplit(input$sel_deuxieme_variable, " ")[[1]][1]
  
  # PARTIE QUALI x QUANTI
  if ((is.numeric(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]])) || 
      (is.factor(donnees_skitour[[premiere_variable]]) && is.numeric(donnees_skitour[[deuxieme_variable]]))) {
    
    # Détermine quelle variable est quantitative et qualitative
    if (is.numeric(donnees_skitour[[premiere_variable]])) {
      marker_variable <- premiere_variable
    } else {
      marker_variable <- deuxieme_variable
    }
    
    # Utilisation de plotly pour un diagramme en barres groupé
    p <- plot_ly(donnees_skitour, x = ~get(premiere_variable), y = ~get(deuxieme_variable), type = 'bar', marker = list(color = ~get(marker_variable)))
    p <- p %>% layout(xaxis = list(title = premiere_variable), yaxis = list(title = deuxieme_variable)) %>% config(displayModeBar = FALSE)
    p
    
    # PARTIE QUANTI X QUANTI
  } else if ((is.numeric(donnees_skitour[[premiere_variable]]) && is.numeric(donnees_skitour[[deuxieme_variable]])) || 
             (is.numeric(donnees_skitour[[deuxieme_variable]]) && is.numeric(donnees_skitour[[premiere_variable]]))) {
    
    p <- plot_ly(donnees_skitour, x = ~get(premiere_variable), y = ~get(deuxieme_variable), type = 'scatter', mode = 'markers')
    mean_x <- mean(donnees_skitour[[premiere_variable]])
    mean_y <- mean(donnees_skitour[[deuxieme_variable]])
    p <- p %>% add_trace(x = c(min(donnees_skitour[[premiere_variable]]), max(donnees_skitour[[premiere_variable]])), y = c(mean_y, mean_y), mode = 'lines', name = paste("Moyenne de", premiere_variable))
    p <- p %>% add_trace(x = c(mean_x, mean_x), y = c(min(donnees_skitour[[deuxieme_variable]]), max(donnees_skitour[[deuxieme_variable]])), mode = 'lines', name = paste("Moyenne de", deuxieme_variable))
    barycenter_x <- mean_x
    barycenter_y <- mean_y
    p <- p %>% add_trace(x = barycenter_x, y = barycenter_y, mode = 'markers', marker = list(size = 10, color = 'red'), name = 'Barycentre')
    p <- p %>% layout(xaxis = list(title = premiere_variable), yaxis = list(title = deuxieme_variable)) %>% config(displayModeBar = FALSE)
    p
    
    # PARTIE QUALI X QUALI
  } else if (is.factor(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]])) {
    
    contingency_table <- table(donnees_skitour[[deuxieme_variable]], donnees_skitour[[premiere_variable]])
    df_contingency <- as.data.frame.matrix(contingency_table)
    df_contingency <- df_contingency / rowSums(df_contingency) * 100
    p1 <- plot_ly(df_contingency, x = ~rownames(df_contingency))
    
    for (i in 1:ncol(df_contingency)) {
      p1 <- p1 %>% add_trace(y = df_contingency[, i], name = colnames(df_contingency)[i])
    }
    
    p1 <- p1 %>% layout(barmode = 'stack', xaxis = list(title = deuxieme_variable), yaxis = list(title = 'Percentage', range = c(0, 100))) %>% config(displayModeBar = FALSE)
    
    # PARTIE AUTRES
  } else {
    p <- plot_ly() %>% layout(title = "Combinaison non supportée")
    p
  }
})

# SUMMARY
output$summary <- renderPrint({
  req(input$sel_premiere_variable)
  req(input$sel_deuxieme_variable)
  
  premiere_variable <- strsplit(input$sel_premiere_variable, " ")[[1]][1]
  deuxieme_variable <- strsplit(input$sel_deuxieme_variable, " ")[[1]][1]
  
  # PARTIE QUANTI X QUALI
  if (is.numeric(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]]) || 
     (is.numeric(donnees_skitour[[deuxieme_variable]]) && is.factor(donnees_skitour[[premiere_variable]])))  {
    
    if (is.numeric(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]])){
      var1<-donnees_skitour[[deuxieme_variable]] # var quali
      var2<-donnees_skitour[[premiere_variable]] # var quanti
    } else {
      var1<-donnees_skitour[[premiere_variable]] # var quali
      var2<-donnees_skitour[[deuxieme_variable]] # var quanti
    }
    
    anova<-aov( var2 ~ var1 )
    VAR.intra <- var(residuals(anova))
    VAR.inter <- var(predict(anova)) 
    rapport.corrélation<-VAR.inter/(VAR.intra + VAR.inter)
    variance <- var(var2)
    
    cat("Variance totale :", variance, "\n")
    cat("Variance Intra-groupe :", VAR.intra, "\n")
    cat("Variance Inter-groupe :", VAR.inter, "\n")
    cat("Coefficient de corrélation entre", premiere_variable, "and", deuxieme_variable, ":", rapport.corrélation,"\n")
    
    
    # PARTIE QUALI X QUALI
  } else if (is.factor(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]])) {
    
    # Calcul des statistiques
    contingency_table <- table(donnees_skitour[[premiere_variable]], donnees_skitour[[deuxieme_variable]])
    n = sum(contingency_table)
    chi2_test <- chisq.test(contingency_table)
    chi2_statistic <- chi2_test$statistic
    dl <- chi2_test$parameter
    phi2 <- chi2_statistic / n
    cramer_v <- sqrt(phi2 / (min(dim(contingency_table))-1))
    
    # Affichage des résultats
    cat("Statistique du Khi2:", chi2_statistic, "\n")
    cat("Nombre de degrés de liberté:", dl, "\n")
    cat("Phi2:", phi2, "\n")
    cat("V2 de Cramer:", cramer_v, "\n")
    
    
    # PARTIE QUANTI X QUANTI
  } else if ((is.numeric(donnees_skitour[[premiere_variable]]) && is.numeric(donnees_skitour[[deuxieme_variable]])) || 
             (is.numeric(donnees_skitour[[deuxieme_variable]]) && is.numeric(donnees_skitour[[premiere_variable]]))) {
    
    # Calcul des statistiques
    mean_x <- mean(donnees_skitour[[premiere_variable]])
    mean_y <- mean(donnees_skitour[[deuxieme_variable]])
    covariance <- cov(donnees_skitour[[premiere_variable]], donnees_skitour[[deuxieme_variable]])
    sd_x <- sd(donnees_skitour[[premiere_variable]])
    sd_y <- sd(donnees_skitour[[deuxieme_variable]])
    correlation <- cor(donnees_skitour[[premiere_variable]], donnees_skitour[[deuxieme_variable]])
    
    # Affichage des résultats
    cat("Moyenne de", premiere_variable, ": ", mean_x, "\n")
    cat("Moyenne de", deuxieme_variable, ": ", mean_y, "\n")
    cat("Covariance:", covariance, "\n")
    cat("Standard deviation de", premiere_variable, ": ", sd_x, "\n")
    cat("Standard deviation de", deuxieme_variable, ": ", sd_y, "\n")
    cat("Coefficient de corrélation de Pearson entre", premiere_variable, "et", deuxieme_variable, ": ", correlation, "\n")
    
    # PARTIE AUTRE
  } else {
    
    cat("Pas de résumé pour cette combinaison de variable.")
    
  }
})


# TABLE
output$table_I <- renderTable({
  req(input$sel_premiere_variable)
  req(input$sel_deuxieme_variable)
  
  premiere_variable <- strsplit(input$sel_premiere_variable, " ")[[1]][1]
  deuxieme_variable <- strsplit(input$sel_deuxieme_variable, " ")[[1]][1]
  
  # PARTIE QUANTI X QUALI
  if (is.numeric(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]]) || 
      (is.numeric(donnees_skitour[[deuxieme_variable]]) && is.factor(donnees_skitour[[premiere_variable]])))  {
    
    if (is.numeric(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]])){
      var1<-donnees_skitour[[deuxieme_variable]] # var quali
      var2<-donnees_skitour[[premiere_variable]] # var quanti
    } else {
      var1<-donnees_skitour[[premiere_variable]] # var quali
      var2<-donnees_skitour[[deuxieme_variable]] # var quanti
    }
    
    eff<-tapply(X=var2, INDEX=var1, FUN="length")
    moy <- tapply(X=var2, INDEX=var1, FUN="mean")
    med<-tapply(X=var2, INDEX=var1, FUN="median")
    variance<-tapply(X=var2, INDEX=var1, FUN="var")
    
    STAT<-data.frame(list(effectif= eff , moyenne=moy , mediane= med, variance=variance ))
    
    # Ajout de la ligne "Total général"
    total <- c(sum(STAT$effectif), round(mean(var2), 2), round(median(var2), 2), round(var(var2), 9))
    table_stat <- rbind(STAT, total)
    rownames(table_stat)[nrow(table_stat)] <- "Total général"
    
    table_stat
    
    
    # PARTIE QUALI X QUALI
  } else if (is.factor(donnees_skitour[[premiere_variable]]) && is.factor(donnees_skitour[[deuxieme_variable]])) {
    
    # Création d'un tableau de contingence
    contingency_table <- as.data.frame.array(table(donnees_skitour[[premiere_variable]], donnees_skitour[[deuxieme_variable]]))
    contingency_table
    
    
    # PARTIE AUTRE 
  } else {
    no_result = data.frame(Resultat="Pas de table pour cette combinaison.")
    no_result
  }
}, rownames=TRUE)


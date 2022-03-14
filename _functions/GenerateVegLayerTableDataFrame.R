generateVegLayerTableDataFrame <- function(Tree_layer_constantcy, Tree_layer_mean_cover, Tree_layer_taxon.all_data, layer_name) {
  
  constantcy <- data.frame(unlist(Tree_layer_constantcy))
  cover <- data.frame(unlist(Tree_layer_mean_cover))
  
  tree_table <- merge(constantcy,cover, by=0, all=TRUE)
  names(tree_table) <- c("species", "constantcy", "meanCover")
  
  extra_data <- Tree_layer_taxon.all_data[Tree_layer_taxon.all_data$Code %in% tree_table$species][,c("Code", "ScientificName", "EnglishName")]
  
  df <- merge(x=tree_table, y=extra_data, by.x="species", by.y="Code") %>% filter(constantcy > 1/100)
  df$Layer <- c("")
  df <- df[, c("Layer", "ScientificName", "constantcy", "meanCover", "EnglishName")]
  df[1, "Layer"] <- str_replace(layer_name, "_", " ")
  df$meanCover <- round(df$meanCover, digit=2)
  df$constantcy <- percent(df$constantcy)

  reports_dir <- "veg_reports"
  if (!dir.exists(reports_dir)) dir.create(reports_dir, recursive = TRUE)
  
  write.csv(df, file.path(reports_dir, layer_name))
  
  return(df)
}

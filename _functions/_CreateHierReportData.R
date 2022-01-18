createHierReportData <- function(level_name, level_value, SUTab) {
  
  
  # Select relevent rows from Heir.data
  level_rows <- Hier.data %>% filter(!!as.name(level) == level_value )
  
  # Levels
  site_units <- unique(level_rows$SiteUnit)
  classes <- unique(level_rows$Class)
  orders <- unique(level_rows$Order)
  sub_orders <- unique(level_rows$Suborder)
  alliances <- unique(level_rows$Alliance)
  associations <- unique(level_rows$Assoc)
  
  heir_summary <- list(site_units, classes, orders, sub_orders, alliances, associations)
  
  
  # Categorical Variables
  heir_summary[["species_frequency_count"]] <- list(table(level_rows$Species))
  
  # Variables
  mean_cover <- level_rows$MeanCov
  constancy <- level_rows$Constancy
  number_of_plots <- level_rows$nPlots
  
  # Aggregated Variables
  heir_summary[["average_mean_cover"]] <- mean(mean_cover)
  heir_summary[["average_constancy"]] <- mean(constancy)
  heir_summary[["total_number_of_plots"]] <- sum(number_of_plots)
  
  
  # Maybe return plot_numbers_in_level (or write it) and do below in a different step
  
  # Look up plots
  heir_summary[[paste("plot_numbers_in_", level_name, sep="")]] <- list(SUTab$PlotNumber[SUTab$SiteUnit %in% site_units]) 
  saveRDS(heir_summary, file=paste("./reports/", level_name, "/", str_replace_all(level_value, " ", "_"), ".RDS", sep = ""))
  
  # Save heir report
  #list.save(heir_summary, cat("./reports/", level_name, "/", str_replace_all(level_value, " ", "_"), ".rdata", sep = ""))
  
}
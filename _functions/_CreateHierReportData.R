createHierReportData <- function(level_name, level_value, SUTab, Hier.data) {
  
  
  # Select relevent rows from Heir.data
  level_rows <- Hier.data %>% filter(!!as.name(level_name) == level_value )
  
  # Levels
  site_units <- unique(level_rows$SiteUnit)
  classes <- unique(level_rows$Class)
  orders <- unique(level_rows$Order)
  sub_orders <- unique(level_rows$Suborder)
  alliances <- unique(level_rows$Alliance)
  associations <- unique(level_rows$Assoc)
  
  heir_summary <- list()
  heir_summary[["SiteUnits"]] <- site_units
  heir_summary[["Classes"]] <- classes
  heir_summary[["Orders"]] <- orders
  heir_summary[["SubOrder"]] <- sub_orders
  heir_summary[["Alliances"]] <- alliances
  heir_summary[["Associations"]] <- associations
  
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
  
  plot_numbers_and_site_units_in_level <- SUTab[SUTab$SiteUnit %in% site_units]
  
  print(plot_numbers_and_site_units_in_level)

  plot_numbers_and_site_units_in_level_file_path <- paste("plot_numbers_in_" , str_replace_all(level_value, " ", "_"), ".RDS", sep="")
  heir_summary_file_path <- paste("heir_summary_" , str_replace_all(level_value, " ", "_"), ".RDS", sep="")
  
  saveRDS(plot_numbers_and_site_units_in_level, file=plot_numbers_and_site_units_in_level_file_path) 
  saveRDS(heir_summary, file=heir_summary_file_path)
  
  return(c(plot_numbers_and_site_units_in_level_file_path, heir_summary_file_path))
  
  
}
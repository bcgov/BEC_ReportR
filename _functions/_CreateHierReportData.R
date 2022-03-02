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
  # heir_summary[[paste("plot_numbers_in_", level_name, sep="")]] <- list(SUTab$PlotNumber[SUTab$SiteUnit %in% site_units]) 
 
  # Save heir report
  reports_dir <- file.path("reports", level_name) 
  if (!dir.exists(reports_dir)) dir.create(reports_dir, recursive = TRUE)
  
  file_name <- paste(str_replace_all(level_value, " ", "_"), ".RDS",  sep="")
  saveRDS(heir_summary, file = file.path(reports_dir, file_name))
  heir_summary_file_path <- file.path(reports_dir, file_name)

  plot_numbers_dir <- file.path("plotNumbers", level_name) 
  if (!dir.exists(plot_numbers_dir)) dir.create(plot_numbers_dir, recursive = TRUE)
  
  plot_numbers_in_level <- list(SUTab$PlotNumber[SUTab$SiteUnit %in% site_units]) 
  saveRDS(plot_numbers_in_level, file =(paste(plot_numbers_dir, "/", "plot_numbers_in_" , str_replace_all(level_value, " ", "_"), ".RDS", sep=""))) 
  plot_numbers_in_level_file_path <- paste(plot_numbers_dir, "/", "plot_numbers_in_" , str_replace_all(level_value, " ", "_"), ".RDS", sep="")
  
  # Save plot numbers 
  # if (!file.exists(paste(dir, "/", "plot_numbers_in_", level_value, ".RDS", sep=""))) {
  #   plot_numbers_in_level <- list(SUTab$PlotNumber[SUTab$SiteUnit %in% site_units]) 
  #   saveRDS(plot_numbers_in_level, file =(paste("plot_numbers_in_" , level_value, ".RDS", sep=""))) 
  # }  
  
  #return(list(heir_summary=heir_summary_file_path, plot_numbers_in_level=plot_numbers_in_level_file_path))
  return(plot_numbers_in_level_file_path)
  
  
}
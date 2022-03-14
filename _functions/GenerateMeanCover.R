generate_mean_cover <- function(VegDat2_data_for_level) {
  
  species_count <- table(VegDat2_data_for_level$Species)
  
  sum_cover_per_species <- list()
  
  for (species_name in names(species_count)) {
   species_data <- VegDat2_data_for_level[VegDat2_data_for_level$Species == species_name,]
   sum_cover_per_species[species_name] <- sum(species_data$Cover)
  }
  
  return(mapply("/", sum_cover_per_species, species_count, SIMPLIFY = FALSE))
   
}
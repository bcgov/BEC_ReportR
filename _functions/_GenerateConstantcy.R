generate_constantcy <- function(species) {
  t <- table(species)
  constantcies <- lapply(table(species), "/", length(species))

  return(constantcies)
}
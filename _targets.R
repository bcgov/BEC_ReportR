library(targets)
library(dplyr)

tar_option_set(packages = c("data.table", "tidyverse", "rjson"))
files.sources <- list.files("_functions")
sapply(paste("_functions/", files.sources, sep = ""), source)


write_df_to_csv_and_return_path <- function(data, path) {
  write.csv(data, path)
  return(path)
}

list(
  ###################################################################################################
  ### Read Various files required to generate Hier.data and  plot_numbers_and_site_units_in_level ###
  ###################################################################################################
  tar_target(
    vegDat2,
    fread("BEC_ReportR/Plot_Data/BECMaster_VegR_clean.csv", data.table = FALSE)
  ),
  tar_target(
    taxon.all,
    fread("BEC_ReportR/LookUp_tables/SpeciesMaster01Dec2020.csv", header = T, stringsAsFactors = F, strip.white = T) %>% filter(Codetype == "U")
  ),
  tar_target(
    SUTab,
    fread("BEC_ReportR/Classification_tables/ALLBECSU_2021_SU.csv")
  ),
  tar_target(
    Vpro.hier,
    fread("BEC_ReportR/Classification_tables/BECv13_ForestHierarchy_v2_26Sept2021_Hierarchy.csv")
  ),
  ###############################
  ### Generate Hierarchy data ###
  ###############################
  tar_target(
    Hier.data,
    CodeUsingTreeFunctions(vegDat2, taxon.all, SUTab, Vpro.hier)
  ),
  tar_target(
    Hier.data_file,
    write_df_to_csv_and_return_path(Hier.data, "hierData.csv"),
    format = "file"
  )
)
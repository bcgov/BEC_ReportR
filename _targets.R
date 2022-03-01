library(targets)
tar_option_set(packages = c("data.table", "tidyverse"))
files.sources <- list.files("_functions")
sapply(paste("_functions/", files.sources, sep=""), source)

# codeUsingTreeFunctions
level_name <- "Order"
level_value <- "ORDER Poputre"

list(
  tar_target(
    level_name,
    level_name
  ),
  tar_target(
    level_value,
    level_value
  ),
  tar_target(
    vegDat2,
    fread("./BEC_ReportR/Plot_Data/BECMaster_VegR_clean.csv", data.table = FALSE)
  ),
  tar_target(
    taxon.all,
    read("./BEC_ReportR/LookUp_tables/SpeciesMaster01Dec2020.csv", header = T, stringsAsFactors = F, strip.white = T) %>% filter(Codetype == "U")
  ),
  tar_target(
    SUTab,
    fread("./BEC_ReportR/Classification_tables/ALLBECSU_2021_SU.csv")
  ),
  tar_target(
    Vpro.hier,
    fread("./BEC_ReportR/Classification_tables/BECv13_ForestHierarchy_v2_26Sept2021_Hierarchy.csv")
  ),
  
  tar_target(
    Hier.data,
    codeUsingTreeFunctions(vegDat2, taxon.all, SUTab, Vpro.hier)
  ),
  
  tar_target(
    HierReportData,
    createHierReportData(level_name, level_value, SUTab)
  ),
  
  tar_target(
    ENV_Plot_data,
    fread("./BEC_ReportR/Plot_Data/BECMaster19_ENV.csv")
  ),
  tar_target(
    Humus_Plot_data,
    fread("./BEC_ReportR/Plot_Data/BECMaster19_Humus.csv")
  ),
  tar_target(
    Mineral_Plot_data,
    fread("./BEC_ReportR/Plot_Data/BECMaster19_Mineral.csv")
  ),
  tar_target(
    Climate_Plot_data, fread("./BEC_ReportR/Plot_Data/BECMaster_Plot_Climatedata.csv")
  ),
  tar_target(
    Admin_Plot_data, fread("./BEC_ReportR/Plot_Data/BECMaster19_Admin.csv")
  )
)


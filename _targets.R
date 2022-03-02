library(targets)
tar_option_set(packages = c("data.table", "tidyverse", "rjson"))
files.sources <- list.files("_functions")
sapply(paste("_functions/", files.sources, sep=""), source)

level.name <- "Order"
level.value <- "ORDER Poputre"

list(
  tar_target(
    level_name,
    level.name
  ),
  tar_target(
    level_value,
    level.value
  ),
  tar_target(
    vegDat2,
    fread("./BEC_ReportR/Plot_Data/BECMaster_VegR_clean.csv", data.table = FALSE)
  ),
  tar_target(
    taxon.all,
    fread("./BEC_ReportR/LookUp_tables/SpeciesMaster01Dec2020.csv", header = T, stringsAsFactors = F, strip.white = T) %>% filter(Codetype == "U")
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
    CodeUsingTreeFunctions(vegDat2, taxon.all, SUTab, Vpro.hier)
  ),
  tar_target(
    plot_numbers_in_level_file_path,
    createHierReportData(level_name, level_value, SUTab, Hier.data),
    format = "file"
  ),
  tar_target(
    plot_numbers_in_level,
    readRDS(file.path(plot_numbers_in_level_file_path))[[1]]
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
  ),
  tar_target(
    ENV_Plot_data_for_level,
    ENV_Plot_data[ENV_Plot_data$PlotNumber %in% plot_numbers_in_level]
  ),
  tar_target(
    Humus_Plot_data_for_level,
    Humus_Plot_data[Humus_Plot_data$PlotNumber %in% plot_numbers_in_level]
  ),
  tar_target(
    Mineral_Plot_data_for_level,
    Mineral_Plot_data[Mineral_Plot_data$PlotNumber %in% plot_numbers_in_level]
  ),
  tar_target(
    Climate_Plot_data_for_level,
    Climate_Plot_data[Climate_Plot_data$PlotNumber %in% plot_numbers_in_level]
  ),
  tar_target(
    Admin_Plot_data_for_level,
    Admin_Plot_data[Admin_Plot_data$PlotNumber %in% plot_numbers_in_level]
  ),
  tar_target(
    env_lookup_functions,
    fromJSON(file="lookup_functions/env_lookup_functions.json")
  ),
  tar_target(
    humus_lookup_functions,
    fromJSON(file="lookup_functions/humus_lookup_functions.json"),
  ),
  tar_target(
    mineral_lookup_functions,
    fromJSON(file="lookup_functions/mineral_lookup_functions.json")
  ),
  tar_target(
    climate_lookup_functions,
    fromJSON(file="lookup_functions/climate_lookup_functions.json")
  ),
  tar_target(
    admin_lookup_functions,
    fromJSON(file="lookup_functions/admin_lookup_functions.json")
  ),
  tar_target(
    rolled_up_env_data_file_path,
    roll_up_plot_data(ENV_Plot_data_for_level, env_lookup_functions, level_name, level_value),
    format = "file"
  ),
  tar_target(
    env_summary,
    fromJSON(file=rolled_up_env_data_file_path)
  ),
)


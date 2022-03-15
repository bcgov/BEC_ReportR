library(targets)
tar_option_set(packages = c("data.table", "tidyverse", "rjson"))
files.sources <- list.files("_functions")
sapply(paste("_functions/", files.sources, sep=""), source)

level.name <- "Order"
level.value <- "ORDER Poputre"
site.unit <- "IDF xm   /10"

level_name_dir <- file.path("level", level.name) 
if (!dir.exists(level_name_dir)) dir.create(level_name_dir, recursive = TRUE)

level_value_dir <- file.path(level_name_dir, level.value) 
if (!dir.exists(level_value_dir)) dir.create(level_value_dir, recursive = TRUE)

setwd(level_value_dir)

list(
  ###########################
  ### Set level variables ###
  ###########################
  tar_target(
    level_name,
    level.name
  ),
  tar_target(
    level_value,
    level.value
  ),
  tar_target(
    site_unit,
    site.unit
  ),
  ###################################################################################################
  ### Read Various files required to generate Hier.data and  plot_numbers_and_site_units_in_level ###
  ###################################################################################################
  tar_target(
    vegDat2,
    fread("../../../BEC_ReportR/Plot_Data/BECMaster_VegR_clean.csv", data.table = FALSE)
  ),
  tar_target(
    taxon.all,
    fread("../../../BEC_ReportR/LookUp_tables/SpeciesMaster01Dec2020.csv", header = T, stringsAsFactors = F, strip.white = T) %>% filter(Codetype == "U")
  ),
  tar_target(
    SUTab,
    fread("../../../BEC_ReportR/Classification_tables/ALLBECSU_2021_SU.csv")
  ),
  tar_target(
    Vpro.hier,
    fread("../../../BEC_ReportR/Classification_tables/BECv13_ForestHierarchy_v2_26Sept2021_Hierarchy.csv")
  ),
  ###############################
  ### Generate Hierarchy data ###
  ###############################
  tar_target(
    Hier.data,
    CodeUsingTreeFunctions(vegDat2, taxon.all, SUTab, Vpro.hier)
  ),
  ############################################
  ### Generate Plot numbers in level data ###
  ############################################
  tar_target(
    file_paths_plot_numbers_and_heir_summary,
    createHierReportData(level_name, level_value, SUTab, Hier.data),
    format = "file"
  ),
  
  tar_target(
    plot_numbers_and_site_units_in_level,
    readRDS(file.path(file_paths_plot_numbers_and_heir_summary[[1]]))
  ),
  tar_target(
    hier_summary,
    readRDS(file.path(file_paths_plot_numbers_and_heir_summary[[2]]))
  ),
  ############################
  ### Read BECmaster files ###
  ############################
  tar_target(
    ENV_Plot_data,
    fread("../../../BEC_ReportR/Plot_Data/BECMaster19_ENV.csv")
  ),
  tar_target(
    Humus_Plot_data,
    fread("../../../BEC_ReportR/Plot_Data/BECMaster19_Humus.csv")
  ),
  tar_target(
    Mineral_Plot_data,
    fread("../../../BEC_ReportR/Plot_Data/BECMaster19_Mineral.csv")
  ),
  tar_target(
    Climate_Plot_data, fread("../../../BEC_ReportR/Plot_Data/BECMaster_Plot_Climatedata.csv") %>% filter(!Latitude == 0)
  ),
  tar_target(
    Admin_Plot_data, fread("../../../BEC_ReportR/Plot_Data/BECMaster19_Admin.csv")
  ),
  tar_target(
   Veg_Plot_data, fread("../../../BEC_ReportR/Plot_Data/BECMaster19_Veg.csv")
  ),
  #################################################
  ### Generate Plot data for level in BECmaster ###
  #################################################
  tar_target(
    ENV_Plot_data_for_level,
    ENV_Plot_data[ENV_Plot_data$PlotNumber %in% plot_numbers_and_site_units_in_level$PlotNumber]
  ),
  tar_target(
    Humus_Plot_data_for_level,
    Humus_Plot_data[Humus_Plot_data$PlotNumber %in%  plot_numbers_and_site_units_in_level$PlotNumber] 
  ),
  tar_target(
    Mineral_Plot_data_for_level,
    Mineral_Plot_data[Mineral_Plot_data$PlotNumber %in%  plot_numbers_and_site_units_in_level$PlotNumber]
  ),
  tar_target(
    Climate_Plot_data_for_level,
    Climate_Plot_data[Climate_Plot_data$PlotNumber %in%  plot_numbers_and_site_units_in_level$PlotNumber]
  ),
  tar_target(
    Admin_Plot_data_for_level,
    Admin_Plot_data[Admin_Plot_data$PlotNumber %in%  plot_numbers_and_site_units_in_level$PlotNumber]
  ),
  tar_target(
    Veg_Plot_data_for_level,
    Veg_Plot_data[Veg_Plot_data$PlotNumber %in%  plot_numbers_and_site_units_in_level$PlotNumber] %>% merge(plot_numbers_and_site_units_in_level, by="PlotNumber")
  ),
  tar_target(
    VegDat2_data_for_level,
    vegDat2[vegDat2$PlotNumber %in%  plot_numbers_and_site_units_in_level$PlotNumber,] %>% merge(plot_numbers_and_site_units_in_level, by="PlotNumber")
  ),
  ##################################
  ### Read lookup function Files ###
  ################################## 
  tar_target(
    env_lookup_functions,
    fromJSON(file="../../../lookup_functions/env_lookup_functions.json")
  ),
  tar_target(
    humus_lookup_functions,
    fromJSON(file="../../../lookup_functions/humus_lookup_functions.json"),
  ),
  tar_target(
    mineral_lookup_functions,
    fromJSON(file="../../../lookup_functions/mineral_lookup_functions.json")
  ),
  tar_target(
    climate_lookup_functions,
    fromJSON(file="../../../lookup_functions/climate_lookup_functions.json")
  ),
  tar_target(
    admin_lookup_functions,
    fromJSON(file="../../../lookup_functions/admin_lookup_functions.json")
  ),
  
  ############################
  ### Create Summary Files ###
  ############################
  
  # Create env data summary
  tar_target(
    rolled_up_env_data_file_path,
    roll_up_plot_data(ENV_Plot_data_for_level, env_lookup_functions, "env", level_name, level_value),
    format = "file"
  ),
  tar_target(
    env_summary,
    fromJSON(file=rolled_up_env_data_file_path)
  ),
  # Create admin data summary
  tar_target(
    rolled_up_admin_data_file_path,
    roll_up_plot_data(Admin_Plot_data_for_level, admin_lookup_functions, "admin", level_name, level_value),
    format = "file"
  ),
  tar_target(
    admin_summary,
    fromJSON(file=rolled_up_admin_data_file_path)
  ),
  # Create climate data summary
  tar_target(
    rolled_up_climate_data_file_path,
    roll_up_plot_data(Climate_Plot_data_for_level, climate_lookup_functions, "climate", level_name, level_value),
    format = "file"
  ),
  tar_target(
    climate_summary,
    fromJSON(file=rolled_up_climate_data_file_path)
  ),
  # Create humus data summary
  tar_target(
    rolled_up_humus_data_file_path,
    roll_up_plot_data(Humus_Plot_data_for_level, humus_lookup_functions, "humas", level_name, level_value),
    format = "file"
  ),
  tar_target(
    humus_summary,
    fromJSON(file=rolled_up_humus_data_file_path)
  ),
  # Create mineral data summary
  tar_target(
    rolled_up_mineral_data_file_path,
    roll_up_plot_data(Mineral_Plot_data_for_level, mineral_lookup_functions, "mineral", level_name, level_value),
    format = "file"
  ),
  tar_target(
    mineral_summary,
    fromJSON(file=rolled_up_mineral_data_file_path)
  ),
  #########################
  ### Create Veg Report ###
  #########################
  
  tar_target(
    uniqueSiteUnits,
    unique(plot_numbers_and_site_units_in_level$SiteUnit)
  ),
  tar_target(
    Tree_layer_data,
    Veg_Plot_data_for_level[Veg_Plot_data_for_level$TotalA > 0]
  ),
  tar_target(
    Shrub_layer_data,
    Veg_Plot_data_for_level[Veg_Plot_data_for_level$TotalB > 0],
  ),
  tar_target(
    Herb_layer_data,
    Veg_Plot_data_for_level[Veg_Plot_data_for_level$Cover6 > 0],
  ),
  tar_target(
    Moss_layer_data,
    Veg_Plot_data_for_level[Veg_Plot_data_for_level$Cover7 > 0],
  ),
  tar_target(
    Tree_layer_VegDat2_data,
    VegDat2_data_for_level[VegDat2_data_for_level$Species %in% Tree_layer_data$Species,]
  ),
  tar_target(
    Veg_reports_path,
    generate_veg_reports(Tree_layer_data, Shrub_layer_data, Herb_layer_data, Moss_layer_data, VegDat2_data_for_level, taxon.all, uniqueSiteUnits)
  )
  

)


## ----setup, include=FALSE---------------------------------------------------------------------------------------
knitr::opts_chunk$set(echo = FALSE)

require(tidyverse)
require(tidymodels)
require(data.table)
require(data.tree)
require(DataExplorer)
require(C50)
require(indicspecies)
require(doParallel)
require(philentropy)
require(dplyr)

CodeUsingTreeFunctions <- function(vegDat2, taxon.all, SUTab, Vpro.hier) {
  cloud_dir <- "F:/OneDrive - Personal/OneDrive/BEC_Classification_Paper/"
  #cloud_dir <- "F:/OneDrive - Government of BC/CCISSv12/"
  
  ## ----import data------------------------------------------------------------------------------------------------
  ### Vegetation From BECMaster cleaning script Long form Plot|Species|Cover (across all layers)
  ### or From Vpro export
  #BGCZone <- fread(paste0(cloud_dir,"All_BGCs_Info_v12_2.csv"), data.table=FALSE)
  
  # Removed when concverted to function
  # vegDat2 <- fread("./BEC_ReportR/Plot_Data/BECMaster_VegR_clean.csv", data.table = FALSE)
  # taxon.all <- fread("./BEC_ReportR/LookUp_tables/SpeciesMaster01Dec2020.csv", header = T, stringsAsFactors = F, strip.white = T) %>% filter(Codetype == "U")
  
  ###SU table
  
  # Removed when concverted to function
  # SUTab <- fread("./BEC_ReportR/Classification_tables/ALLBECSU_2021_SU.csv")
  
  #SUTab <- fread("./inputs/BECv13Analysis_Forest_17Sept2021_SU.csv")
  SUTab$SiteUnit <-  trimws(SUTab$SiteUnit)
  SS.names <- unique(SUTab$SiteUnit)
  
  vegdat_test <- left_join(SUTab, vegDat2)
  # #####list of official current and future correlated units from BECdb
  # current <- c('Current', 'Future')
  # ecotypes <- c("Forest", "Deciduous")
  # #### cleaned list of official site series
  # BECdb_SS <- fread("./inputs/BECdb_SiteUnitv12.csv") %>% filter(Status %in% current) %>% filter(ArchivedinVersion == "") %>% filter(`Forest-NonForest` %in% ecotypes) %>% 
  #   select(MergedBGC_SS, SS_NoSpace, SiteUnitLongName, SiteUnitScientificName) %>% rename (SiteUnit = 1, SSName = 3, SciName = 4) %>% distinct(SiteUnit, .keep_all = TRUE)
  # #### compare SUTab to BECdb.  Whan all BECdb units to have data and SUTab to include no unofficial units
  # SS_missing <- full_join(SUTab, BECdb_SS) %>% filter(is.na(PlotNumber))
  ##Import Vpro hierarchy table widen and reformat
  
  
  ## ----summarize site series, echo=FALSE--------------------------------------------------------------------------
  #SUTab <- fread("./inputs/BECMster_V2020_2_SU.csv")
  ### Summarize by SU including mean cover and constancy percent
  ##roll up into site series summary data
  ### Filter out all species but tree species
  vegSum <- VegdatSUsummary(vegDat2, SUTab)
  vegSum2 <- spp_importance(vegSum) 
  
  #vegDat_test <- vegSum %>% dplyr::filter(MeanCov > covercut) %>% dplyr::filter(Constancy > covercut) ## remove rare or very low cover species in SU
  # 
  # vegDat <- as.data.table(vegDat2)
  # 
  # vegDat[SUTab, SiteUnit := i.SiteUnit, on = "PlotNumber"]
  # vegDat <- vegDat[!is.na(SiteUnit) & SiteUnit != "",]
  # 
  # vegDat <- unique(vegDat[!is.na(SiteUnit) & SiteUnit != "",])
  # vegDat3 <- vegDat[,if(.N > 1) .SD, by = .(SiteUnit,Species)]
  # vegDat3[,nPlots := length(unique(PlotNumber)), by = .(SiteUnit)]
  # vegSum <- vegDat3[,.(MeanCov = sum(Cover, na.rm = TRUE)/nPlots[1], Constancy = (.N/nPlots[1])*100, nPlots = nPlots[1]), by = .(SiteUnit,Species)]
  #fwrite(vegSum, './clean_tabs/BECv12SiteUnitSummaryVegData.csv')
  
  
  ## ----reduce summary for analysis, echo=FALSE--------------------------------------------------------------------
  ##limit life forms to tree species
  trees <- c(1,2)
  constCut <- 0.1 ##remove species less than cutoff
  covercut <- 0.1
  treespp <- taxon.all[Lifeform %in% trees, ] %>% dplyr::select(Code)
  treespp <- as.vector(treespp$Code)
  vegDat_test <- vegSum[Species %in% treespp,]### include only trees for hierarchy build
  vegDat_test <- vegDat_test %>% dplyr::filter(MeanCov > covercut) %>% dplyr::filter(Constancy > covercut)
  
  tree.sum <- as.data.table(vegDat_test)#vegDat <- as_tibble(vegDat)
  tree.sum$SiteUnit <- as.factor(tree.sum$SiteUnit)
  
  
  #fwrite(tree.sum, './inputs/SiteUnitConiferSummary.csv')
  
  
  
  ## ----import  hierarchy data-------------------------------------------------------------------------------------
  ##Import wide matrix as training data
  #SUhier <- fread("./outputs/BECv12_Hierarchy_Matrix.csv")
  
  
  ###Import Vpro hierarchy and turn to widematrix
  # Removed when concverted to function
  # Vpro.hier <- fread("./BEC_ReportR/Classification_tables/BECv13_ForestHierarchy_v2_26Sept2021_Hierarchy.csv")
  Vpro.hier <- as.data.table(Vpro.hier)
  
  #Vpro.hier <- fread("./inputs/BECv13Hierarchy_v1_22Sept2021_Hierarchy.csv")
  SUhier <- treeToTable(Vpro.hier)
  Hier.clean <- SUhier$table
  
  
  
  ## ----filter and prepare for analysis----------------------------------------------------------------------------
  
  vegSum <- tree.sum
  
  SS_good <- vegSum %>% filter(nPlots >=3) %>% filter(Constancy >= 33)  %>% distinct()  #%>% rename(SiteUnit = SiteUnit))## Select only site series will enough plots
  Hier.units <- Hier.clean %>% dplyr::select(SiteUnit, Class, Order, Suborder, Alliance, Assoc) %>% distinct()
  Hier.data <- left_join(Hier.units, SS_good) %>% filter(!is.na(nPlots)) %>% arrange(Species) %>% distinct()
  #fwrite(Hier.data, './inputs/SiteUnitForested_w_HierarchyUnits.csv')
  
  #print(SS_good)   # SiteUnit, Species, MeanCov, Constancy, nPlots
  #print(Hier.data)  # SiteUnit, Species, MeanCov, Constancy, nPlots, Class, Order, Suborder, MeanCov, Constancy
  
  Hier.data <- Hier.data[order(Hier.data$SiteUnit),]
  SUTab <- SUTab[order(SUTab$SiteUnit)]
  
  ## ----some hierarchy stats---------------------------------------------------------------------------------------
  classes <- unique(Hier.data$Class)
  orders <- unique(Hier.data$Order)
  suborders <- unique(Hier.data$Suborder)
  suborders
  ### Choose hierarchical level for analysis
  
 
  return(Hier.data)
}


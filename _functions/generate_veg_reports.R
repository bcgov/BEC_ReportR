generate_veg_reports <- function(Tree_layer_data, Shrub_layer_data, Herb_layer_data, Moss_layer_data, VegDat2_data_for_level, taxon.all, uniqueSiteUnits) {
  
  for (site_unit in uniqueSiteUnits) {
    print(site_unit)
    tree <- Tree_layer_data %>% filter(SiteUnit == site_unit)
    shrub <- Shrub_layer_data %>% filter(SiteUnit == site_unit)
    herb <- Herb_layer_data %>% filter(SiteUnit == site_unit)
    moss <- Moss_layer_data %>% filter(SiteUnit == site_unit)
    
    Tree_layer_constantcy <- generate_constantcy(tree$Species)
    Shrub_layer_constantcy <- generate_constantcy(shrub$Species)
    Herb_layer_constantcy <- generate_constantcy(herb$Species)
    Moss_layer_constantcy <- generate_constantcy(moss$Species)
    
    Tree_layer_VegDat2_data <- VegDat2_data_for_level[VegDat2_data_for_level$Species %in% tree$Species,]
    Shurb_layer_VegDat2_data <- VegDat2_data_for_level[VegDat2_data_for_level$Species %in% shrub$Species,]
    Herb_layer_VegDat2_data <- VegDat2_data_for_level[VegDat2_data_for_level$Species %in% herb$Species,]
    Moss_layer_VegDat2_data <- VegDat2_data_for_level[VegDat2_data_for_level$Species %in% moss$Species,]
    
    Tree_layer_mean_cover <- generate_mean_cover(Tree_layer_VegDat2_data)
    Shurb_layer_mean_cover <- generate_mean_cover(Shurb_layer_VegDat2_data)
    Herb_layer_mean_cover <- generate_mean_cover(Herb_layer_VegDat2_data)
    Moss_layer_mean_cover <- generate_mean_cover(Moss_layer_VegDat2_data)
    
    Tree_layer_taxon.all_data <- taxon.all[taxon.all$Code %in% tree$Species,]
    Shurb_layer_taxon.all_data <- taxon.all[taxon.all$Code %in% shrub$Species,]
    Herb_layer_taxon.all_data <- taxon.all[taxon.all$Code %in% herb$Species,]
    Moss_layer_taxon.all_data <- taxon.all[taxon.all$Code %in% moss$Species,]
    
    Tree_layer_table_data <- generateVegLayerTableDataFrame(Tree_layer_constantcy, Tree_layer_mean_cover, Tree_layer_taxon.all_data, "Tree_Layer", site_unit)
    Shurb_layer_table_data <- generateVegLayerTableDataFrame(Shrub_layer_constantcy, Shurb_layer_mean_cover, Shurb_layer_taxon.all_data, "Shrub_Layer", site_unit)
    Herb_layer_table_data <- generateVegLayerTableDataFrame(Herb_layer_constantcy, Herb_layer_mean_cover, Herb_layer_taxon.all_data, "Herb_Layer", site_unit)
    Moss_layer_table_data <- generateVegLayerTableDataFrame(Moss_layer_constantcy, Moss_layer_mean_cover, Moss_layer_taxon.all_data, "Moss_Layer", site_unit)

    #return(c(Tree_layer_table_data, Shurb_layer_table_data, Herb_layer_table_data, Moss_layer_table_data))
  }
  
  print("TEST")
  
}
generate_veg_reports <- function(Tree_layer_data, Shrub_layer_data, Herb_layer_data, Moss_layer_data, VegDat2_data_for_level, taxon.all) {
  
    tree <- Tree_layer_data
    shrub <- Shrub_layer_data
    herb <- Herb_layer_data
    moss <- Moss_layer_data
    
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
    
    Tree_layer_table_data <- generateVegLayerTableDataFrame(Tree_layer_constantcy, Tree_layer_mean_cover, Tree_layer_taxon.all_data, "Tree_Layer")
    Shurb_layer_table_data <- generateVegLayerTableDataFrame(Shrub_layer_constantcy, Shurb_layer_mean_cover, Shurb_layer_taxon.all_data, "Shrub_Layer")
    Herb_layer_table_data <- generateVegLayerTableDataFrame(Herb_layer_constantcy, Herb_layer_mean_cover, Herb_layer_taxon.all_data, "Herb_Layer")
    Moss_layer_table_data <- generateVegLayerTableDataFrame(Moss_layer_constantcy, Moss_layer_mean_cover, Moss_layer_taxon.all_data, "Moss_Layer")

    #return(c(Tree_layer_table_data, Shurb_layer_table_data, Herb_layer_table_data, Moss_layer_table_data))
  
  
}
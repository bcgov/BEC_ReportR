##convert cover + constancy into importance value for analysis
## apply to table built from VegdatSUsummary function
#vegsum = vegSum
spp_importance <- function(vegsum){
  vegsum$MeanCov[vegsum$MeanCov >100] <- 100
  vegsum$spp_importance <- vegsum$MeanCov^0.5
  vegsum$spp_importance[vegsum$spp_importance < 0.1] <- NA 
  vegsum$spp_importance[vegsum$spp_importance < 1.1] <- 0.1 
  vegsum$spp_importance[is.na(vegsum$spp_importance)] <- 0 
  vegsum <- vegsum %>% mutate(spp_importance = spp_importance * (Constancy/100))
  return(vegsum)
}

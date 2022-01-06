##convert cover + constancy into importance value for analysis
## apply to table built from VegdatSUsummary function
#plotdat = vegDat2
cov_rescale <- function(plotdat){
  plotdat$Cover[plotdat$Cover>100] <- 100
  plotdat$Cover2 <- plotdat$Cover^0.5
  #plotdat$Cover2[plotdat$Cover2 < 0.1] <- NA 
  #plotdat$Cover2[plotdat$Cover2 < 1.1] <- 0.1 
  #plotdat$Cover2[is.na(plotdat$Cover2)] <- 0 
  return(plotdat)
}

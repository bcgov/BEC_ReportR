### Summarizes a long table of plot data by site units
### calculates mean cover and constancy

#SUTab = BECv13_SU
#vegdata


VegdatSUsummary <- function(vegdata, SUTab){
 
  vegDat <- as.data.table(vegdata)
  
  vegDat[SUTab, SiteUnit := i.SiteUnit, on = "PlotNumber"]
  vegDat <- vegDat[!is.na(SiteUnit) & SiteUnit != "",]
  
  vegDat <- unique(vegDat[!is.na(SiteUnit) & SiteUnit != "",])
  vegDat3 <- vegDat[,if(.N > 1) .SD, by = .(SiteUnit,Species)]
  vegDat3[,nPlots := length(unique(PlotNumber)), by = .(SiteUnit)]
  vegSum <- vegDat3[,.(MeanCov = sum(Cover, na.rm = TRUE)/nPlots[1], Constancy = (.N/nPlots[1])*100, nPlots = nPlots[1]), by = .(SiteUnit,Species)]
  return(vegSum)
}

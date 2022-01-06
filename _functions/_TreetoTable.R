
treeToTable <- function(SUhier){
  hierLookup <- SUhier[,.(ID,Name)]
  HierClean <- SUhier[,.(ID,Parent,Name,Level)]
  roots <- HierClean$Parent[!HierClean$Parent %in% HierClean$ID]
  roots <- unique(roots[!is.na(roots)])
  if(length(roots) >= 1){
    warning("There are duplicate roots. Please check ID ", roots)
  }
  HierClean[is.na(Parent), Parent := 1]
  temp <- data.table(ID = roots,Parent = rep(1,length(roots)), Name = rep("XXX",length(roots)),Level = rep(1, length(roots)))
  HierClean <- rbind(HierClean,temp)
  
  HierClean[hierLookup, ParentName := i.Name, on = c(Parent = "ID")]
  HierClean[is.na(ParentName), ParentName := "root2"]
  HierClean <- HierClean[,.(Name,ParentName,Level)]
  HierClean$ParentName[!HierClean$ParentName %in% HierClean$Name]
  tree <- FromDataFrameNetwork(HierClean)
  wideTab <- ToDataFrameTypeCol(tree)
  wideTab <- as.data.table(wideTab)
  wideTab[,ID := 1:nrow(wideTab)]
  wideTab[,level_1 := NULL]
  tab2 <- melt(wideTab, id.vars = "ID")
  tab2 <- na.omit(tab2)
  tab2 <- as.data.table(tab2)
  tab2[HierClean, Level := i.Level, on = c(value = "Name")]
  dupLevels <- tab2[,.(Len = .N), by = .(ID,Level)]
  dupLevels <- dupLevels[Len > 1,]
  dups <- tab2[ID %in% dupLevels$ID,]
  setorder(dups,"ID")
  dups[,variable := NULL] ##these are the branches with duplicates
  tabOut <- dcast(tab2, ID ~ Level, value.var = "value", fun.aggregate = function(x){x[1]}) %>% as.data.table
  setnames(tabOut, c("ID","Formation","Class","Order","Suborder","Alliance","Suball","Assoc","Subass","Facies","Working", "SiteUnit"))
  tabOut[is.na(Subass), Subass := Assoc]
  tabOut[is.na(Suborder), Suborder := Order]
  tabOut[is.na(Suball), Suball := Alliance]
  return(list(table = tabOut, duplicates = dups))
}

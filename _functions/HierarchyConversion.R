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
  tab2[HierClean, Level := i.Level, on = c(value = "Name")]
  dupLevels <- tab2[,.(Len = .N), by = .(ID,Level)]
  dupLevels <- dupLevels[Len > 1,]
  dups <- tab2[ID %in% dupLevels$ID,]
  setorder(dups,"ID")
  dups[,variable := NULL] ##these are the branches with duplicates
  tabOut <- dcast(tab2, ID ~ Level, value.var = "value", fun.aggregate = function(x){x[1]})
  print(tabOut)
  setnames(tabOut, c("ID","Formation","Class","Order","Suborder","Alliance","Suball","Assoc","Subass","Facies","SiteUnit"))
  tabOut[is.na(Subass), Subass := Assoc]
  tabOut[is.na(Suborder), Suborder := Order]
  tabOut[is.na(Suball), Suball := Alliance]
  return(list(table = tabOut, duplicates = dups))
}

tableToTree <- function(hierWide, levelNames){
  levelID <- data.table(Name = levelNames, Level = 1:length(levelNames))
  hierWide[,ID := 1:nrow(hierWide)]
  cols <- names(hierWide)
  hierWide[,(cols) := lapply(.SD, FUN = function(x){gsub("_"," ",x)}), .SDcols = cols]
  levs <- melt(hierWide, id.vars = "ID")
  levs[,ID := NULL]
  levs <- unique(levs)
  levs[levelID, Level := i.Level, on = c(variable = "Name")]
  levs <- levs[!is.na(value)]## this is unique names and where an unique ID number should be assigned
  hierWide[,ID := NULL]
  hierWide[,Root := "TempRoot"]
  temp <- data.table::transpose(hierWide,keep.names = "Level")
  temp <- temp[, lapply(.SD, function(x) replace(x, duplicated(x), NA))]
  temp <- data.table::transpose(temp, make.names = "Level")
  #setcolorder(hierWide,c(ncol(hierWide),1:(ncol(hierWide)-1)))
  paths <- tidyr::unite(temp, "pathString", na.rm = T, sep = "_")
  tr <- as.Node(paths,pathDelimiter = "_")
  tr$Set(Lab = tr$Get("name"))
  tr$Set(name = 1:tr$totalCount)
  dat <- ToDataFrameNetwork(tr,"Lab",direction = "climb")
  dat <- as.data.table(dat)
  setnames(dat, old = c("from","to","Lab"), new = c("Parent","ID","Name"))
  dat[levs, Level := i.Level, on = c(Name = "value")]
  setcolorder(dat,c("ID","Name","Parent","Level"))
  return(dat)
}
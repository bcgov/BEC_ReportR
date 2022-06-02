#hierWide = Hier2
tableToTree <- function(hierWide, levelNames){
  levelID <- data.table(Name = levelNames, Level = 1:length(levelNames))
  hierWide[,ID := 1:nrow(hierWide)]
  cols <- names(hierWide)
  hierWide[,(cols) := lapply(.SD, FUN = function(x){gsub("_"," ",x)}), .SDcols = cols]
  levs <- melt(hierWide, id.vars = "ID")
  setDT(levs)
  levs[,ID := NULL]
  levs <- unique(levs)
  levs[levelID, Level := i.Level, on = c(variable = "Name")]
  levs <- levs[!is.na(value)]## this is unique names and where an unique ID number should be assigned
  hierWide[,ID := NULL]
  hierWide[,Root := "TempRoot"]
  hierWide <- hierWide %>% dplyr::select(Root, everything())
  temp <- data.table::transpose(hierWide,keep.names = "Level")
  temp <- temp[, lapply(.SD, function(x) replace(x, duplicated(x), NA))]
  temp <- data.table::transpose(temp, make.names = "Level")
  #setcolorder(hierWide,c(ncol(hierWide),1:(ncol(hierWide)-1)))
  paths <- tidyr::unite(temp, "pathString", na.rm = T, sep = "_")
  tr <- as.Node(paths,pathDelimiter = "_")
  tr$Set(Lab = tr$Get("name"))
  tr$Set(name = 1:tr$totalCount-1)
  dat <- ToDataFrameNetwork(tr,"Lab",direction = "climb")
  dat <- as.data.table(dat)
  setnames(dat, old = c("from","to","Lab"), new = c("Parent","ID","Name"))
  dat[levs, Level := i.Level, on = c(Name = "value")]
  setcolorder(dat,c("ID","Name","Parent","Level"))
  return(dat)
}

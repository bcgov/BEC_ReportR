# 
# library("here")
# 
# current_dir <- here()
# print(current_dir)
# level_values <- read.csv(
#   header = TRUE,
#   strip.white = TRUE,
#   sep = ',',
#   file = file.path(current_dir,"level_name_value.csv")
# )
# source(file = file.path(current_dir,"_targets.R"))
# setwd(current_dir)
# tar_make()

# print("TEST")
# 
# args <- commandArgs(trailingOnly = TRUE)
# print(args)

tar_make()
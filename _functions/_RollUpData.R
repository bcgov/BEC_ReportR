library(rjson)

clean_list_element <- function(element) {
  items <- as.list(trimws(el(strsplit(element, "/|,|;|-|\\+| AND | and |&|,"))))
  return (items)
}

clean_list_data <- function(df_column) {
  l <- unlist(lapply(df_column, function(element) clean_list_element(element)))
  return(l)
}

roll_up_plot_data <- function(plot_data, lookup_function_list, becmaster_name, level_name, level_value) {
  
  print("*** PLOT DATA ***")
  print(plot_data)
  variable_summaries <- list()
  
  for (variable_name in names(lookup_function_list)) {
    
    
    variable_type <- lookup_function_list[[variable_name]]$variableType
    is_list <- lookup_function_list[[variable_name]]$isList
    
    #data <- list(plot_data[[variable_name]])
    
    if(!is.null(is_list) && is_list) {
      data <- clean_list_data(plot_data[[variable_name]])
    } else {
      data <- trimws(plot_data[[variable_name]])
      
    }
    
    data <- data[!is.null(data)]
    data <- data[data != ""]
    data <- data[!is.na(data)]
    
    if(variable_type == "categorical") {
      variable_summaries[[variable_name]] <- list(variable_type=variable_type, summary=table(data))
    } else if(variable_type == "quantitative") {
      variable_summaries[[variable_name]] <- list(variable_type=variable_type, summary=summary(as.numeric(data)))
    } else if(variable_type == "coordinate") {
      variable_summaries[[variable_name]] <- list(variable_type=variable_type, summary=unique(data))
    } else if(variable_type == "description"){
      variable_summaries[[variable_name]] <- list(variable_type=variable_type, summary=data)
    }
    
    #variable_summaries[[function_name]] <- list(do.call(function_name, list(plot_data[[variable_name]])))
    
  }
  
  reports_dir <- file.path("summaries", becmaster_name, level_name) 
  if (!dir.exists(reports_dir)) dir.create(reports_dir, recursive = TRUE)
  
  file_path <-  file.path(reports_dir, paste(str_replace_all(level_value, " ", "_"), ".JSON",  sep=""))
  write(toJSON(variable_summaries), file_path)
  
  print(file_path)
  
  return(file_path)
}
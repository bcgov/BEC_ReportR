#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
options(shiny.autoreload = FALSE)

library(ggplot2movies)
library(tidyverse)
library(scales)
library(rlang)
library(targets)
library(data.table)
library(dplyr)

source("pipeline.R")
source("_functions/_CodeUsingTreeFunctions.R")
source("Report/Report.R")

## Get hier data
tar_make()
Hier.data <- read.csv("hierData.csv")

Class <- unique(na.omit(Hier.data$Class))
Order <- unique(na.omit(Hier.data$Order))
Suborder <- unique(na.omit(Hier.data$Suborder))
Alliance <- unique(na.omit(Hier.data$Alliance))
Assoc <- unique(na.omit(Hier.data$Assoc))

hier <- list(Class = Class, Order = Order, Suborder = Suborder, Alliance = Alliance, Assoc = Assoc)

wd <- getwd()

ui <- htmlTemplate("template.html",
    run = actionButton("run", "Run"),
)

server <- function(input, output) {
    output$listLevelNames <- renderUI({
        selectInput("selectLevelName", "Select level name",
            choices = c("Class", "Order", "Suborder", "Alliance", "Assoc"),
            selected = "Class"
        )
    })

    makeListLevelValues <- reactive({
        if (req(!is.null(input$selectLevelName))) {
            selectInput("selectLevelValue", "Select level value",
                choices = hier[[input$selectLevelName]],
                selected = hier$Class
            )
        }
    })

    output$listLevelValues <- renderUI({
        print("MAKE")
        makeListLevelValues()
    })

    observeEvent(input$run, {
        level.name <- input$selectLevelName
        level.value <- input$selectLevelValue
        # level.value <- "CLASS Tsugmer"

        level_name_dir <- file.path("level", level.name)
        if (!dir.exists(level_name_dir)) dir.create(level_name_dir, recursive = TRUE)

        level_value_dir <- file.path(level_name_dir, level.value)
        if (!dir.exists(level_value_dir)) dir.create(level_value_dir, recursive = TRUE)

        script <- file.path(level_value_dir, "_targets.R")

        write_pipeline(level_value_dir, level.name, level.value)
        tar_make(
            script = script
        )
        setwd(wd)
        # setwd(file.path(level.name, level.value))

        public_dir <- file.path("www", level.name, level.value)
        if (!dir.exists(public_dir)) dir.create(public_dir, recursive = TRUE)

        generateReport(level.name, level.value)
        print("DONE")
        # js$refresh();
    })
}


# Run the application

shinyApp(ui = ui, server = server)
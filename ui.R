library(shiny)
library(leaflet)
library(sp)
library(magrittr)
library(markdown)
library(ggplot2)

shinyUI(bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
  leafletOutput("mymap", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 20, width = 350, draggable = TRUE, 
                wellPanel(h3("Traffic in New York", align="left"),
                          p("Select whether you'd like to inspect Weekdays, Weekends, or all days. 
                          Use the slider to select a time and hit 'Play!' to begin the animation."),
                          br(),
                          div(id="XXmin",selectInput("selection", NULL, width = 125, 
                                                     choices = c("All" = "full", 
                                                                 "Weekdays" = "wkdy", 
                                                                 "Weekends" = "wknd"), 
                                                     selected=NULL, 
                                                     multiple=F)),
                          tags$head(tags$style(type="text/css", "#XXmin {display: inline-block}")),
                          tags$head(tags$style(type="text/css", "#selection {max-width: 150}")),
                          div(id="XXmax",sliderInput("sldr", label = NULL, min = 1, max = 144, width = 160, 
                                                     value = 31, step = 1, sep = "", ticks = FALSE,
                                                     animate = animationOptions(interval=500, 
                                                                                loop=F, 
                                                                                playButton = "Play!", 
                                                                                pauseButton="Pause"))),
                          tags$head(tags$style(type="text/css", "#XXmax {display: inline-block}")),
                          tags$head(tags$style(type="text/css", "#sldr {max-width: 160px}")),
                          br(),
                          br(),
                          h4(textOutput("tm"), align="center"),
                          plotOutput("rctvplt", height = 200),
                          br(),
                          br(),
                          div(id="buttontext",h6("If mapping becomes sluggish, use this button to clear all plotted lines.")),
                          tags$head(tags$style(type="text/css", "#buttontext {display: inline-block}")),
                          tags$head(tags$style(type="text/css", "#buttontext {max-width: 200px}")),
                          div(id="button",actionButton("gobutt","Clear")),
                          tags$head(tags$style(type="text/css", "#button {display: inline-block}")),
                          tags$head(tags$style(type="text/css", "#gobutt {max-width: 200px}"))),
                style = "opacity: 0.92")
))








# h6("If mapping becomes sluggish, use the below button to clear all plotted lines."),
# actionButton("gobutt","Clear")















# Straight Input items
# 
# choices = c("All" = "full", 
#             "Weekdays" = "wkdy", 
#             "Weekends" = "wknd"), selected=NULL, multiple=F),
# sliderInput("sldr", label = NULL, 
#             min = 1, max = 144, 
#             value = 31, step = 1, 
#             sep = "", ticks = FALSE,
#             animate = animationOptions(interval=200, loop=F, playButton = "Play!", pauseButton="Pause")),

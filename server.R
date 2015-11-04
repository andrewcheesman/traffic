library(leaflet)
library(RColorBrewer)
library(colorRamps)
library(sp)
library(magrittr)
library(stringr)
library(ggplot2)

load("/srv/shiny-server/traffic/splndf.RDA")
load("/srv/shiny-server/traffic/avg_speeds.RDA")


test <- rev(blue2red(10))

pal <- colorNumeric(
  palette = test,
  domain = c(0,70)
)

shinyServer(function(input, output) {
  
  # Renders the underlying map tool
  output$mymap <- renderLeaflet({
    leaflet(data=splndf) %>%
      setView(lng = -73.9, lat = 40.685, zoom = 11) %>%
      addTiles("http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}", attribution = 'Map layer by <a href="http://leaflet-extras.github.io/leaflet-providers/preview/index.html">ArcGIS</a>; Based on data available from <a href="http://207.251.86.229/nyc-links-cams/LinkSpeedQuery.txt">NYC DOT</a>') %>%
      addPolylines(color = pal(splndf[[1]]), noClip = T, weight = .5) %>%
      addLegend("bottomleft", pal = pal, values = ~splndf[[1]],
                title = "MPH",
                labFormat = labelFormat(prefix = ""),
                opacity = .8)
    
  })
  
  output$rctvplt <- renderPlot({
    ggplot(data=avg_speed, aes(x=time, y=avg_spd, color=Period)) +
      geom_line() +
      theme_bw() +
      geom_vline(xintercept = (trunc((input$sldr-1)/6, 0)*100)+((input$sldr-1)/6-trunc((input$sldr-1)/6, 0))*60,
                 colour = "red") +
      scale_x_continuous(breaks=seq(0, 2400, 300)) +
      theme(legend.justification = c(0,0), 
            legend.position = c(0,0),
            legend.title = element_blank(),
            legend.background = element_blank()) +
      labs(x="Time of Day", y="MPH")
  })
  
  # Displays the time being exposed (translates using the layer indicies)
  output$tm <- renderText({
    tm_fmt <- (trunc((input$sldr-1)/6, 0)*100)+((input$sldr-1)/6-trunc((input$sldr-1)/6, 0))*60
    paste("Time Displayed: ", 
          if(is.na(as.numeric(str_sub(tm_fmt, -4, -3)))==T) { "00"
          } else if(as.numeric(str_sub(tm_fmt, -4, -3))>12) { as.numeric(str_sub(tm_fmt, -4, -3))-12
          } else { as.numeric(str_sub(tm_fmt, -4, -3)) }, 
          ":",
          ifelse(str_sub(tm_fmt, -2, -1)>0, str_sub(tm_fmt, -2, -1), "00"), 
          ifelse(tm_fmt > 1151, " PM", " AM"),
          sep="")
  })
  
  # Determines which layer to show, based on selection and slider inputs
  # Drawing a new map layer using the reactive input through 'eph'
  observe({
    input$sldr
    eph <- get(paste(input$selection, "_", input$sldr, sep=""))
    leafletProxy("mymap", data = eph) %>%
      addPolylines(color = pal(eph[[1]]))
  })
  
  observe({
    if (input$sldr%%10==0) {
      leafletProxy("mymap") %>% clearShapes()
    }
  })
  
  observeEvent(input$gobutt, {
    leafletProxy("mymap") %>% clearShapes
  })
  
})

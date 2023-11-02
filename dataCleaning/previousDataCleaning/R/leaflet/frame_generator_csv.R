frame_generator = function(timestamp) {
  colours = c('grey', 'blue', 'orange', 'red')
  
  posix_time = as.POSIXct(timestamp, origin = "1970-01-01", tz = "UTC")
  time_display <- format(posix_time, format = "%H:%M")
  
  busses = intData[intData$timestamps == timestamp,]
  
  m <- leaflet() %>%
    addTiles() %>%
    setView(lng=174.768, lat=-36.852, zoom = 10) 
  
  for (i in 1 :nrow(busses)) {
    m = m %>% 
      addCircleMarkers(lng = busses$lon[i], 
                               lat = busses$lat[i], 
                               radius = 0.5,  
                               color = colours[busses$status[i] + 1], 
                               fillOpacity = 0.2) 
  }
  
  m <- m %>% addControl(
    html = paste("Time:", time_display),
    position = "topright"
  )
  
  # delay to ensure all tiles are loaded
  mapshot(m, file = paste0("leafletImages/m", timestamp, ".png"), delay = 1) 
  return(TRUE)
}

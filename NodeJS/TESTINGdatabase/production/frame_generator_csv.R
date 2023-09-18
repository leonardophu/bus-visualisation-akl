frame_generator = function(timestamp) {
  colours = c('grey', 'blue', 'orange', 'red')
  
  posix_time = as.POSIXct(timestamp, origin = "1970-01-01", tz = "UTC")
  time_display <- format(posix_time, format = "%H:%M")
  
  busses = intData[intData$timestamps == timestamp,]
  m <- leaflet() %>%
    addTiles() %>%
    setView(lng=174.768, lat=-36.852, zoom = 10)
  
  for (i in 1 :nrow(busses)) {
    m = m %>% addCircleMarkers(lng = busses$lon[i], 
                               lat = busses$lat[i], 
                               radius = 2,  # adjust the radius as you like
                               color = colours[busses$status[i] + 1],  # adjust the color as you like
                               fillOpacity = 0.8) 
  }
  
  m <- m %>% addControl(
    html = paste("Time:", time_display),
    position = "topright"
  )
  mapshot(m, file = paste0("images/m", timestamp, ".png"), delay = 1) # delay to ensure all tiles are loaded
  return(TRUE)
}

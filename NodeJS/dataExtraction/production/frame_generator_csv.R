frame_generator = function(timestamp) {
  colours = c('grey', 'blue', 'orange', 'red')
  
  posix_time = as.POSIXct(timestamp, origin = "1970-01-01", tz = "UTC")
  time_display <- format(posix_time, format = "%H:%M")
  
  busses = intData[intData$timestamps == timestamp,]
  
  bottom_left <- c(lon = 174.7, lat = -36.9)
  top_right <- c(lon = 174.9, lat = -36.8)
  
  m <- leaflet() %>%
    addTiles() %>%
    setView(lng=174.768, lat=-36.852, zoom = 10) 
  
  for (i in 1 :nrow(busses)) {
    m = m %>% addCircleMarkers(lng = busses$lon[i], 
                               lat = busses$lat[i], 
                               radius = 0.5,  # adjust the radius as you like
                               color = colours[busses$status[i] + 1],  # adjust the color as you like
                               fillOpacity = 0.2) 
  }
  
  m <- m %>% addControl(
    html = paste("Time:", time_display),
    position = "topright"
  )
  mapshot(m, file = paste0("images/m", timestamp, ".png"), delay = 1) # delay to ensure all tiles are loaded
  return(TRUE)
}

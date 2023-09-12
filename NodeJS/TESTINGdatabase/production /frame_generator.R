frame_generator = function(timestamp) {
  colours = c('grey', 'blue', 'orange', 'red')
  
  busses = dbGetQuery(con, paste0("SELECT longitude, 
                                  latitude, 
                                  status, 
                                  route
                                  FROM points_fps WHERE timestamp = ", timestamp))
  
  m <- leaflet() %>%
    addTiles() %>%
    setView(lng=174.768, lat=-36.852, zoom = 10)
  
  for (i in 1 :nrow(busses)) {
    m <- m %>% addCircleMarkers(lng = busses$longitude[i], 
                                lat = busses$latitude[i], 
                                radius = 3,  # adjust the radius as you like
                                color = colours[busses$status[i] + 1],  # adjust the color as you like
                                fillOpacity = 1) 
  }
  mapshot(m, file = paste0("/images/m", timestamp, ".png"), delay = 0.25) # delay to ensure all tiles are loaded
}




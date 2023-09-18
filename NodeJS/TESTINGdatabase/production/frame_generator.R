frame_generator = function(timestamp) {
  colours = c('grey', 'blue', 'orange', 'red')
  
  con = dbConnect(RPostgres::Postgres(),
                  dbname = "bus_trial",
                  port = 5432,
                  user = "postgres",
                  password = "postgres",
                  host = "localhost")
  
  # Ensure connection is always closed on exit
  on.exit(dbDisconnect(con), add = TRUE)
  
  busses = dbGetQuery(con, paste0("SELECT longitude, 
                                  latitude, 
                                  status, 
                                  route
                                  FROM points_fps WHERE timestamp = ", timestamp))
  
  # Check connection
  if (is.null(con) || !DBI::dbIsValid(con)) {
    stop(paste("Failed to connect to database for timestamp", timestamp))
  }
  
  m <- leaflet() %>%
    addTiles() %>%
    setView(lng=174.768, lat=-36.852, zoom = 10)
  
  for (i in 1 :nrow(busses)) {
    m <- m %>% addCircleMarkers(lng = busses$longitude[i], 
                                lat = busses$latitude[i], 
                                radius = 2,  # adjust the radius as you like
                                color = colours[busses$status[i] + 1],  # adjust the color as you like
                                fillOpacity = 0.8) 
  }
  mapshot(m, file = paste0("images/m", timestamp, ".png"), delay = 0.05) # delay to ensure all tiles are loaded
}

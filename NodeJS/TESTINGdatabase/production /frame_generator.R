frame_generator = function(timestamp) {
  
  busses = dbGetQuery(con, paste0("SELECT longitude, 
                                  latitude, 
                                  status, 
                                  route
                                  FROM points_fps WHERE timestamp = ", timestamp))
  return(busses)
}


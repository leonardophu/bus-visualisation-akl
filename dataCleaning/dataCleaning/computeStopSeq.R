compute_stop_sequences_unique = function(trip_data) {
  # Function to find the closest point and its stop_sequence for unique stop_sequences
  
  stop_times_coordinates = subset(stop_time_coords, trip_id == trip_data$trip_id[1])
  
  find_closest_stop = function(lat, lon) {
    distances = geosphere::distVincentySphere(
      p1 = c(lon, lat),
      p2 = stop_times_coordinates[, c("stop_lon", "stop_lat")]
    )
    closest_index = which.min(distances)
    closest_stop_sequence = stop_times_coordinates$stop_sequence[closest_index]
    closest_departure_time = stop_times_coordinates$departure_time[closest_index]
    return(list(stop_sequence = closest_stop_sequence, 
                departure_time = closest_departure_time))
  }
  
  # Add temporary columns with stop_sequence and departure_time information to trip_data
  trip_data = trip_data %>%
    rowwise() %>%
    mutate(result = list(find_closest_stop(lat, lng)),
           stop_sequence = result$stop_sequence,
           departure_time = result$departure_time) %>%
    select(-result)
  
  # Use dplyr to filter only the rows with unique stop_sequences and closest points
  unique_stop_sequences_data = trip_data %>%
    distinct(stop_sequence, .keep_all = TRUE)
  
  return(unique_stop_sequences_data)
}




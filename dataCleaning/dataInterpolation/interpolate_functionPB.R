# Interpolation of points
library(sf)

even_split = function(totalPoints, bin_size) {
  base_value = totalPoints %/% bin_size       # Integer division
  remainder = totalPoints %% bin_size         # Remainder
  
  # Create a vector filled with base values
  bins = rep(base_value, bin_size)
  
  # Add 1 to the first 'remainder' number of bins
  if (remainder > 0) {
    bins[1:remainder] = bins[1:remainder] + 1
  }
  
  return(array(bins, dim = length(bins)))
}

find_closest_point = function(lat, lon, shape_data){
  distances = distHaversine(matrix(c(lon, lat), ncol=2), 
                             shape_data[,c("shape_pt_lon", "shape_pt_lat")])
  return(which.min(distances))
}


interpolation = function(trip_data, date_) {
  start_time = as.numeric(as.POSIXct(paste0(date_, "04:00:00"), 
                                     format="%Y-%m-%d %H:%M:%S", tz="UTC"))
  end_time = as.numeric(as.POSIXct(paste0(date_, "23:59:59"), 
                                   format="%Y-%m-%d %H:%M:%S", tz="UTC"))
  
  tryCatch({
    # Date_obj is a global variable where we store the interpolated points at 
    storage_path = paste0("interpolation/", date_str, "/")
    shape_path = paste0("shapefiles/", date_str, "/")
    # Get the shape_id
    shape_id = unique(trip_data$shape_id)
    # Check if shape_id is NA
    if(is.na(shape_id) || shape_id == 0) {
      stop("No shape_id for trip_id:", trip_data$trip_id[1])
    }
    
    # Get the required shape
    shapes_file = read.csv(paste0(shape_path, shape_id, ".csv"))
    
    full_df = data.frame()
    for(i in 1:(nrow(trip_data) - 1)) {
      # Get the start and end position
      start = find_closest_point(trip_data$stop_lat[i], trip_data$stop_lon[i], shapes_file)
      end = find_closest_point(trip_data$stop_lat[i+1], trip_data$stop_lon[i+1], shapes_file)
      
      if (length(start > 1) || length(end > 1)) {
        #print(paste0("More than one matching row found for trip_data row: ", i))
        points_between = shapes_file[start[1]:end[length(end)], ] # Extract the rows
      } else {
        points_between = shapes_file[start:end,]
      }
      
      # Edge case that we have no start and end
      if (length(start) == 0 || length(end) == 0) {
        stop("Empty found for trip_data row: ", i)
      }
      
      # Road shape
      lines = st_sfc(st_linestring(as.matrix(points_between[,c("shape_pt_lon", "shape_pt_lat")])))
      # need to do difference time stamp + 1 to include original point. E.g. 10-5 = 5, 5,6,7,8,9,10
      interpolated_point = st_line_sample(lines, 
                                          sample = seq(0,
                                                       1, 
                                                       length.out = trip_data$timestamps[i+1] - trip_data$timestamps[i] + 1))
      
      # Store the dataframe
      df = data.frame(
        lat = st_coordinates(interpolated_point)[,2],
        lon = st_coordinates(interpolated_point)[,1]
      )
      # Get the respective timestamps
      df$timestamps = seq(trip_data$timestamps[i], trip_data$timestamps[i+1])
      
      # Bus status
      if (trip_data$status[i] != trip_data$status[i+1]) {
        # Number to put in each bin
        bins = even_split(trip_data$timestamps[i+1] - trip_data$timestamps[i] + 1, abs(trip_data$status[i] - trip_data$status[i+1]) + 1)
        # Replace status
        df$status = rep(seq(trip_data$status[i], trip_data$status[i+1]), times = bins)
      } else {
        df$status = rep(trip_data$status[i], length.out = trip_data$timestamps[i+1] - trip_data$timestamps[i] + 1)
      }
      # Combine the dataframes together
      full_df = rbind(full_df, df)
    }
    full_df = subset(full_df, timestamps >= start_time & timestamps <= end_time)
    write.csv(full_df, file = paste0(storage_path, trip_data$trip_id[1],".csv"), row.names = FALSE)
    
  }, error = function(e) {
    # Custom error message that prints the original error and the trip_id
    cat(paste("Error:", e$message, "for trip_id:", trip_data$trip_id[1], "\n"))
  })
}
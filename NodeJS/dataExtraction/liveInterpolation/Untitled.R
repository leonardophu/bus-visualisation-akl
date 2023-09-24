library(dplyr)

shape_path = "../shapefiles/"
trip_data = read.csv("../data/1010-98109-18000-2-fc6666b6.csv")

given_timestamp = c(1683262821, 1683264242)

find_values_dataframes <- function(X, Y) {
  # Assuming "timestamps" column is present in both dataframes
  x <- X$timestamps
  
  lower_bound <- max(x[x < min(y)])
  upper_bound <- min(x[x > max(y)])
  
  in_between <- X[X$timestamps >= lower_bound & X$timestamps <= upper_bound, ]
  return(in_between)
}

# Get the dataset required inside the given timerange
data = find_values_dataframes(trip_data, given_timestamp)
# Get the fulltimestamp needed
full_timestamps = seq(given_timestamp[1], given_timestamp[2])
# Put them into required intervals
intervals = findInterval(full_timestamps, data$timestamps)
# Split it all up into lists
split_timestamps = split(full_timestamps, intervals)

shapes_file = read.csv(paste0(shape_path, shape_id, ".csv"))

computeInterpolation = function(shapes_file, timestamps, subset_data) {
  start = which(shapes_file$shape_pt_lat == subset_data$stop_lat[1] & shapes_file$shape_pt_lon == subset_data$stop_lon[1])
  end = which(shapes_file$shape_pt_lat == subset_data$stop_lat[2] & shapes_file$shape_pt_lon == subset_data$stop_lon[2])
  
  if (length(start > 1) || length(end > 1)) {
    #print(paste0("More than one matching row found for trip_data row: ", i))
    points_between = shapes_file[start[1]:end[length(end)], ] # Extract the rows
  } else {
    points_between = shapes_file[start:end,]
  }
  
  lines = st_sfc(st_linestring(as.matrix(points_between[,c("shape_pt_lon", "shape_pt_lat")])))
  # Give a sample (the point we want in the map) given by maths (c-a) / (b-a) where c is our timestamp, 'b' is max timestamp 'a' is min timestamp in range
  
  sample_prop = (timestamps - subset_data$timestamps[1]) / (subset_data$timestamps[2] - subset_data$timestamps[1])
  print(sample_prop)
  interpolated_point = st_line_sample(lines, sample = sample_prop)
  
  df = data.frame(
    lat = st_coordinates(interpolated_point)[,2],
    lon = st_coordinates(interpolated_point)[,1]
  )
  df$timestamps = timestamps
  
  return(df)
}

for (i in 1:(nrow(data) - 1)){
  print(i)
  computeInterpolation(shapes_file, split_timestamps[[i]] , data[i:(i+1), ])
}


# Attempt to do live interpolation in R 

shape_path = "../shapefiles/"
trip_data = read.csv("../data/1010-98109-18000-2-fc6666b6.csv")
# Given one timestamp

given_timestamp = c(1683262821, 1683264242)
trip_data[trip_data$timestamps > given_timestamp,] %>% head(1)
shape_id = unique(trip_data$shape_id)
ranges = rbind(trip_data[trip_data$timestamps < given_timestamp,] %>% arrange(desc(stop_sequence)) %>% head(1),
      trip_data[trip_data$timestamps > given_timestamp,] %>% head(1))

shapes_file = read.csv(paste0(shape_path, shape_id, ".csv"))

# This would be put into a function lol 

start = which(shapes_file$shape_pt_lat == ranges$stop_lat[1] & shapes_file$shape_pt_lon == ranges$stop_lon[1])
end = which(shapes_file$shape_pt_lat == ranges$stop_lat[2] & shapes_file$shape_pt_lon == ranges$stop_lon[2])

if (length(start > 1) || length(end > 1)) {
  #print(paste0("More than one matching row found for trip_data row: ", i))
  points_between = shapes_file[start[1]:end[length(end)], ] # Extract the rows
} else {
  points_between = shapes_file[start:end,]
}

lines = st_sfc(st_linestring(as.matrix(points_between[,c("shape_pt_lon", "shape_pt_lat")])))

# Give a sample (the point we want in the map) given by maths (c-a) / (b-a) where c is our timestamp, 'b' is max timestamp 'a' is min timestamp in range
sample_prop = (given_timestamp - ranges$timestamps[1]) / (ranges$timestamps[2] - ranges$timestamps[1])

interpolated_point = st_line_sample(lines, sample = sample_prop)

df = data.frame(
  lat = st_coordinates(interpolated_point)[,2],
  lon = st_coordinates(interpolated_point)[,1]
)

df$timestamps = given_timestamp



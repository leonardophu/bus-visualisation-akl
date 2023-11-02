# Get all the interpolated files
intFiles = list.files(interpolate_path)

intPoints = data.frame()
# Load the interpolated files
load_file = function(x) {
  trip_id = gsub(".csv$", "", x)
  points = read.csv(paste0(interpolate_path, "/",x))
  if (nrow(points) == 0) {
    print(trip_id)
    return(data.frame())
  }
  points$trip_id = trip_id
  return(points)
}

# Use lapply to read each file into a data frame and add to a list
intFilesApply = lapply(intFiles, load_file)

# Combine the list of data frames into a single data frame
intPoints = do.call(rbind, intFilesApply)

# Get the trips.txt
trips = read.table(paste0(busInfoPath, "trips.txt"), header = TRUE, sep = ",", quote = "", fill = TRUE)
# Get the routes.txt
routes = read.table(paste0(busInfoPath, "routes.txt"), header = TRUE, sep = ",", quote = "", fill = TRUE)

# Get the route name for the data
trip_route = trips %>%
  select(trip_id, route_id, shape_id) %>%
  left_join(routes %>% select(route_id, route_short_name), by = c('route_id')) 

# Store all the interpolated data points as YYYY_MM_DD-interpolated_data.csv
intPoints = intPoints %>% left_join(trip_route %>% select(trip_id, route_short_name), by = c("trip_id"))
write.csv(intPoints, paste0(date_str,"-interpolated_data.csv"), row.names = FALSE)
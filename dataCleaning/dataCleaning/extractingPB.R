# Given the directory path, obtain all the files (we want vechile_locations)
files = list.files(path = directory_path, pattern = "^vehicle_locations_.*")

# Function that given a file name, will convert the pb to a dataframe
extractData = function(file_name) {
  a = read(transit_realtime.FeedMessage, file_name)
  pb_to_df(a)
}

# Function to convert pb file to a dataframe. Extracts all the columns of interest
pb_to_df <- function(feed) {
  ## converts protobuf GTFS file into a dataframe
  do.call(rbind, lapply(feed$entity, function(x) {
    data.frame(route_id = x$vehicle$trip$route_id,
               trip_id = x$vehicle$trip$trip_id,
               lat = x$vehicle$position$latitude,
               lng = x$vehicle$position$longitude,
               timestamp = x$vehicle$timestamp,
               start_time = x$vehicle$trip$start_time,
               stop_id = x$vehicle$stop_id,
               current_stop_sequence = x$vehicle$current_stop_sequence)
  }))
}

# Parallelisation 

# Determine the number of cores to use (minus 1 to leave one free)
num_cores <- detectCores() - 1

# Apply extractData function in parallel
dataframes_list <- mclapply(files, function(file_name) {
  extractData(paste0(directory_path, "/", file_name))
}, mc.cores = num_cores)

# Combine all the dataframes into one
system.time(raw_data  <- do.call(rbind, dataframes_list))


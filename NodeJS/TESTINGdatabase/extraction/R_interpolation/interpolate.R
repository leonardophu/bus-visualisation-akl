source("interpolate_function.R")

points_path = "../../data"

files = list.files(points_path)

# List to store the time taken for each file
time_taken_list <- list()

date_ = "2023-05-05"

runInterpolation = function() {
  # Loop through each file
  for(file_name in files) {
    # Read the file
    trip_data <- read.csv(paste0(points_path, "/", file_name))
    interpolation(trip_data, date_)
  }
}

system.time(runInterpolation())





# In parallisation 

# Define function to process a single file
processFile = function(file_name) {
  # Read the file
  trip_data = read.csv(paste0(points_path, "/", file_name))
  interpolation(trip_data, date_)
  return(TRUE)
}

# Determine the number of cores to use
no_cores = detectCores() - 1  

# Use mclapply to run the function in parallel
results = mclapply(files, processFile, mc.cores = no_cores)

# Measure time taken
system.time({
  results = mclapply(files, processFile, mc.cores = no_cores)
})





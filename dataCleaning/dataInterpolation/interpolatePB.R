files = list.files(data_paths)

# List to store the time taken for each file
time_taken_list <- list()

# In parallisation 

# Define function to process a single file
processFile = function(file_name) {
  # Read the file
  trip_data = read.csv(paste0(data_paths, "/", file_name))
  interpolation(trip_data, date_obj)
  return(TRUE)
}

# Determine the number of cores to use
no_cores = detectCores() - 1  

# Use mclapply to run the function in parallel
results = mclapply(files, processFile, mc.cores = no_cores)


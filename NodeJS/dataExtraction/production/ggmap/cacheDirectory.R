library(httr)
library(png)  # Add this line to load the png package

# Define a cache directory
cache_dir <- "../map_cache/"

# Create the directory if it doesn't exist
if (!dir.exists(cache_dir)) {
  dir.create(cache_dir)
}

# Function to download and cache a map
download_and_cache_map <- function(bbox, zoom, maptype) {
  # Generate a unique filename based on the parameters
  filename <- paste0(cache_dir, "map_", paste0(c(bbox, zoom, maptype), collapse = "_"), ".png")
  
  # Check if the map image is already cached
  if (!file.exists(filename)) {
    # If not cached, download the map
    map_url <- sprintf("http://maps.stamen.com/%s/%.6f/%.6f/%.6f.png", maptype, zoom, bbox[1], bbox[2])
    map_response <- GET(map_url)
    
    # Check if the download was successful
    if (status_code(map_response) == 200) {
      # Save the downloaded map image to the cache directory
      map_content <- content(map_response, "raw")
      writeBin(map_content, filename)
    } else {
      # Handle download error, e.g., print an error message
      cat("Failed to download the map.\n")
    }
  }
  
  # Load the map image from the cache
  map <- readPNG(filename)
  return(map)
}


          
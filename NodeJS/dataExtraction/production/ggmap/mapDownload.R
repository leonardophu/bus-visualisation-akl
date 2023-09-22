# Example usage:
bbox <- c(174.51351991992968, -37.16610140560065, 175.4871832621358, -36.498361075414714)
zoom_level <- 11
maptype <- 'terrain'

# Download and cache the map
auckland_map <- download_and_cache_map(bbox, zoom_level, maptype)
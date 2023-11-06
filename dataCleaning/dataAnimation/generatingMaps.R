library(ggmap)

# Add in your API Key given from goggle
api_key = "YOUR API KEY"
register_google(key = api_key)

# Generate Auckland Outer Map
auckland_map = get_map(location = c(lon = 174.9678300285132, 
                                    lat = -36.855924425978934), 
                       zoom = 10, maptype = "roadmap")

# Generate Auckland Zoomed Map
zoomed_map = get_map(location = c(lon = 174.75241956819966, 
                                  lat = -36.88119270303182), 
                     zoom = 13, maptype = "roadmap")
ggmap(zoomed_map)

# Fill in the file path where you want to store the maps
save(zoomed_map, file = "zoomed file path")
save(auckland_map, file = "auckland file path")


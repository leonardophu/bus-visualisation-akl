# Adding custom font for the text
font_add_google("Oswald", family = "oswald")
showtext_auto()

# Get the interpolated data set
intData = fread(paste0(date_of_data, "-interpolated_data.csv"))
intData$status = factor(intData$status)

# Get the maps from the mapDataPath
load(paste0(mapDataPath, 'auckland_map.RData'))
load(paste0(mapDataPath, 'auckland_central.RData'))

# Boundry box for ggmap zoomed in 
bbox2 = attr(auckland_central, "bb")

# Colour scheme to show bus status on map.
colour_scheme <- c("0" = "#595656", "1" = "blue", "2" = "orange", "3" = "red")

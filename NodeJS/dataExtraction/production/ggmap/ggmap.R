#https://www.google.com/maps/@-36.9524217,174.9131067,11.51z?entry=ttu
#https://www.google.com/maps/@-36.8494455,174.9989783,11z?entry=ttu

#-37.16610140560065, 174.51351991992968 , -36.498361075414714, 175.4871832621358

library(ggmap)
library(ggplot2)
library(data.table)

bbox = c(174.51351991992968, -37.16610140560065, 175.4871832621358, -36.498361075414714)
zoom_level = 11
colour_scheme <- c("0" = "grey", "1" = "blue", "2" = "orange", "3" = "red")



intData = fread("Desktop/bus-visualisation-akl/NodeJS/dataExtraction/R_interpolation/interpolated_data.csv")

getFrame = function(timestamp) {
  timed_data = subset(intData, timestamp == timestamp)
  
}
# Get the map using the specified center and zoom
auckland_map = get_stamenmap(bbox, zoom = zoom_level, maptype = 'terrain')

ggmap(auckland_map) + geom_point(data = testing, aes(x = lon, y= lat, color = status), size = 1) +
  scale_color_manual(values = colour_scheme) +
  
  # Remove x and y axes
  theme(axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        
        # Remove the legend
        legend.position = "none")



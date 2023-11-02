library(ggmap)
library(ggplot2)
library(data.table)
library(grid)
library(dplyr)
library(showtext)
library(parallel)
library(gggrid)
library(av)

# Contains the path that stores the map.RData
mapDataPath = 'mapData/'
# Set up date of data
date_of_data = '2020_03_21'
# The file path where we want to store the frames for animation. I'm doing it by animation/YYYY_MM_DD/MissingLateFrames/
frame_path =  paste0("animation/", date_of_data, "/MissingFrames/")
# Set animation type
# There are two "Late" or "Missing"
animation_type = "Missing"




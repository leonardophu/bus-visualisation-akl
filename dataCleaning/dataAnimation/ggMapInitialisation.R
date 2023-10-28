library(ggmap)
library(ggplot2)
library(data.table)
library(grid)
library(dplyr)
library(showtext)
library(parallel)
library(gggrid)
library(av)

mapDataPath = 'mapData/'
date_of_data = '2020_03_21'
frame_path =  paste0("animation/", date_of_data, "/MissingFrames/")
# "Late", "Missing"
animation_type = "Missing"




#https://www.google.com/maps/@-36.9524217,174.9131067,11.51z?entry=ttu
#https://www.google.com/maps/@-36.8494455,174.9989783,11z?entry=ttu

#-37.16610140560065, 174.51351991992968 , -36.498361075414714, 175.4871832621358

# ZOOMED IN 
#https://www.google.com/maps/@-36.8612228,174.7658703,15z?entry=ttu
# -36.88331495682457, 174.69149797930748 -36.83943341709491, 174.8454353098962
# -36.88300601996546, 174.71623867157618 -36.83723524397908, 174.7994086071811



#source('cacheDirectory.R')
library(ggmap)
library(ggplot2)
library(data.table)
library(grid)
source('ggmapFrame.R')

bbox = c(174.51351991992968, -37.16610140560065, 175.4871832621358, -36.498361075414714)
bbox2 = c(174.71623867157618, -36.88300601996546, 174.7994086071811, -36.83723524397908)
zoom_level_full = 11
zoom_level_min = 15
auckland_map = get_stamenmap(bbox, zoom = zoom_level_full, maptype = 'terrain')
auckland_central = get_stamenmap(bbox2, zoom = zoom_level_min, maptype = 'terrain')

colour_scheme <- c("0" = "black", "1" = "blue", "2" = "orange", "3" = "red")

intData = fread("Desktop/bus-visualisation-akl/NodeJS/dataExtraction/R_interpolation/interpolated_data.csv")
intData$status = factor(intData$status)

time_seq = seq(range(intData$timestamps)[1], range(intData$timestamps)[2])

getFrame(time_seq[31000])

grid.newpage()


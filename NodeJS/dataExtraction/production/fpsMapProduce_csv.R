library(data.table)
library(leaflet)
library(parallel)
library(magick)
library(mapview)
library(foreach)
library(av)

intData = fread("../extraction/R_interpolation/interpolated_data.csv")

source('step_generator_csv.R')
source('frame_generator_csv.R')
source('map_production_csv.R')

createMap(20,60) 
runMap(20)
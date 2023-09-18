library(leaflet)
library(DBI)
library(RODBC)
library(odbc)
library(mapview)
library(parallel)
library(magick)
library(foreach)
library(doParallel)

source('step_generator.R')
source('frame_generator.R')
source('map_production.R')

# Initalise to do parallelisatoin
numCores <- detectCores()
cl <- makeCluster(numCores)
registerDoParallel(cl)
# Allow cluster to make their frames
clusterExport(cl, "frame_generator")
system.time(createMap(20, 60))
stopCluster(cl)
runMap()

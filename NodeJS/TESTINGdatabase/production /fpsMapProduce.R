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

# Initalise to do parallelisatoin
numCores <- detectCores()
cl <- makeCluster(numCores)
registerDoParallel(cl)
# Allow cluster to make their frames
clusterExport(cl, "frame_generator")

createMap = function(fps, seconds) {
  # Clearing the images folder
  files_to_remove <- list.files(path = "images/", pattern = "m*.png", full.names = TRUE)
  if (length(files_to_remove) > 0) {
    file.remove(files_to_remove)
  }
  
  # Creating the image
  steps = step_generator(fps, seconds)
  
  # Parallelization using foreach
  foreach(step=steps, .packages=c("leaflet", "DBI", "RODBC", "odbc", "mapview")) %dopar% {
    frame_generator(step)
  }
}

system.time(createMap(20, 60))
stopCluster(cl)

runMap = function(loop = 0, fps = 20) {
  img <- image_read(list.files(path = "images/", pattern="m*.png", full.names = TRUE))
  animation = image_animate(img, loop = loop, optimize = TRUE, fps = fps)
  image_write(animation, "images/animation.gif")
  animation 
}

runMap()

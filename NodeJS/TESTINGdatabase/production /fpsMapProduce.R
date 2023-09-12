library(leaflet)
library(DBI)
library(RODBC)
library(odbc)
library(mapview)

source('connection.R')
source('step_generator.R')
source('frame_generator.R')

createMap = function(fps, seconds) {
  # Clearing the images folder
  files_to_remove <- list.files(path = "images/", pattern = "m*.png", full.names = TRUE)
  if (length(files_to_remove) > 0) {
    file.remove(files_to_remove)
  }
  
  # Creating the image
  steps = step_generator(fps, seconds)
  for(timestamp in steps) {
    frame_generator(timestamp)
  }
  
  library(magick)
  img <- image_read(list.files(path = "images/", pattern="m*.png", full.names = TRUE))
  image_animate(img, loop = 1, optimize = TRUE, fps = 20)
}

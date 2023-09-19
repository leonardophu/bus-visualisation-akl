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

runMap = function(loop = 0, fps = 20) {
  img <- image_read(list.files(path = "images/", pattern="m*.png", full.names = TRUE))
  animation = image_animate(img, loop = loop, optimize = TRUE, fps = fps)
  image_write(animation, "images/animation.gif")
  animation 
}

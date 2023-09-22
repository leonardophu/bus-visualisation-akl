createMap = function(fps = 1, seconds = 60, numCores = NA) {
  # Clearing the images folder
  files_to_remove <- list.files(path = "images/", pattern = "m*.png", full.names = TRUE)
  if (length(files_to_remove) > 0) {
    file.remove(files_to_remove)
  }
  
  # Creating the image
  steps = step_generator(fps, seconds)
  
  # User pre-specificed cores
  if (is.na(numCores)) {
    numCores = detectCores() 
  }
  done = mclapply(steps, frame_generator, mc.cores = numCores)
}

runMap = function(fps = 1,loop = 0) {
  file_names <- list.files(path = "images/", pattern = "m*.png", full.names = TRUE)
  file_names <- sort(file_names)
  
  # Use av_encode_video to create a movie
  av_encode_video(file_names, output = "images/animation.mp4", framerate = fps)
  invisible(NULL) # Do not return anything 
}

createMaps = function(fps, seconds) {
  # Clearing the images folder
  files_to_remove <- list.files(path = "frames/", pattern = "m*.png", full.names = TRUE)
  if (length(files_to_remove) > 0) {
    file.remove(files_to_remove)
  }
  
  time_seq = step_generator(fps, seconds)
  cores = detectCores() 
  generate_frames = mclapply(time_seq, getFrame, mc.cores = cores)
}

runMap = function(fps = 1,loop = 0) {
  file_names <- list.files(path = "frames/", pattern = "m*.png", full.names = TRUE)
  file_names <- sort(file_names)
  
  # Use av_encode_video to create a movie
  av_encode_video(file_names, output = "frames/animation.mp4", framerate = fps)
  invisible(NULL) # Do not return anything 
}
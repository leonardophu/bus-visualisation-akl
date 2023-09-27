createMaps = function(fps, seconds, filepath = "frames/", frametype = "Late") {
  
  if (!(frametype %in% c("Missing", "Late"))) {
    stop("frametype must be 'Missing' or 'Late'")
  }
  
  # Clearing the images folder
  files_to_remove <- list.files(path = filepath, pattern = "m*.png", full.names = TRUE)
  if (length(files_to_remove) > 0) {
    file.remove(files_to_remove)
  }
  
  time_seq = step_generator(fps, seconds)
  cores = detectCores() 
  
  generate_function <- switch(frametype,
                              "Late" = getFrameLate,
                              "Missing" = getFrameMissing)
  
  generate_frames = mclapply(time_seq, function(x) generate_function(x, filepath), mc.cores = cores)
}



runMap = function(fps = 1,loop = 0, filepath = "frames/") {
  file_names <- list.files(path = filepath, pattern = "m*.png", full.names = TRUE)
  file_names <- sort(file_names)
  
  # Use av_encode_video to create a movie
  av_encode_video(file_names, output = paste0(filepath, "animation.mp4"), framerate = fps)
  invisible(NULL) # Do not return anything 
}
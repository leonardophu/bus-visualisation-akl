createMaps = function(fps, seconds, filepath = "frames/", frametype = "Late") {
  
  # If the frametype isn't missing or late, send error message
  if (!(frametype %in% c("Missing", "Late"))) {
    stop("frametype must be 'Missing' or 'Late'")
  }
  
  # Clearing the images folder
  files_to_remove = list.files(path = filepath, pattern = "\\.(png|mp4)$", full.names = TRUE)
  if (length(files_to_remove) > 0) {
    file.remove(files_to_remove)
  }
  
  # Get the requried timestamps for animation
  time_seq = step_generator(fps, seconds)
  cores = detectCores() 
  
  # Depending on user input, get the right function to generate frames
  generate_function = switch(frametype,
                              "Late" = getFrameLate,
                              "Missing" = getFrameMissing)
  
  # Generate frames in parallel
  generate_frames = mclapply(time_seq, function(x) generate_function(x, filepath), mc.cores = cores)
}

# Given the fps we want to display the image (and the file path the frames are stored)
runMap = function(fps = 1, filepath = "frames/") {
  # Get files names of the frames (note I called my frames 'mTimestamp.png', change pattern according to how you stored the data)
  file_names = list.files(path = filepath, pattern = "m*.png", full.names = TRUE)
  file_names = sort(file_names)
  
  # Use av_encode_video to create a movie
  av_encode_video(file_names, output = paste0(filepath, "animation.mp4"), framerate = fps)
  invisible(NULL) # Do not return anything 
}
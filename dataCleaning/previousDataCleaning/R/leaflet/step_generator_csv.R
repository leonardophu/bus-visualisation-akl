step_generator = function(fps = 1, seconds = 60) {
  time_range = range(intData$timestamps)
  
  total_frames = fps * seconds 
  
  # Sequential timestamps to extract
  per_timestamp = abs(diff(time_range)) / total_frames
  
  # Whole numbers don't account for the end
  if (per_timestamp %% 1 == 0) {
    steps = seq(time_range[1], time_range[2], per_timestamp)
  } else {
    # add final frame which is the end of the day
    
    #Round the per timestamp up and include the last point 
    per_timestamp = ceiling(per_timestamp)
    steps = c(seq(time_range[1], time_range[2], per_timestamp), time_range[2])
  }
  return(steps)
}

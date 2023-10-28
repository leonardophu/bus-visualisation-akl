timestamp_conversion = function(x) {
  useful_date = date_obj
  timestamps = paste(useful_date,x)
  timestamps = ymd_hms(timestamps, tz = "UTC")
  timestamps = as.numeric(timestamps)
  timestamps = timestamps  + utc_diff*3600
  return(timestamps)
}

getLessData = function(data) {
  if(is.na(data)) {
    return(FALSE)
  } else {
    if (data < 0) return(TRUE)
    else return(FALSE)
  }
}

getEqualData = function(data) {
  if(is.na(data)) {
    return(FALSE)
  } else {
    if (data == 0) return(TRUE)
    else return(FALSE)
  }
}


problemLess = function(bus_data) {
  bus_data = bus_data %>%
    group_by(trip_id) %>%
    arrange(trip_id, timestamp_altered) %>%
    mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence))
  # Extract the problem data
  
  problem_data = bus_data[sapply(bus_data$diff_stop_sequence, getLessData), ]
  problem_id = unique(problem_data$trip_id)
  
  problem_set = subset(bus_data, trip_id %in% problem_id)
  
  # Clean the problem dataset - ask Thomas should I even clean this like what I have done before! 
  
  cleaned_problem = subset(problem_set, delay > - 1700 & delay < 3200)
  # Remove observations which stop_sequence is after another. 
  cleaned_problem = cleaned_problem[is.na(cleaned_problem$diff_stop_sequence) | cleaned_problem$diff_stop_sequence >= 0, ]
  
  # Then combine the dataset all together
  ids = unique(bus_data$trip_id)
  other_ids = ids[!ids %in% problem_id]
  valid_data = subset(bus_data, trip_id %in% other_ids)
  bus_data = rbind(cleaned_problem,valid_data)
  
  return(bus_data)
}



# Can have a problem where 35,37,35 need to first remove 37, then remove 35
problemEqual = function(bus_data) {
  bus_data = bus_data %>%
    group_by(trip_id) %>%
    arrange(trip_id, timestamp_altered) %>%
    mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence))
  
  # Get the problem data when there are sequences that are the same 
  pe = bus_data[sapply(bus_data$diff_stop_sequence, getEqualData), ]$trip_id
  
  #problem_equal = subset(bus_data, trip_id %in% pe) %>% 
  #  select(trip_id, delay, act_arrival_time_date,stop_sequence, diff_stop_sequence)
  
  problem_equal = subset(bus_data, trip_id %in% pe) 
  
  # The way to fix this issue is going to remove all the observations after the FIRST one
  # Essentially just remove the 0's
  
  cleaned_equal = problem_equal[is.na(problem_equal$diff_stop_sequence) | problem_equal$diff_stop_sequence != 0, ]
  
  # Take the cleaned equal ids and the problem set ids and combine together! 
  # Then combine the dataset all together
  ids = unique(bus_data$trip_id)
  other_ids = ids[!ids %in% pe]
  valid_data = subset(bus_data, trip_id %in% other_ids)
  bus_data = rbind(cleaned_equal,valid_data)
  return(bus_data)
}


problemLead = function(bus_data) {
  bus_data = bus_data %>%
    group_by(trip_id) %>%
    arrange(trip_id, timestamp_altered) %>%
    mutate(lead_stop_sequence = lead(stop_sequence) - stop_sequence)
  
  problem_data = bus_data[sapply(bus_data$lead_stop_sequence, getLessData), ]
  problem_id = unique(problem_data$trip_id)
  
  problem_set = subset(bus_data, trip_id %in% problem_id)
  # Remove observations which stop_sequence is after another. 
  cleaned_problem = problem_set[is.na(problem_set$lead_stop_sequence) | problem_set$lead_stop_sequence >= 0, ]
  # Then combine the dataset all together
  ids = unique(bus_data$trip_id)
  other_ids = ids[!ids %in% problem_id]
  valid_data = subset(bus_data, trip_id %in% other_ids)
  bus_data = rbind(cleaned_problem,valid_data)
  return(bus_data)
}

# Function to get required rows within each group
getPointsExceed = function(data, time_col = "departure_time") {
  before_24 = data %>% 
    filter(!!sym(time_col) <= '24:00:00')
  
  # If before_24 is empty, return an empty data frame
  if(nrow(before_24) == 0) {
    return(data.frame())
  }
  
  after_24_closest = data %>% 
    filter(!!sym(time_col) > '24:00:00') %>%
    arrange(!!sym(time_col)) %>%
    head(1)
  
  return(rbind(before_24, after_24_closest))
}

# Function to get the first and last rows for teh dataset
getRemainingSequence = function(tripData) {
  
  # This code already assumes you have the date and make sure we get the times that are valid! 
  
  fullSequence = subset(stop_times, trip_id == tripData$trip_id[1])
  # Ensures we get that extra bit! 
  fullSequence = getPointsExceed(fullSequence)
  # Checks to see if we got the start of the sequence
  if (min(tripData$stop_sequence) != 1) {
    
    # Get the dataset that has the first and earliest stop sequence
    first_sequence = subset(fullSequence, stop_sequence %in% c(1, min(tripData$stop_sequence)))
    # Get the difference in time stamps
    first_sequence$timestamps = timestamp_conversion(first_sequence$departure_time)
    
    #T Then we need to get the first stop lat and lon
    first_stop_loc = which(first_sequence$stop_sequence == 1)
    
    first_stop = first_sequence$stop_id[first_stop_loc]
    
    first_stop = subset(stops, stop_id == first_stop)
    
    # Difference between the new times 
    diff_time = abs(first_sequence$timestamps[2] - first_sequence$timestamps[1])
    
    
    first_data_point = data.frame(trip_id = tripData$trip_id[1], 
                                  shape_id = tripData$shape_id[1],
                                  timestamps = tripData$timestamps[1] - diff_time,
                                  status = tripData$status[1], 
                                  stop_lat = first_stop$stop_lat,
                                  stop_lon = first_stop$stop_lon, 
                                  route_id = tripData$route_id[1],
                                  route_short_name = tripData$route_short_name[1],
                                  stop_sequence = 1)
    tripData = rbind(first_data_point, tripData)
  }
  
  
  # Might need to fix this code
  
  # We want to specifically do less than. This is because of the edge case that a stop sequence is delayed but ends up at a very late time 
  if (max(tripData$stop_sequence) < max(fullSequence$stop_sequence)) {
    
    # Create a dataframe which has the last stop sequence and the stop sequence we have in dataset
    
    last_sequence = subset(fullSequence, stop_sequence %in% c(max(fullSequence$stop_sequence), max(tripData$stop_sequence)))

    # Convert to right format
    last_sequence$timestamps = timestamp_conversion(last_sequence$departure_time)
    
    # THen get the stop lat and lon for that stop
    last_stop_loc = which(last_sequence$stop_sequence == max(fullSequence$stop_sequence))
    
    last_stop = last_sequence$stop_id[last_stop_loc]
    
    last_stop = subset(stops, stop_id == last_stop)
    
    # Get the difference
    diff_time = abs(last_sequence$timestamps[2] - last_sequence$timestamps[1])
    
    last_data_point = data.frame(trip_id = tripData$trip_id[1], 
                                 shape_id = tripData$shape_id[1],
                                 # Add the additional time 
                                 timestamps = tripData$timestamps[nrow(tripData)] + diff_time,
                                 status = tripData$status[nrow(tripData)], 
                                 stop_lat = last_stop$stop_lat,
                                 stop_lon = last_stop$stop_lon, 
                                 route_id = tripData$route_id[1],
                                 route_short_name = tripData$route_short_name[1],
                                 stop_sequence = max(fullSequence$stop_sequence))
    tripData = rbind(tripData, last_data_point)
  }
  # Just to make sure we return when the stop_sequence is arranged correctly! 
  return(tripData %>% arrange(stop_sequence))
}
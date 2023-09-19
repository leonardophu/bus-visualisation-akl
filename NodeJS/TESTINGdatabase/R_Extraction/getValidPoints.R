# ASSUMES WE HAVE RAN processedData

# Convert to POSIXct
minimum_time =  as.numeric(as.POSIXct(paste(date_, "04:00:00"), format="%Y-%m-%d %H:%M:%S", tz="UTC"))

timestamp_conversion = function(x) {
  useful_date = date_
  timestamps = paste(useful_date,x)
  timestamps = ymd_hms(timestamps, tz = "UTC")
  timestamps = as.numeric(timestamps)
  timestamps = timestamps  + 12*3600
  return(timestamps)
}

# Remove duplicates that have same group and arrival date
arrival_bus <- arrival_bus %>%
  group_by(trip_id, stop_sequence) %>%
  filter(act_arrival_time_date == max(act_arrival_time_date)) %>%
  ungroup()

# Get only buses that are after 4 am
arrival_bus = subset(arrival_bus, as.numeric(format(act_arrival_time_date, "%H")) >= 4)

# Want to group our observations by the actual arrival time and the trip_id 
arrival_bus = arrival_bus %>%
  group_by(trip_id) %>%
  arrange(trip_id, act_arrival_time) %>%
  mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence),
         lead_stop_sequence = lead(stop_sequence) - stop_sequence)

# There are cases when the difference in stop_sequence is 0. If this is the case we have problems
any(arrival_bus$diff_stop_sequence <= 0)

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

problemLess = function(arrival_bus) {
  arrival_bus = arrival_bus %>%
    group_by(trip_id) %>%
    arrange(trip_id, act_arrival_time) %>%
    mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence))
  # Extract the problem data
  
  problem_data = arrival_bus[sapply(arrival_bus$diff_stop_sequence, getLessData), ]
  problem_id = unique(problem_data$trip_id)
  
  problem_set = subset(arrival_bus, trip_id %in% problem_id)
  
  # Clean the problem dataset - ask Thomas should I even clean this like what I have done before! 
  
  cleaned_problem = subset(problem_set, delay > - 1700 & delay < 3200)
  # Remove observations which stop_sequence is after another. 
  cleaned_problem = cleaned_problem[is.na(cleaned_problem$diff_stop_sequence) | cleaned_problem$diff_stop_sequence >= 0, ]
  
  # Then combine the dataset all together
  ids = unique(arrival_bus$trip_id)
  other_ids = ids[!ids %in% problem_id]
  valid_data = subset(arrival_bus, trip_id %in% other_ids)
  arrival_bus = rbind(cleaned_problem,valid_data)
  
  return(arrival_bus)
}

arrival_bus = problemLess(arrival_bus)

# Can have a problem where 35,37,35 need to first remove 37, then remove 35
problemEqual = function(arrival_bus) {
  arrival_bus = arrival_bus %>%
    group_by(trip_id) %>%
    arrange(trip_id, act_arrival_time) %>%
    mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence))
  
  # Get the problem data when there are sequences that are the same 
  pe = arrival_bus[sapply(arrival_bus$diff_stop_sequence, getEqualData), ]$trip_id
  
  #problem_equal = subset(arrival_bus, trip_id %in% pe) %>% 
  #  select(trip_id, delay, act_arrival_time_date,stop_sequence, diff_stop_sequence)
  
  problem_equal = subset(arrival_bus, trip_id %in% pe) 
  
  # The way to fix this issue is going to remove all the observations after the FIRST one
  # Essentially just remove the 0's
  
  cleaned_equal = problem_equal[is.na(problem_equal$diff_stop_sequence) | problem_equal$diff_stop_sequence != 0, ]
  
  # Take the cleaned equal ids and the problem set ids and combine together! 
  # Then combine the dataset all together
  ids = unique(arrival_bus$trip_id)
  other_ids = ids[!ids %in% pe]
  valid_data = subset(arrival_bus, trip_id %in% other_ids)
  arrival_bus = rbind(cleaned_equal,valid_data)
  return(arrival_bus)
}

arrival_bus = problemEqual(arrival_bus)

problemLead = function(arrival_bus) {
  arrival_bus = arrival_bus %>%
    group_by(trip_id) %>%
    arrange(trip_id, act_arrival_time) %>%
    mutate(lead_stop_sequence = lead(stop_sequence) - stop_sequence)
  
  problem_data = arrival_bus[sapply(arrival_bus$lead_stop_sequence, getLessData), ]
  problem_id = unique(problem_data$trip_id)
  
  problem_set = subset(arrival_bus, trip_id %in% problem_id)
  # Remove observations which stop_sequence is after another. 
  cleaned_problem = problem_set[is.na(problem_set$lead_stop_sequence) | problem_set$lead_stop_sequence >= 0, ]
  # Then combine the dataset all together
  ids = unique(arrival_bus$trip_id)
  other_ids = ids[!ids %in% problem_id]
  valid_data = subset(arrival_bus, trip_id %in% other_ids)
  arrival_bus = rbind(cleaned_problem,valid_data)
  return(arrival_bus)
}

arrival_bus = problemLead(arrival_bus)

arrival_bus = arrival_bus %>%
  group_by(trip_id) %>%
  arrange(trip_id, act_arrival_time) %>%
  mutate(lead_stop_sequence = lead(stop_sequence) - stop_sequence, 
         diff_stop_sequence = stop_sequence - lag(stop_sequence))


# We see that this should be 0. As there should not be any ids that the less and equal have the same! 
unique(arrival_bus[sapply(arrival_bus$diff_stop_sequence, getLessData), ]$trip_id)
unique(arrival_bus[sapply(arrival_bus$diff_stop_sequence, getEqualData), ]$trip_id)
unique(arrival_bus[sapply(arrival_bus$lead_stop_sequence, getLessData), ]$trip_id)

# Now we can combine all the data together! Want 
# valid_data (data that was already right!)
# cleaned_data (data that has been cleaned)

# Columns I want for interpolation 
# ("trip_id", "shape_id", "timestamps", "status", "stop_lat", "stop_lon", "route_id", "route_short_name")

# For non-cancelled trips we need to get the dataset
non_cancelled_trips = arrival_bus
# For places that don't have a shape_id nor lats or lon, we can get them. 
non_cancelled_trips = left_join(non_cancelled_trips, stop_times, by = c("trip_id", "stop_id", "stop_sequence"))
non_cancelled_trips = left_join(non_cancelled_trips, trips %>% select(trip_id, shape_id), by = c("trip_id"))

# Seems like something is wrong here!! Need to ask Thomas Lumley
any(is.na(non_cancelled_trips$shape_id.y))
unique(non_cancelled_trips[is.na(non_cancelled_trips$shape_id.y),]$route_short_name)


# For non-cancelled trips we need to put in the first and last point
nc = non_cancelled_trips %>% select(trip_id, shape_id.x, timestamps, status, stop_lat, stop_lon, route_id, route_short_name, stop_sequence)

colnames(nc)[2] = "shape_id"

# We doing this for now until we fix it! 
nc_hs = subset(nc, !is.na(shape_id))

# Get the nc_hs that has the required time 
nc_hs = nc_hs[nc_hs$timestamps >= minimum_time,]

splitted_nc_hs = split(nc_hs, nc_hs$trip_id)

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
    print(last_sequence)
    # Convert to right format
    last_sequence$timestamps = timestamp_conversion(last_sequence$departure_time)
    
    # THen get the stop lat and lon for that stop
    last_stop_loc = which(last_sequence$stop_sequence == max(fullSequence$stop_sequence))
    
    last_stop = last_sequence$stop_id[last_stop_loc]
    
    last_stop = subset(stops, stop_id == last_stop)
    
    # Get the difference
    diff_time = abs(last_sequence$timestamps[2] - last_sequence$timestamps[1])
    print(diff_time)
    
    print("error")
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

library(parallel)
# Want to use all the cores we have 
cores = detectCores()
# Want to run using parallisation since it saves us alot of times! Would estimate around 9 minutes to complete if we were doing single core 
valid_dataframes =  mclapply(splitted_nc_hs, getRemainingSequence, mc.cores=cores) 
valid_dataframes = do.call(rbind, valid_dataframes) 

source('businfoextraction.R')

t = full_bus_data

# We have complete cases 
any(rowSums(is.na(full_bus_data)) == length(colnames(full_bus_data)))

# Get the day make sure it matches 
day <- format(full_bus_data$act_arrival_time_date, "%d")
# Get the day here we are working the 5th
our_day = "05"

# Get the cancelled buses
cancelled_bus = full_bus_data[full_bus_data$cancelled == TRUE, ]
# Get the unqiue IDS 
ids = unique(cancelled_bus$trip_id)

cancelled_trips = trips[trips$trip_id %in% ids,]
cancelled_trips = cancelled_trips %>% select(route_id, trip_id, shape_id)

cancelled_trips = left_join(cancelled_trips, stop_times %>% select(trip_id, departure_time, stop_sequence, stop_id), by = c("trip_id"))
cancelled_trips = left_join(cancelled_trips, stops %>% select(stop_id, stop_lat, stop_lon), by = c("stop_id"))
cancelled_trips = left_join(cancelled_trips, routes %>% select(route_id, route_short_name), by = c("route_id"))

# Subsetted trips
cancelled_trips = subset(cancelled_trips, departure_time < "24:00:00")

timestamp_conversion = function(x) {
  timestamps = paste(date_,x)
  timestamps = ymd_hms(timestamps, tz = "UTC")
  timestamps = as.numeric(timestamps)
  timestamps = timestamps  + 12*3600
  return(timestamps)
}

# Converting the timestamps into seconds
# Paste the required date
cancelled_trips$timestamps = timestamp_conversion(cancelled_trips$departure_time)

cancelled_trips$status = 0
# Now dealing with the non cancelled trips 

# Get the day make sure it matches 
day <- format(full_bus_data$act_arrival_time_date, "%d")
# Get the day here we are working the 5th
our_day = "05"

arrival_bus = subset(full_bus_data, day == our_day)
arrival_bus = arrival_bus[arrival_bus$cancelled == FALSE, ]

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
  mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence))

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

# Extract the problem data
problem_data = arrival_bus[sapply(arrival_bus$diff_stop_sequence, getLessData), ]
problem_id = unique(problem_data$trip_id)

problem_set = subset(arrival_bus, trip_id %in% problem_id)

# Clean the problem dataset - ask Thomas should I even clean this like what I have done before! 

cleaned_problem = subset(problem_set, delay > - 1700 & delay < 3200)

# Remove observations which stop_sequence is after another. 
cleaned_problem = cleaned_problem[is.na(cleaned_problem$diff_stop_sequence) | cleaned_problem$diff_stop_sequence >= 0, ]

# Get the problem data when there are sequences that are the same 
pe = arrival_bus[sapply(arrival_bus$diff_stop_sequence, getEqualData), ]$trip_id

#problem_equal = subset(arrival_bus, trip_id %in% pe) %>% 
#  select(trip_id, delay, act_arrival_time_date,stop_sequence, diff_stop_sequence)

problem_equal = subset(arrival_bus, trip_id %in% pe) 

# Check for anamolies 
unique(subset(problem_equal, delay > 3000)$trip_id)
hist(problem_equal$delay)

# The way to fix this issue is going to remove all the observations after the FIRST one
# Essentially just remove the 0's

cleaned_equal = problem_equal[is.na(problem_equal$diff_stop_sequence) | problem_equal$diff_stop_sequence != 0, ]

# Take the cleaned equal ids and the problem set ids and combine together! 

cleaned_data = rbind(cleaned_equal, cleaned_problem)

# Take the trip_id of the cleaned data, we want to ignore these now.
cleaned_ids = unique(cleaned_data$trip_id)
other_ids = unique(arrival_bus$trip_id)[!unique(arrival_bus$trip_id) %in% cleaned_ids]

# Double checkign for any ideas that might have leaked through 
valid_data = subset(arrival_bus, trip_id %in% other_ids)

# We see that this should be 0. As there should not be any ids that the less and equal have the same! 
unique(valid_data[sapply(valid_data$diff_stop_sequence, getLessData), ]$trip_id)
unique(valid_data[sapply(valid_data$diff_stop_sequence, getEqualData), ]$trip_id)

# This shows that there's no intercept between the two problem sets.
any(pe %in% problem_id)
any(problem_id %in% pe)

# Now we can combine all the data together! Want 
# valid_data (data that was already right!)
# cleaned_data (data that has been cleaned)
# cancelled_trips (trips that were cancelled!)

# Columns I want for interpolation 
# ("trip_id", "shape_id", "timestamps", "status", "stop_lat", "stop_lon", "route_id", "route_short_name")

# For non-cancelled trips we need to get the dataset
non_cancelled_trips = rbind(cleaned_data, valid_data)
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

splitted_nc_hs = split(nc_hs, nc_hs$trip_id)


# Function to get the first and last rows for teh dataset
getRemainingSequence = function(tripData) {
  
  # This code already assumes you have the date and make sure we get the times that are valid! 
  fullSequence = subset(stop_times, trip_id == tripData$trip_id[1] & departure_time < "24:00:00")
  
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

library(parallel)
# Want to use all the cores we have 
cores = detectCores()
# Want to run using parallisation since it saves us alot of times! Would estimate around 9 minutes to complete if we were doing single core 
processed_dataframes =  mclapply(splitted_nc_hs, getRemainingSequence, mc.cores=cores) 
processed_dataframes = do.call(rbind, processed_dataframes) 


c = cancelled_trips %>% select(trip_id, shape_id, timestamps, status, stop_lat, stop_lon, route_id, route_short_name, stop_sequence)

# This should be the complete dataset! 
complete_dataset = rbind(processed_dataframes, c)
complete_dataset = complete_dataset %>% group_by(trip_id) %>% arrange(trip_id, stop_sequence) 

write.csv(complete_dataset, file = "complete_data.csv", row.names = FALSE)

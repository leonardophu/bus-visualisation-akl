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
non_cancelled_trips[is.na(non_cancelled_trips$shape_id.y),]$route_short_name

non_cancelled_trips %>% select(trip_id, shape_id, act_arrival_time_date, status, stop_lat, stop_lon, route_id, route_short_name)


cancelled_trips %>% select(trip_id, shape_id, timestamps, status, stop_lat, stop_lon, route_id, route_short_name)


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

# Converting the timestamps into seconds
# Paste the required date
cancelled_trips$timestamps = paste(date_,cancelled_trips$departure_time)
# Convert the time to UTC
cancelled_trips$timestamps = ymd_hms(cancelled_trips$timestamps, tz = "UTC")
cancelled_trips$timestamps = as.numeric(cancelled_trips$timestamps)
# Then add 12 hours since for some reason it's 12 hours behind 
cancelled_trips$timestamps = cancelled_trips$timestamps  + 12*3600


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

# Clean the problem dataset 

cleaned_problem = subset(problem_set, delay > - 1700 & delay < 3200)
# Remove observations which are after another one. 
cleaned_problem = subset(cleaned_problem, diff_stop_sequence >= 0)



# Get the problem data when there are sequences that are the same 
pe = arrival_bus[sapply(arrival_bus$diff_stop_sequence, getEqualData), ]$trip_id
problem_equal = subset(arrival_bus, trip_id %in% pe) %>% select(trip_id, delay, act_arrival_time_date,stop_sequence, diff_stop_sequence)
# Check for anamolies 
unique(subset(problem_equal, delay > 3000)$trip_id)
hist(problem_equal$delay)

# Check for anamolies 

# Cases when there's only one observation
unique(subset(problem_equal, delay < -1000)$trip_id)
subset(problem_equal, trip_id == unique(subset(problem_equal, delay < -1000)$trip_id)[13])

subset(problem_equal, trip_id == unique(trip_id)[20])

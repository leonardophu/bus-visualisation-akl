missing_timestamp_conversion = function(dates, times) {
  # Convert strings to dates and hms (hours, minutes, seconds) objects
  useful_dates <- as.Date(dates)
  time_objects <- hms(times)
  
  # Extract hours from time_objects and calculate additional days
  additional_days <- floor(hour(time_objects) / 24)
  
  # Update the hours by taking modulo 24 and dates by adding additional_days
  hours_updated <- hour(time_objects) %% 24
  useful_dates <- useful_dates + additional_days
  
  # Construct new HMS objects and combine with dates
  new_times <- sprintf("%02d:%02d:%02d", hours_updated, minute(time_objects), second(time_objects))
  timestamps <- ymd_hms(paste(useful_dates, new_times), tz = "UTC")
  
  # Convert to numeric and return
  as.numeric(timestamps)
}

# These are all the ids which have points
valid_ids = unique(valid_dataframes$trip_id)

# Get the day of the week
day_of_week = tolower(weekdays(as.Date(date_obj)))

# Get the ids that buses within the day
validTrips = trips %>% left_join(calendar, by = c("service_id"))
valid_index = which(validTrips[[day_of_week]] == 1)
validTrips = validTrips[valid_index,]

# trip_route contains all the buses that are missing within the day

trip_route = validTrips %>%
  select(trip_id, route_id, shape_id) %>%
  left_join(routes %>% select(route_id, route_short_name), by = c('route_id')) %>%
  filter(!(route_short_name %in% trains) &
           !(route_short_name %in% ships) &
           !(trip_id %in% valid_ids))

# Now using the dates, get the busses that are on that time!

missingPoints = subset(stop_times, trip_id %in% trip_route$trip_id)

# Function to get required rows within each group
getPointsExceed <- function(data) {
  before_24 <- data %>% 
    filter(departure_time <= '24:00:00')
  
  # If before_24 is empty, return an empty data frame
  if(nrow(before_24) == 0) {
    return(data.frame())
  }
  
  after_24_closest <- data %>% 
    filter(departure_time > '24:00:00') %>%
    arrange(departure_time) %>%
    head(1)
  
  return(rbind(before_24, after_24_closest))
}

missingPoints = missingPoints %>% 
  group_by(trip_id) %>% 
  group_modify(~ getPointsExceed(.x))

# Converting the timestamps into seconds

# Paste the required date
missingPoints$timestamps = missing_timestamp_conversion(date_obj, missingPoints$departure_time)

missingPoints <- missingPoints %>% 
  left_join(stops %>% select(stop_id, stop_lat, stop_lon), by = "stop_id") %>%
  left_join(trip_route, by = "trip_id") %>% 
  select(trip_id, shape_id, timestamps, stop_lat, stop_lon, route_id, route_short_name, stop_sequence)

missingPoints$status = 0 

full_data = rbind(missingPoints, valid_dataframes)
full_data = full_data[is.na(full_data$timestamps) == FALSE,]

# Doing final checks, make sure we get the data for the required date
full_data = full_data %>% group_by(trip_id) %>% arrange(trip_id, stop_sequence) 

write.csv(full_data, file = paste0(date,"-complete_data.csv"), row.names = FALSE)
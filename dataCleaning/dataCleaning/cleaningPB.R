# Get all PB data that has a trip_id

raw_data = subset(raw_data, trip_id != "")

# Cleaning stop_times

duplicates_exist <- any(duplicated(stop_times[, c("trip_id", "arrival_time")]))
#print(duplicates_exist)  # Will print TRUE if duplicates exist, FALSE otherwise

duplicated_rows <- stop_times[duplicated(stop_times[, c("trip_id", "arrival_time")], fromLast = FALSE) | 
                                duplicated(stop_times[, c("trip_id", "arrival_time")], fromLast = TRUE), ]
#print(duplicated_rows)

# Remove duplicate rows

stop_times = stop_times %>%
  group_by(trip_id, arrival_time) %>%
  filter(stop_sequence == min(stop_sequence)) %>%
  ungroup()


raw_data <- subset(raw_data, !duplicated(raw_data))

stop_time_coords = stop_times %>% left_join(stops, by = c("stop_id"))

raw_data_split = split(raw_data, raw_data$trip_id)

# Parallelisation

num_cores = 10
cl = makeCluster(num_cores)
clusterExport(cl, c("compute_stop_sequences_unique", "raw_data_split", "stop_time_coords"))
raw_data_clean = mclapply(raw_data_split, function(trip_data) {
  compute_stop_sequences_unique(trip_data)
}, mc.cores = num_cores)
stopCluster(cl)

raw_data_clean = do.call(rbind, raw_data_clean)

# Remove duplicate rows

full_bus_data = raw_data_clean %>%
  left_join(routes %>% select("route_id", "route_short_name"), 
            by = c("route_id" = "route_id")) %>% 
  left_join(trips %>% select("trip_id", "shape_id"),
            by = c("trip_id" = "trip_id"))


# Removing duplicates
full_bus_data = distinct(full_bus_data)

# We only want busses, these were found to be non busses 
trains = c("QODTAK", "WEST", "EAST", "STH", "HUIA", "ONE")
ships = c("PINE", "BAYS", "BIRK", "HMB", "HOBS", "RAK", "RANG", "MTIA", "DEV", "WSTH", "GULF", "CORO")

full_bus_data = subset(full_bus_data, !route_short_name %in% c(trains, ships))

full_bus_data = subset(full_bus_data, is.na(shape_id) == FALSE)

# Compute delay. Please double check the dataset if we are UTC + 12 or UTC + 13, this case its UTC + 13

full_bus_data$timestamp_altered = full_bus_data$timestamp + utc_diff*3600

# If we look at thsi code, it the times should be close together
#full_bus_data$timestamp_altered_date = as.POSIXct(full_bus_data$timestamp_altered, origin = "1970-01-01", tz = "UTC")

full_bus_data$expected_timestamp = paste0(gsub("_", "-", date), " ", full_bus_data$departure_time)
full_bus_data$expected_timestamp = as.numeric(as.POSIXct(full_bus_data$expected_timestamp, format="%Y-%m-%d %H:%M:%S", tz="UTC"))

full_bus_data$delay = full_bus_data$timestamp_altered - full_bus_data$expected_timestamp

# Playing around with data
full_bus_data$status = ifelse(full_bus_data$delay < 300, 1,
                              ifelse(full_bus_data$delay < 600, 2, 3))

full_bus_data = subset(full_bus_data, !(delay <= -3600 | delay >= 3600))

# Getting all the data for that specific date
full_bus_data$day = as.Date(as.POSIXct(full_bus_data$timestamp_altered, origin="1970-01-01", tz="UTC"))
full_bus_data = subset(full_bus_data, day == date_obj & start_time >= "04:00:00" & start_time < "24:00:00")

arrival_bus = full_bus_data

arrival_bus = arrival_bus %>%
  group_by(trip_id) %>%
  arrange(trip_id, timestamp_altered) %>%
  mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence),
         lead_stop_sequence = lead(stop_sequence) - stop_sequence)

# There are cases when the difference in stop_sequence is 0. If this is the case we have problems
any(arrival_bus$diff_stop_sequence <= 0)

# Remove stop sequences that are too ahead (lag)
arrival_bus = problemLess(arrival_bus)
# Remove stop sequences that are the same (equal)
arrival_bus = problemEqual(arrival_bus)
# Remove stop sequences that are too behind (lead)
arrival_bus = problemLead(arrival_bus)

# To double check
arrival_bus = arrival_bus %>%
  group_by(trip_id) %>%
  arrange(trip_id, timestamp_altered) %>%
  mutate(lead_stop_sequence = lead(stop_sequence) - stop_sequence, 
         diff_stop_sequence = stop_sequence - lag(stop_sequence))

# We see that this should be 0. As there should not be any ids that the less and equal have the same! 
unique(arrival_bus[sapply(arrival_bus$diff_stop_sequence, getLessData), ]$trip_id)
unique(arrival_bus[sapply(arrival_bus$diff_stop_sequence, getEqualData), ]$trip_id)
unique(arrival_bus[sapply(arrival_bus$lead_stop_sequence, getLessData), ]$trip_id)

# Columns I want for interpolation 
# ("trip_id", "shape_id", "timestamps", "status", "stop_lat", "stop_lon", "route_id", "route_short_name")

non_cancelled_trips = arrival_bus

any(is.na(non_cancelled_trips$shape_id))

nc = non_cancelled_trips %>% select(trip_id, shape_id, timestamp_altered, status, lat, lng, route_id, route_short_name, stop_sequence)
colnames(nc)[c(3,5,6)] <- c('timestamps', "stop_lat", "stop_lon")

splitted_nc_hs = split(nc, nc$trip_id)

# Want to use all the cores we have 
cores = detectCores()
# Want to run using parallisation since it saves us alot of times! Would estimate around 9 minutes to complete if we were doing single core 
valid_dataframes =  mclapply(splitted_nc_hs, getRemainingSequence, mc.cores=cores) 
valid_dataframes = do.call(rbind, valid_dataframes) 
# Extract buses

source('businfoextraction.R')

bus75 = subset(full_bus_data, route_short_name == "24B")
data75 = bus75 %>% group_by(trip_id) %>% arrange(trip_id, act_arrival_time)
trial = subset(data75, trip_id == "24-02404-64020-2-64484aca")
trial$timestamps = trial$arrival_fixed
send = trial %>% select("trip_id", "shape_id", "timestamps", "status", "stop_lat", "stop_lon", "route_id", "route_short_name")
write.csv(send, file = "bus24B.csv", row.names = FALSE)

trial_data = subset(full_bus_data, trip_id == "1010-98109-23400-2-96dc00c8")
trial_data$timestamps = trial_data$arrival_fixed
send = trial_data %>% select("trip_id", "shape_id", "timestamps", "status", "stop_lat", "stop_lon", "route_id")
write.csv(send, file = "testing.csv", row.names = FALSE)


trial_data = subset(full_bus_data, trip_id == "1010-98109-23400-2-96dc00c8")

shape_data = subset(shapes, shape_id == "1010-98109-d221c68a")


View(trips)

View(full_bus_data)

# Want to group our observations by the actual arrival time and the trip_id 
full_bus_data <- full_bus_data %>%
    group_by(trip_id) %>%
    arrange(trip_id, act_arrival_time) %>%
    mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence))

# Remove any cases that has NA's for all columns 
full_bus_data <- full_bus_data[complete.cases(full_bus_data), ]

# There are cases when the difference in stop_sequence is 0. If this is the case we have problems
any(full_bus_data$diff_stop_sequence < 0)

# Extract the problem data
problem_data = full_bus_data[full_bus_data$diff_stop_sequence < 0, ]




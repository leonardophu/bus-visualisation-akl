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


# Getting the data 

t = full_bus_data
full_bus_data = t

# Remove any cases that has NA's for all columns 
#full_bus_data <- full_bus_data[complete.cases(full_bus_data), ]

# We have complete cases 
any(rowSums(is.na(full_bus_data)) == length(colnames(full_bus_data)))

#Only focus the days we are intersted in 
full_bus_data = full_bus_data[day == date, ]

cancelled_bus = full_bus_data[full_bus_data$cancelled == TRUE, ]

# Get the day make sure it matches 
day <- format(full_bus_data$act_arrival_time_date, "%d")
# Get the day here we are working the 5th
our_day = "05"

arrival_bus = full_bus_data[day == our_day, ]
arrival_bus = arrival_bus[arrival_bus$cancelled == FALSE, ]

# Remove duplicates that have same group and arrival date
arrival_bus <- arrival_bus %>%
  group_by(trip_id, stop_sequence) %>%
  filter(act_arrival_time_date == max(act_arrival_time_date)) %>%
  ungroup()

# Get only buses that are after 4 am
arrival_bus = subset(arrival_bus, as.numeric(format(act_arrival_time_date, "%H")) >= 4)

# Want to group our observations by the actual arrival time and the trip_id 
arrival_bus <- arrival_bus %>%
    group_by(trip_id) %>%
    arrange(trip_id, act_arrival_time) %>%
    mutate(diff_stop_sequence = stop_sequence - lag(stop_sequence))

# There are cases when the difference in stop_sequence is 0. If this is the case we have problems
any(full_bus_data$diff_stop_sequence < 0)

getLessData = function(data) {
  if(is.na(data)) {
    return(FALSE)
  } else {
    if (data < 0) return(TRUE)
    else return(FALSE)
  }
}

# Extract the problem data
problem_data = arrival_bus[sapply(arrival_bus$diff_stop_sequence, getLessData), ]
problem_id = unique(problem_data$trip_id)

# See that some observations have multiple same stop_sequence and trip_id but are ruining our results to fix this issue we will take the time that is the latest arrival time 
format(subset(arrival_bus, trip_id == problem_id[10])$act_arrival_time_date, "%d")
subset(arrival_bus, trip_id == problem_id[2])


# Solve the issue with busses with no lat or lon -> These are because they have no shape_id. we can get that easily! 
missing_coords = subset(arrival_bus, is.na(stop_lon) == TRUE | is.na(stop_lat) == TRUE)
missing_id = unique(missing_coords$trip_id)

# This is the dataset we would like to deal with 
norm = subset(arrival_bus, !(trip_id %in% missing_id) & !(trip_id %in% problem_id))
any(is.na(norm$stop_sequence))
any(is.na(norm$stop_lon))
any(is.na(norm$stop_lat))
# We still have some missing shape_ids
any(is.na(norm$shape_id))

# To fix this issue, we will try and join the shapes file iwth the norms and missing_coords dataset 
processed_data = left_join(arrival_bus, trips %>% select(trip_id, shape_id), by = "trip_id")

# Check if all shape_ids are equal from the cirrent one
avaliable = processed_data[is.na(processed_data$shape_id.x) == FALSE, ]
# All were the same. This leads me confidence that we can just use the one we have joined from the original tables!! 
all(avaliable$shape_id.x == avaliable$shape_id.y)
# It appears that there is no stop_ids that are null 
any(is.na(avaliable$stop_id))

# Now want to check if the avaliable data that we have, has correct stop_seq, stop_id, trip_id
nrow(inner_join(avaliable, stop_times %>% select(trip_id, stop_id, stop_sequence), by = c("trip_id", "stop_id", "stop_sequence")))
nrow(avaliable)

matched = inner_join(avaliable, stop_times %>% select(trip_id, stop_id, stop_sequence), by = c("trip_id", "stop_id", "stop_sequence"))
# Observations which don't appear on both
umatched = anti_join(avaliable, matched, by = c("trip_id", "stop_id", "stop_sequence"))

# After finish data exploration lets get the dataset! 



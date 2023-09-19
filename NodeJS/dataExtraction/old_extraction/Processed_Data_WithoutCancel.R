# Extracting data another way

# Bus extraction 
library(tidyverse)
library(leaflet)
library(jsonlite)
library(httr)

key = "567bb1fb7ab64582905c7812648075e1"

# Directory of bus 
busInfoPath = "../businfo/"
# Get all the data together
date_= "2023-05-05"
# 
dates_dir <- paste("..", date_, sep = "/")

#Reading in static files 
stops = read.table(paste0(busInfoPath,"stops.txt"), header = TRUE, sep = ",", quote = "")

stop_times = read.table(paste0(busInfoPath,"stop_times.txt"), header = TRUE, sep = ",", quote = "")

trips = read.table(paste0(busInfoPath,"trips.txt"), header = TRUE, sep = ",", quote = "", fill = TRUE)

routes = read.table(paste0(busInfoPath,"routes.txt"), header = TRUE, sep = ",", quote = "")

shapes = read.table(paste0(busInfoPath,"shapes.txt"), header = TRUE, sep = ",", quote = "")

stop_times = stop_times %>% mutate(stop_code = substring(stop_id, 1, regexpr("-", stop_id)[1] - 1))

# Original time 
seconds = function(x) {
  return(as.numeric(difftime(x, ymd_h("1970-01-01"), units = "secs")))
}

extract_data = function(trip_updates){
  trip_content = trip_updates[[2]][[2]]   # All the required information is in a nested list
  
  # Null check is a function that checks if a feature for an entity (individual buses) exist, if they don't we will replace that column as NA 
  null_check = function(x) if(is.null(x)) NA else x
  
  # Filtering for invalid trip ID entries
  trips = trips %>% filter(trip_id != "trip_id")
  
  # Extracting all relevant columns from the trip_updates GTFS file.
  trip_data = as.data.frame(do.call(rbind, lapply(trip_content, 
                                                  function(x) c(null_check(x$trip_update$trip$trip_id[[1]][1]),
                                                                null_check(x$trip_update$trip$direction_id),
                                                                null_check(x$trip_update$trip$route_id),
                                                                null_check(x$trip_update$stop_time_update$stop_id),
                                                                null_check(x$trip_update$trip$schedule_relationship),
                                                                null_check(x$trip_update$delay), 
                                                                null_check(x$trip_update$stop_time_update$stop_sequence),
                                                                null_check(x$trip_update$stop_time_update$arrival$time),
                                                                null_check(x$trip_update$stop_time_update$arrival$delay),
                                                                null_check(x$trip_update$stop_time_update$departure$time),
                                                                null_check(x$trip_update$stop_time_update$departure$delay)
                                                  ))))
  
  trip_data = as.data.frame(lapply(trip_data, unlist))    # Converting to data frame
  
  # Setting column names
  colnames(trip_data) = c("trip_id", 
                          "direction_id", 
                          "route_id", 
                          "stop_id", 
                          "schedule_relationship", 
                          "delay", 
                          "stop_sequence", 
                          "act_arrival_time", 
                          "arrival_delay", 
                          "act_departure_time", 
                          "act_departure_delay")
  
  trip_data$stop_sequence = as.integer(trip_data$stop_sequence)   # Fixing stop sequence type
  
  
  bus_arrivals_full = trip_data %>% 
    left_join(stop_times %>% 
                select("trip_id", "stop_sequence", "arrival_time", "departure_time"), 
              by = c("trip_id" = "trip_id", "stop_sequence" = "stop_sequence")) %>%
    left_join(stops %>% select("stop_id", "stop_lat", "stop_lon"), 
              by = c("stop_id" = "stop_id")) %>%
    left_join(routes %>% select("route_id", "route_short_name"), 
              by = c("route_id" = "route_id")) %>% 
    left_join(trips %>% select("trip_id", "shape_id"),
              by = c("trip_id" = "trip_id"))
  
  return(bus_arrivals_full)
}

full_bus_data <- data.frame()
# Getting unique times for each specific date
times <- list.files(dates_dir, recursive = FALSE)

# Loop to get dataset
for(time in times) {
  
  # For a given time for a given day, go into that file directory
  dates_time_dir <- paste(dates_dir, time, sep = "/")
  trip_updates <- read_json(paste(dates_time_dir, "tripupdates.json", sep = "/"))
  
  # Get the required dataset for a given day 
  date_time_data <- extract_data(trip_updates)
  
  # Store the date the data was collected
  date_time_data$date <- date_
  
  # Combine date_time_data with the existing combined_data
  full_bus_data <- rbind(full_bus_data, date_time_data)
}

# Creating day of week column
full_bus_data <- full_bus_data %>% 
  mutate(day_of_week = wday(as.Date(date, format = "%Y-%m-%d"), label = TRUE)) 

# Removing duplicates
full_bus_data = distinct(full_bus_data)

# We only want busses, these were found to be non busses 
trains = c("QODTAK", "WEST", "EAST", "STH", "HUIA", "ONE")
ships = c("PINE", "BAYS", "BIRK", "HMB", "HOBS", "RAK", "RANG", "MTIA", "DEV", "WSTH", "GULF")

full_bus_data = subset(full_bus_data, !route_short_name %in% c(trains, ships))

# Some rows don't have both arrival and departure time. If we don't have both, we assume they are the same
full_bus_data$act_arrival_time = ifelse(is.na(full_bus_data$act_arrival_time) == TRUE & is.na(full_bus_data$act_departure_time) == FALSE, 
                                        full_bus_data$act_departure_time, 
                                        full_bus_data$act_arrival_time)

full_bus_data$act_departure_time = ifelse(is.na(full_bus_data$act_arrival_time) == FALSE & is.na(full_bus_data$act_departure_time) == TRUE,  
                                          full_bus_data$act_arrival_time, 
                                          full_bus_data$act_departure_time)

full_bus_data = subset(full_bus_data, !(is.na(stop_id) == TRUE & is.na(stop_sequence) == TRUE & is.na(act_arrival_time) == TRUE & is.na(stop_lat) == TRUE & is.na(stop_lon) == TRUE & is.na(departure_time) == TRUE))

# Now we want to convert the arrival time
#full_bus_data$arrival_time = paste(date_,full_bus_data$arrival_time)
#full_bus_data$arrival_time = ymd_hms(full_bus_data$arrival_time, tz = "UTC")
#full_bus_data$arrival_time = as.numeric(full_bus_data$arrival_time)
#full_bus_data$arrival_time = full_bus_data$arrival_time + 12*3600

# NZ we are UTC + 12 so got to add another 12 hours! 
full_bus_data$timestamps = full_bus_data$act_arrival_time + 12*3600
full_bus_data$act_arrival_time_date = as.POSIXct(full_bus_data$timestamps, origin = "1970-01-01", tz = "UTC")

# Playing around with data
full_bus_data$status = ifelse(full_bus_data$delay < 300, 1,
                                  ifelse(full_bus_data$delay < 600, 2, 3))

# Now dealing with the non cancelled trips 

# Get the day make sure it matches 
day <- format(full_bus_data$act_arrival_time_date, "%d")

# Get the day here we are working the 5th. Not perfect for days like 31 etc.
our_day = as.integer("05")

arrival_bus = subset(full_bus_data, day != our_day - 1 & day != our_day - 2)


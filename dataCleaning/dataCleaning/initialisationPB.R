library(parallel)
library(RProtoBuf)
library(dplyr)
library(lubridate)
library(geosphere)
readProtoFiles("gtfs-realtime.proto")

# Store the date of the data set
date = "2020_03_21"
# Date obj converts date to a date object, change according to how date is stored
date_obj = as.Date(gsub("_", "-", date), format="%Y-%m-%d")
# Directory path to where the dataset is (for me my directory is archive_YYYY_MM_DD)
directory_path = paste0("archive_", date)
# Directory path to the static files. For example, mine is in (bus_info/..)
busInfoPath = paste0('bus_info/', date, "/")
# UTC difference might differ per each date. Sometimes it's 12 (03_21) or 13! 
utc_diff = 12

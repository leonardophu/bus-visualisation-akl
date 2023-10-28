library(parallel)
library(RProtoBuf)
library(dplyr)
library(lubridate)
library(geosphere)
readProtoFiles("gtfs-realtime.proto")

date = "2020_03_21"
date_obj = as.Date(gsub("_", "-", date), format="%Y-%m-%d")

directory_path = paste0("archive_", date)

# UTC difference might differ per each date. Sometimes it's 12 (03_21) or 13! 
utc_diff = 12
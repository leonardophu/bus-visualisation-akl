library(DBI)
library(RODBC)
library(odbc)
library(sf)
library(dplyr)
library(parallel)
library(geosphere)

# Insert Date 
date_str = '2020_03_21'
# This will convert our formated date into YYYY-MM-DD, feel free to ignore
date_obj = gsub("_", "-", date_str)
# Directory to the file that we will store the SHAPE CSVs
shape_paths = paste0("shapefiles/", date_str)
# Directory to the file that we will store the RAW CSVs
data_paths = paste0("data/", date_str)
# Directory to the file that has the static files
busInfoPath = paste0('bus_info/', date_str, "/")
# Directory to the file that has the complete dataset
complete_data = read.csv(paste0(date_str, "-complete_data.csv"))
# Directory to the file that will store the INTERPOLATED CSVs
interpolate_path = paste0("interpolation/", date_str)

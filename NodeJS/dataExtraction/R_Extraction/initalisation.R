# Initialisation 

# Library Packages
library(tidyverse)
library(leaflet)
library(jsonlite)
library(httr)

# Key 
key = "567bb1fb7ab64582905c7812648075e1"

# Directory of bus 
busInfoPath = "../businfo/"

# Get all the required date information
date_= "2023-05-05"
dataInfoPath <- paste("..", date_, sep = "/")
# Get the day here we are working the 5th. Not perfect for days like 31 etc.
our_day = as.integer("05")
library(leaflet)
library(DBI)
library(RODBC)
library(odbc)

source('connection.R')
source('step_generator.R')
source('frame_generator.R')



m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R") %>%
  setView(lng=174.768, lat=-36.852, zoom = 10.5)
m  # Print the map
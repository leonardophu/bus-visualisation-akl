library(leaflet)
library(DBI)
library(RODBC)
library(odbc)
 
# Accessing databse
con = dbConnect(RPostgres::Postgres(),
                   dbname = "bus_trial",
                   port = 5432,
                   user = "postgres",
                   password = "postgres",
                   host = "localhost")


step_generator = function(fps = 1, seconds = 60) {
  
  total_frames = fps * seconds
  time_range = dbGetQuery(con, 'SELECT MIN(timestamp) AS "min", 
                          MAX(timestamp) AS "max", 
                          MAX(timestamp) - MIN(timestamp) AS "range"
                          FROM points_fps')
  
  
  # Sequential timestamps to extract
  per_timestamp = ceiling(time_range$range / total_frames)
  
  # Whole numbers don't account for the end
  if (per_timestamp %% 1 == 0) {
    steps = seq(time_range$min, time_range$max, per_timestamp)
  } else {
    steps = c(seq(time_range$min, time_range$max, per_timestamp), time_range$max)
  }
  print(steps)
}

step_generator()



m <- leaflet() %>%
  addTiles() %>%  # Add default OpenStreetMap map tiles
  addMarkers(lng=174.768, lat=-36.852, popup="The birthplace of R") %>%
  setView(lng=174.768, lat=-36.852, zoom = 10.5)
m  # Print the map
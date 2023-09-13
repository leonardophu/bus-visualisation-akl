step_generator = function(fps = 1, seconds = 60) {
  
  con = dbConnect(RPostgres::Postgres(),
                  dbname = "bus_trial",
                  port = 5432,
                  user = "postgres",
                  password = "postgres",
                  host = "localhost")
  
  total_frames = fps * seconds
  time_range = dbGetQuery(con, 'SELECT MIN(timestamp) AS "min", 
                          MAX(timestamp) AS "max", 
                          MAX(timestamp) - MIN(timestamp) AS "range"
                          FROM points_fps')
  DBI::dbDisconnect(con)
  
  
  # Sequential timestamps to extract
  per_timestamp = ceiling(time_range$range / total_frames)
  
  # Whole numbers don't account for the end
  if (per_timestamp %% 1 == 0) {
    steps = seq(time_range$min, time_range$max, per_timestamp)
  } else {
    # add final frame which is the end of the day
    steps = c(seq(time_range$min, time_range$max, per_timestamp), time_range$max)
  }
  return(steps)
}

# Goal of this code was to insert the interpolated points [[lat1, lon1], ..]

library(data.table)
library(RPostgreSQL)
library(dplyr)
library(parallel)

d = fread("interpolated_data.csv")

trip_list = split(d, d$trip_id)

insert_database = function(trip_data) {
  con = dbConnect(RPostgres::Postgres(),
                  dbname = "bus_trial",
                  port = 5432,
                  user = "postgres",
                  password = "postgres",
                  host = "localhost")
  
  df_transformed = trip_data %>%
    summarise(
      int_points = paste0('{', paste(sprintf('{%f,%f}', lon, lat), collapse=','), '}'),
      bus_status = sprintf("{%s}", paste(status, collapse=",")),
      start_time = first(timestamps),
      bus_number = first(route_short_name)
    ) %>%
    ungroup()
  
  dbWriteTable(con, "points", df_transformed, append=TRUE, row.names=FALSE)
  dbDisconnect(con)
}

d %>% 
  group_by(trip_id) %>% 
  group_walk(~insert_database(.x))




# Get separate files
library(DBI)
library(RODBC)
library(odbc)
library(sf)

shape_paths = "../shapefiles"
data_paths = "../data"

complete_data <- read.csv("../R_Extraction/complete_data.csv")
trip_id_groups <- split(complete_data, complete_data$trip_id)

for (trip_id in names(trip_id_groups)) {
  filename <- paste0(data_paths,"/", trip_id, ".csv")
  write.csv(trip_id_groups[[trip_id]], file = filename, row.names = FALSE)
}

con = dbConnect(RPostgres::Postgres(),
                dbname = "bus_trial",
                port = 5432,
                user = "postgres",
                password = "postgres",
                host = "localhost")


routes = dbGetQuery(con, "SELECT * FROM shapes")

dbDisconnect(con)

route_groups <- split(routes, routes$shape_id)

for (shape_id in names(route_groups)) {
  filename <- paste0(shape_paths,"/", shape_id, ".csv")
  write.csv(route_groups[[shape_id]], file = filename, row.names = FALSE)
}

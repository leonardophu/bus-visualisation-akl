# testing 
#Reading in static files 
library(DBI)
library(RODBC)
library(odbc)
library(tidyverse)

trips = read.table("../businfo/trips.txt", header = TRUE, sep = ",", quote = "", fill = TRUE)

shapes = read.table("../businfo/shapes.txt", header = TRUE, sep = ",", quote = "")

con = dbConnect(RPostgres::Postgres(),
                dbname = "bus_trial",
                port = 5432,
                user = "postgres",
                password = "postgres",
                host = "localhost")
trip_interpolate = dbGetQuery(con, 'SELECT trip_id, count(*) AS "ticount"
                                    FROM points_fps
                                    GROUP BY trip_id
                                    order by count(*) desc')
shape_count = dbGetQuery(con, "SELECT shape_id, count(*) from shapes GROUP BY shape_id")

dbDisconnect(con)

t_s = trips %>% select(trip_id, shape_id)
trip_interpolate
shape_count

whole = inner_join(inner_join(t_s, trip_interpolate, by = 'trip_id'), shape_count, by = 'shape_id')

whole$ratio = whole$ticount / whole$count

hist(whole$ratio)

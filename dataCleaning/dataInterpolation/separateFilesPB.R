# Assumes we have run initialisationInterpolation and has shapefile

trip_id_groups = split(complete_data, complete_data$trip_id)

for (trip_id in names(trip_id_groups)) {
  filename <- paste0(data_paths,"/", trip_id, ".csv")
  write.csv(trip_id_groups[[trip_id]], file = filename, row.names = FALSE)
}

shapes = read.table(paste0(busInfoPath,"shapes.txt"), header = TRUE, sep = ",", quote = "")

shape_groups <- split(shapes, shapes$shape_id)

for (shape_id in names(shape_groups)) {
  filename <- paste0(shape_paths,"/", shape_id, ".csv")
  write.csv(shape_groups[[shape_id]], file = filename, row.names = FALSE)
}
# Store all the data together
interpolate_path = "../../interpolation"

intFiles = list.files(interpolate_path)

intPoints = data.frame()

load_file = function(x) {
  trip_id = gsub(".csv$", "", x)
  points = read.csv(paste0(interpolate_path, "/",x))
  if (nrow(points) == 0) {
    print(trip_id)
    return(data.frame())
  }
  points$trip_id = trip_id
  return(points)
}

# Use lapply to read each file into a data frame and add to a list
intFilesApply = lapply(intFiles, load_file)

# Combine the list of data frames into a single data frame
intPoints = do.call(rbind, intFilesApply)


# Have to read from Processed_Data_WithoutCancel.R

trips = read.table("../../businfo/trips.txt", header = TRUE, sep = ",", quote = "", fill = TRUE)

routes = read.table("../../businfo/routes.txt", header = TRUE, sep = ",", quote = "")

trip_route = trips %>%
  select(trip_id, route_id, shape_id) %>%
  left_join(routes %>% select(route_id, route_short_name), by = c('route_id')) 

intPoints = intPoints %>% left_join(trip_route %>% select(trip_id, route_short_name), by = c("trip_id"))
write.csv(intPoints, "interpolated_data.csv", row.names = FALSE)

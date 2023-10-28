busInfoPath = paste0('bus_info/', date, "/")

#Reading in static files 
stops = read.table(paste0(busInfoPath,"stops.txt"), header = TRUE, sep = ",", quote = "")

stop_times = read.table(paste0(busInfoPath,"stop_times.txt"), header = TRUE, sep = ",", quote = "")

trips = read.table(paste0(busInfoPath,"trips.txt"), header = TRUE, sep = ",", quote = "", fill = TRUE)

routes <- read.table(paste0(busInfoPath,"routes.txt"), header = TRUE, sep = ",", quote = "", fill = TRUE)

shapes = read.table(paste0(busInfoPath,"shapes.txt"), header = TRUE, sep = ",", quote = "")

calendar = read.table(paste0(busInfoPath,"calendar.txt"), header = TRUE, sep = ",", quote = "")

calendar_dates = read.table(paste0(busInfoPath,"calendar_dates.txt"), header = TRUE, sep = ",", quote = "")


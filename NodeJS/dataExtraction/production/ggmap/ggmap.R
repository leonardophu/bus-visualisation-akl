source('ggMapInitialisation.R')
source('ggmapFrame.R')
source('ggmapFrameLateness.R')
source('ggmapFrameMissing.R')
source('step_generator.R')
source('ggMapCreation.R')

colour_scheme <- c("0" = "#595656", "1" = "blue", "2" = "orange", "3" = "red")

intData = fread("../R_interpolation/interpolated_data.csv")
intData$status = factor(intData$status)

system.time(createMaps(20,60,"MissingFrames/", "Missing"))
system.time(runMap(20,60, "MissingFrames/"))

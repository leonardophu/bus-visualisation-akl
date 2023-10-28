# Data cleaning

dataCleaning = "dataCleaning/"

file_paths = c(
  'initialisationPB.r', 
  'extractingPB.r', 
  'computeStopSeq.r',
  'getStaticFiles.r', 
  'cleaningPB.r', 
  'validPointsFunctions.r', 
  'getValidPointsPB.r', 
  'getMissingPointsPB.r'
)

# Append 'dataCleaning/' to each file path
full_paths <- paste0(dataCleaning, file_paths)

# Source each file
lapply(full_paths, source)

# Data interpolation 

dataInterpolation = "dataInterpolation/"

file_paths = c(
  'initialisationInterpolation.r', 
  'separateFilesPB.r',
  'interpolate_functionPB.r',
  'interpolatePB.r',
  'storeDataPB.r'
)

full_paths <- paste0(dataInterpolation, file_paths)

# Source each file
lapply(full_paths, source)

# Data map creation

dataAnimationPath = "dataAnimation/"

file_paths = c(
  'ggMapInitialisation.R',
  'loadMapData.R',
  'ggmapFrameLateness.R',
  'ggmapFrameMissing.R',
  'step_generator.R',
  'ggMapCreation.R',
  'ggmap.R'
)

full_paths <- paste0(dataAnimationPath, file_paths)

# Source each file
lapply(full_paths, source)

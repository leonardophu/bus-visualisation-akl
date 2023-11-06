# Introduction
The files contained here provide all the necessary code (given a full day's worth of data, the static GTFS, and the protobuf file) to generate animations. The three important folders are **dataAnimation**, **dataInterpolation**, and **dataCleaning**. The folder **previousDataCleaning** contains previous attempts at data cleaning/extraction.

**Note:** Each folder includes an R file with the term *initialisation* in its name. These R files contain information that the user must fill out, such as directories where data will be stored, dictionaries where specific data are kept, and the date the data was collected.


# dataCleaning

The folder is designed to process the raw protobuf bus files, combining and cleaning them. The result is a whole CSV file that combines all the collected data.

**Assumptions:**  
- You are aware of the UTC time difference (In New Zealand, it would be UTC +12 or UTC +13, depending on daylight saving time).
- You have the proto file for gtfs-realtime. (In our case, we got our proto file from [https://developers.google.com/transit/gtfs-realtime/gtfs-realtime-proto](https://developers.google.com/transit/gtfs-realtime/gtfs-realtime-proto))
- You have the Static GTFS file for the specific date in question.

# dataInterpolation

The folder is designed to process the raw data for each **trip_id**. The result will be CSV files containing the raw data for each **trip_id**, CSV files containing the raw shape data for each **shape_id**, CSV files containing the interpolated dataset for each **trip_id**

**Assumptions:**  
- The raw complete cleaned CSV (obtained by **dataCleaning**)
- You have the Static GTFS file for the specific date in question.

# dataAnimation

This folder contains all the code required to convert our interpolated dataset into an MP4 animation

**Assumptions:**  
- The complete interpolated dataset for a day's worth of data is available (obtained by **dataInterpolation**)
- Your downloaded maps are saved as RData files
  - For this project, the code to generate the maps can be seen in **generatingMaps.R** in the **dataAnimation** folder



# Running
If you've got all the needed files ready and have set up the initial files the way you like, you can just run the runPB.pb file. This will automatically do the **dataCleaning**, **dataInterpolation**, and **dataAnimation** steps for you all at once.

# Introduction
The files contained here provide all the necessary code (given a full day's worth of data, the static GTFS, and the protobuf file) to generate animations. The three important folders are **dataAnimation**, **dataInterpolation**, and **dataCleaning**. The folder **previousDataCleaning** contains previous attempts at data cleaning/extraction.

**Note:** Each folder includes an R file with the term *initialisation* in its name. These R files contain information that the user must fill out, such as directories where data will be stored, dictionaries where specific data are kept, and the date the data was collected.


# dataCleaning

The folder will take the raw protobuf bus files, and combine them all together and clean them. 

**Assumptions:**  
- You know the UTC difference in time (In New Zealand it would be either UTC + 12 or UTC + 13 depending on daylight saving)
- You have your downloaded maps as RData
- You have the proto file for gtfs-raetime
- You have the Static GTFS file for the specific Real-time GTFS file

# dataAnimation

This folder contains all the code required to convert our interpolated dataset into an MP4 animation

**Assumptions:**  
- The complete interpolated dataset for a day's worth of data is available (obtained by **dataInterpolation**)
- Your downloaded maps are saved as RData files



# Running
Given that all the directories and files are stored, and the initialised files are updated to the user liking. Can run runPB.pb file to automate everything

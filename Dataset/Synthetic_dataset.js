const coordinates = [
    [[-74.001, 40.712], 
    [-74.001, 40.709],  
    [-73.999, 40.709]],  
    
    [[-74.001, 40.712],  // Point 1: Top-left
    [-73.999, 40.712],  // Point 2: Top-right
    [-74.001, 40.709],  // Point 3: Bottom-left
    [-73.999, 40.709]],

    [[-74.001, 40.712],  // Point 1: Top-left
    [-73.999, 40.712],  // Point 2: Top-right
    [-74.001, 40.709],  // Point 3: Bottom-left
    [-73.999, 40.709]]
  ];

// Further enhance this! 

const cancelled = [false, true, false];

const route_identity = ["75", "75","75"];

const bus_status = [[3, 3, 3], [0,1,2,3], [1,1,1,1]];

const routes = [[[-74.001, 40.712],  // Point 1: Top-left
[-73.999, 40.712],  // Point 2: Top-right
[-74.001, 40.709],  // Point 3: Bottom-left
[-73.999, 40.709]]];

//Problem is we can't see other point and replay isn't working! 
const coordinateTimestamps = [[0, 5, 20], [1,3,4,5], [4,5,6,19]]

// Synthetic dataset ////////////////////////////
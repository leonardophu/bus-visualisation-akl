const coordinates = [
    [
      [-74.001, 40.712],  // Point 1: Top-left
      // [-73.999, 40.712],  // Point 2: Top-right
      [-74.001, 40.709],  // Point 3: Bottom-left
      [-73.999, 40.709]   // Point 4: Bottom-right
    ]
  ];
  
  const routes = [
    [
      [-74.001, 40.712],  // Point 1: Top-left
      [-73.999, 40.712],  // Point 2: Top-right
      [-74.001, 40.709],  // Point 3: Bottom-left
      [-73.999, 40.709]   // Point 4: Bottom-right
    ]
  ];
  
  const coordinateTimestamps = [[0, 5, 20]];
  

  // Gets the number of coordinates
const num_destinations = coordinates.length;

let minTimestamp = Number.MAX_VALUE;
let maxTimestamp = Number.MIN_VALUE;

// We want to obtain the maxiumum and miniumum time stamps
for (const timestamps of coordinateTimestamps) {
const localMin = Math.min(...timestamps);
const localMax = Math.max(...timestamps);

minTimestamp = Math.min(minTimestamp, localMin);
maxTimestamp = Math.max(maxTimestamp, localMax);
}

//Get the range of values which will be used.
time_range = maxTimestamp - minTimestamp;

// For each column or array, we want to assign a number of steps to this. For our analysis 
designatedSteps = [];

multiplier = 50;
//For now 1 timestamp is equavialent to 50 steps.
steps = time_range * multiplier;

for (i = 0; i < coordinateTimestamps.length; i++) {
    range = Math.max(...coordinateTimestamps[i]) - Math.min(...coordinateTimestamps[i])
    designatedSteps.push(Math.round((range / time_range) * steps))
}

console.log(designatedSteps);
  function interpolation(uniqueCoordinates,uniqueRoute, uniqueTimestamps) {
    const uniqueSteps = uniqueRouteSteps(uniqueTimestamps);
    const interpolatedPoints = [];

    // For loop to now get the individual infromatio
    for (let i = 0; i < uniqueTimestamps.length - 1; i++) {

      const subsetCoordinates = [];
      const startPoint = uniqueCoordinates[i];
      const endPoint = uniqueCoordinates[i + 1];
  
      let j = 0;
      while (j < uniqueRoute.length) {
        let currentCoordinates = uniqueRoute[j];
  
        if (isEqual(currentCoordinates, startPoint)) {
          subsetCoordinates.push(currentCoordinates);
  
          while (!isEqual(currentCoordinates, endPoint)) {
            j++;
            currentCoordinates = uniqueRoute[j];
            subsetCoordinates.push(currentCoordinates);
          }
  
          break;
        }
        j++;
      };

      let line = turf.lineString(subsetCoordinates);
      let lineDistance = turf.length(line);

      for (let z = 0; z < lineDistance; z += lineDistance / steps)  {
        let interpolatedPoint = turf.along(line, i);
        interpolatedPoints.push(interpolatedPoint.geometry.coordinates);
      };
    };
    return(interpolatedPoints);
  };

  
  function isEqual(coord1, coord2) {
    return coord1[0] === coord2[0] && coord1[1] === coord2[1];
  }
  
  function uniqueRouteSteps(timestamps) {
    const newArray = [];
  
    for (let i = 0; i < timestamps.length - 1; i++) {
      const difference = timestamps[i + 1] - timestamps[i];
      const multipliedValue = difference * multiplier;
      newArray.push(multipliedValue);
    }
  
    return newArray;
  }
  
console.log(interpolation(coordinates[0], routes[0], coordinateTimestamps[0]));
  

const cancelled = [false, true, false];
console.log(cancelled[0]);
console.log(cancelled[1]);
console.log(cancelled[2]);

console.log(cancelled[1] === true);

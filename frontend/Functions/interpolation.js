// Calculates the number of screens to represent each movement between bus nodes 
function uniqueRouteSteps(timestamps) {
  // Want to store the number of steps per two points 
  const individualSteps = [];

  for (let i = 0; i < timestamps.length - 1; i++) {
    // Calculate the difference in steps
    const difference = timestamps[i + 1] - timestamps[i];
    // Use that difference to get the number of steps - a bit skeptical of round, could do better
    const multipliedValue = Math.round(difference * multiplier);
    // Store that value 
    individualSteps.push(multipliedValue);
  }

  return individualSteps;
}

// Function to check if two set of coordinates are the exact same 
function isEqual(coord1, coord2) {
  return coord1[0] === coord2[0] && coord1[1] === coord2[1];
}

// Function to do interpolation 
function interpolation(uniqueCoordinates, uniqueRoute, uniqueTimestamps, uniqueStatus) {

    // Get number of steps between each set of coordinates
    const uniqueSteps = uniqueRouteSteps(uniqueTimestamps);

    // Storing all points used for interpolation
    const interpolatedPoints = [];

    const statusConditions = [];

    // For loop to now get the individual infromatio
    for (let i = 0; i < uniqueTimestamps.length - 1; i++) {

      // We want to know if the bus status has changed. E.g. if the bus is now late compared to being it on time
      let changedBus = false; 

      // First status is the current bus status
      let firstStatus = uniqueStatus[i];
      
      // Checks if teh bus status has changed
      if(uniqueStatus[i] !== uniqueStatus[i + 1]) {
        // keep track of the new status 
        secondStatus = uniqueStatus[i + 1];
        // set changedBus = true since the bus status has now changed
        changedBus = true;
        // Find the difference. If it's more than 2 we need to consider doing multiple changes in teh animation 
        statusDifference = Math.abs(secondStatus - firstStatus);
      };

      // Want to extract all coordinates between two points 
      const subsetCoordinates = [];

      // Keep track of the two nodes 
      const startPoint = uniqueCoordinates[i];
      const endPoint = uniqueCoordinates[i + 1];
      
      // Loop through all point in the route

      let j = 0;

      // Goal of while loop is to find the set of coordinates in the route we need to go through
      while (j < uniqueRoute.length) {
        
        let currentCoordinates = uniqueRoute[j];
        
        // If we found the startPoint we want to keep track of it 
        if (isEqual(currentCoordinates, startPoint)) {
          subsetCoordinates.push(currentCoordinates);
          
          //Keep track of all the points till the end point
          while (!isEqual(currentCoordinates, endPoint)) {
            j++;
            currentCoordinates = uniqueRoute[j];
            subsetCoordinates.push(currentCoordinates);
          }
  
          break;
        }
        j++;
      };

      // Create a polyline of our coordinates
      const line = turf.lineString(subsetCoordinates);

      //Get the distance, so that we can evenly spread the interpolated points
      const lineDistance = turf.length(line);

      // Means no changed buses, don't have to worry about it 
      if (changedBus == false) {
        // Start at the start of the polyline -> then add the distance / number of steps. Such that we get "number of steps" interpolated points between the two points
        for (let z = 0; z < lineDistance; z += lineDistance / uniqueSteps[i]) {
          //Find the interpolated along the line
          const interpolatedPoint = turf.along(line, z);
          // Store the interpolated point 
          interpolatedPoints.push(interpolatedPoint.geometry.coordinates);
          // Store the bus status 
          statusConditions.push(firstStatus);
        };
      } else {
        // This means the bus condition has changed and we need to keep track of it.
        for (let z = 0; z < lineDistance; z += lineDistance / uniqueSteps[i]) {
          const interpolatedPoint = turf.along(line, z);
          interpolatedPoints.push(interpolatedPoint.geometry.coordinates);

          // Will find the position proportionally to the line Distance to create different bus images 
          const interpolationIndex = z / lineDistance;

          // status is the status of the bus we will be pushing in
          let status;

          // If the difference is one means that we only focus on 50/50 split.
          if (statusDifference == 1) {
            
            if (interpolationIndex < 0.5) {
              status = firstStatus;
            } else {
              status = secondStatus;
            }

          // If the difference is by 2 then we will need to consider this change. Where the first third will be the first state. Second third be the inbetween state and the final third being the last state
          } else if (statusDifference == 2) {
            if (interpolationIndex < 1 / 3) {
              status = firstStatus;
            } else if (interpolationIndex >= 1 / 3 && interpolationIndex < 2 / 3) {
              if (firstStatus < secondStatus) {
                status = firstStatus + 1; // In-between status (1)
              } else {
                status = firstStatus - 1; // In-between status (1)
              }
            } else {
              // It will just be the last state if it's no the inbetween or the first state
              status = secondStatus;
            };
          };

          // We can continue with else if, if I need to consider cancelled buses changing from one another

          statusConditions.push(status);
        };

      };
    };
    // Return the interpolatedPoints and the statusConditions
    return [interpolatedPoints, statusConditions];
  };
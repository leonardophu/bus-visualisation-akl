const colours = [
  'brown',
  'blue',
  'green',
  'yellow',
  'orange',
  'purple',
  'pink'
];

// Initialisation
origin = [];
points_index = [];
points_waiting_index = [];
interpolationPoints = [];
points_obj = [];
currentBusStatus = [];
interpolatedBusStatus = [];

function initialise() {
  for (let i = 0; i < num_destinations; i++) {
    origin.push(coordinates[i][0]);

    currentBusStatus.push(bus_status[i][0]);
    // Fix routes[0] 
    interpolated_data = interpolation(coordinates[i], routes[0], coordinateTimestamps[i], bus_status[i]);
    interpolationPoints.push(interpolated_data[0]);
    interpolatedBusStatus.push(interpolated_data[1]);
    points_obj.push(points(i));
    points_waiting_index.push(i);
  }
}
// Get the desired points
initialise();

// Keeps the initial points 
var originalPointsWaitingIndex = JSON.parse(JSON.stringify(points_waiting_index));
var originalInterpolationPoints = JSON.parse(JSON.stringify(interpolationPoints));
var originalBusStatus = JSON.parse(JSON.stringify(currentBusStatus));
var originalBusStatusInterpolation = JSON.parse(JSON.stringify(interpolatedBusStatus));
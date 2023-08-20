
// Attach the 'load' event listener to the map
map.on('load', async () => {
console.log("Map loaded.");

// Get the busNumber from the URL parameters
const urlParams = new URLSearchParams(window.location.search);
const busNumber = urlParams.get('busNumber');

// Fetch the required data
const requiredData = await fetchBusData(busNumber);
const roads = await getRoad(requiredData);
const {busStatus, intPoints, startTime} = await getBusInterpolatedData(busNumber);

const num_destinations = intPoints.length;

// Initialisation
const origin = [];
const points_index = [];
const points_waiting_index = [];
const points_obj = [];
const currentBusStatus = [];

function initialise() {
  for (let i = 0; i < num_destinations; i++) {
    origin.push(intPoints[i][0]);
    currentBusStatus.push(busStatus[i][0]);
    points_obj.push(points(origin[i]));
    points_waiting_index.push(i);
  }
}
// Get the desired points
initialise();

// Keeps the initial points 
const originalPointsWaitingIndex = JSON.parse(JSON.stringify(points_waiting_index));
const originalInterpolationPoints = JSON.parse(JSON.stringify(intPoints));
const originalBusStatus = JSON.parse(JSON.stringify(currentBusStatus));
const originalBusStatusInterpolation = JSON.parse(JSON.stringify(busStatus));

// Setting up map
addRouteLayer(roads);
loadBusIcons(() => {
  // Initialization continues after loading bus icons
  addOrigins();
});   
});


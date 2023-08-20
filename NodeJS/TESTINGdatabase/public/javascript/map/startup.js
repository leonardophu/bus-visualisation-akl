let num_destinations;
let minTimestamp;
let points_index;
let points_waiting_index;
let busStatus, intPoints, startTime;


const origin = [];
points_index = [];
points_waiting_index = [];
const points_obj = [];
const currentBusStatus = [];

map.on('load', async () => {
  console.log("Map loaded.");

  // Get the busNumber from the URL parameters
  const urlParams = new URLSearchParams(window.location.search);
  const busNumber = urlParams.get('busNumber');

  // Fetch the required data
  const requiredData = await fetchBusData(busNumber);
  const roads = await getRoad(requiredData);
  ({busStatus, intPoints, startTime} = await getBusInterpolatedData(busNumber));

  num_destinations = intPoints.length;

  minTimestamp = Math.min(...startTime);

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
  await loadBusIcons();
  addOrigins();  

  let running = false;
  let counter = minTimestamp;

  function animate() {
    running = true;
    document.getElementById('replay').disabled = true;
  }
});


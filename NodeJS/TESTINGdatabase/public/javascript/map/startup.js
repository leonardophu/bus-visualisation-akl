window.addEventListener("load", async function () {
  const urlParams = new URLSearchParams(window.location.search);
  const busNumber = urlParams.get('busNumber');

  const requiredData = await fetchBusData(busNumber);
  const roads = await getRoad(requiredData);

  const {busStatus, intPoints, startTime} = await getBusInterpolatedData(busNumber);

  const num_destinations = intPoints.length;
  let minTimestamp = startTime.MAX_VALUE;

  // Initialisation
  origin = [];
  points_index = [];
  points_waiting_index = [];
  points_obj = [];
  currentBusStatus = [];

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
  var originalPointsWaitingIndex = JSON.parse(JSON.stringify(points_waiting_index));
  var originalInterpolationPoints = JSON.parse(JSON.stringify(intPoints));
  var originalBusStatus = JSON.parse(JSON.stringify(currentBusStatus));
  var originalBusStatusInterpolation = JSON.parse(JSON.stringify(busStatus));

  map.on('load', () => {
    addRouteLayer(roads);
  });
});

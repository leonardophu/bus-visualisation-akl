// Global variables needed for visual display
let num_destinations;
let minTimestamp;
let points_index;
let points_waiting_index;
let busStatus, intPoints, startTime;
let wholemap = true;
let roads;
let busStops;
let busNumber; 


const origin = [];
points_index = [];
points_waiting_index = [];
const points_obj = [];
let currentBusStatus = [];


map.on('load', async () => {
  console.log("Map loaded.");

  // Get the busNumber from the URL parameters
  const urlParams = new URLSearchParams(window.location.search);
  busNumber = urlParams.get('busNumber'); // Assign the value to the global variable

  const requiredData = await fetchBusData(busNumber);
  // If there are no bus numbers, this suggests we are seeing the whole map! 
  if (busNumber !== null) {
    roads = await getRoad(requiredData);
    busStops = await getBusStops(busNumber);
    wholemap = false;
  }

  // We get the busStops given a busNumber
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

  // Check if we are looking at specific busses, if so load route and bus stops
  if (wholemap === false) {
    addBusStopsLayer(busStops);
    addRouteLayer(roads);
  }
  await loadBusIcons();
  addOrigins();  

  let running = false;
  let counter = minTimestamp;

  function animate() {
    running = true;
    document.getElementById('replay').disabled = true;

    // For points that are already in the visual, if point is at the end (so no more points to interpolate)
    // Remove the point in the visual

    for(const index of points_index) {
      if(intPoints[index].length === 0) {
          points_index = points_index.filter(item => item !== index);
          removeOldSource(index);
      }; 
    };
    for(const index of points_waiting_index) {
      //These are for instances which didn't have 0 at the start, or the minumum
      if(startTime[index] === counter) {
          //Points we are animating 
          points_index.push(index);
          //Points not to animate yet
          points_waiting_index = points_waiting_index.filter(item => item !== index);
          getNewSource(index);
      }; 
    };

    //The visualisation is done when there are no more points left to be animated
    const finished = points_waiting_index.length === 0 && points_index.length === 0;

    if(finished) {
      running = false;
      document.getElementById('replay').disabled = false;
      return;
    };

    // Update points
    for(const index of points_index) {
      // Setting datapoint 
      const currentPosition = intPoints[index].shift();
      points_obj[index].features[0].geometry.coordinates = currentPosition;
      map.getSource('point' + index).setData(points_obj[index]);
      // Checking for the colours 
      const checkingBusStatus = busStatus[index].shift();
      // Checking if the colours have changed or not
      if(checkingBusStatus !== currentBusStatus[index]) {
          console.log('bus change')
          // Then we get the new colour 
          currentBusStatus[index] = checkingBusStatus;
          //Get new bus icon
          newStatus = getBusIcons(index);
          map.setLayoutProperty('point' + index, 'icon-image', newStatus);
      };
    };
    counter = counter + 1;
    updateCounterValue(counter);

    // If points are avaliable, we will go to the next frame 
    if (!(points_index.length === 0 && points_waiting_index.length === 0)) {
      requestAnimationFrame(animate);
    };
  };

  // Replay button, waits to see if anyone clicks on the replay button

  document.getElementById('replay').addEventListener('click', () => {
    if (running) {
        void 0;
    } else {
        for(let i = 0; i < num_destinations; i++) {
            points_obj[i].features[0].geometry.coordinates = origin[i];
        }

        // Reset all the points
        points_waiting_index = JSON.parse(JSON.stringify(originalPointsWaitingIndex));
        intPoints = JSON.parse(JSON.stringify(originalInterpolationPoints));
        currentBusStatus= JSON.parse(JSON.stringify(originalBusStatus));
        busStatus= JSON.parse(JSON.stringify(originalBusStatusInterpolation));
        
        // Reset the cancellation tab
        document.getElementById('directions').innerHTML = "";
        
        // Want to add the origin points agin
        addOrigins();
        // Reset the counter to the minimum timestamp
        counter = minTimestamp;
        // Restart the animation
        animate();
    };

});
  animate();
});


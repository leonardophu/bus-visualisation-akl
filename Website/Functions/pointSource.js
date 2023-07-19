// This code now having problems, for some reason map.loadImage doesn't want to work. 
// This code loads the bus icons in our map

function loadImageAsync(path) {
    return new Promise((resolve, reject) => {
      map.loadImage(path, (error, image) => {
        if (error) reject(error);
        resolve(image);
      });
    });
}

// We want to create a asynchronous function, this way it runs all on one thread 

async function loadBusIcons() {
    console.warn("LoadBusIcons");
    try {
      console.warn("LoadedBusIcons");
      console.log("before loading images");
  
      const onTimeBusImage = await loadImageAsync('/BusImages/OnTimeBus.png');
      map.addImage('OnTimeBus', onTimeBusImage);
      
      const ghostBusImage = await loadImageAsync('/BusImages/GhostBus.png');
      map.addImage('GhostBus', ghostBusImage);
      
      const veryLateBusImage = await loadImageAsync('/BusImages/VeryLate.png');
      map.addImage('VeryLateBus', veryLateBusImage);
      
      const slightlyLateBusImage = await loadImageAsync('/BusImages/SlightlyLate.png');
      map.addImage('SlightlyLateBus', slightlyLateBusImage);
  
      console.log("after loading images");
    } catch (error) {
      console.error(error);
      console.log("There was an error");
    }
}

// This code gets our bus icons from our desktop 
function getBusIcons(i) {
    if(currentBusStatus[i] == 0) {
        return('OnTimeBus');
    } else if (currentBusStatus[i] == 1) {
        return('SlightlyLateBus');
    } else if (currentBusStatus[i] == 2) {
        return('VeryLateBus');
    } else {
        return('GhostBus');
    };
};

function points(i) {
    const point = {
        'type': 'FeatureCollection',
        'features': [
            {
                'type': 'Feature',
                'properties': {},
                'geometry': {
                    'type': 'Point',
                    'coordinates': origin[i]
                }
            }
        ]
    };
    return(point);
    };
    
function addCancellation(i) {
    const directions = document.getElementById('directions');
    directions.innerHTML += `<li>Bus ${route_identity[i]} - Time : ${coordinateTimestamps[i][0]}</li>`
}
    
// This code adds the routes to our map layer
function addRouteLayer() {
    //For loop to add the sources for the route and plot them on the map.
    for(let i = 0; i < routes.length; i++) {
        map.addSource('route' + i, {
        'type': 'geojson',
        'data': {
        'type': 'Feature',
        'properties': {},
        'geometry': {
        'type': 'LineString',
        'coordinates': routes[i]
        }
        }
        });

        // Add our routes to the map
    map.addLayer({
        'id': 'route' + i,
        'type': 'line',
        'source': 'route' + i,
        'layout': {
        'line-join': 'round',
        'line-cap': 'round'
        },
        'paint': {
        'line-color': colours[i],
        'line-width': 5
        }
        });
    };
};
    
// This code adds the starting to our may layer
function addOrigins() {
//For loop to add the sources for the route and plot them on the map.
    for(let i = 0; i < num_destinations; i++) {
        //Starting timestamp
        if(coordinateTimestamps[i][0] === minTimestamp) {
            
            map.addSource('point' + i, {
                'type': 'geojson',
                //Each point is associated with
                'data': points_obj[i]
            });

            busicon = getBusIcons(i);
            if(busicon === "GhostBus") {
                addCancellation(i);
            };

            console.log("Solution");

            map.addLayer({
                'id': 'point' + i,
                'source': 'point' + i,
                'type': 'symbol',
                'layout': {
                    'icon-image': busicon,
                    'icon-size': 0.07,
                    'icon-rotate': ['get', 'bearing'],
                    'icon-rotation-alignment': 'map',
                    'icon-allow-overlap': true,
                    'icon-ignore-placement': true
                }
            });

            console.log("Problem");

            //Points we are animating 
            points_index.push(i);
            //Points not to animate yet
            points_waiting_index = points_waiting_index.filter(item => item !== i);
        }; 
    };
};

// This code adds a new source, so a new point on our map
function getNewSource(i) {
    map.addSource('point' + i, {
                'type': 'geojson',
                //Each point is associated with
                'data': points_obj[i] });

    busicon = getBusIcons(i);
    if(busicon === "GhostBus") {
        addCancellation(i);
    };


    map.addLayer({
    'id': 'point' + i,
    'source': 'point' + i,
    'type': 'symbol',
    'layout': {
        'icon-image': busicon,
        'icon-size': 0.07,
        'icon-rotate': ['get', 'bearing'],
        'icon-rotation-alignment': 'map',
        'icon-allow-overlap': true,
        'icon-ignore-placement': true
    }
    });
}

// This code removes a source, so once a bus is done, it gets removed.
function removeOldSource(i) {
    map.removeLayer('point' + i);
    map.removeSource('point' + i);
}

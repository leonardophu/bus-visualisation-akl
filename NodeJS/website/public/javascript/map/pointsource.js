// Given some lat and lon, we will create a point for the map object
function points(origin) {
    const point = {
        'type': 'FeatureCollection',
        'features': [
            {
                'type': 'Feature',
                'properties': {},
                'geometry': {
                    'type': 'Point',
                    'coordinates': origin
                }
            }
        ]
    };
    return(point);
};

function addOrigins() {
//For loop to add the sources for the route and plot them on the map.
    for(let i = 0; i < num_destinations; i++) {
        //Starting timestamp
        if(startTime[i] === minTimestamp) {
            
            map.addSource('point' + i, {
                'type': 'geojson',
                //Each point is associated with
                'data': points_obj[i]
            });

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
                    'icon-size': 0.05,
                    'icon-rotate': ['get', 'bearing'],
                    'icon-rotation-alignment': 'map',
                    'icon-allow-overlap': true,
                    'icon-ignore-placement': true
                }
            });

            //Points we are animating 
            points_index.push(i);
            //Points not to animate yet
            points_waiting_index = points_waiting_index.filter(item => item !== i);
        }; 
    };
    return;
};

// This code removes a source, so once a bus is done, it gets removed.
function removeOldSource(i) {
    map.removeLayer('point' + i);
    map.removeSource('point' + i);
}

// This code adds a new source, so a new point on our map
function getNewSource(i) {
    map.addSource('point' + i, {
                'type': 'geojson',
                //Each point is associated with
                'data': points_obj[i] });

    // If the bus icon is GhostBus (which means it's cancelled) then we need to add that onto the cancellation text
    busicon = getBusIcons(i);
    if(busicon === "GhostBus") {
        addCancellation(i);
    };

    // Add the point onto the map to show
    map.addLayer({
    'id': 'point' + i,
    'source': 'point' + i,
    'type': 'symbol',
    'layout': {
        'icon-image': busicon,
        'icon-size': 0.05,
        'icon-rotate': ['get', 'bearing'],
        'icon-rotation-alignment': 'map',
        'icon-allow-overlap': true,
        'icon-ignore-placement': true
    }
    });
};
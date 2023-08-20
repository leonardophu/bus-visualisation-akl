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
                //addCancellation(i);
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
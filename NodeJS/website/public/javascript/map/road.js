// This code adds the routes to our map layer
function addRouteLayer(routes) {
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
        // Change later to colours[o]
        'line-color': 'black',
        'line-width': 5
        }
        });
    };
};

async function getRoad(required_data) {
    // Get all the shape_id for the routes
    const shapeIds = [];

    // 
    for (const obj of required_data) {
        shapeIds.push(obj.shape_id);        
    }

    // Store all our road coordinates
    const route_coordinates = []
    
    // Collect all the shape coordinates (we call it route_cordinates) in our query
    for (const id of shapeIds) {
        const uniqueCoords = await fetch(`/shapedata?shapeID=${id}`);
        const data = await uniqueCoords.json();
        route_coordinates.push(data[0].route_coordinates);
    }

    // Assuming route_coordinates[0] contains an array with the first coordinate's [longitude, latitude]
    if (route_coordinates.length > 0 && route_coordinates[0].length > 0) {
        const [longitude, latitude] = route_coordinates[0][0]; // Extract longitude and latitude
        // Update the map center with the extracted coordinates
        map.setCenter([longitude, latitude]);
    }
    return(route_coordinates);
}
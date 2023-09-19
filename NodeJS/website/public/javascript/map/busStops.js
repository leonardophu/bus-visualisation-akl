async function getBusStops(busNumber) {
    if (busNumber) {
        try {
            const response = await fetch(`/busstopsdata?busNumber=${busNumber}`);
            const data = await response.json();

            // Extracting stop_coordinates into a new array
            const coordinates = data.map(item => item.stop_coordinates);
            return coordinates;
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    }
};

// This code adds the routes to our map layer
function addBusStopsLayer(busStopsCoordinates) {
    // Convert bus stops coordinates to GeoJSON format
    const geojson = {
        'type': 'FeatureCollection',
        'features': busStopsCoordinates.map(coord => ({
            'type': 'Feature',
            'properties': {},
            'geometry': {
                'type': 'Point',
                'coordinates': coord
            }
        }))
    };

    // Add source for the bus stops
    map.addSource('busStops', {
        'type': 'geojson',
        'data': geojson
    });

    // Add layer for the bus stops
    map.addLayer({
        'id': 'busStops',
        'type': 'circle',
        'source': 'busStops',
        'paint': {
            'circle-radius': 5,  // size of the circle/dot
            'circle-color': '#FF0000'  // color of the circle/dot
        }
    });
};

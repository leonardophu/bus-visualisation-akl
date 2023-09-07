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

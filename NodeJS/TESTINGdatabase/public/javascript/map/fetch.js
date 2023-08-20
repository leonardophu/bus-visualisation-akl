async function getBusInterpolatedData(busNumber) {
    console.log(busNumber);
    if (busNumber) {
        const busData = await fetch(`/busdata?busNumber=${busNumber}`);
        const data = await busData.json();
        
        const busStatusArray = data.map(item => item.bus_status).flat();
        const intPointsArray = data.map(item => item.int_points);
        const startTimeArray = data.map(item => item.start_time);

        return {
            busStatus: busStatusArray,
            intPoints: intPointsArray,
            startTime: startTimeArray
        };
    } else {
        // Consider the case when it doesn't exist
    }
}

async function fetchBusData(busNumber) {
    if (busNumber) {
        try {
            const response = await fetch(`/routedata?busNumber=${busNumber}`);
            const data = await response.json();
            return(data);
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    } else {
        // This means that we want the entire data! 
        console.log("Need to continue on ")
    }
}
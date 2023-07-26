// When map loads, do initalisation

map.on('load', () => {
    // Load bus icons first
    loadBusIcons(() => {
        // Initialization continues after loading bus icons
        addOrigins();
    });   
    addRouteLayer();
    
    //Animation happening

    let running = false;

    //Remeber the steps in javascript start at 0. Currently we assume that each has the same length. However need to fix later on

    let counter = minTimestamp; //Counter stores current position in animation. We want to start at the minimum time stamp

    function animate() {
        running = true;
        document.getElementById('replay').disabled = true;
        
        // For points that are already in the visual, if point is at the end (so no more points to interpolate)
        // Remove the point in the visual

        for(const index of points_index) {
            if(interpolationPoints[index].length === 0) {
                points_index = points_index.filter(item => item !== index);
                removeOldSource(index);
            } 
        }
        
        for(const index of points_waiting_index) {
            //These are for instances which didn't have 0 at the start, or the minumum
            if(coordinateTimestamps[index][0] * multiplier === counter) {
                //Points we are animating 
                points_index.push(index);
                //Points not to animate yet
                points_waiting_index = points_waiting_index.filter(item => item !== index);
                getNewSource(index);
            } 
        }

        //The visualisation is done when there are no more points left to be animated
        const finished = points_waiting_index.length === 0 && points_index.length === 0;

        if(finished) {
            running = false;
            document.getElementById('replay').disabled = false;
            return;
       }
        
        //Update points
        // Need to fix this code 
        for(const index of points_index) {
            // Setting datapoint 
            const currentPosition = interpolationPoints[index].shift();
            points_obj[index].features[0].geometry.coordinates = currentPosition;
            map.getSource('point' + index).setData(points_obj[index]);
            // Checking for the colours 
            const checkingBusStatus = interpolatedBusStatus[index].shift();
            // Checking if the colours have changed or not
            if(checkingBusStatus !== currentBusStatus[i]) {
                // Then we get the new colour 
                currentBusStatus[i] = checkingBusStatus;
                //Get new bus icon
                newStatus = getBusIcons(i);
                map.setLayoutProperty('point' + index, 'icon-image', newStatus);
            };

        }

        // Also need to fix interpolation for duplicate points. The code below may be an issue. better to use counter < steps instead of relying on the points_index.length!!! 
        if (points_index.length !== 0) {
            requestAnimationFrame(animate);
        };
        counter = counter + 1;
    };

    document.getElementById('replay').addEventListener('click', () => {
        if (running) {
            void 0;
        } else {
            //Reinitialise our waiting and interpolationPoints 
            points_waiting_index = [];
            // Interpolation points which are our interpolated points
            interpolationPoints = [];
            for(let i = 0; i < num_destinations; i++) {
                points_obj[i].features[0].geometry.coordinates = origin[i];
                // Really inefficient, tried using another variable = but keeps going to same reference point
                points_waiting_index.push(i);
                console.log(origin[i]);
            }
            // Want to add the origin points agin
            addOrigins();
            interpolationPoints = JSON.parse(JSON.stringify(originalInterpolationPoints));
            currentBusStatus= JSON.parse(JSON.stringify(originalBusStatus));
            interpolatedBusStatus= JSON.parse(JSON.stringify(originalBusStatusInterpolation));
            
            document.getElementById('directions').innerHTML = ''
            // Reset the counter to the minimum timestamp
            counter = minTimestamp;
            // Restart the animation
            animate();
        };
    });
    animate();

});


// Gets the number of coordinates
const num_destinations = coordinates.length;

let minTimestamp = Number.MAX_VALUE;
let maxTimestamp = Number.MIN_VALUE;

// We want to obtain the maxiumum and miniumum time stamps
for (const timestamps of coordinateTimestamps) {
    const localMin = Math.min(...timestamps);
    const localMax = Math.max(...timestamps);

    minTimestamp = Math.min(minTimestamp, localMin);
    maxTimestamp = Math.max(maxTimestamp, localMax);
}

//Get the range of values which will be used.
time_range = maxTimestamp - minTimestamp;

// For each column or array, we want to assign a number of steps to this. For our analysis 
designatedSteps = [];

multiplier = 50;
//For now 1 timestamp is equavialent to 50 steps.
steps = time_range * multiplier;

for (i = 0; i < coordinateTimestamps.length; i++) {
    range = Math.max(...coordinateTimestamps[i]) - Math.min(...coordinateTimestamps[i])
    designatedSteps.push(Math.round((range / time_range) * steps))
}
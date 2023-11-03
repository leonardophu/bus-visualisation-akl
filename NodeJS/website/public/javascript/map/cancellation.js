// Contains function to add cancellation, input is i which is index

function addCancellation(i) {
    // Get the cancellation box object
    const directions = document.getElementById('directions');
    // Add the cancelled bus onto the cancellation box object
    directions.innerHTML += `<li> Bus ${busNumber} cancelled at ${getHoursAndMinutes(startTime[i])} </li>`;
}
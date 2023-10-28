function addCancellation(i) {
    const directions = document.getElementById('directions');
    directions.innerHTML += `<li> Bus ${busNumber} cancelled at ${getHoursAndMinutes(startTime[i])} </li>`;
}
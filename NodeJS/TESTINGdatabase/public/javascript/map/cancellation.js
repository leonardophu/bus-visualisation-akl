function addCancellation(i) {
    const directions = document.getElementById('directions');
    directions.innerHTML += `<li>Bus ${route_identity[i]} - Time : ${coordinateTimestamps[i][0]}</li>`;
}
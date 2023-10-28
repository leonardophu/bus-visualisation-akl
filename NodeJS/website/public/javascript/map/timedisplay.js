function updateCounterValue(counter) {
    currentTime = getHoursAndMinutes(counter);
    document.getElementById("timeNowDisplay").textContent = currentTime;
}

function getHoursAndMinutes(second) {
    const milliseconds = (second - 43200) * 1000;
    const date = new Date(milliseconds);
    
    // Get the hours and minutes components
    const hours = date.getHours();
    const minutes = date.getMinutes();

    // Format the hours and minutes into "HH:mm" format
    const formattedTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;

    return formattedTime;
}
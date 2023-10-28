function updateCounterValue(counter) {
    currentTime = getHoursAndMinutes(counter);
    document.getElementById("timeNowDisplay").textContent = currentTime;
}

function getDate(second) {
    const milliseconds = (second - 43200) * 1000
    const date = new Date(milliseconds);
    
    //Get components of the date 
    const year = date.getFullYear();
    const month = date.getMonth() + 1; // Note: Months are zero-based, so we add 1
    const day = date.getDate();
    const hours = date.getHours();
    const minutes = date.getMinutes();
    const seconds = date.getSeconds();

    const formattedDate = `${year}-${month.toString().padStart(2, '0')}-${day.toString().padStart(2, '0')} ${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;

    return(formattedDate);
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
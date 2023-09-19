function updateCounterValue(counter) {
    currentTime = getDate(counter);
    document.getElementById("timeNowDisplay").textContent = currentTime;
    console.log(currentTime);
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
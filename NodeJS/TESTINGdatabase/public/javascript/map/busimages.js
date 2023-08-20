async function loadBusIcons() {
    try {
      const onTimeBusImage = await loadImageAsync('./busimages/OnTimeBus.png');
      map.addImage('OnTimeBus', onTimeBusImage);
      
      const ghostBusImage = await loadImageAsync('./busimages/GhostBus.png');
      map.addImage('GhostBus', ghostBusImage);
      
      const veryLateBusImage = await loadImageAsync('./busimages/VeryLate.png');
      map.addImage('VeryLateBus', veryLateBusImage);
      
      const slightlyLateBusImage = await loadImageAsync('./busimages/SlightlyLate.png');
      map.addImage('SlightlyLateBus', slightlyLateBusImage);
  
    } catch (error) {
      console.error(error);
      console.log("There was an error");
    }
}

function loadImageAsync(path) {
    return new Promise((resolve, reject) => {
      map.loadImage(path, (error, image) => {
        if (error) reject(error);
        resolve(image);
      });
    });
};

// This code gets our bus icons from our desktop 
function getBusIcons(i) {
  if(currentBusStatus[i] == 0) {
      return('OnTimeBus');
  } else if (currentBusStatus[i] == 1) {
      return('SlightlyLateBus');
  } else if (currentBusStatus[i] == 2) {
      return('VeryLateBus');
  } else {
      return('GhostBus');
  };
};
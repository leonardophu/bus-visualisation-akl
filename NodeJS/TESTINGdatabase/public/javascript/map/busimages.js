async function loadBusIcons() {
  const onTimeBusImage = await loadImageAsync('./busimages/OnTimeBus.png');
  map.addImage('OnTimeBus', onTimeBusImage);
  
  const ghostBusImage = await loadImageAsync('./busimages/GhostBus.png');
  map.addImage('GhostBus', ghostBusImage);
  
  const veryLateBusImage = await loadImageAsync('./busimages/VeryLate.png');
  map.addImage('VeryLateBus', veryLateBusImage);
  
  const slightlyLateBusImage = await loadImageAsync('./busimages/SlightlyLate.png');
  map.addImage('SlightlyLateBus', slightlyLateBusImage);

  console.log("loaded");
};

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
  if(currentBusStatus[i] == 1) {
      return('OnTimeBus');
  } else if (currentBusStatus[i] == 2) {
      return('SlightlyLateBus');
  } else if (currentBusStatus[i] == 3) {
      return('VeryLateBus');
  } else {
      return('GhostBus');
  };
};
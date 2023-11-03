// Load the map on mapbox

const map = new mapboxgl.Map({
    container: 'map', // container ID
    // Choose from Mapbox's core styles, or make your own style with Mapbox Studio
    style: 'mapbox://styles/mapbox/streets-v12', // style URL
    center: [174.7645, -36.8509], // starting position [lng, lat]
    zoom: 11 // starting zoom
});

// Make the map object global
window.map = map;
console.log(map instanceof mapboxgl.Map);
mapboxgl.accessToken = 'pk.eyJ1IjoibHBodTUwMCIsImEiOiJjbGhlcHNtZjAwcTdqM2xyNDNuMHBvcXg5In0.dfh6B9xx0-XC3AI6EZs8bg';
const map = new mapboxgl.Map({
container: 'map', // container ID
// Choose from Mapbox's core styles, or make your own style with Mapbox Studio
style: 'mapbox://styles/mapbox/streets-v12', // style URL
center: [-74.001, 40.712], // starting position [lng, lat]
zoom: 13 // starting zoom
});

// Add zoom and rotation controls to the map.
map.addControl(new mapboxgl.NavigationControl());

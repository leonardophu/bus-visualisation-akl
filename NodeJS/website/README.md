# Website
This directory contains all the code that will produce the bus visualisation website.

# Server.js
Contains the code to run my back-end. Assumes we have set up the PostgreSQL. 

The PostgreSQL should contain 4 tables
- Points
- Stops
- Stop Trips
- Route

To run the back-end please run the following code on the bash
```bash
npm run devStart
```
# Public
Contains all the front-end code.
Please note you will need to get an API key from Mapbox.

Create a file called **accesstoken.js** in NodeJS/website/javascript/map/accesstoken.js

The code will be 
```javascript
mapboxgl.accessToken = 'your API key';
```

const express = require('express')
const app = express()
app.use(express.static('public'))
const { Client } = require('pg')

app.listen(3000)

const client = new Client({
  user: 'postgres',
  host: 'localhost',
  database: 'bus_trial',
  password: 'postgres',
  port: 5432,
})

client.connect(function(err) {
  if (err) throw err;
  console.log("Connected!");
});


app.get('/trial.html', (req,res) => {
    console.log('Here')
    res.json({message: "Error"})
})

app.get('/routedata', async(req, res) => {
    const busNumber = req.query.busNumber;

    if (busNumber) {
        const result = await client.query('SELECT shape_id, route_name FROM route_table WHERE route_name = $1', [busNumber])
        res.json(result.rows);
    // This means no busNumber. We actually don't want to input the lines, there will be too many 
    } else {
        console.log("Too many lines ")
    }
});

app.get('/shapedata', async(req,res) => {
    const shapeID = req.query.shapeID;

    try {
        const result = await client.query('SELECT route_coordinates from route_table WHERE shape_id = $1', [shapeID])
        res.json(result.rows);
    } catch(err) {
        console.error(err);
        res.status(500).json({error : 'Failed to retrieve data'});
    }
})

app.get('/busdata', async(req,res) => {
    const busNumber = req.query.busNumber;
    const result = await client.query('SELECT * from points WHERE bus_number = $1', [busNumber])
    res.json(result.rows);
})
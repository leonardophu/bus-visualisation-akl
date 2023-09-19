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
    let values = [];
    if (busNumber) {
        sql = `SELECT * from points WHERE bus_number = $1`;
        values.push(busNumber);
    } else {
        sql = `SELECT * from points`;
    }
    const result = await client.query(sql, values);
    res.json(result.rows);
})

app.get('/busstopsdata', async(req,res) => {
    const busNumber = req.query.busNumber;
    const sql = `
        WITH cte AS (
            SELECT DISTINCT(stop_id)
            FROM stoptrips_table
            WHERE route_name = $1
        )
        SELECT s.stop_coordinates
        FROM stop_table s
        JOIN cte c ON s.stop_id = c.stop_id
    `;
    
    const result = await client.query(sql, [busNumber]);
    res.json(result.rows);
})
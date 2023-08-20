
let sortedNames 

// These name sare used to store the state of the bus. Previous Value is the previous clicked bus value. Current is the one the user inputed 
let previousValue = ""
let currentValue = ""

// Fetch the JSON file and process the data
fetch('./data/uniqueRoutes.json')
  .then(response => response.json())
  .then(data => {
    // Sort names in ascending order
    sortedNames = data.sort();
  })
  .catch(error => console.error('Error fetching the JSON file:', error));

//reference
let input = document.getElementById("input");

//Execute function on keyup
input.addEventListener("keyup", (e) => {

  let directions = document.getElementById("directions");
  directions.innerHTML = input.value;

  //loop through above array
  //Initially remove all elements ( so if user erases a letter or adds new letter then clean previous outputs)
  removeElements();
  for (let i of sortedNames) {
    //convert input to lowercase and compare with each string

    if (
      i.toLowerCase().startsWith(input.value.toLowerCase()) &&
      input.value != ""
    ) {
      //create li element
      let listItem = document.createElement("li");
      //One common class name
      listItem.classList.add("list-items");
      listItem.style.cursor = "pointer";
      // When they click on something we want to record that value 
      listItem.setAttribute("onclick", "displayNames('" + i + "')");
      //Display matched part in bold
      let word = "<b>" + i.substr(0, input.value.length) + "</b>";
      word += i.substr(input.value.length);
      //display the value in array
      listItem.innerHTML = word;
      document.querySelector(".list").appendChild(listItem);
    }
  }
});

form.addEventListener("submit", (e) => {
  e.preventDefault(); // Prevent the default form submission behavior
  removeElements(); // Clear the suggestion list after form submission
});

//Got to fix this 

function displayNames(value) {
  // Set previous value of the bus
  previousValue = currentValue
  // Get the current value of the bus
  currentValue = value;

  //Fill in the input.value with the clicked value whenever someone clicks on a status 
  input.value = value;

  removeElements();
  if (previousValue !== input.value) {
    getBusData(input.value);
  }
}
function removeElements() {
  //clear all the item
  let items = document.querySelectorAll(".list-items");
  items.forEach((item) => {
    item.remove();
  });
}

function getBusData(busNumber) {
    window.location.href = `/map.html?busNumber=${busNumber}`
    fetch(`/getBusData/${busNumber}`)
    .then(response => {
        if (!response.ok) {
            throw new Error('Failed to fetch bus data.');
        }
        console.log("parsing data");
        return response.json();
    })
    // Some data manupulation I work with
    .then(data => {
        console.log(typeof data);
        // Some usecase but here
        let output = '';
        data.forEach(bus => {
            // Format bus data as you wish. This is a simple example.
            output += `<p>Bus ID: ${bus.route_id}, Route: ${bus.route_name}}</p>`;
        });

        const directions = document.getElementById("testingcontent");

        directions.innerHTML = output;
    })
    .catch(error => console.error('Error:', error));
}




let sortedNames 
// These names are used to store the state of the bus. Previous Value is the previous clicked bus value. Current is the one the user inputed 
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

let input = document.getElementById("bus_input");

//Execute function on keyup
input.addEventListener("keyup", (e) => {
  
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
      };
    };
});

function removeElements() {
    //clear all the item
    let items = document.querySelectorAll(".list-items");
    items.forEach((item) => {
        item.remove();
    });
};

function displayNames(value) {
    // Set previous value of the bus
    previousValue = currentValue
    // Get the current value of the bus
    currentValue = value;
  
    //Fill in the input.value with the clicked value whenever someone clicks on a status 
    input.value = value;
  
    removeElements();
    if (previousValue !== input.value) {
      newWebsite(input.value);
    };
};


// If a new bus number is inputted, then we will go into a new website
function newWebsite(busNumber) {
    window.location.href = `/?busNumber=${busNumber}`
};

let sortedNames 
// These name sare used to store the state of the bus. Previous Value is the previous clicked bus value. Current is the one the user inputed 
let previousValue = ""
let currentValue = ""


// Fetch the JSON file and process the data
fetch('/Dataset/uniqueRoutes.json')
  .then(response => response.json())
  .then(data => {
    // Sort names in ascending order
    sortedNames = data.sort();
  })
  .catch(error => console.error('Error fetching the JSON file:', error));

//Reference to the input 
let input = document.getElementById("bus_input");

//Execute function on keyup
input.addEventListener("keyup", (e) => {

  //Initially remove all elements ( so if user erases a letter or adds new letter then clean previous outputs)
  removeElements();

  //Then goes through every bus in the bus list
  for (let bus of sortedNames) {
    //convert input to lowercase and compare with each string

    // If the starting letters of the bus starts with the user input. Want to add it in the list
    if (bus.toLowerCase().startsWith(input.value.toLowerCase()) && input.value != "") {
      //create li element
      let listItem = document.createElement("li");
      //One common class name to do CSS manipulation
      listItem.classList.add("list-items");
      //Add pointer cursor
      listItem.style.cursor = "pointer";
      //When the user CLICKS on a bus. We want to save that value to extract the required data
      listItem.setAttribute("onclick", "displayNames('" + bus + "')");
      //Display matched part in bold
      let word = "<strong>" + bus.substr(0, input.value.length) + "</strong>";
      word += bus.substr(input.value.length);
      //display the value in array
      listItem.innerHTML = word;
      document.querySelector(".list").appendChild(listItem);
    }
  }
});

// DisplayNames function displays and saves the bus the user inputted 
function displayNames(value) {
  // Set previous value of the bus
  previousValue = currentValue
  // Get the current value of the bus
  currentValue = value;
  //Fill in the input.value with the clicked value whenever someone clicks on a status 
  input.value = value;

  removeElements();
}

function removeElements() {
  //clear all the item
  let items = document.querySelectorAll(".list-items");
  items.forEach((item) => {
    item.remove();
  });
}
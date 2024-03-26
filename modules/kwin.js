// kwin.js

// Process command line arguments
const args = process.argv.slice(2);

// Check if any arguments are provided
if (args.length > 0) {
  // Assuming the first argument is the parameter you want to receive
  const parameter = args[0];
  console.log("Parameter received:", parameter);
} else {
  console.log("No parameters received.");
}

// Your main script logic goes here


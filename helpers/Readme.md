## Installation
```
Modules = {
  helpers = "github.com/Donorhan/cubzh-library/helpers:[commit-id]",
}
```

## How to
### Table
`helpers.table.display(table, [customDisplay])`
Displays key-value pairs of the given map on the console.

`helpers.table.every(table, callback)`
Checks if a callback function returns true for every element in the table.

`helpers.table.fill(table, value)`
Fills the table with the value given as a parameter

`helpers.table.filter(table, callback)`
Creates a new table containing only the elements from the original table for which the callback function returns true.

`helpers.table.forEach(table, callback)`
Executes a callback function for each element in the table.

`helpers.table.get(table, key, default)`
Retrieves an element from the array; if the value does not exist, returns the default value given in parameter.

`helpers.table.keys(table)`
Retrieves all the keys of a table.

`helpers.table.map(table, callback)`
Modifies each element in the table using the provided callback function.

`helpers.table.merge(firstTable, secondTable)`
Merges two arrays: if an element in the second array already exists in the first, its value will be overwritten.

`helpers.table.sample(table)`
Take a random element from the array.

`helpers.table.values(table)`
Returns an array containing all the values from the table.

`helpers.table.removeKey(table, key)`
Removes a key-value pair from the table, if the key exists.

`helpers.table.some(table, callback)`
Checks if at least one element in the table satisfies the condition specified by the callback function.

### Math
`helpers.math.clamp(value, min, max)`
Clamp a value between min and max included.

`helpers.math.lerp(from, to, time)`
Linear interpolation between two values

`helpers.math.pingPong(value, length)`
The value will alternate between "value" and "length" progressively.

`helpers.math.repeatValue(value, length)`
The value will go to "length" and then return directly to 0.

`helpers.math.remap(value, low1, high1, low2, high2)`
Remaps a value from one range to another using linear interpolation.

`helpers.math.round(value)`
Round a number to its nearest higher or lower value.

### Shape
`helpers.shape.easeColorLinear = function(shape, startColor, color, duration, paletteIndexes = { 1 })`
Gradually animates the color of a shape

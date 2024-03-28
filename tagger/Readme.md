## Installation
```
Modules = {
  helpers = "github.com/Donorhan/cubzh-library/tagger:[commit-id]",
}
```

## How to
### Properties
`tagger.tags`
List of tags with their associated table of objects.
```
 {
   "tag1": ["object1", "object2"],
   "tag2": ["object3"], 
 }
```

### Functions
`tagger.tag(object, tags: array)`
Associates one or more tags with a given object.

`tagger.findAll(tags: array)`
Retrieves all objects that have been tagged with any of the specified tags. It returns an array containing all the objects found.

`tagger.findAllWithAllTags(tags: array)`
Return all objects possessing the entire set of tags provided as parameters.

`tagger.call(tags, callback)`
Finds all objects associated with the specified tags and executes a callback function on each of them.

`tagger.removeTags(object, [tags: array])`
Removes tags from an object. Deletes all tags if the "tags" parameter is not specified

## Examples

### Simple example
```
local playerA = { ["name"] = "Foo" }
local playerB = { ["name"] = "Bar" }
local playerC = { ["name"] = "Baz" }

tagger.tag(playerA, { "friends" })
tagger.tag(playerB, { "enemies" })
tagger.tag(playerC, { "friends", "npc" })

local friendsWithTags = tagger.findAll({ "enemies", "npc" })
table.display(friendsWithAllTags) -- Bar, Baz

local friendsWithAllTags = tagger.findAllWithAllTags({ "friends", "npc" })
table.display(friendsWithAllTags) -- Baz

tagger.call({ "enemies", "npc" }, function(object)
    -- Bar, Baz
end)
```

### Display objects per tag (using helper module)
```
helpers.table.display(tagger.tags, function(objects, tag)
  print(tag)
  helpers.table.display(objects, function(object, key) print("->", object.name) end)
end)
```

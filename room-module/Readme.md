
## Installation

```
Modules = {
	roomModule = "github.com/Donorhan/cubzh-library/room-module:[commit-id]",
}
```

## How to
```
local config = {
        width = 32,
        height = 10,
        depth = 12,
        bottom = {
            blocScale = 3,
            thickness = 1,
        },
        left = {
            blocScale = 100,
            color = wallColor,
            thickness = 1,
        },
        right = {
            blocScale = 100,
            color = wallColor,
            thickness = 1,
        },
        front = {
            ignore = true,
        },
        top = {
            blocScale = 1,
            thickness = 1,
        },
        back = {
            blocScale = 100,
            color = backgroundColor,
            thickness = 1,
        },
    }

    local room = mod.create(roomConfig)
    room.root:SetParent(World)

    -- Edit room main object
    room.root.Scale = Number3(2, 2, 2)

    -- Get room walls & edit properties
    room.walls[Face.Bottom].CollisionGroups = 5
    room.walls[Face.Bottom].CollidesWithGroups = 1
```

## Functions
`create(conf: {})`
Create a new room

`createWall(face: Face, blocSizeMax: Integer, paintColor: Color)`
Create a wall/face to the room

`createHoleFromBlockCoordinates(face: Face, blockCoordinates: Number3, size: Number3)`
Create an hole in a wall at the given block coordinates and with the given size around

`destroy()`
Remove the room

local conf = require("config")

local defaultConfig = {
    width = 80,
    height = 30,
    depth = 40,
    top = {
        blocScale = 4,
        color = Color.Pink,
        thickness = 2,
    },
    bottom = {
        blocScale = 2,
        color = Color.Red,
        thickness = 2,
    },
    left = {
        blocScale = 4,
        color = Color.Blue,
        thickness = 2,
    },
    right = {
        blocScale = 4,
        color = Color.Green,
        thickness = 2,
    },
    front = {
        blocScale = 4,
        color = Color.Purple,
        thickness = 2,
    },
    back = {
        blocScale = 4,
        color = Color.Yellow,
        thickness = 2,
    },
    exteriorColor = Color(150, 150, 150),
    paintSize = 0.01,
}

local WALL_CONFIGS = {
    [Face.Bottom] = {
        getDimensions = function(config)
            return {
                width = config.width,
                height = config.bottom.thickness,
                depth = config.depth
            }
        end,
        getPosition = function(_)
            return Number3(0, 0, 0)
        end,
        paintFace = Face.Top
    },

    [Face.Top] = {
        getDimensions = function(config)
            return {
                width = config.width,
                height = config.top.thickness,
                depth = config.depth
            }
        end,
        getPosition = function(config)
            return Number3(0, config.height - config.top.thickness, 0)
        end,
        paintFace = Face.Bottom
    },

    [Face.Back] = {
        getDimensions = function(config, wallHeight)
            return {
                width = config.width - config.left.thickness * 2,
                height = wallHeight,
                depth = config.back.thickness
            }
        end,
        getPosition = function(config)
            return Number3(
                0,
                config.bottom.thickness,
                config.depth * 0.5 - config.back.thickness * 0.5
            )
        end,
        paintFace = Face.Front
    },

    [Face.Front] = {
        getDimensions = function(config, wallHeight)
            return {
                width = config.width - config.left.thickness * 2,
                height = wallHeight,
                depth = config.front.thickness
            }
        end,
        getPosition = function(config)
            return Number3(
                0,
                config.bottom.thickness,
                -config.depth * 0.5 + config.front.thickness * 0.5
            )
        end,
        paintFace = Face.Back
    },

    [Face.Left] = {
        getDimensions = function(config, wallHeight)
            return {
                width = config.left.thickness,
                height = wallHeight,
                depth = config.depth
            }
        end,
        getPosition = function(config)
            return Number3(
                -config.width * 0.5 + config.left.thickness * 0.5,
                config.bottom.thickness,
                0
            )
        end,
        paintFace = Face.Right
    },

    [Face.Right] = {
        getDimensions = function(config, wallHeight)
            return {
                width = config.right.thickness,
                height = wallHeight,
                depth = config.depth
            }
        end,
        getPosition = function(config)
            return Number3(
                config.width * 0.5 - config.right.thickness * 0.5,
                config.bottom.thickness,
                0
            )
        end,
        paintFace = Face.Left
    }
}

local ALL_FACES = {
    { name = "top", face = Face.Top },
    { name = "bottom", face = Face.Bottom },
    { name = "back", face = Face.Back },
    { name = "front", face = Face.Front },
    { name = "left", face = Face.Left },
    { name = "right", face = Face.Right }
}

local function createWall(room, face, blocSizeMax, paintColor)
    local wallConfig = WALL_CONFIGS[face]
    local wallHeight = room:_calculateWallHeight()
    local dimensions = wallConfig.getDimensions(room.config, wallHeight)
    local position = wallConfig.getPosition(room.config)

    return room:_createWallWithPaint(
        dimensions.width,
        dimensions.height,
        dimensions.depth,
        position,
        wallConfig.paintFace,
        blocSizeMax,
        paintColor
    )
end

local mod = {}
mod.create = function(config)
    local room = {}
    room.__index = room

    function room.new(roomConfig)
        local self = setmetatable({}, room)
        self.config = roomConfig

        self.root = Object()
        self.walls = {}
        self.root.room = self

        for _, faceData in ipairs(ALL_FACES) do
            local config = self.config[faceData.name]
            if config and not config.ignore then
                self:createWall(faceData.face, config.blocScale, config.color)
            end
        end

        return self
    end

    function room:_calculateWallHeight()
        return self.config.height - self.config.bottom.thickness - self.config.top.thickness
    end

    function room:_calculateOptimalBlockSize(value, maxBlockSize)
        if value <= maxBlockSize then
            return value
        end

        local limit = math.min(maxBlockSize, math.floor(value * 0.5))
        for size = limit, 1, -1 do
            if value % size == 0 then
                return size
            end
        end

        return 1
    end

    function room:_createShape(parent, width, height, depth, blocSizeMax, color)
        local blocCount = Number3(
            math.max(math.floor(width / self:_calculateOptimalBlockSize(width, blocSizeMax)) - 1, 0),
            math.max(math.floor(height / self:_calculateOptimalBlockSize(height, blocSizeMax)) - 1, 0),
            math.max(math.floor(depth / self:_calculateOptimalBlockSize(depth, blocSizeMax)) - 1, 0)
        )

        local optimalSizes = Number3(
            self:_calculateOptimalBlockSize(width, blocSizeMax),
            self:_calculateOptimalBlockSize(height, blocSizeMax),
            self:_calculateOptimalBlockSize(depth, blocSizeMax)
        )

        local shape = MutableShape()
        shape:SetParent(parent)
        shape.Physics = PhysicsMode.Static

        local countZ = blocCount.Z + 1
        local countY = blocCount.Y + 1
        local countZY = countZ * countY
        local totalBlocks = countZY * (blocCount.X + 1)
        for index = 0, totalBlocks - 1 do
            local k = index % countZ
            local j = math.floor(index / countZ) % countY
            local i = math.floor(index / countZY)
            shape:AddBlock(color, i, j, k)
        end

        shape.Pivot = Number3(shape.Width * 0.5, 0, shape.Depth * 0.5)
        shape.LocalScale = optimalSizes

        return shape
    end

    function room:_calculateRelativeShapePosition(referenceShape, shape, face)
        local positions = {
            [Face.Top] = Number3(0, referenceShape.Height, 0),
            [Face.Bottom] = Number3(0, -shape.Height * shape.LocalScale.Y, 0),
            [Face.Left] = Number3(-referenceShape.Width * 0.5 - (shape.Width * 0.5) * shape.LocalScale.X, 0, 0),
            [Face.Right] = Number3(referenceShape.Width * 0.5 + (shape.Width * 0.5) * shape.LocalScale.X, 0, 0),
            [Face.Back] = Number3(0, 0, referenceShape.Depth * 0.5 + shape.Depth * 0.5 * shape.LocalScale.Z),
            [Face.Front] = Number3(0, 0, -referenceShape.Depth * 0.5 - shape.Depth * 0.5 * shape.LocalScale.Z)
        }

        return positions[face]
    end

    function room:_createWallWithPaint(width, height, depth, position, paintFace, blocSizeMax, paintColor)
        local wall = self:_createShape(self.root, width, height, depth, blocSizeMax, self.config.exteriorColor)

        if paintColor then
            local dimensionMap = {
                [Face.Left] = Number3(1, height, depth),
                [Face.Right] = Number3(1, height, depth),
                [Face.Top] = Number3(width, 1, depth),
                [Face.Bottom] = Number3(width, 1, depth),
                [Face.Front] = Number3(width, height, 1),
                [Face.Back] = Number3(width, height, 1)
            }

            local dims = dimensionMap[paintFace]
            wall.paintShape = self:_createShape(wall, dims.X, dims.Y, dims.Z, blocSizeMax, paintColor)
            wall.paintShape.Physics = PhysicsMode.Disabled

            local paintMargin = 0.999
            local scaleX = ((paintFace == Face.Left or paintFace == Face.Right) and self.config.paintSize or 1) * paintMargin
            local scaleY = ((paintFace == Face.Top or paintFace == Face.Bottom) and self.config.paintSize or 1) * paintMargin
            local scaleZ = ((paintFace == Face.Front or paintFace == Face.Back) and self.config.paintSize or 1) * paintMargin
            wall.paintShape.LocalScale = Number3(scaleX, scaleY, scaleZ)
            wall.paintShape.LocalPosition = self:_calculateRelativeShapePosition(wall, wall.paintShape, paintFace)
        end

        wall.LocalPosition = position
        return wall
    end

    function room:createWall(face, blocSizeMax, paintColor)
        self.walls[face] = createWall(self, face, blocSizeMax, paintColor)
        self.walls[face].room = self
    end

    function room:createHoleFromBlockCoordinates(face, blockCoordinates, size)
        local wall = self.walls[face]
        if not wall then
            return
        end

        local startX = math.max(0, blockCoordinates.X - math.floor(size.X / 2))
        local startY = math.max(0, blockCoordinates.Y - math.floor(size.Y / 2))
        local startZ = math.max(0, blockCoordinates.Z - math.floor(size.Z / 2))
        local endX = math.min(wall.Width - 1, blockCoordinates.X + math.floor(size.X / 2))
        local endY = math.min(wall.Height - 1, blockCoordinates.Y + math.floor(size.Y / 2))
        local endZ = math.min(wall.Depth - 1, blockCoordinates.Z + math.floor(size.Z / 2))
        local shapesToCheck = { wall, wall.paintShape }
        local blocksToRemove = {}

        for _, shape in ipairs(shapesToCheck) do
            if shape then
                for x = startX, endX do
                    for y = startY, endY do
                        for z = startZ, endZ do
                            local block = shape:GetBlock(x, y, z)
                            if block ~= nil then
                                table.insert(blocksToRemove, block)
                            end
                        end
                    end
                end
            end
        end

        for _, block in ipairs(blocksToRemove) do
            block:Remove()
        end
    end

    function room:destroy()
        if self.root then
            self.root:RemoveFromParent()
        end

        self.walls = nil
        self.config = nil
        self.root = nil
    end

    return room.new(conf:merge(defaultConfig, config))
end

return mod

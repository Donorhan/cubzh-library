local hierarchyActions = require("hierarchyactions")

local mod = {}

mod.dustify = function(entity, config)
    local stride = config.stride or 4
    local direction = config.direction or Number3.Zero
    local velocity = config.velocity or Number3(30, 150, 30)

    local function calculateVelocity()
        if direction == Number3.Zero then
            return Number3(
                math.random(-velocity.X, velocity.X),
                math.random(100, velocity.Y),
                math.random(-velocity.Z, velocity.Z)
            )
        else
            local x = math.random(2, velocity.X) * sign(direction.X)
            local z = math.random(2, velocity.Z) * sign(direction.Z)
            return Number3(x, math.random(100, velocity.Y), z)
        end
    end

    local convertToParticles = function(s)
        local container = Object()
        for i = 0, s.Width - 1, stride do
            for j = 0, s.Height - 1, stride do
                for k = 0, s.Depth - 1, stride do
                    local block = s:GetBlock(i, j, k)
                    if block ~= nil then
                        local cube = MutableShape()
                        cube:AddBlock(config.blockColor or block.Color, 0, 0, 0)
                        container:AddChild(cube)
                        cube.Position = s:BlockToWorld(i, j, k)
                        cube.Physics = PhysicsMode.Dynamic
                        cube.CollisionGroups = config.collisionGroups
                        cube.CollidesWithGroups = config.collidesWithGroups
                        cube.Bounciness = config.bounciness or 0.6
                        cube.Velocity = calculateVelocity()
                    end
                end
            end
        end

        return container
    end

    local shapeContainer = Object()
    hierarchyActions:applyToDescendants(entity, { includeRoot = true }, function(o)
        if type(o) == "Shape" or type(o) == "MutableShape" then
            local particlesContainer = convertToParticles(o)
            shapeContainer:AddChild(particlesContainer)
        end
    end)

    shapeContainer:SetParent(World)

    Timer(config.duration or 1.5, false, function()
        shapeContainer:RemoveFromParent()
    end)
end

return mod

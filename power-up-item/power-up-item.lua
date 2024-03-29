local powerUpItem = {
    defaultConfig = {
        color = Color(220, 220, 255, 140),
        model = nil,
        modelScale = Number3(1, 1, 1),
        onCollected = nil,
        onCollectedEffect = nil,
    },
}

local lerp = function(from, to, time)
    return from + (to - from) * time
end

local defaultCollectAnimation = function(container, color)
    local particles = require("particles")
    local emitter = particles:newEmitter({
        life = function()
            return 1
        end,
        velocity = function()
            return Number3(math.random(-35, 35), math.random(0, 75), math.random(-35, 35))
        end,
        color = function()
            return color or powerUpItem.defaultConfig.color
        end,
        scale = function()
            return Number3(0.5, 0.5, 0.5)
        end,
    })
    container:AddChild(emitter)
    emitter:spawn(20)
end

powerUpItem.create = function(config)
    local powerUpContainer = Object()
    powerUpContainer.Physics = PhysicsMode.Disabled

    local mainContainer = Object()
    mainContainer.Physics = PhysicsMode.Disabled
    powerUpContainer:AddChild(mainContainer)

    local collisionArea = MutableShape()
    collisionArea:AddBlock(config.color or powerUpItem.defaultConfig.color, Number3.Zero)
    mainContainer:AddChild(collisionArea)
    collisionArea.Scale = Number3(7.5, 7.5, 7.5)
    collisionArea.Pivot = Number3(0.5, 0.5, 0.5)
    collisionArea.Rotation = { 45, 0, 25 }
    collisionArea.Physics = PhysicsMode.Trigger
    collisionArea.CollisionGroups = PowerUpsCollisionGroups
    collisionArea.CollidesWithGroups = Player.CollisionGroups
    collisionArea.OnCollisionBegin = function(_, other)
        if not other.UserID then
            return
        end

        if config.onCollectedEffect then
            config.onCollectedEffect(other, powerUpContainer)
        else
            defaultCollectAnimation(powerUpContainer, config.color)
            sfx("whooshes_small_2", { Position = powerUpContainer.Position, Volume = 0.75 })
        end

        if config.onCollected then
            config.onCollected(other, powerUpContainer)
        end
    end

    local shape = Shape(config.model)
    mainContainer:AddChild(shape)
    shape.Scale = config.modelScale or powerUpItem.defaultConfig.modelScale
    shape.Physics = PhysicsMode.Disabled

    -- animations
    collisionArea.animTime = 0
    collisionArea.Tick = function(object, dt)
        local newRotation = lerp(0, 360, collisionArea.animTime)
        collisionArea.Rotation = { 65, newRotation, -newRotation }
        collisionArea.animTime = collisionArea.animTime + (dt / 200.0)
    end

    local ease = require("ease")
    mainContainer.anim = function()
        ease:inOutSine(mainContainer, 0.2, {
            onDone = function()
                ease:inOutSine(mainContainer, 0.2, {
                    onDone = function()
                        mainContainer.anim()
                    end,
                }).Scale = Number3(0.8, 1.2, 0.8)
            end,
        }).Scale = Number3(1.2, 0.8, 1.2)
    end
    mainContainer.anim()

    return powerUpContainer
end

return powerUpItem

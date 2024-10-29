local ease = require("ease")

local helpers = {
    colors = {},
    math = {},
    table = {},
    shape = {},
}


----------------
-- Table
----------------
helpers.table.copy = function(t)
    local copy = {}
    for index, value in pairs(t) do
        copy[index] = value
    end

    return setmetatable(copy, getmetatable(t))
end

helpers.table.display = function(map, customDisplay)
    if not customDisplay then
        for index, value in pairs(map) do
            print(index, " -> ", value)
        end
    else
        for index, value in pairs(map) do
            print(customDisplay(value, index, map))
        end
    end
end

helpers.table.every = function(t, callback)
    local mapLength = helpers.table.length(t)
    local succeedCount = 0

    for index, value in pairs(t) do
        if callback(value, index, t) then
            succeedCount = succeedCount + 1
        end
    end

    return succeedCount == mapLength
end

helpers.table.fill = function(t, value)
    for index, _ in pairs(t) do
        t[index] = value
    end
end

helpers.table.filter = function(t, callback)
    local filteredMap = {}
    for key, value in pairs(t) do
        if callback(value, key, t) then
            filteredMap[key] = value
        end
    end

    return filteredMap
end

helpers.table.findIndex = function(t, value)
    for index, tableValue in pairs(t) do
        if tableValue == value then
            return index
        end
    end

    return -1
end

helpers.table.forEach = function(t, callback)
    for index, value in pairs(t) do
        callback(value, index, t)
    end
end

helpers.table.get = function(t, key, default)
    return t[key] or default
end

helpers.table.keys = function(t)
    local keys = {}
    for key in pairs(t) do
        table.insert(keys, key)
    end

    return keys
end

helpers.table.map = function(t, callback)
    for index, value in pairs(t) do
        t[index] = callback(value, index, t)
    end
end

helpers.table.merge = function(firstTable, secondTable)
    local mergedTables = {}

    local func = function(value, key) mergedTables[key] = value end
    helpers.table.forEach(firstTable, func)
    helpers.table.forEach(secondTable, func)

    return mergedTables
end

helpers.table.sample = function(t)
    local keys = helpers.table.keys(t)
    local size = #keys
    if size > 0 then
        local key = keys[math.random(size)]
        return t[key]
    end
end

helpers.table.values = function(t)
    local values = {}
    for _, value in pairs(t) do
        table.insert(values, value)
    end

    return values
end

helpers.table.removeKey = function(t, key)
    if t[key] then
        t[key] = nil
    end
end

helpers.table.some = function(t, callback)
    for index, value in pairs(t) do
        if callback(value, index, t) then
            return true
        end
    end

    return false
end


----------------
-- Math
----------------
helpers.math.clamp = function(value, min, max)
    return math.min(math.max(value, min), max)
end

helpers.math.lerp = function(from, to, time)
    return from + (to - from) * time
end

helpers.math.remap = function(value, low1, high1, low2, high2)
    return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

helpers.math.round = function(value)
    return math.floor(value + 0.5)
end

helpers.math.pingPong = function(value, length)
    local mod = value % (length * 2)
    return length - math.abs(mod - length)
end

helpers.math.repeatValue = function(value, length)
    return value % length
end


----------------
-- Shape
----------------
helpers.shape.easeColorLinear = function(shape, startColor, color, duration, paletteIndexes)
    if shape.easeColor then
        ease:cancel(shape.easeColor)
    end

    local conf = {
        onUpdate = function(obj)
            for _, index in ipairs(paletteIndexes or { 1 }) do
                shape.Palette[index].Color:Lerp(startColor, color, obj.easeLerp)
            end
        end
    }

    shape.easeLerp = 0.0
    shape.easeColor = ease:linear(shape, duration, conf)
    shape.easeColor.easeLerp = 1.0
end


----------------
-- Colors
----------------
helpers.colors.HSLToRGB = function(h, s, l)
    h = h / 360
    s = s / 100
    l = l / 100

    local function hue2rgb(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end

    local r, g, b
    if s == 0 then
        r, g, b = l, l, l
    else
        local q = l < 0.5 and l * (1 + s) or l + s - l * s
        local p = 2 * l - q

        r = hue2rgb(p, q, h + 1/3)
        g = hue2rgb(p, q, h)
        b = hue2rgb(p, q, h - 1/3)
    end

    return Color(
        math.floor(r * 255 + 0.5),
        math.floor(g * 255 + 0.5),
        math.floor(b * 255 + 0.5)
    )
end

helpers.colors.RGBToHSL = function(color)
    local r = color.R / 255
    local g = color.G / 255
    local b = color.B / 255

    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2

    if max ~= min then
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)

        if max == r then
            h = (g - b) / d
            if g < b then h = h + 6 end
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end

        h = h / 6
    end

    return {
        h = math.floor(h * 360 + 0.5),
        s = math.floor(s * 100 + 0.5),
        l = math.floor(l * 100 + 0.5)
    }
end

return helpers

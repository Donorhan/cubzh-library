local helpers = {
    color = {},
    math = {},
    shape = {},
}

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

helpers.table.length = function(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end

    return count
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

return helpers

local helpers = {}

helpers.display = function(map)
  for index, value in pairs(map) do
    print(index, " -> ", value)
  end
end

helpers.every = function(t, callback)
  local mapLength = helpers.length(t)
  local succeedCount = 0

  for index, value in pairs(t) do
    if callback(value, index, t) then
      succeedCount = succeedCount + 1
    end
  end

  return succeedCount == mapLength
end

helpers.filter = function(t, callback)
  local filteredMap = {}
  for key, value in pairs(t) do
    if callback(value, key, t) then
      filteredMap[key] = value
    end
  end

  return filteredMap
end

helpers.forEach = function(t, callback)
  for index, value in pairs(t) do
    callback(value, index, t)
  end
end

helpers.length = function(t)
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end

  return count
end

helpers.map = function(t, callback)
  for index, value in pairs(t) do
    t[index] = callback(value, index, t)
  end
end

helpers.values = function(t)
  local values = {}
  for _, value in pairs(t) do
    table.insert(values, value)
  end

  return values
end

helpers.removeKey = function(t, key)
  if t[key] then
    t[key] = nil
  end
end

helpers.some = function(t, callback)
  for index, value in pairs(t) do
    if callback(value, index, t) then
      return true
    end
  end

  return false
end

helpers.remap = function(value, low1, high1, low2, high2)
  return low2 + (value - low1) * (high2 - low2) / (high1 - low1)
end

return helpers

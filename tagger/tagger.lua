local tagger = {}

-- Formatted like that
-- {
--   "tag1": ["object1", "object2"],
--   "tag2": ["object3"], 
-- }
tagger.tags = {}

local findTableIndex = function(t, v)
    for index, tableValue in pairs(t) do
        if tableValue == v then
            return index
        end
    end

    return -1
end

tagger.tag = function(object, tags)
    for _, tag in ipairs(tags) do
        if not tagger.tags[tag] then
            tagger.tags[tag] = {}
        end

        table.insert(tagger.tags[tag], object)
    end
end

tagger.findAll = function(tags)
    local objects = {}
    for _, tag in ipairs(tags) do
        if tagger.tags[tag] then
            for _, object in ipairs(tagger.tags[tag]) do
                table.insert(objects, object)
            end
        end
    end

    return objects
end

tagger.findAllWithAllTags = function(tags)
    local objects = {}
    local firstTag = tags[1]

    if not tagger.tags[firstTag] then
        return objects
    end

    local taggedObjects = {}
    for _, object in ipairs(tagger.tags[firstTag]) do
        taggedObjects[object] = true
    end

    for i = 2, #tags do
        local tag = tags[i]
        if not tagger.tags[tag] then
            return objects
        end

        for object, _ in pairs(taggedObjects) do
            if findTableIndex(tagger.tags[tag], object) == -1 then
                taggedObjects[object] = nil
            end
        end
    end

    for object, _ in pairs(taggedObjects) do
        table.insert(objects, object)
    end

    return objects
end

tagger.call = function(tags, callback)
    local objects = tagger.findAll(tags)
    for _, object in ipairs(objects) do
        callback(object)
    end
end

tagger.removeTags = function(object, tags)
    if tags then
        for i, tag in ipairs(tags) do
            local index = findTableIndex(tagger.tags[tag], object)
            if index ~= -1 then
                table.remove(tagger.tags[tag], index)
            end
        end
    else
        for tag, objects in pairs(tagger.tags) do
            local index = findTableIndex(objects, object)
            if index ~= -1 then
                table.remove(tagger.tags[tag], index)
            end
        end
    end
end

return tagger

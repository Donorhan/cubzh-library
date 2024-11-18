local mod = {}

mod.create = function(size, createFunc, autoResize)
    local pool = {}
    pool.__index = pool

    function pool.new(size, createFunc, autoResize)
        local self = setmetatable({}, pool)
        self.size = 0
        self.createFunc = createFunc
        self.objects = {}
        self.available = {}
        self.autoResize = autoResize or false

        if size > 0 then
            self:resize(size)
        else
            self.autoResize = true
        end

        return self
    end

    function pool:acquire()
        local index
        for i = 1, self.size do
            if self.available[i] then
                index = i
                break
            end
        end

        if not index then
            if self.autoResize then
                self:resize(self.size + self.resizeAmount)
                return self:acquire()
            else
                return nil
            end
        end

        self.available[index] = false
        local obj = self.objects[index]
        obj.poolIndex = index

        return obj
    end

    function pool:acquireRandom()
        local availableIndices = {}
        for i = 1, self.size do
            if self.available[i] then
                table.insert(availableIndices, i)
            end
        end

        if #availableIndices == 0 then
            return nil
        end

        local randomIndex = math.random(#availableIndices)
        local selected = availableIndices[randomIndex]

        self.available[selected] = false
        local obj = self.objects[selected]
        obj.poolIndex = selected

        return obj
    end

    function pool:release(obj)
        local index = obj.poolIndex
        if not index or not self.objects[index] then
            print("Tried to release an object that is not managed by this pool: ", obj, index, self.objects[index])
            return
        end

        self.available[index] = true
    end

    function pool:releaseAll()
        for i = 1, self.size do
            self.available[i] = true
        end
    end

    function pool:resize(newSize)
        if newSize <= self.size then return end

        for i = self.size + 1, newSize do
            local obj = self.createFunc()
            obj.poolIndex = i
            self.objects[i] = obj
            self.available[i] = true
        end

        self.size = newSize
        self.resizeAmount = math.max(math.floor(self.size * 0.5), 1)
    end

    function pool:forEach(func)
        for i = 1, self.size do
            if not self.available[i] then
                func(self.objects[i])
            end
        end
    end

    return pool.new(size, createFunc, autoResize)
end

return mod

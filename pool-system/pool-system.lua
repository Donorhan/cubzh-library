local mod = {}

function table.contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

mod.create = function(size, createFunc, autoResize)
    local pool = {}
    pool.__index = pool

    function pool.new(size, createFunc, autoResize)
        local self = setmetatable({}, pool)
        self.size = size
        self.createFunc = createFunc
        self.objects = {}
        self.available = {}
        self.autoResize = autoResize or false
        self.resizeAmount = math.max(math.floor(size * 0.5), 1)
        self:init()

        return self
    end

    function pool:init()
        for i = 1, self.size do
            local obj = self.createFunc()
            obj.poolIndex = i
            self.objects[i] = obj
            self.available[i] = i
        end
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

        self.available[index] = nil
        local obj = self.objects[index]
        obj.poolIndex = index

        return obj
    end

    function pool:acquireRandom()
        local count = 0
        local selected
        for k in pairs(self.available) do
            count = count + 1
            if math.random(count) == 1 then
                selected = k
            end
        end

        if not selected then
            if self.autoResize then
                self:resize(self.size + self.resizeAmount)
                return self:acquire()
            else
                return nil
            end
        end

        self.available[selected] = nil
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
            self.available[i] = i
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

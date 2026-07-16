---@diagnostic disable param-type-mismatch

--[[-------------------------------------
    Signal
--]]-------------------------------------

---@class SUI_Signal<F>: { Connect: fun(self: SUI_Signal<F>, fn: F), Disconnect: fun(self: SUI_Signal<F>, fn: F) }
---@field list {func: F, id: string?}[]
---@overload fun(): SUI_Signal<F>
local Signal = {}
Signal.__index = Signal

---
---@return SUI_Signal
function Signal:new()
    local object = {
        list = {}
    }

    return setmetatable(object, self)
end

---
---@param fn F
---@param id string?
function Signal:Connect(fn, id)
    self.list[#self.list + 1] = {
        func = fn,
        id = id
    }
end

---
---@param fn F
---@return boolean
function Signal:Disconnect(fn)
    for i = #self.list, 1, -1 do
        local callback = self.list[i]
        if callback.func == fn then
            table.remove(self.list, i)
            return true
        end
    end

    return false
end

---
---@param id string
---@return boolean
function Signal:DisconnectByID(id)
    for i = #self.list, 1, -1 do
        local callback = self.list[i]
        if callback.id == id then
            table.remove(self.list, i)
            return true
        end
    end

    return false
end

---
---@param ...any
function Signal:Emit(...)
    local list = self.list
    if #list == 0 then return end

    for i = #list, 1, -1 do
        local callback = list[i]
        callback.func(...)
    end
end

--[[-------------------------------------
    Exports
--]]-------------------------------------

SektaUI.Signal = setmetatable(Signal, {
    __call = function(self, ...)
        return self:new(...)
    end
})

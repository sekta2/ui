---@diagnostic disable param-type-mismatch

--[[-------------------------------------
    Signal
--]]-------------------------------------

---@class SUI_Signal<F>: { Connect: fun(self: SUI_Signal<F>, fn: F), Disconnect: fun(self: SUI_Signal<F>, fn: F) }
---@field list F[]
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
function Signal:Connect(fn)
    self.list[#self.list+1] = fn
end

---
---@param fn F
function Signal:Disconnect(fn)
    for i = #self.list, 1, -1 do
        local other_fn = self.list[i]
        if other_fn == fn then
            table.remove(self.list, i)
            break
        end
    end
end

---
---@param ...any
function Signal:Emit(...)
    local list = self.list
    if #list == 0 then return end

    for i = #list, 1, -1 do
        local fn = list[i]
        fn(...)
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

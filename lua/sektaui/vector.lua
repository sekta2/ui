---@diagnostic disable param-type-mismatch

---@class Vector2
---@field x number
---@field y number
---@overload fun(x: number, y: number): Vector2
local Vector2 = {}
Vector2.__index = Vector2

---@param x number
---@param y number
---@return Vector2
function Vector2:new(x, y)
    x = x or 0
    y = y or 0

    return setmetatable({
        x = x,
        y = y
    }, self)
end

---@param self Vector2
---@param other any
---@private
Vector2.__add = function(self, other)
    if type(other) == "number" then
        return Vector2:new(self.x + other, self.y + other)
    else
        return Vector2:new(self.x + other.x, self.y + other.y)
    end
end

---@param self Vector2
---@param other any
---@private
Vector2.__sub = function(self, other)
    if type(other) == "number" then
        return Vector2:new(self.x - other, self.y - other)
    else
        return Vector2:new(self.x - other.x, self.y - other.y)
    end
end

---@param self Vector2
---@param other any
---@private
Vector2.__mul = function(self, other)
    if type(other) == "number" then
        return Vector2:new(self.x * other, self.y * other)
    else
        return Vector2:new(self.x * other.x, self.y * other.y)
    end
end

---@param self Vector2
---@param other any
---@private
Vector2.__div = function(self, other)
    if type(other) == "number" then
        return Vector2:new(self.x / other, self.y / other)
    else
        return Vector2:new(self.x / other.x, self.y / other.y)
    end
end

---@param self Vector2
---@private
Vector2.__unm = function(self)
    return Vector2:new(-self.x, -self.y)
end

---@param self Vector2
---@param other Vector2
---@private
Vector2.__eq = function(self, other)
    return self.x == other.x and self.y == other.y
end

---@param self Vector2
---@private
Vector2.__tostring = function(self)
    return string.format("Vector2(%s, %s)", self.x, self.y)
end

---@param self Vector2
---@param other any
---@private
Vector2.__concat = function(self, other)
    return tostring(self) .. tostring(other)
end

SektaUI.Vector2 = setmetatable(Vector2, {
    __call = function(self, ...)
        return self:new(...)
    end
})

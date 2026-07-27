---@diagnostic disable param-type-mismatch

---@alias ANCHOR_GROW 0|1|2

SektaUI.ANCHOR_GROW_TOP = 0
SektaUI.ANCHOR_GROW_LEFT = 0
SektaUI.ANCHOR_GROW_BOTH = 1
SektaUI.ANCHOR_GROW_BOTTOM = 2
SektaUI.ANCHOR_GROW_RIGHT = 2

---@class Anchor
---@field left number
---@field right number
---@field top number
---@field bottom number
---@field left_offset number
---@field right_offset number
---@field top_offset number
---@field bottom_offset number
---@field grow_horizontal ANCHOR_GROW
---@field grow_vertical ANCHOR_GROW
---@overload fun(): Anchor
local Anchor = {}
Anchor.__index = Anchor

---@return Anchor
function Anchor:new()
    return setmetatable({
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
        left_offset = 0,
        right_offset = 0,
        top_offset = 0,
        bottom_offset = 0,
        grow_horizontal = 0,
        grow_vertical = 0
    }, self)
end

---@return Anchor
function Anchor:Clone()
    return setmetatable({
        left = self.left,
        right = self.right,
        top = self.top,
        bottom = self.bottom,
        left_offset = self.left_offset,
        right_offset = self.right_offset,
        top_offset = self.top_offset,
        bottom_offset = self.bottom_offset,
        grow_horizontal = self.grow_horizontal,
        grow_vertical = self.grow_vertical
    }, Anchor)
end

---@param left number
---@param right number
---@param top number
---@param bottom number
---@return Anchor
function Anchor:SetPoints(left, right, top, bottom)
    self.left = left
    self.right = right
    self.top = top
    self.bottom = bottom

    return self
end

---@param left number
---@param right number
---@param top number
---@param bottom number
---@return Anchor
function Anchor:SetOffset(left, right, top, bottom)
    self.left_offset = left
    self.right_offset = right
    self.top_offset = top
    self.bottom_offset = bottom

    return self
end

---@param type ANCHOR_GROW
---@return Anchor
function Anchor:SetGrowHorizontal(type)
    self.grow_horizontal = type
    return self
end

---@param type ANCHOR_GROW
---@return Anchor
function Anchor:SetGrowVertical(type)
    self.grow_vertical = type
    return self
end

---@param parent_w number
---@param parent_h number
---@param min_w number
---@param min_h number
---@return number x, number y, number w, number h
function Anchor:Resolve(parent_w, parent_h, min_w, min_h)
    local x1 = self.left * parent_w + self.left_offset
    local y1 = self.top * parent_h + self.top_offset
    local x2 = self.right * parent_w + self.right_offset
    local y2 = self.bottom * parent_h + self.bottom_offset

    local w = x2 - x1
    local h = y2 - y1

    if w < min_w then
        local diff = min_w - w
        if self.grow_horizontal == ANCHOR_GROW_LEFT then
            x1 = x1 - diff
        elseif self.grow_horizontal == ANCHOR_GROW_BOTH then
            x1 = x1 - diff / 2
        end
        w = min_w
    end

    if h < min_h then
        local diff = min_h - h
        if self.grow_vertical == ANCHOR_GROW_TOP then
            y1 = y1 - diff
        elseif self.grow_vertical == ANCHOR_GROW_BOTH then
            y1 = y1 - diff / 2
        end
        h = min_h
    end

    return x1, y1, w, h
end

--[[-------------------------------------
    Presets
--]] -------------------------------------

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetTopLeft(w, h)
    self:SetPoints(0, 0, 0, 0)
    self:SetOffset(0, w, 0, h)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetTopRight(w, h)
    self:SetPoints(1, 1, 0, 0)
    self:SetOffset(-w, 0, 0, h)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetBottomLeft(w, h)
    self:SetPoints(0, 0, 1, 1)
    self:SetOffset(0, w, -h, 0)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetBottomRight(w, h)
    self:SetPoints(1, 1, 1, 1)
    self:SetOffset(-w, 0, -h, 0)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetCenterLeft(w, h)
    self:SetPoints(0, 0, 0.5, 0.5)
    self:SetOffset(0, w, -h / 2, h / 2)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetCenterRight(w, h)
    self:SetPoints(1, 1, 0.5, 0.5)
    self:SetOffset(-w, 0, -h / 2, h / 2)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetCenterTop(w, h)
    self:SetPoints(0.5, 0.5, 0, 0)
    self:SetOffset(-w / 2, w / 2, 0, h)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetCenterBottom(w, h)
    self:SetPoints(0.5, 0.5, 1, 1)
    self:SetOffset(-w / 2, w / 2, -h, 0)
    return self
end

---@param w number
---@param h number
---@return Anchor
function Anchor:PresetCenter(w, h)
    self:SetPoints(0.5, 0.5, 0.5, 0.5)
    self:SetOffset(-w / 2, w / 2, -h / 2, h / 2)
    return self
end

---@param w number
---@return Anchor
function Anchor:PresetLeftWide(w)
    self:SetPoints(0, 0, 0, 1)
    self:SetOffset(0, w, 0, 0)
    return self
end

---@param w number
---@return Anchor
function Anchor:PresetRightWide(w)
    self:SetPoints(1, 1, 0, 1)
    self:SetOffset(-w, 0, 0, 0)
    return self
end

---@param h number
---@return Anchor
function Anchor:PresetTopWide(h)
    self:SetPoints(0, 1, 0, 0)
    self:SetOffset(0, 0, 0, h)
    return self
end

---@param h number
---@return Anchor
function Anchor:PresetBottomWide(h)
    self:SetPoints(0, 1, 1, 1)
    self:SetOffset(0, 0, -h, 0)
    return self
end

---@param w number
---@return Anchor
function Anchor:PresetVCenterWide(w)
    self:SetPoints(0.5, 0.5, 0, 1)
    self:SetOffset(-w / 2, w / 2, 0, 0)
    return self
end

---@param h number
---@return Anchor
function Anchor:PresetHCenterWide(h)
    self:SetPoints(0, 1, 0.5, 0.5)
    self:SetOffset(0, 0, -h / 2, h / 2)
    return self
end

---@return Anchor
function Anchor:PresetFullRect()
    self:SetPoints(0, 1, 0, 1)
    self:SetOffset(0, 0, 0, 0)
    return self
end

--[[-------------------------------------
    Exports
--]]-------------------------------------

SektaUI.Anchor = setmetatable(Anchor, {
    __call = function(self, ...)
        return self:new()
    end
})

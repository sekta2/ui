---@diagnostic disable assign-type-mismatch

--[[-------------------------------------
    Theme
--]]-------------------------------------

---@class SUI_Theme
---@field elements table<string, {inherit: string?, style: table<string, any>}>
local Theme = {}
Theme.__index = Theme

---@return SUI_Theme
function Theme:new()
    local object = {
        elements = {}
    }

    return setmetatable(object, self)
end

---@param name string
---@param inherit string?
---@return table<string, any>
function Theme:AddElement(name, inherit)
    local element = {
        inherit = inherit,
        style = {}
    }

    self.elements[name] = element

    return element.style
end

---@param name string
---@return {inherit: string?, style: table<string, any>}?
function Theme:GetElement(name)
    return self.elements[name]
end

---@param name string
---@param key string
---@return any|nil
function Theme:GetElementParam(name, key)
    local element = self:GetElement(name)
    if not element then return end

    if not element.style[key] and element.inherit then
        return self:GetElementParam(element.inherit, key)
    end

    return element.style[key]
end

--[[-------------------------------------
    StyleBox
--]]-------------------------------------

---@class SUI_StyleBox: ClassicObject
---@field margin_left number
---@field margin_top number
---@field margin_right number
---@field margin_bottom number
---@overload fun(): SUI_StyleBox
local StyleBox = SektaUI.Classic:extend()

function StyleBox:new()
    self.margin_left = 0
    self.margin_top = 0
    self.margin_right = 0
    self.margin_bottom = 0
end

function StyleBox:Draw()
end

---@param x number
---@param y number
---@param w number
---@param h number
---@return number, number, number, number
function StyleBox:GetContentRect(x, y, w, h)
    return x + self.margin_left,
        y + self.margin_top,
        w - self.margin_left - self.margin_right,
        h - self.margin_top - self.margin_bottom
end

--[[-------------------------------------
    StyleBoxFlat
--]]-------------------------------------

---@class SUI_StyleBoxFlat: SUI_StyleBox
---@field bg_color Color
---@field border_color Color?
---@field border_width number
---@field corner_radius number
---@overload fun(): SUI_StyleBoxFlat
local StyleBoxFlat = StyleBox:extend()

function StyleBoxFlat:new()
    StyleBoxFlat.super.new(self)

    self.bg_color = color_white
    self.border_color = nil
    self.border_width = 0
    self.corner_radius = 0
end

function StyleBoxFlat:Draw(x, y, w, h)
    SektaUI.RNDX.Draw(self.corner_radius, x, y, w, h, self.bg_color)

    if self.border_color and self.border_width > 0 then
        SektaUI.RNDX.DrawOutlined(self.corner_radius, x, y, w, h, self.border_color, self.border_width)
    end
end

--[[-------------------------------------
    Exports
--]]-------------------------------------

SektaUI.Theme = setmetatable(Theme, {
    __call = function(self, ...)
        return self:new(...)
    end
})

SektaUI.StyleBox = StyleBox
SektaUI.StyleBoxFlat = StyleBoxFlat

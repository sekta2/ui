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
---@field blur_intensity number
---@overload fun(): SUI_StyleBoxFlat
local StyleBoxFlat = StyleBox:extend()

function StyleBoxFlat:new()
    StyleBoxFlat.super.new(self)

    self.bg_color = color_white
    self.border_color = nil
    self.border_width = 0
    self.corner_radius = 0
    self.blur_intensity = 0
end

function StyleBoxFlat:Draw(x, y, w, h)
    if self.blur_intensity > 0 then
        SektaUI.RNDX().Rect(x, y, w, h)
            :Rad(self.corner_radius)
            :Blur(self.blur_intensity)
            :Draw()
    end

    SektaUI.RNDX.Draw(self.corner_radius, x, y, w, h, self.bg_color)

    if self.border_color and self.border_width > 0 then
        SektaUI.RNDX.DrawOutlined(self.corner_radius, x, y, w, h, self.border_color, self.border_width)
    end
end

--[[-------------------------------------
    StyleBoxTexture
--]]-------------------------------------

---@alias SUI_StyleBoxTextureMode "border"|"stretch"|"center"

---@class SUI_StyleBoxTexture: SUI_StyleBox
---@field material IMaterial?
---@field tex_x number
---@field tex_y number
---@field tex_w number
---@field tex_h number
---@field mode SUI_StyleBoxTextureMode
---@field color Color
---@overload fun(): SUI_StyleBoxTexture
local StyleBoxTexture = StyleBox:extend()

function StyleBoxTexture:new()
    StyleBoxTexture.super.new(self)

    self.material = nil

    self.tex_x = 0
    self.tex_y = 0
    self.tex_w = 0
    self.tex_h = 0

    self.mode = "border"
    self.color = color_white
end

---@private
---@return number, number
function StyleBoxTexture:GetTextureSize()
    local tex = self.material:GetTexture("$basetexture")
    return tex:Width(), tex:Height()
end

function StyleBoxTexture:Draw(x, y, w, h)
    if not self.material then return end

    if self.mode == "stretch" then
        self:DrawStretch(x, y, w, h)
    elseif self.mode == "center" then
        self:DrawCenter(x, y, w, h)
    else
        self:DrawBorder(x, y, w, h)
    end
end

---@private
function StyleBoxTexture:DrawStretch(x, y, w, h)
    local texW, texH = self:GetTextureSize()

    local u1, v1 = self.tex_x / texW, self.tex_y / texH
    local u2, v2 = (self.tex_x + self.tex_w) / texW, (self.tex_y + self.tex_h) / texH

    surface.SetMaterial(self.material)
    surface.SetDrawColor(self.color)
    surface.DrawTexturedRectUV(x, y, w, h, u1, v1, u2, v2)
end

---@private
function StyleBoxTexture:DrawCenter(x, y, w, h)
    local texW, texH = self:GetTextureSize()

    local cx = x + (w - self.tex_w) * 0.5
    local cy = y + (h - self.tex_h) * 0.5

    local u1, v1 = self.tex_x / texW, self.tex_y / texH
    local u2, v2 = (self.tex_x + self.tex_w) / texW, (self.tex_y + self.tex_h) / texH

    surface.SetMaterial(self.material)
    surface.SetDrawColor(self.color)
    surface.DrawTexturedRectUV(cx, cy, self.tex_w, self.tex_h, u1, v1, u2, v2)
end

---@private
function StyleBoxTexture:DrawBorder(x, y, w, h)
    local texW, texH = self:GetTextureSize()

    local _x, _y = self.tex_x / texW, self.tex_y / texH
    local _w, _h = self.tex_w / texW, self.tex_h / texH

    -- клэмп границ, если бокс меньше суммы border'ов
    local halfW, halfH = w * 0.5, h * 0.5
    local left = math.min(self.margin_left, math.ceil(halfW))
    local right = math.min(self.margin_right, math.floor(halfW))
    local top = math.min(self.margin_top, math.ceil(halfH))
    local bottom = math.min(self.margin_bottom, math.floor(halfH))

    local _l = left / texW
    local _t = top / texH
    local _r = right / texW
    local _b = bottom / texH

    surface.SetMaterial(self.material)
    surface.SetDrawColor(self.color)

    -- top
    surface.DrawTexturedRectUV(x, y, left, top, _x, _y, _x + _l, _y + _t)
    surface.DrawTexturedRectUV(x + left, y, w - left - right, top, _x + _l, _y, _x + _w - _r, _y + _t)
    surface.DrawTexturedRectUV(x + w - right, y, right, top, _x + _w - _r, _y, _x + _w, _y + _t)

    -- middle
    surface.DrawTexturedRectUV(x, y + top, left, h - top - bottom, _x, _y + _t, _x + _l, _y + _h - _b)
    surface.DrawTexturedRectUV(x + left, y + top, w - left - right, h - top - bottom, _x + _l, _y + _t, _x + _w - _r, _y + _h - _b)
    surface.DrawTexturedRectUV(x + w - right, y + top, right, h - top - bottom, _x + _w - _r, _y + _t, _x + _w, _y + _h - _b)

    -- bottom
    surface.DrawTexturedRectUV(x, y + h - bottom, left, bottom, _x, _y + _h - _b, _x + _l, _y + _h)
    surface.DrawTexturedRectUV(x + left, y + h - bottom, w - left - right, bottom, _x + _l, _y + _h - _b, _x + _w - _r, _y + _h)
    surface.DrawTexturedRectUV(x + w - right, y + h - bottom, right, bottom, _x + _w - _r, _y + _h - _b, _x + _w, _y + _h)
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
SektaUI.StyleBoxTexture = StyleBoxTexture

---@diagnostic disable assign-type-mismatch

---@class SUI_Control: SUI_Base
---@field custom_minimum_size Vector2
---@field custom_maximum_size Vector2
---@field anchor Anchor
---@field theme SUI_Theme?
---@field theme_override table<string, any>
local PANEL = {
    SUI_Class = "SUI_Control",
}

function PANEL:Init()
    self.custom_minimum_size =  SektaUI.Vector2(0, 0)
    self.custom_maximum_size = SektaUI.Vector2(-1, -1)
    self.anchor = SektaUI.Anchor():PresetTopLeft(self:SUI_GetMinimumSize())
    self.theme_override = {}
end

---@return string
function PANEL:GetCurrentStyleState()
    return "normal"
end

---@return number
---@return number
function PANEL:SUI_GetMinimumSize()
    local vec = self.custom_minimum_size
    return vec.x, vec.y
end

--[[-------------------------------------
    Theme
--]]-------------------------------------

---@param theme SUI_Theme?
function PANEL:SUI_SetTheme(theme)
    self.theme = theme
end

---@return SUI_Theme?
function PANEL:SUI_GetTheme()
    local parent = self:GetParent()
    return self.theme or parent.theme or SektaUI.Default:GetTheme()
end

---@param key string
---@return any
function PANEL:GetThemeParam(key)
    if self.theme_override[key] then
        return self.theme_override[key]
    end

    local name = self.SUI_Class
    return (self:SUI_GetTheme()):GetElementParam(name, key)
end

---@return StyleBox?
function PANEL:GetStyle()
    local state = self:GetCurrentStyleState()
    return self:GetThemeParam("style_" .. state)
end

--[[-------------------------------------
    Hooks
--]]-------------------------------------

---@param width number
---@param height number
---@return boolean
---@private
function PANEL:Paint(width, height)
    local style = self:GetStyle()

    local cx, cy, cw, ch = 0, 0, width, height
    if style then
        style:Draw(0, 0, width, height)
        cx, cy, cw, ch = style:GetContentRect(0, 0, width, height)
    end

    self:DrawContent(cx, cy, cw, ch)
    return true
end

---@param x number
---@param y number
---@param w number
---@param h number
---@private
function PANEL:DrawContent(x, y, w, h)
end

--[[-------------------------------------
    Register
--]]-------------------------------------

vgui.Register("SUI_Control", PANEL, "SUI_Base")

---@diagnostic disable assign-type-mismatch

---@class SUI_Control: SUI_Base
---@field theme SUI_Theme?
---@field theme_override table<string, any>
---@field pressed boolean
local PANEL = {}

function PANEL:Init()
    self.theme_override = {}

    self.pressed = false
end

---@return string
function PANEL:GetCurrentStyleState()
    if not self:IsEnabled() then return "disabled" end
    if self.pressed and self:IsHovered() then return "hover_pressed" end
    if self.pressed then return "pressed" end
    if self:IsHovered() then return "hover" end

    return "normal"
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

    local name = self.ThisClass
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

---@param key_code number
---@private
function PANEL:OnMousePressed(key_code)
    if key_code ~= MOUSE_LEFT then return end

    self.pressed = true
end

---@param key_code number
---@private
function PANEL:OnMouseReleased(key_code)
    if key_code ~= MOUSE_LEFT then return end

    self.pressed = false
end

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

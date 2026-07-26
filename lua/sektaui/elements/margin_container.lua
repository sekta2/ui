---@class SUI_MarginContainer: SUI_Control
local PANEL = {
    SUI_Class = "SUI_MarginContainer"
}

---@private
---@return number, number, number, number
function PANEL:SUI_GetMargins()
    local left = self:GetThemeParam("margin_left") or 0
    local top = self:GetThemeParam("margin_top") or 0
    local right = self:GetThemeParam("margin_right") or 0
    local bottom = self:GetThemeParam("margin_bottom") or 0

    return left, top, right, bottom
end

---@param width number
---@param height number
---@private
function PANEL:PerformLayout(width, height)
    local left, top, right, bottom = self:SUI_GetMargins()

    local cx = left
    local cy = top
    local cw = math.max(width - left - right, 0)
    local ch = math.max(height - top - bottom, 0)

    local children = self:GetChildren()
    for i = 1, #children do
        ---@type SUI_Control
        local child = children[i]
        if not child.SUI_BASED then goto skip end

        child:SetPos(cx, cy)
        child:SetSize(cw, ch)

        ::skip::
    end
end

--[[-------------------------------------
    Style
--]] -------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_MarginContainer")
DermaStyle.margin_left = 0
DermaStyle.margin_top = 0
DermaStyle.margin_right = 0
DermaStyle.margin_bottom = 0

--[[-------------------------------------
    Register
--]] -------------------------------------

vgui.Register("SUI_MarginContainer", PANEL, "SUI_Control")

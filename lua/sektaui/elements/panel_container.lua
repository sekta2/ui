---@class SUI_PanelContainer: SUI_Control
local PANEL = {
    SUI_Class = "SUI_PanelContainer"
}

---@private
---@param flags SUI_SIZE_FLAGS
---@param flag SUI_SIZE_FLAGS
---@return boolean
local function HasFlag(flags, flag)
    return bit.band(flags, flag) ~= 0
end

---@private
---@param flags SUI_SIZE_FLAGS
---@param allocated number
---@param actual number
---@return number offset, number size
local function ResolveAxis(flags, allocated, actual)
    if HasFlag(flags, SektaUI.SIZE_FILL) then
        return 0, allocated
    end

    if HasFlag(flags, SektaUI.SIZE_SHRINK_CENTER) then
        return (allocated - actual) / 2, actual
    elseif HasFlag(flags, SektaUI.SIZE_SHRINK_END) then
        return allocated - actual, actual
    end

    return 0, actual
end

---@param width number
---@param height number
---@private
function PANEL:PerformLayout(width, height)
    local style = self:GetStyle()

    local cx, cy, cw, ch = 0, 0, width, height
    if style then
        cx, cy, cw, ch = style:GetContentRect(0, 0, width, height)
    end

    local children = self:GetChildren()
    for i = 1, #children do
        ---@type SUI_Control
        local child = children[i]
        if not child.SUI_BASED then goto skip end

        local min_w, min_h = child:SUI_GetMinimumSize()

        local offset_x, actual_w = ResolveAxis(child.container_size_horizontal, cw, min_w)
        local offset_y, actual_h = ResolveAxis(child.container_size_vertical, ch, min_h)

        child:SetPos(cx + offset_x, cy + offset_y)
        child:SetSize(actual_w, actual_h)

        ::skip::
    end
end

--[[-------------------------------------
    Style
--]] -------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_PanelContainer")

local panel_style = SektaUI.StyleBoxTexture()
panel_style.material = SektaUI.Default.GWENGMod
panel_style.tex_x, panel_style.tex_y = 256, 0
panel_style.tex_w, panel_style.tex_h = 63, 63
panel_style.margin_left, panel_style.margin_top = 16, 16
panel_style.margin_right, panel_style.margin_bottom = 16, 16
panel_style.mode = "border"

DermaStyle.style_normal = panel_style

--[[-------------------------------------
    Register
--]] -------------------------------------

vgui.Register("SUI_PanelContainer", PANEL, "SUI_Control")

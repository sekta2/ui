---@class SUI_Button: SUI_BaseButton
local PANEL = {
    SUI_Class = "SUI_Button",
}

--[[-------------------------------------
    Style
--]]-------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_Button")

local btn_normal = SektaUI.StyleBoxTexture()
btn_normal.material = SektaUI.Default.GWENGMod
btn_normal.tex_x, btn_normal.tex_y = 480, 0
btn_normal.tex_w, btn_normal.tex_h = 31, 31
btn_normal.margin_left, btn_normal.margin_top = 8, 8
btn_normal.margin_right, btn_normal.margin_bottom = 8, 8
btn_normal.mode = "border"

local btn_hover = SektaUI.StyleBoxTexture()
btn_hover.material = SektaUI.Default.GWENGMod
btn_hover.tex_x, btn_normal.tex_y = 480, 0
btn_hover.tex_w, btn_normal.tex_h = 31, 31
btn_hover.margin_left, btn_normal.margin_top = 8, 8
btn_hover.margin_right, btn_normal.margin_bottom = 8, 8
btn_hover.mode = "border"

DermaStyle.style_normal = btn_normal
DermaStyle.style_hover = btn_hover

--[[-------------------------------------
    Register
--]]-------------------------------------

vgui.Register("SUI_Button", PANEL, "SUI_BaseButton")

---@class SUI_Button: SUI_BaseButton
---@field text string
local PANEL = {
    SUI_Class = "SUI_Button",
}

function PANEL:Init()
    self.text = "Button"
end

---@param text string
function PANEL:SetText(text)
    self.text = text
end

---@return string
function PANEL:GetText()
    return self.text
end

---@param x number
---@param y number
---@param w number
---@param h number
---@private
function PANEL:DrawContent(x, y, w, h)
    local font = self:GetThemeParam("font"):Get()
    draw.SimpleText("Button", font, x + w / 2, y + h / 2, self:GetThemeParam(self.pressed and "font_pressed_color" or self:IsHovered() and "font_hover_color" or "font_normal_color"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

--[[-------------------------------------
    Style
--]]-------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_Button")

DermaStyle.font = SektaUI.Default.DermaFont
DermaStyle.font_normal_color = GWEN.TextureColor(4 + 8 * 2, 508)
DermaStyle.font_hover_color = GWEN.TextureColor( 4 + 8 * 3, 508 )
DermaStyle.font_pressed_color = GWEN.TextureColor( 4 + 8 * 2, 500 )

local btn_normal = SektaUI.StyleBoxTexture()
btn_normal.material = SektaUI.Default.GWENGMod
btn_normal.tex_x, btn_normal.tex_y = 480, 0
btn_normal.tex_w, btn_normal.tex_h = 31, 31
btn_normal.margin_left, btn_normal.margin_top = 8, 8
btn_normal.margin_right, btn_normal.margin_bottom = 8, 8
btn_normal.mode = "border"

local btn_hover = SektaUI.StyleBoxTexture()
btn_hover.material = SektaUI.Default.GWENGMod
btn_hover.tex_x, btn_hover.tex_y = 480, 32
btn_hover.tex_w, btn_hover.tex_h = 31, 31
btn_hover.margin_left, btn_hover.margin_top = 8, 8
btn_hover.margin_right, btn_hover.margin_bottom = 8, 8
btn_hover.mode = "border"

local btn_pressed = SektaUI.StyleBoxTexture()
btn_pressed.material = SektaUI.Default.GWENGMod
btn_pressed.tex_x, btn_pressed.tex_y = 480, 96
btn_pressed.tex_w, btn_pressed.tex_h = 31, 31
btn_pressed.margin_left, btn_pressed.margin_top = 8, 8
btn_pressed.margin_right, btn_pressed.margin_bottom = 8, 8
btn_pressed.mode = "border"

DermaStyle.style_normal = btn_normal
DermaStyle.style_hover = btn_hover
DermaStyle.style_pressed = btn_pressed

--[[-------------------------------------
    Register
--]]-------------------------------------

vgui.Register("SUI_Button", PANEL, "SUI_BaseButton")

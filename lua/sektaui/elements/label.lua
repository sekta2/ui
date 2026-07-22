--[[-------------------------------------
    Enum
--]]-------------------------------------

---@alias TEXT_ALIGNMENT_HORIZONTAL 0|1|2
---@alias TEXT_ALIGNMENT_VERTICAL 3|1|4

--[[-------------------------------------
    Label
--]]-------------------------------------

---@class SUI_Label: SUI_Control
---@field text string
---@field horizontal_alignment TEXT_ALIGNMENT_HORIZONTAL
---@field vertical_alignment TEXT_ALIGNMENT_VERTICAL
local PANEL = {
    SUI_Class = "SUI_Label"
}

function PANEL:Init()
    self.horizontal_alignment = TEXT_ALIGN_LEFT
    self.vertical_alignment = TEXT_ALIGN_TOP
    self.text = "Label"
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

    local tx = self.horizontal_alignment == 0 and x or
        self.horizontal_alignment == 1 and x + w * 0.5 or x + w
    local ty = self.vertical_alignment == 3 and y or
        self.vertical_alignment == 1 and y + h * 0.5 or y + h

    draw.SimpleText(self:GetText(), font, tx, ty, self:GetThemeParam("font_color"), self.horizontal_alignment, self.vertical_alignment)
end

--[[-------------------------------------
    Style
--]]-------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_Label")

DermaStyle.font = SektaUI.Default.DermaFont
DermaStyle.font_color = SektaUI.Default.GWENGMod:GetColor(4 + 8 * 8, 508)

local label_normal = SektaUI.StyleBox()
DermaStyle.style_normal = label_normal

--[[-------------------------------------
    Register
--]]-------------------------------------

vgui.Register("SUI_Label", PANEL, "SUI_Control")

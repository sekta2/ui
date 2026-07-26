---@class SUI_CenterContainer: SUI_Control
local PANEL = {
    SUI_Class = "SUI_CenterContainer"
}

---@param width number
---@param height number
---@private
function PANEL:PerformLayout(width, height)
    local children = self:GetChildren()
    for i = 1, #children do
        ---@type SUI_Control
        local child = children[i]
        if not child.SUI_BASED then goto skip end

        local min_size_x, min_size_y = child:SUI_GetMinimumSize()
        child:SetSize(min_size_x, min_size_y)
        child:SetPos(width / 2 - min_size_x / 2, height / 2 - min_size_y / 2)

        ::skip::
    end
end

--[[-------------------------------------
    Register
--]]-------------------------------------

vgui.Register("SUI_CenterContainer", PANEL, "SUI_Control")

---@class SUI_VBoxContainer: SUI_Control
---@field separation number?
local PANEL = {
    SUI_Class = "SUI_VBoxContainer"
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

---@return number
function PANEL:SUI_GetSeparation()
    return self.separation or self:GetThemeParam("separation") or 4
end

---@return number, number
function PANEL:SUI_GetMinimumSize()
    local children = self:GetChildren()
    local separation = self:SUI_GetSeparation()

    local total_h = 0
    local max_w = 0
    local count = 0

    for i = 1, #children do
        local child = children[i]
        if child.SUI_BASED then
            local cw, ch = child:SUI_GetMinimumSize()
            total_h = total_h + ch
            if cw > max_w then max_w = cw end
            count = count + 1
        end
    end

    if count > 1 then
        total_h = total_h + separation * (count - 1)
    end

    return max_w, total_h
end

---@param width number
---@param height number
---@private
function PANEL:PerformLayout(width, height)
    local children = {}
    for _, child in ipairs(self:GetChildren()) do
        if child.SUI_BASED then children[#children + 1] = child end
    end
    if #children == 0 then return end

    local separation = self:SUI_GetSeparation()
    local min_sizes = {}
    local total_min = 0
    local expand_ratio_sum = 0

    for i, child in ipairs(children) do
        local min_w, min_h = child:SUI_GetMinimumSize()
        min_sizes[i] = { w = min_w, h = min_h }
        total_min = total_min + min_h

        if HasFlag(child.container_size_vertical, SektaUI.SIZE_EXPAND) then
            expand_ratio_sum = expand_ratio_sum + (child.container_stretch_ratio or 1)
        end
    end

    total_min = total_min + separation * (#children - 1)
    local remaining = math.max(height - total_min, 0)

    local y = 0
    for i, child in ipairs(children) do
        local min_w, min_h = min_sizes[i].w, min_sizes[i].h
        local allocated_h = min_h

        if HasFlag(child.container_size_vertical, SektaUI.SIZE_EXPAND) and expand_ratio_sum > 0 then
            local ratio = child.container_stretch_ratio or 1
            allocated_h = allocated_h + remaining * (ratio / expand_ratio_sum)
        end

        local offset_y, actual_h = ResolveAxis(child.container_size_vertical, allocated_h, min_h)
        local offset_x, actual_w = ResolveAxis(child.container_size_horizontal, width, min_w)

        child:SetPos(offset_x, y + offset_y)
        child:SetSize(actual_w, actual_h)

        y = y + allocated_h + separation
    end
end

--[[-------------------------------------
    Style
--]] -------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_VBoxContainer")
DermaStyle.separation = 4

--[[-------------------------------------
    Register
--]] -------------------------------------

vgui.Register("SUI_VBoxContainer", PANEL, "SUI_Control")

---@class SUI_GridContainer: SUI_Control
---@field columns integer
local PANEL = {
    SUI_Class = "SUI_GridContainer"
}

function PANEL:Init()
    self.columns = 1
end

---@param columns integer
function PANEL:SUI_SetColumns(columns)
    self.columns = math.max(columns, 1)
    self:InvalidateLayout(true)
end

---@return integer
function PANEL:SUI_GetColumns()
    return self.columns
end

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

---@private
---@return SUI_Control[]
function PANEL:SUI_GetGridChildren()
    local out = {}
    for _, child in ipairs(self:GetChildren()) do
        if child.SUI_BASED then out[#out + 1] = child end
    end
    return out
end

---@private
---@return integer rows, table<integer, SUI_Control[]> cells
function PANEL:SUI_BuildGrid()
    local children = self:SUI_GetGridChildren()
    local columns = self:SUI_GetColumns()
    local rows = math.ceil(#children / columns)

    local cells = {}
    for i, child in ipairs(children) do
        local row = math.ceil(i / columns)
        local col = ((i - 1) % columns) + 1

        cells[row] = cells[row] or {}
        cells[row][col] = child
    end

    return rows, cells
end

---@return number, number
function PANEL:SUI_GetMinimumSize()
    local children = self:SUI_GetGridChildren()
    if #children == 0 then return 0, 0 end

    local columns = self:SUI_GetColumns()
    local rows, cells = self:SUI_BuildGrid()
    local h_sep = self:GetThemeParam("h_separation")
    local v_sep = self:GetThemeParam("v_separation")

    local col_widths = {}
    local row_heights = {}

    for row = 1, rows do
        for col = 1, columns do
            local child = cells[row] and cells[row][col]
            if child then
                local cw, ch = child:SUI_GetMinimumSize()
                col_widths[col] = math.max(col_widths[col] or 0, cw)
                row_heights[row] = math.max(row_heights[row] or 0, ch)
            end
        end
    end

    local total_w, total_h = 0, 0
    for col = 1, columns do
        total_w = total_w + (col_widths[col] or 0)
    end
    for row = 1, rows do
        total_h = total_h + (row_heights[row] or 0)
    end

    total_w = total_w + h_sep * (columns - 1)
    total_h = total_h + v_sep * (rows - 1)

    return total_w, total_h
end

--[[-------------------------------------
    Layout
--]] -------------------------------------

---@param width number
---@param height number
---@private
function PANEL:PerformLayout(width, height)
    local children = self:SUI_GetGridChildren()
    if #children == 0 then return end

    local columns = self:SUI_GetColumns()
    local rows, cells = self:SUI_BuildGrid()
    local h_sep = self:GetThemeParam("h_separation")
    local v_sep = self:GetThemeParam("v_separation")

    local col_min_w = {}
    local row_min_h = {}
    local col_expand = {}
    local row_expand = {}

    for row = 1, rows do
        for col = 1, columns do
            local child = cells[row] and cells[row][col]
            if child then
                local cw, ch = child:SUI_GetMinimumSize()
                col_min_w[col] = math.max(col_min_w[col] or 0, cw)
                row_min_h[row] = math.max(row_min_h[row] or 0, ch)

                if HasFlag(child.container_size_horizontal, SektaUI.SIZE_EXPAND) then
                    col_expand[col] = true
                end
                if HasFlag(child.container_size_vertical, SektaUI.SIZE_EXPAND) then
                    row_expand[row] = true
                end
            end
        end
    end

    local total_min_w = 0
    local expand_cols = 0
    for col = 1, columns do
        total_min_w = total_min_w + (col_min_w[col] or 0)
        if col_expand[col] then expand_cols = expand_cols + 1 end
    end
    total_min_w = total_min_w + h_sep * (columns - 1)
    local remaining_w = math.max(width - total_min_w, 0)

    local total_min_h = 0
    local expand_rows = 0
    for row = 1, rows do
        total_min_h = total_min_h + (row_min_h[row] or 0)
        if row_expand[row] then expand_rows = expand_rows + 1 end
    end
    total_min_h = total_min_h + v_sep * (rows - 1)
    local remaining_h = math.max(height - total_min_h, 0)

    local col_alloc_w = {}
    for col = 1, columns do
        local w = col_min_w[col] or 0
        if col_expand[col] and expand_cols > 0 then
            w = w + remaining_w / expand_cols
        end
        col_alloc_w[col] = w
    end

    local row_alloc_h = {}
    for row = 1, rows do
        local h = row_min_h[row] or 0
        if row_expand[row] and expand_rows > 0 then
            h = h + remaining_h / expand_rows
        end
        row_alloc_h[row] = h
    end

    local y = 0
    for row = 1, rows do
        local x = 0
        for col = 1, columns do
            local child = cells[row] and cells[row][col]
            if child then
                local min_w, min_h = child:SUI_GetMinimumSize()

                local offset_x, actual_w = ResolveAxis(child.container_size_horizontal, col_alloc_w[col], min_w)
                local offset_y, actual_h = ResolveAxis(child.container_size_vertical, row_alloc_h[row], min_h)

                child:SetPos(x + offset_x, y + offset_y)
                child:SetSize(actual_w, actual_h)
            end

            x = x + col_alloc_w[col] + h_sep
        end

        y = y + row_alloc_h[row] + v_sep
    end
end

--[[-------------------------------------
    Style
--]] -------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_GridContainer")
DermaStyle.h_separation = 4
DermaStyle.v_separation = 4

--[[-------------------------------------
    Register
--]] -------------------------------------

vgui.Register("SUI_GridContainer", PANEL, "SUI_Control")

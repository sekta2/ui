---@class SUI_ScrollContainer: SUI_Control
---@field scroll_x number
---@field scroll_y number
---@field scroll_horizontal_enabled boolean
---@field scroll_vertical_enabled boolean
local PANEL = {
    SUI_Class = "SUI_ScrollContainer"
}

function PANEL:Init()
    self.scroll_x = 0
    self.scroll_y = 0

    self.scroll_horizontal_enabled = false
    self.scroll_vertical_enabled = true

    self.v_scroll_dragging = false
    self.h_scroll_dragging = false

    self.max_scroll_x = 0
    self.max_scroll_y = 0

    self:SetMouseInputEnabled(true)
end

---@return number
function PANEL:SUI_GetScrollbarSize()
    return self:GetThemeParam("scrollbar_size") or 16
end

---@private
---@return SUI_Control?
function PANEL:SUI_GetContentChild()
    local children = self:GetChildren()
    for i = 1, #children do
        if children[i].SUI_BASED then return children[i] end
    end
end

--[[-------------------------------------
    Layout
--]] -------------------------------------

---@param w number
---@param h number
---@private
function PANEL:PerformLayout(w, h)
    local child = self:SUI_GetContentChild()
    if not child then return end

    local min_w, min_h = child:SUI_GetMinimumSize()
    local sb_size = self:SUI_GetScrollbarSize()
    local sep_h = self:GetThemeParam("separation_horizontal")
    local sep_v = self:GetThemeParam("separation_vertical")

    local needs_v = self.scroll_vertical_enabled and min_h > h
    local needs_h = self.scroll_horizontal_enabled and min_w > w

    local view_w = w - (needs_v and (sb_size + sep_h) or 0)
    local view_h = h - (needs_h and (sb_size + sep_v) or 0)

    -- пересчёт needs с учётом занятого скроллбарами места (второй проход)
    needs_v = self.scroll_vertical_enabled and min_h > view_h
    needs_h = self.scroll_horizontal_enabled and min_w > view_w
    view_w = w - (needs_v and (sb_size + sep_h) or 0)
    view_h = h - (needs_h and (sb_size + sep_v) or 0)

    local content_w = self.scroll_horizontal_enabled and math.max(min_w, view_w) or view_w
    local content_h = self.scroll_vertical_enabled and math.max(min_h, view_h) or view_h

    self.max_scroll_x = math.max(content_w - view_w, 0)
    self.max_scroll_y = math.max(content_h - view_h, 0)

    self.scroll_x = math.Clamp(self.scroll_x, 0, self.max_scroll_x)
    self.scroll_y = math.Clamp(self.scroll_y, 0, self.max_scroll_y)

    self.view_w = view_w
    self.view_h = view_h
    self.content_w = content_w
    self.content_h = content_h
    self.needs_v = needs_v
    self.needs_h = needs_h

    child:SetPos(-self.scroll_x, -self.scroll_y)
    child:SetSize(content_w, content_h)
end

--[[-------------------------------------
    Scroll API
--]] -------------------------------------

---@param x number
---@param y number
function PANEL:SUI_SetScroll(x, y)
    self.scroll_x = math.Clamp(x, 0, self.max_scroll_x)
    self.scroll_y = math.Clamp(y, 0, self.max_scroll_y)
    self:InvalidateLayout(true)
end

--[[-------------------------------------
    Input
--]] -------------------------------------

---@param delta number
---@private
function PANEL:OnMouseWheeled(delta)
    if not self.needs_v then return end

    self.scroll_y = math.Clamp(self.scroll_y - delta * 40, 0, self.max_scroll_y)
    self:InvalidateLayout(true)
end

---@param code number
---@private
function PANEL:OnMousePressed(code)
    if code ~= MOUSE_LEFT then return end

    local mx, my = self:CursorPos()

    local v = self.v_thumb_rect
    if v and mx >= v.x and mx <= v.x + v.w and my >= v.y and my <= v.y + v.h then
        self.v_scroll_dragging = true
        self.drag_start_my = my
        self.drag_start_scroll_y = self.scroll_y
        self:MouseCapture(true)
        return
    end

    local hb = self.h_thumb_rect
    if hb and mx >= hb.x and mx <= hb.x + hb.w and my >= hb.y and my <= hb.y + hb.h then
        self.h_scroll_dragging = true
        self.drag_start_mx = mx
        self.drag_start_scroll_x = self.scroll_x
        self:MouseCapture(true)
        return
    end
end

---@param code number
---@private
function PANEL:OnMouseReleased(code)
    if code ~= MOUSE_LEFT then return end

    self.v_scroll_dragging = false
    self.h_scroll_dragging = false
    self:MouseCapture(false)
end

---@param x number
---@param y number
---@private
function PANEL:OnCursorMoved(x, y)
    if self.v_scroll_dragging and self.v_thumb_rect then
        local track = self.v_thumb_rect.track_h - self.v_thumb_rect.h
        local delta = track > 0 and ((y - self.drag_start_my) / track) * self.max_scroll_y or 0
        self.scroll_y = math.Clamp(self.drag_start_scroll_y + delta, 0, self.max_scroll_y)
        self:InvalidateLayout(true)
    end

    if self.h_scroll_dragging and self.h_thumb_rect then
        local track = self.h_thumb_rect.track_w - self.h_thumb_rect.w
        local delta = track > 0 and ((x - self.drag_start_mx) / track) * self.max_scroll_x or 0
        self.scroll_x = math.Clamp(self.drag_start_scroll_x + delta, 0, self.max_scroll_x)
        self:InvalidateLayout(true)
    end
end

--[[-------------------------------------
    Draw
--]] -------------------------------------

---@param w number
---@param h number
---@private
function PANEL:PaintOver(w, h)
    local sb_size = self:SUI_GetScrollbarSize()

    self.v_thumb_rect = nil
    self.h_thumb_rect = nil

    if self.needs_v then
        local track_x = w - sb_size
        local track_h = h - (self.needs_h and sb_size or 0)

        local track_style = self:GetThemeParam("style_track_v")
        if track_style then track_style:Draw(track_x, 0, sb_size, track_h) end

        local ratio = self.view_h / self.content_h
        local thumb_h = math.max(track_h * ratio, 20)
        local thumb_y = (track_h - thumb_h) * (self.max_scroll_y > 0 and (self.scroll_y / self.max_scroll_y) or 0)

        local mx, my = self:CursorPos()
        local hovered = mx >= track_x and mx <= track_x + sb_size and my >= thumb_y and my <= thumb_y + thumb_h

        local state = "normal"
        if not self:IsEnabled() then
            state = "disabled"
        elseif self.v_scroll_dragging then
            state = "pressed"
        elseif hovered then
            state = "hover"
        end

        local thumb_style = self:GetThemeParam("style_thumb_v_" .. state)
        if thumb_style then thumb_style:Draw(track_x, thumb_y, sb_size, thumb_h) end

        self.v_thumb_rect = { x = track_x, y = thumb_y, w = sb_size, h = thumb_h, track_h = track_h }
    end

    if self.needs_h then
        local track_y = h - sb_size
        local track_w = w - (self.needs_v and sb_size or 0)

        local track_style = self:GetThemeParam("style_track_h")
        if track_style then track_style:Draw(0, track_y, track_w, sb_size) end

        local ratio = self.view_w / self.content_w
        local thumb_w = math.max(track_w * ratio, 20)
        local thumb_x = (track_w - thumb_w) * (self.max_scroll_x > 0 and (self.scroll_x / self.max_scroll_x) or 0)

        local mx, my = self:CursorPos()
        local hovered = my >= track_y and my <= track_y + sb_size and mx >= thumb_x and mx <= thumb_x + thumb_w

        local state = "normal"
        if not self:IsEnabled() then
            state = "disabled"
        elseif self.h_scroll_dragging then
            state = "pressed"
        elseif hovered then
            state = "hover"
        end

        local thumb_style = self:GetThemeParam("style_thumb_h_" .. state)
        if thumb_style then thumb_style:Draw(thumb_x, track_y, thumb_w, sb_size) end

        self.h_thumb_rect = { x = thumb_x, y = track_y, w = thumb_w, h = sb_size, track_w = track_w }
    end
end

--[[-------------------------------------
    Style
--]] -------------------------------------

local DermaStyle = SektaUI.Default.Themes.Derma:AddElement("SUI_ScrollContainer")
DermaStyle.scrollbar_size = 16
DermaStyle.separation_horizontal = 4
DermaStyle.separation_vertical = 4

---@param x number
---@param y number
---@param w number
---@param h number
---@return SUI_StyleBoxTexture
local function MakeScrollTex(x, y, w, h)
    local box = SektaUI.StyleBoxTexture()
    box.material = SektaUI.Default.GWENGMod
    box.tex_x, box.tex_y = x, y
    box.tex_w, box.tex_h = w, h
    box.margin_left, box.margin_top = 4, 4
    box.margin_right, box.margin_bottom = 4, 4
    box.mode = "border"

    return box
end

DermaStyle.style_track_v          = MakeScrollTex(384, 208, 15, 127)
DermaStyle.style_thumb_v_normal   = MakeScrollTex(400, 208, 15, 127)
DermaStyle.style_thumb_v_hover    = MakeScrollTex(416, 208, 15, 127)
DermaStyle.style_thumb_v_pressed     = MakeScrollTex(432, 208, 15, 127)
DermaStyle.style_thumb_v_disabled = MakeScrollTex(448, 208, 15, 127)

DermaStyle.style_track_h          = MakeScrollTex(384, 128, 127, 15)
DermaStyle.style_thumb_h_normal   = MakeScrollTex(384, 144, 127, 15)
DermaStyle.style_thumb_h_hover    = MakeScrollTex(384, 160, 127, 15)
DermaStyle.style_thumb_h_pressed     = MakeScrollTex(384, 176, 127, 15)
DermaStyle.style_thumb_h_disabled = MakeScrollTex(384, 192, 127, 15)

--[[-------------------------------------
    Register
--]] -------------------------------------

vgui.Register("SUI_ScrollContainer", PANEL, "SUI_Control")

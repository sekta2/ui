---@diagnostic disable invisible

---@alias AnchorPreset
---| "TopLeft"
---| "TopRight"
---| "BottomLeft"
---| "BottomRight"
---| "CenterLeft"
---| "CenterRight"
---| "CenterTop"
---| "CenterBottom"
---| "Center"
---| "LeftWide"
---| "RightWide"
---| "TopWide"
---| "BottomWide"
---| "VCenterWide"
---| "HCenterWide"
---| "FullRect"

---@class SUI_MarkupObject
---@field class string Classname, e.g.: Label / Texture / VBoxContainer
---@field children SUI_MarkupObject[] Node children
---@field name string? **SUI_Base**: Name of node, set's classname by default
---@field unique string? **SUI_Base**: Unique name
---@field theme SUI_Theme? **SUI_Control**: Custom theme
---@field theme_override table<string, any>? **SUI_Control**: Theme fields override
---@field custom_minimum_size Vector2? **SUI_Control**: Custom minimum size of node, default: `Vector2(0, 0)`
---@field custom_maximum_size Vector2? **SUI_Control**: Custom maximum size of node, default: `Vector2(-1, -1)`
---@field anchor Anchor? **SUI_Control**: Anchor, e.g.: SektaUI.Anchor():PresetFullRect(), does not support presets that use the node size
---@field anchor_preset AnchorPreset? Anchor preset, e.g.: `"Center"`
---@field container_size_horizontal SUI_SIZE_FLAGS? **SUI_Control**: Horizontal align in container
---@field container_size_vertical SUI_SIZE_FLAGS? **SUI_Control**: Vertical align in container
---@field container_stretch_ratio number? **SUI_Control**: Stretch ratio, default: `1`
---@field action_mode ACTION_MODE_BUTTON? **SUI_BaseButton**: Action mode, 1 - Triggers a signal when the button is pressed; 2 - Triggers a signal after the button is released, default: `1`
---@field scroll_horizontal_enabled boolean? **SUI_ScrollContainer**: Horizontal scroll, default: `false`
---@field scroll_vertical_enabled boolean? **SUI_ScrollContainer**: Vertical scroll, default: `true`
---@field columns number? **SUI_GridContainer**: Columns, default: `1`
---@field text string? **SUI_Button**/**SUI_Label**: Text of button/label
---@field horizontal_alignment TEXT_ALIGNMENT_HORIZONTAL **SUI_Label**: Horizontal text alignment, default: `TEXT_ALIGN_LEFT`
---@field vertical_alignment TEXT_ALIGNMENT_VERTICAL **SUI_Label**: Vertical text alignment, default: `TEXT_ALIGN_TOP`

---@class SUI_Scene
---@field markup SUI_MarkupObject
local Scene = {}
Scene.__index = Scene

---@param markup SUI_MarkupObject
---@return SUI_Scene
function Scene:new(markup)
    local obj = {
        markup = markup
    }

    return setmetatable(obj, self)
end

---@param markup SUI_MarkupObject
---@param parent Panel?
---@return SUI_Control?
function Scene:Instantiate(markup, parent)
    markup = markup or self.markup
    if not markup then return end

    local classname = "SUI_" .. markup.class
    local obj = vgui.Create(classname, parent)
    if not IsValid(obj) then
        error(("SUI_Scene: failed to create element of class '%s'"):format(markup.class))
    end

    -- обычные поля копируем как есть
    for key, value in pairs(markup) do
        if key ~= "class"
            and key ~= "children"
            and key ~= "name"
            and key ~= "unique"
            and key ~= "theme_override"
            and key ~= "anchor_preset"
        then
            obj[key] = value
        end
    end

    -- theme_override мёржим, а не перезаписываем целиком
    if markup.theme_override then
        for k, v in pairs(markup.theme_override) do
            obj.theme_override[k] = v
        end
    end

    -- anchor_preset применяем поверх anchor
    if markup.anchor_preset then
        local anchor = obj.anchor or SektaUI.Anchor()
        local w, h = obj:SUI_GetMinimumSize()

        local method = anchor["Preset" .. markup.anchor_preset]
        if not method then
            error(("SUI_Scene: unknown anchor preset '%s'"):format(markup.anchor_preset))
        end

        method(anchor, w, h)
        obj.anchor = anchor
    end

    if markup.name then
        obj:SUI_SetName(markup.name)
    end

    if markup.unique then
        obj:SUI_SetUniqueName(markup.unique)
    end

    -- ВАЖНО: применяем размер СЕЙЧАС, до создания детей —
    -- иначе дети будут резолвить anchor против ещё не выставленного размера родителя
    if IsValid(parent) then
        local pw, ph = parent:GetSize()
        if obj.SUI_ApplyAnchor then
            obj:SUI_ApplyAnchor(pw, ph)
        end
    else
        -- корневой элемент: родителя нет, применить anchor не к чему —
        -- выставляем размер напрямую из минимального размера
        if obj.SUI_GetMinimumSize then
            local w, h = obj:SUI_GetMinimumSize()
            obj:SetSize(w, h)
        end
    end

    -- дети — теперь родитель уже имеет правильный размер
    if markup.children then
        for i = 1, #markup.children do
            self:Instantiate(markup.children[i], obj)
        end
    end

    return obj
end

--[[-------------------------------------
    Exports
--]]-------------------------------------

SektaUI.Scene = setmetatable(Scene, {
    __call = function(self, ...)
        return self:new(...)
    end
})

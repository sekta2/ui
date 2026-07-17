---@class SUI_ButtonBase: SUI_Control
---@field action_mode 1|2
---@field pressed boolean
---@field button_down SUI_Signal<fun()>
---@field button_up SUI_Signal<fun()>
---@field button_pressed SUI_Signal<fun()>
local PANEL = {}

function PANEL:Init()
    self.action_mode = ACTION_MODE_BUTTON_PRESS

    self.pressed = false

    self.button_down = SektaUI.Signal()
    self.button_up = SektaUI.Signal()
    self.button_pressed = SektaUI.Signal()
end

--[[-------------------------------------
    Action Mode
--]]-------------------------------------

ACTION_MODE_BUTTON_PRESS = 1
ACTION_MODE_BUTTON_RELEASE = 2

---@param mode 1|2
function PANEL:SetActionMode(mode)
    self.action_mode = mode
end

---@return 1|2
function PANEL:GetActionMode()
    return self.action_mode
end

--[[-------------------------------------
    Hooks
--]]-------------------------------------

---@param key_code number
---@private
function PANEL:OnMousePressed(key_code)
    if not self:IsEnabled() then return end
    if key_code ~= MOUSE_LEFT then return end

    self.pressed = true
    self.button_down:Emit()

    if self.action_mode == ACTION_MODE_BUTTON_PRESS then
        self.button_pressed:Emit()
    end
end

---@param key_code number
---@private
function PANEL:OnMouseReleased(key_code)
    if key_code ~= MOUSE_LEFT then return end

    local was_pressed = self.pressed
    self.pressed = false

    if not self:IsEnabled() or not was_pressed then return end

    self.button_up:Emit()

    if self.action_mode == ACTION_MODE_BUTTON_RELEASE then
        self.button_pressed:Emit()
    end
end

--[[-------------------------------------
    Register
--]]-------------------------------------

vgui.Register("SUI_ButtonBase", PANEL, "SUI_Control")

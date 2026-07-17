---@diagnostic disable assign-type-mismatch

---@class Panel
---@field ThisClass string

---@class SUI_Base: Panel
---@field SUI_BASED true
---@field root SUI_Base?
---@field name string
---@field unique_name string?
---@field children_index table<string, SUI_Base>
---@field unique_index table<string, SUI_Base>
---@field on_changed_name SUI_Signal<fun(obj: SUI_Base, old_name: string, new_name: string)>
---@field on_remove SUI_Signal<fun(obj: SUI_Base)>
local PANEL = {
    SUI_BASED = true
}

---@private
function PANEL:Init()
    self.name = self.ThisClass
    self.children_index = {}
    self.unique_index = {}

    self.on_changed_name = SektaUI.Signal()
    self.on_remove = SektaUI.Signal()
end

--[[-------------------------------------
    Utils
--]]-------------------------------------

---
---@param method string
---@param ...any
function PANEL:CallParent(method, ...)
    local parent = self:GetParent()
    if IsValid(parent) and parent[method] and type(parent[method]) == "function" then
        local fn = parent[method]
        return fn(parent, ...)
    end
end

---@param name string
function PANEL:SUI_SetName(name)
    local old = self.name

    self.name = name
    self.on_changed_name:Emit(self, old, name)

    self:CallParent("OnChildNameChanged", self, old, name)
end

---@return string
function PANEL:SUI_GetName()
    return self.name
end

--[[-------------------------------------
    Root
--]]-------------------------------------

---@private
function PANEL:OnRootChanged(new)
    local old = self:GetRoot()
    self.root = new

    if self.unique_name then
        if IsValid(old) then old:OnNodeUniqueName(self, self.unique_name, nil) end
        new:OnNodeUniqueName(self, nil, self.unique_name)
    end

    local children = self:GetChildren()
    if #children == 0 then return end

    for i = 1, #children do
        local child = children[i]
        child:OnRootChanged(new)
    end
end

---@return boolean
function PANEL:IsRoot()
    local parent = self:GetParent()
    if not (IsValid(parent) and parent.SUI_BASED) then return true end

    return false
end

---@return SUI_Base
function PANEL:GetRootRecursive()
    ---@type SUI_Base
    local parent = self:GetParent()
    if not (IsValid(parent) and parent.SUI_BASED) then return self end

    return parent:GetRootRecursive()
end

---@return SUI_Base
function PANEL:GetRoot()
    return self.root or self:GetRootRecursive()
end

--[[-------------------------------------
    Remove
--]]-------------------------------------

---@private
function PANEL:OnRemove()
    self.on_remove:Emit(self)
end

--[[-------------------------------------
    Children
--]]-------------------------------------

---@param child SUI_Base
---@private
function PANEL:OnChildAdded(child)
    if child.SUI_Prepared and child.SUI_BASED then
        self:OnChildAddedReady(child)
    end
end

---@param child SUI_Base
---@private
function PANEL:OnChildAddedReady(child)
    if not self.children_index[child:SUI_GetName()] then
        self.children_index[child:SUI_GetName()] = child
    end

    child:OnRootChanged(self:GetRootRecursive())
end

---@param child SUI_Base
---@private
function PANEL:OnChildRemoved(child)
    if child.SUI_BASED and self.children_index[child:SUI_GetName()] then
        self.children_index[child:SUI_GetName()] = nil

        local children = self:GetChildren()
        for i = 1, #children do
            local other_child = children[i]
            if other_child.SUI_BASED and other_child:SUI_GetName() == child:SUI_GetName() then
                self.children_index[other_child:SUI_GetName()] = other_child
                break
            end
        end
    end

    child:OnRootChanged(child:GetRootRecursive())
end

---@param child SUI_Base
---@param old string
---@param new string
---@private
function PANEL:OnChildNameChanged(child, old, new)
    self.children_index[old] = nil

    local children = self:GetChildren()
    for i = 1, #children do
        local other_child = children[i]
        if other_child.SUI_BASED and other_child:SUI_GetName() == old then
            self.children_index[old] = other_child
            break
        end
    end

    if not self.children_index[new] then
        self.children_index[new] = child
    end
end

---@param name string
---@return SUI_Base?
function PANEL:SUI_GetChild(name)
    return self.children_index[name]
end

--[[-------------------------------------
    Unique Name
--]]-------------------------------------

---@param node SUI_Base
---@param old string?
---@param new string?
---@private
function PANEL:OnNodeUniqueName(node, old, new)
    if old then
        self.unique_index[old] = nil
    end

    if new then
        self.unique_index[new] = node
    end
end

---@param name string
function PANEL:SUI_SetUniqueName(name)
    local old = self.unique_name

    self.unique_name = name
    self:GetRoot():OnNodeUniqueName(self, old, name)
end

---@return string
function PANEL:SUI_GetUniqueName()
    return self.unique_name
end

---@param name string
---@return SUI_Base?
function PANEL:SUI_GetUnique(name)
    return self:GetRoot().unique_index[name]
end

--[[-------------------------------------
    FreeName
--]]-------------------------------------

---
---@param name string
---@return string
function PANEL:GetFreeName(name)
    local parent = self:GetParent()
    if not parent then return name end

    local children = parent:GetChildren()
    if #children <= 1 then return name end

    local newname = name
    local number_added = false
    local number = 1
    local founded = false

    while not founded do
        founded = true
        for i = 1, #children do
            local child = children[i]
            if child == self then goto skip end

            if child.name == newname then
                founded = false
                if number_added then
                    number = number + 1
                    newname = name .. " (" .. number .. ")"
                else
                    number_added = true
                    newname = name .. " (1)"
                end
            end

            ::skip::
        end
    end

    return newname
end

--[[-------------------------------------
    Register
--]]-------------------------------------

vgui.Register("SUI_Base", PANEL, "Panel")

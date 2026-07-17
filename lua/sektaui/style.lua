--[[-------------------------------------
    Theme
--]]-------------------------------------

---@class SUI_Theme
---@field elements table<string, {inherit: string?, style: table<string, any>}>
local Theme = {}
Theme.__index = Theme

---@return SUI_Theme
function Theme:new()
    local object = {
        elements = {}
    }

    return setmetatable(object, self)
end

---@param name string
---@param inherit string?
---@return table<string, any>
function Theme:AddElement(name, inherit)
    local element = {
        inherit = inherit,
        style = {}
    }

    self.elements[name] = element

    return element.style
end

---@param name string
---@return {inherit: string?, style: table<string, any>}?
function Theme:GetElement(name)
    return self.elements[name]
end

---@param name string
---@param key string
---@return any|nil
function Theme:GetElementParam(name, key)
    local element = self:GetElement(name)
    if not element then return end

    if not element.style[key] and element.inherit then
        return self:GetElementParam(element.inherit, key)
    end

    return element.style[key]
end

--[[-------------------------------------
    Exports
--]]-------------------------------------

SektaUI.Theme = setmetatable(Theme, {
    __call = function(self, ...)
        return self:new(...)
    end
})

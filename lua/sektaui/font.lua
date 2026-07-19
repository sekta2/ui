---@diagnostic disable param-type-mismatch

--[[-------------------------------------
    Fonts
--]] -------------------------------------

---@type table<string, true>
SUI_FontCache = SUI_FontCache or {}

---@class SUI_FontData
---@field font string?
---@field size number?
---@field weight number?
---@field antialias boolean?

---@class SUI_Font: SUI_FontData
---@field name string
---@overload fun(data: SUI_FontData): SUI_Font
local Font = {}
Font.__index = Font

---@param data SUI_FontData
---@return SUI_Font
function Font:new(data)
    data = data or {}

    local object = {
        font = data.font or "Arial",
        size = data.size or 13,
        weight = data.weight or 500,
        antialias = data.antialias ~= false
    }

    setmetatable(object, self)
    object.name = object:CalcName()

    return object
end

local prefix = "SUI"

function Font:CalcName()
    return table.concat({prefix, self.font, self.size, self.weight, self.antialias}, "_")
end

function Font:Compile()
    surface.CreateFont(self.name, {
        font = self.font,
        size = self.size,
        weight = self.weight,
        antialias = self.antialias,

        extended = true
    })
end

function Font:Get()
    local name = self.name
    if not SUI_FontCache[name] then
        self:Compile()
        SUI_FontCache[name] = true
    end

    return name
end

--[[-------------------------------------
    Exports
--]] -------------------------------------

SektaUI.Font = setmetatable(Font, {
    __call = function(self, ...)
        return self:new(...)
    end
})

--[[-------------------------------------
    Modules
--]]-------------------------------------

if SERVER then
    AddCSLuaFile("patch.lua")
    AddCSLuaFile("signal.lua")
    AddCSLuaFile("style.lua")
else
    include("patch.lua")
    include("signal.lua")
    include("style.lua")
end

--[[-------------------------------------
    Elements
--]]-------------------------------------

local function load_element(name)
    if SERVER then
        AddCSLuaFile("elements/" .. name .. ".lua")
    else
        include("elements/" .. name .. ".lua")
    end
end

load_element("base")

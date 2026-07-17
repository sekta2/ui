--[[-------------------------------------
    Modules
--]]-------------------------------------

if SERVER then
    AddCSLuaFile("classic.lua")
    AddCSLuaFile("rndx.lua")
    AddCSLuaFile("patch.lua")
    AddCSLuaFile("signal.lua")
    AddCSLuaFile("style.lua")
    AddCSLuaFile("default.lua")
else
    include("classic.lua")
    include("rndx.lua")
    include("patch.lua")
    include("signal.lua")
    include("style.lua")
    include("default.lua")
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
load_element("control")
load_element("basebutton")
load_element("button")
load_element("label")
load_element("texture")

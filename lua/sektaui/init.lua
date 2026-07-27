--[[-------------------------------------
    Modules
--]]-------------------------------------

if SERVER then
    AddCSLuaFile("vector.lua")
    AddCSLuaFile("anchor.lua")
    AddCSLuaFile("classic.lua")
    AddCSLuaFile("rndx.lua")
    AddCSLuaFile("patch.lua")
    AddCSLuaFile("signal.lua")
    AddCSLuaFile("style.lua")
    AddCSLuaFile("font.lua")
    AddCSLuaFile("default.lua")
    AddCSLuaFile("scene.lua")
else
    include("vector.lua")
    include("anchor.lua")
    include("classic.lua")
    include("rndx.lua")
    include("patch.lua")
    include("signal.lua")
    include("style.lua")
    include("font.lua")
    include("default.lua")
    include("scene.lua")
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
load_element("center_container")
load_element("margin_container")
load_element("hbox_container")
load_element("vbox_container")
load_element("panel_container")
load_element("scroll_container")
load_element("grid_container")

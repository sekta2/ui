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

if SERVER then return end

concommand.Add("sui_test_center_container", function(ply, cmd, args, argStr)
    if IsValid(gui_test_root) then
        gui_test_root:Remove()
    end

    gui_test_root = vgui.Create("SUI_PanelContainer")
    gui_test_root:SetSize(800, 600)
    gui_test_root:Center()

    print(gui_test_root.Think)

    local button = vgui.Create("SUI_Button", gui_test_root)
    button.custom_minimum_size = SektaUI.Vector2(100, 50)
    button.container_size_horizontal = bit.bor(SektaUI.SIZE_SHRINK_CENTER, SektaUI.SIZE_EXPAND)
    button.container_size_vertical = bit.bor(SektaUI.SIZE_SHRINK_CENTER, SektaUI.SIZE_EXPAND)
end)

if SERVER then
    AddCSLuaFile("signal.lua")
    AddCSLuaFile("style.lua")
else
    include("signal.lua")
    include("style.lua")
end

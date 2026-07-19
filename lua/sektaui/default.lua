--[[-------------------------------------
    ConVar
--]]-------------------------------------

local DefaultConvar = CreateClientConVar("sektaui_theme", "derma", true)

--[[-------------------------------------
    Main
--]]-------------------------------------

local Default = {
    Themes = {},
    GWENGMod = Material("gwenskin/GModDefault.png")
}

Default.Themes.Godot = SektaUI.Theme:new()
Default.Themes.Derma = SektaUI.Theme:new()

function Default:GetTheme()
    local var = DefaultConvar:GetString()

    if var == "derma" then return Default.Themes.Derma end
    if var == "godot" then return Default.Themes.Godot end

    return Default.Themes.Derma
end

--[[-------------------------------------
    Exports
--]]-------------------------------------

SektaUI.Default = Default

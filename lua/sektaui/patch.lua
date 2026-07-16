---@diagnostic disable assign-type-mismatch

--[[-------------------------------------
    OnChildAdded Patch
--]] -------------------------------------

---@class Panel
---@field SUI_Prepared true|nil

_G.SUI_OnChildAdded_Patched = _G.SUI_OnChildAdded_Patched == nil and false or _G.SUI_OnChildAdded_Patched
if not _G.SUI_OnChildAdded_Patched then
    _G.SUI_OnChildAdded_Patched = true

    ---@type Panel
    local panel_meta = FindMetaTable("Panel")
    local original_prepare = panel_meta.Prepare

    function panel_meta:Prepare()
        original_prepare(self)

        self.SUI_Prepared = true

        local parent = self:GetParent()
        if IsValid(parent) and parent.OnChildAddedReady then
            parent:OnChildAddedReady(self)
        end
    end
end

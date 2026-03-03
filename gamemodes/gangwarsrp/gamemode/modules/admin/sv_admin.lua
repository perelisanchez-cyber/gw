-- GangWarsRP - Admin Server Logic
-- TODO: Implement kick, ban, teleport, noclip, module toggle commands

GWRP.Admin = GWRP.Admin or {}

-- Net handler for admin actions
net.Receive("GWRP_AdminAction", function(len, ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    if not GWRP.Security:RateCheck(ply, "GangAction", 3, 5) then return end

    local action = net.ReadString()
    action = GWRP.Security:SanitizeString(action, 32)
    local target = net.ReadEntity()

    if action == "kick" and IsValid(target) and target:IsPlayer() then
        local reason = net.ReadString()
        reason = GWRP.Security:SanitizeString(reason, 128)
        target:Kick(reason ~= "" and reason or "Kicked by admin")
        GWRP.Log(string.format("[ADMIN] %s kicked %s: %s", ply:SteamID(), target:SteamID(), reason), "info")
    end
end)

-- Net handler for module toggles
net.Receive("GWRP_AdminModuleToggle", function(len, ply)
    if not IsValid(ply) or not ply:IsSuperAdmin() then return end
    if not GWRP.Security:RateCheck(ply, "GangAction", 1, 5) then return end

    local moduleID = net.ReadString()
    moduleID = GWRP.Security:SanitizeString(moduleID, 32)
    local enabled = net.ReadBool()

    if moduleID == "f4menu" then
        GWRP.Notify(ply, "Cannot toggle core module", 3)
        return
    end

    if enabled then
        GWRP.Modules:Enable(moduleID)
    else
        GWRP.Modules:Disable(moduleID)
    end

    GWRP.Notify(ply, moduleID .. " " .. (enabled and "enabled" or "disabled") .. " (reload required)", 1)
    GWRP.Log(string.format("[ADMIN] %s toggled module %s: %s", ply:SteamID(), moduleID, tostring(enabled)), "info")
end)

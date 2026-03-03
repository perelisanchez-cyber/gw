-- GangWarsRP - Client Entry Point
-- Auto-refresh safe: re-execution reloads modules without breaking state
-- Derives from sandbox: spawnmenu (Q) works normally

include("shared.lua")

-- Explicitly allow the sandbox spawnmenu to open on Q key.
-- Without this, the spawnmenu won't open because our gamemode's cl_init.lua
-- replaces sandbox's cl_init.lua in the load chain.
hook.Add("SpawnMenuOpen", "GWRP_AllowSpawnMenu", function()
    return true
end)

-- First-time module load on game start
hook.Add("Initialize", "GWRP_ClientInit", function()
    GWRP.Modules:LoadAll()
end)

-- On auto-refresh, Initialize won't fire again, so reload modules directly
if GWRP.Modules._initialized then
    GWRP.Modules:LoadAll()
end

-- Preserve local player data across reloads
GWRP.LocalPlayerData = GWRP.LocalPlayerData or {}

-- Receive player data sync from server
net.Receive("GWRP_PlayerDataSync", function()
    local money = net.ReadInt(32)
    local bank = net.ReadInt(32)
    local job = net.ReadString()
    local gang = net.ReadString()
    local gangRank = net.ReadUInt(8)

    GWRP.LocalPlayerData = {
        money = money,
        bank = bank,
        job = job,
        gang = gang,
        gangRank = gangRank,
    }

    hook.Run("GWRP_PlayerDataUpdated", GWRP.LocalPlayerData)
end)

-- Receive notifications from server
net.Receive("GWRP_Notification", function()
    local msg = net.ReadString()
    local notifType = net.ReadUInt(4)

    -- notifType: 0 = info, 1 = success, 2 = warning, 3 = error
    hook.Run("GWRP_ShowNotification", msg, notifType)

    -- Fallback to chat if HUD notification system isn't loaded
    if not GWRP.Modules:IsEnabled("hud") then
        chat.AddText(Color(255, 200, 50), "[GWRP] ", Color(255, 255, 255), msg)
    end
end)

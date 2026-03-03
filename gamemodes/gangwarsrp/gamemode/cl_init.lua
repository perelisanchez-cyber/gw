-- GangWarsRP - Client Entry Point

include("shared.lua")

-- Load all modules on client
hook.Add("Initialize", "GWRP_ClientInit", function()
    GWRP.Modules:LoadAll()
end)

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

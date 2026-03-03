-- GangWarsRP - Police Server Logic
-- Auto-refresh safe: preserves wanted player state across reloads

GWRP.Police = GWRP.Police or {}
GWRP.Police.WantedPlayers = GWRP.Police.WantedPlayers or {}

-- Set a player as wanted
function GWRP.Police:SetWanted(officer, target, reason)
    if not IsValid(officer) or not IsValid(target) then return false, "Invalid player" end
    if not officer:IsPolice() then return false, "Not a police officer" end
    if target:IsPolice() then return false, "Cannot set police as wanted" end

    reason = GWRP.Security:SanitizeString(reason, 64)
    if reason == "" then reason = "Criminal activity" end

    self.WantedPlayers[target:SteamID()] = {
        reason = reason,
        officer = officer:SteamID(),
        time = CurTime(),
        expires = CurTime() + GWRP.Config.WantedDuration,
    }

    target:SetNWBool("GWRP_Wanted", true)
    target:SetNWString("GWRP_WantedReason", reason)

    GWRP.Log(string.format("[POLICE] %s set %s as wanted: %s", officer:SteamID(), target:SteamID(), reason), "info")
    GWRP.Notify(target, "You are now WANTED: " .. reason, 2)
    return true
end

-- Clear wanted status
function GWRP.Police:ClearWanted(target)
    if not IsValid(target) then return end
    self.WantedPlayers[target:SteamID()] = nil
    target:SetNWBool("GWRP_Wanted", false)
    target:SetNWString("GWRP_WantedReason", "")
end

-- Expire wanted statuses
timer.Create("GWRP_WantedExpiry", 10, 0, function()
    local now = CurTime()
    for sid, data in pairs(GWRP.Police.WantedPlayers) do
        if now > data.expires then
            GWRP.Police.WantedPlayers[sid] = nil
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) and ply:SteamID() == sid then
                    ply:SetNWBool("GWRP_Wanted", false)
                    ply:SetNWString("GWRP_WantedReason", "")
                    GWRP.Notify(ply, "You are no longer wanted", 1)
                    break
                end
            end
        end
    end
end)

-- Net handlers
net.Receive("GWRP_PoliceWanted", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "GangAction", GWRP.Config.RateLimits.GangAction.max, GWRP.Config.RateLimits.GangAction.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local target = net.ReadEntity()
    local reason = net.ReadString()
    if not IsValid(target) or not target:IsPlayer() then return end

    local ok, err = GWRP.Police:SetWanted(ply, target, reason)
    if ok then
        GWRP.Notify(ply, target:Nick() .. " is now wanted", 1)
    else
        GWRP.Notify(ply, err or "Failed", 3)
    end
end)

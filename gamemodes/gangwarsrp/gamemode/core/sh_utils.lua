-- GangWarsRP - Shared Utility Functions

GWRP = GWRP or {}

-- Placeholder log function (overridden by sv_logging.lua on server)
-- On client, just prints to console
if CLIENT then
    function GWRP.Log(msg, level)
        level = level or "info"
        print("[GWRP][" .. string.upper(level) .. "] " .. msg)
    end
end

----------------------------------------------
-- Security Utilities
----------------------------------------------

GWRP.Security = GWRP.Security or {}
GWRP.Security.RateLimits = {}

-- Rate limiter: returns true if action is allowed, false if rate limited
function GWRP.Security:RateCheck(ply, actionID, maxCalls, windowSeconds)
    if CLIENT then return true end -- only enforce on server
    if not IsValid(ply) then return false end

    local key = ply:SteamID64() .. "_" .. actionID
    local now = CurTime()
    local record = self.RateLimits[key]

    if not record then
        self.RateLimits[key] = {count = 1, reset = now + windowSeconds}
        return true
    end

    if now > record.reset then
        record.count = 1
        record.reset = now + windowSeconds
        return true
    end

    record.count = record.count + 1
    if record.count > maxCalls then
        GWRP.Log(string.format("[SECURITY] Rate limited %s (%s) on %s (%d/%d in %.1fs)",
            ply:Nick(), ply:SteamID(), actionID, record.count, maxCalls, windowSeconds), "warn")
        return false
    end

    return true
end

-- Cleanup expired rate limit entries periodically
if SERVER then
    timer.Create("GWRP_RateLimitCleanup", 60, 0, function()
        local now = CurTime()
        for key, record in pairs(GWRP.Security.RateLimits) do
            if now > record.reset + 30 then
                GWRP.Security.RateLimits[key] = nil
            end
        end
    end)
end

-- Sanitize a string for display (strip control chars, limit length)
function GWRP.Security:SanitizeString(str, maxLen)
    if type(str) ~= "string" then return "" end
    str = str:gsub("[%c]", "")              -- Remove control characters
    str = str:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
    if maxLen then str = str:sub(1, maxLen) end
    return str
end

-- Validate and clamp a number
function GWRP.Security:SanitizeNumber(num, min, max, mustBeInt)
    if type(num) ~= "number" then return nil end
    if num ~= num then return nil end           -- NaN check
    if num == math.huge or num == -math.huge then return nil end
    if mustBeInt and num ~= math.floor(num) then return nil end
    return math.Clamp(num, min or 0, max or 2^31)
end

-- Validate a SteamID format
function GWRP.Security:ValidateSteamID(sid)
    if type(sid) ~= "string" then return false end
    return string.match(sid, "^STEAM_%d:%d:%d+$") ~= nil
end

-- Validate entity interaction (distance, ownership, class)
function GWRP.Security:ValidateEntityInteraction(ply, ent, requiredClass, maxDistance)
    if not IsValid(ply) or not IsValid(ent) then return false end
    if requiredClass and ent:GetClass() ~= requiredClass then return false end
    if ply:GetPos():DistToSqr(ent:GetPos()) > (maxDistance or GWRP.Config.EntityInteractDistance) ^ 2 then return false end
    if ent:GetNWString("OwnerID", "") ~= ply:SteamID() and not ply:IsAdmin() then return false end
    return true
end

-- Permission checker for actions requiring specific state
function GWRP.Security:CanPerformAction(ply, requirements)
    if not IsValid(ply) then return false end

    if requirements.alive and not ply:Alive() then return false end
    if requirements.job and ply:GetNWString("GWRP_Job", "") ~= requirements.job then return false end
    if requirements.jobCategory and not table.HasValue(requirements.jobCategory, ply:GetNWString("GWRP_Job", "")) then return false end
    if requirements.gangRank and ply:GetNWInt("GWRP_GangRank", 0) < requirements.gangRank then return false end
    if requirements.admin and not ply:IsAdmin() then return false end
    if requirements.superadmin and not ply:IsSuperAdmin() then return false end

    return true
end

----------------------------------------------
-- General Utilities
----------------------------------------------

-- Format money for display
function GWRP.FormatMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then
        return "-$" .. string.Comma(math.abs(amount))
    end
    return "$" .. string.Comma(amount)
end

-- Format time in seconds to readable string
function GWRP.FormatTime(seconds)
    seconds = math.floor(seconds)
    if seconds < 60 then
        return seconds .. "s"
    elseif seconds < 3600 then
        return math.floor(seconds / 60) .. "m " .. (seconds % 60) .. "s"
    else
        local h = math.floor(seconds / 3600)
        local m = math.floor((seconds % 3600) / 60)
        return h .. "h " .. m .. "m"
    end
end

-- Send a notification to a player (server only)
if SERVER then
    function GWRP.Notify(ply, msg, notifType)
        if not IsValid(ply) then return end
        notifType = notifType or 0 -- 0=info, 1=success, 2=warning, 3=error
        net.Start("GWRP_Notification")
            net.WriteString(msg)
            net.WriteUInt(notifType, 4)
        net.Send(ply)
    end
end

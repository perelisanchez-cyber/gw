-- GangWarsRP - Gangs Server Logic

GWRP.Gangs = GWRP.Gangs or {}

-- Create a new gang
function GWRP.Gangs:Create(ply, name, color)
    if not IsValid(ply) then return false, "Invalid player" end
    if ply:IsInGang() then return false, "You are already in a gang" end

    name = GWRP.Security:SanitizeString(name, GWRP.Config.GangNameMaxLen)
    if #name < GWRP.Config.GangNameMinLen then return false, "Gang name too short" end

    -- Check if name is taken
    local existing = GWRP.DB:Select("gwrp_gangs", {name = name})
    if existing and #existing > 0 then return false, "Gang name already taken" end

    -- Check funds
    if not GWRP.Modules:IsEnabled("economy") then return false, "Economy module required" end
    if ply:GetMoney() < GWRP.Config.GangCreationCost then return false, "Not enough money" end

    -- Take money
    GWRP.Economy:TakeMoney(ply, GWRP.Config.GangCreationCost)

    -- Create gang in DB
    GWRP.DB:Insert("gwrp_gangs", {
        name = name,
        color = color or "255,255,255",
        bank = 0,
        motd = "",
        leader_steamid = ply:SteamID(),
        created_at = os.time(),
    })

    -- Set player as leader
    ply:SetGang(name)
    ply:SetGangRank(GWRP.GANG_RANK.LEADER)
    GWRP.DB:SavePlayerData(ply)

    GWRP.Log(string.format("[GANGS] %s (%s) created gang '%s'", ply:Nick(), ply:SteamID(), name), "info")
    return true
end

-- Invite a player to a gang
function GWRP.Gangs:Invite(ply, target)
    if not IsValid(ply) or not IsValid(target) then return false, "Invalid player" end
    if not ply:IsInGang() then return false, "You are not in a gang" end
    if ply:GetGangRank() < GWRP.GANG_RANK.OFFICER then return false, "Insufficient rank" end
    if target:IsInGang() then return false, "Player is already in a gang" end

    -- Check gang size
    local members = 0
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) and p:GetGang() == ply:GetGang() then members = members + 1 end
    end
    if members >= GWRP.Config.MaxGangSize then return false, "Gang is full" end

    target:SetGang(ply:GetGang())
    target:SetGangRank(GWRP.GANG_RANK.RECRUIT)
    GWRP.DB:SavePlayerData(target)

    GWRP.Log(string.format("[GANGS] %s invited %s to '%s'", ply:SteamID(), target:SteamID(), ply:GetGang()), "info")
    return true
end

-- Leave a gang
function GWRP.Gangs:Leave(ply)
    if not IsValid(ply) or not ply:IsInGang() then return false, "Not in a gang" end

    local gangName = ply:GetGang()
    local wasLeader = ply:IsGangLeader()

    ply:SetGang("")
    ply:SetGangRank(0)
    GWRP.DB:SavePlayerData(ply)

    GWRP.Log(string.format("[GANGS] %s (%s) left gang '%s'", ply:Nick(), ply:SteamID(), gangName), "info")

    -- If leader left, promote next highest rank or dissolve
    if wasLeader then
        local newLeader = nil
        local highestRank = -1
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) and p:GetGang() == gangName and p:GetGangRank() > highestRank then
                highestRank = p:GetGangRank()
                newLeader = p
            end
        end

        if newLeader then
            newLeader:SetGangRank(GWRP.GANG_RANK.LEADER)
            GWRP.DB:SavePlayerData(newLeader)
            GWRP.DB:Update("gwrp_gangs", {leader_steamid = newLeader:SteamID()}, {name = gangName})
            GWRP.Notify(newLeader, "You are now the gang leader!", 1)
        else
            -- No members left, dissolve
            GWRP.DB:Delete("gwrp_gangs", {name = gangName})
            GWRP.Log(string.format("[GANGS] Gang '%s' dissolved (no members)", gangName), "info")
        end
    end

    return true
end

-- Net handlers
net.Receive("GWRP_GangCreate", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "GangCreation", GWRP.Config.RateLimits.GangCreation.max, GWRP.Config.RateLimits.GangCreation.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local name = net.ReadString()
    name = GWRP.Security:SanitizeString(name, GWRP.Config.GangNameMaxLen)

    local ok, err = GWRP.Gangs:Create(ply, name)
    if ok then
        GWRP.Notify(ply, "Gang '" .. name .. "' created!", 1)
    else
        GWRP.Notify(ply, err or "Failed to create gang", 3)
    end
    GWRP.DB:SyncPlayerData(ply)
end)

net.Receive("GWRP_GangLeave", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "GangAction", GWRP.Config.RateLimits.GangAction.max, GWRP.Config.RateLimits.GangAction.window) then return end
    if not IsValid(ply) then return end

    local ok, err = GWRP.Gangs:Leave(ply)
    if ok then
        GWRP.Notify(ply, "You left the gang", 1)
    else
        GWRP.Notify(ply, err or "Failed to leave gang", 3)
    end
    GWRP.DB:SyncPlayerData(ply)
end)

net.Receive("GWRP_GangInvite", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "GangAction", GWRP.Config.RateLimits.GangAction.max, GWRP.Config.RateLimits.GangAction.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local target = net.ReadEntity()
    if not IsValid(target) or not target:IsPlayer() then return end

    local ok, err = GWRP.Gangs:Invite(ply, target)
    if ok then
        GWRP.Notify(ply, "Invited " .. target:Nick() .. " to the gang", 1)
        GWRP.Notify(target, "You joined " .. ply:GetGang() .. "!", 1)
    else
        GWRP.Notify(ply, err or "Failed to invite", 3)
    end
    GWRP.DB:SyncPlayerData(target)
end)

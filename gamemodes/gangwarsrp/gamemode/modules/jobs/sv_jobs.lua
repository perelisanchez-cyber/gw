-- GangWarsRP - Jobs Server Logic

GWRP.Jobs = GWRP.Jobs or {}

-- Switch a player's job
function GWRP.Jobs:SwitchJob(ply, jobID)
    if not IsValid(ply) then return false, "Invalid player" end

    local jobDef = GWRP.Jobs.List[jobID]
    if not jobDef then return false, "Unknown job" end

    -- Check gang requirement
    if jobDef.requiresGang and ply:GetNWString("GWRP_Gang", "") == "" then
        return false, "You must be in a gang for this job"
    end

    -- Check slot limit
    if jobDef.maxSlots and jobDef.maxSlots > 0 then
        local count = 0
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) and p:GetJob() == jobID then count = count + 1 end
        end
        if count >= jobDef.maxSlots then return false, "No slots available for this job" end
    end

    ply:SetJob(jobID)
    GWRP.DB:Update("gwrp_players", {job = jobID}, {steamid = ply:SteamID()})
    GWRP.Log(string.format("[JOBS] %s (%s) switched to %s", ply:Nick(), ply:SteamID(), jobID), "info")

    hook.Run("GWRP_PlayerJobChanged", ply, jobID, jobDef)
    return true
end

-- Net handler for job switching
net.Receive("GWRP_JobSwitch", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "JobSwitch", GWRP.Config.RateLimits.JobSwitch.max, GWRP.Config.RateLimits.JobSwitch.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local jobID = net.ReadString()
    jobID = GWRP.Security:SanitizeString(jobID, 32)
    if jobID == "" then return end

    local ok, err = GWRP.Jobs:SwitchJob(ply, jobID)
    if ok then
        GWRP.Notify(ply, "You are now a " .. (GWRP.Jobs.List[jobID] and GWRP.Jobs.List[jobID].name or jobID), 1)
        GWRP.DB:SyncPlayerData(ply)
    else
        GWRP.Notify(ply, err or "Cannot switch jobs", 3)
    end
end)

-- Salary timer
timer.Create("GWRP_SalaryTimer", GWRP.Config.SalaryInterval, 0, function()
    if not GWRP.Modules:IsEnabled("economy") then return end

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local jobDef = GWRP.Jobs.List[ply:GetJob()]
            if jobDef and jobDef.salary and jobDef.salary > 0 then
                GWRP.Economy:AddMoney(ply, jobDef.salary)
                GWRP.Notify(ply, "Salary: " .. GWRP.FormatMoney(jobDef.salary), 1)
            end
        end
    end
end)

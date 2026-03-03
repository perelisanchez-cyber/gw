-- GangWarsRP - Jobs Shared Definitions

GWRP.Jobs = GWRP.Jobs or {}
GWRP.Jobs.List = GWRP.Jobs.List or {}

-- Player job accessor
local PLAYER = FindMetaTable("Player")

function PLAYER:GetJob()
    return self:GetNWString("GWRP_Job", GWRP.Config.DefaultJob)
end

if SERVER then
    function PLAYER:SetJob(jobID)
        self:SetNWString("GWRP_Job", jobID)
    end
end

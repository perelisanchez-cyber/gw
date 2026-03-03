-- GangWarsRP - Police Shared Definitions

GWRP.Police = GWRP.Police or {}

-- Police job IDs
GWRP.Police.Jobs = {"police", "police_chief", "mayor"}

-- Check if a player is a police officer
local PLAYER = FindMetaTable("Player")

function PLAYER:IsPolice()
    return table.HasValue(GWRP.Police.Jobs, self:GetNWString("GWRP_Job", ""))
end

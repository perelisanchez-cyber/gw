-- GangWarsRP - Gangs Shared Helpers

GWRP.Gangs = GWRP.Gangs or {}

local PLAYER = FindMetaTable("Player")

function PLAYER:GetGang()
    return self:GetNWString("GWRP_Gang", "")
end

function PLAYER:GetGangRank()
    return self:GetNWInt("GWRP_GangRank", 0)
end

function PLAYER:IsInGang()
    return self:GetGang() ~= ""
end

function PLAYER:IsGangLeader()
    return self:GetGangRank() == GWRP.GANG_RANK.LEADER
end

if SERVER then
    function PLAYER:SetGang(gangName)
        self:SetNWString("GWRP_Gang", gangName)
    end

    function PLAYER:SetGangRank(rank)
        self:SetNWInt("GWRP_GangRank", rank)
    end
end

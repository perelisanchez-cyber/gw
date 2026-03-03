-- GangWarsRP - Economy Shared Helpers

GWRP.Economy = GWRP.Economy or {}

-- Player money accessor helpers (use NWVars for fast shared access)
local PLAYER = FindMetaTable("Player")

function PLAYER:GetMoney()
    return self:GetNWInt("GWRP_Money", 0)
end

function PLAYER:GetBank()
    return self:GetNWInt("GWRP_Bank", 0)
end

if SERVER then
    function PLAYER:SetMoney(amount)
        self:SetNWInt("GWRP_Money", math.floor(amount))
    end

    function PLAYER:SetBank(amount)
        self:SetNWInt("GWRP_Bank", math.floor(amount))
    end
end

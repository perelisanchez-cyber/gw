-- GangWarsRP - Shops Server Logic

GWRP.Shops = GWRP.Shops or {}

-- Process a shop purchase
function GWRP.Shops:Purchase(ply, itemID)
    if not IsValid(ply) or not ply:Alive() then return false, "Cannot purchase now" end

    local item = self.Items[itemID]
    if not item then return false, "Item not found" end

    -- Price comes from server config, NEVER from client
    local price = item.price
    if not price or price <= 0 then return false, "Item not for sale" end

    if not GWRP.Modules:IsEnabled("economy") then return false, "Economy unavailable" end
    if ply:GetMoney() < price then return false, "Not enough money" end

    -- Check entity limits if it's an entity spawn
    if item.entity then
        local count = 0
        for _, ent in ipairs(ents.FindByClass(item.entity)) do
            if IsValid(ent) and ent:GetNWString("OwnerID", "") == ply:SteamID() then
                count = count + 1
            end
        end
        local maxEnts = item.maxPerPlayer or 3
        if count >= maxEnts then return false, "Entity limit reached (" .. maxEnts .. ")" end
    end

    -- Take money
    local ok, err = GWRP.Economy:TakeMoney(ply, price)
    if not ok then return false, err end

    -- Spawn item/entity/weapon
    if item.weapon then
        ply:Give(item.weapon)
    elseif item.entity then
        local ent = ents.Create(item.entity)
        if IsValid(ent) then
            local tr = ply:GetEyeTrace()
            ent:SetPos(tr.HitPos + Vector(0, 0, 10))
            ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
            ent:Spawn()
            ent:SetNWString("OwnerID", ply:SteamID())
        end
    end

    GWRP.DB:LogTransaction(ply:SteamID(), "purchase", -price, "Bought " .. (item.name or itemID))
    GWRP.Log(string.format("[SHOPS] %s purchased %s for %s", ply:SteamID(), itemID, GWRP.FormatMoney(price)), "info")
    return true
end

-- Net handler
net.Receive("GWRP_ShopPurchase", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "ShopPurchase", GWRP.Config.RateLimits.ShopPurchase.max, GWRP.Config.RateLimits.ShopPurchase.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local itemID = net.ReadString()
    itemID = GWRP.Security:SanitizeString(itemID, 64)
    if itemID == "" then return end

    local ok, err = GWRP.Shops:Purchase(ply, itemID)
    if ok then
        GWRP.Notify(ply, "Purchased!", 1)
    else
        GWRP.Notify(ply, err or "Purchase failed", 3)
    end
    GWRP.DB:SyncPlayerData(ply)
end)

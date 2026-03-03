-- GangWarsRP - Inventory Server Logic
-- TODO: Implement full inventory CRUD, item use, drop/pickup

GWRP.Inventory = GWRP.Inventory or {}

-- Get a player's inventory from DB
function GWRP.Inventory:GetPlayerInventory(ply)
    if not IsValid(ply) then return {} end
    return GWRP.DB:Select("gwrp_inventory", {steamid = ply:SteamID()}) or {}
end

-- Add an item to a player's inventory
function GWRP.Inventory:AddItem(ply, itemID, amount)
    if not IsValid(ply) then return false, "Invalid player" end
    amount = amount or 1

    -- Find an empty slot
    local inv = self:GetPlayerInventory(ply)
    local usedSlots = {}
    for _, row in ipairs(inv) do
        usedSlots[tonumber(row.slot)] = true
    end

    local maxSlots = GWRP.Config.DefaultInventorySize
    local freeSlot = nil
    for i = 1, maxSlots do
        if not usedSlots[i] then
            freeSlot = i
            break
        end
    end

    if not freeSlot then return false, "Inventory full" end

    GWRP.DB:Insert("gwrp_inventory", {
        steamid = ply:SteamID(),
        slot = freeSlot,
        item_id = itemID,
        amount = amount,
    })

    GWRP.Log(string.format("[INVENTORY] %s gained %dx %s", ply:SteamID(), amount, itemID), "info")
    return true
end

-- Remove an item from a player's inventory
function GWRP.Inventory:RemoveItem(ply, slot)
    if not IsValid(ply) then return false end
    GWRP.DB:Delete("gwrp_inventory", {steamid = ply:SteamID(), slot = slot})
    return true
end

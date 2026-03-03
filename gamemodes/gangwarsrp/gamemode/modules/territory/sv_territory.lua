-- GangWarsRP - Territory Server Logic
-- TODO: Implement capture mechanics, passive income, zone management

GWRP.Territory = GWRP.Territory or {}

-- Load territory state from database
function GWRP.Territory:LoadState()
    local rows = GWRP.DB:Select("gwrp_territories", {})
    if rows then
        for _, row in ipairs(rows) do
            if self.Zones[row.zone_id] then
                self.Zones[row.zone_id].owner = row.owner_gang
                self.Zones[row.zone_id].captured_at = tonumber(row.captured_at) or 0
            end
        end
    end
    GWRP.Log("[TERRITORY] Loaded territory state from DB", "info")
end

-- Save territory state
function GWRP.Territory:SaveZone(zoneID)
    local zone = self.Zones[zoneID]
    if not zone then return end

    local existing = GWRP.DB:Select("gwrp_territories", {zone_id = zoneID})
    if existing and #existing > 0 then
        GWRP.DB:Update("gwrp_territories", {owner_gang = zone.owner or "", captured_at = zone.captured_at or 0}, {zone_id = zoneID})
    else
        GWRP.DB:Insert("gwrp_territories", {zone_id = zoneID, owner_gang = zone.owner or "", captured_at = zone.captured_at or 0})
    end
end

-- Load map-specific zone config
hook.Add("GWRP_ModuleLoaded", "GWRP_TerritoryInit", function(moduleID)
    if moduleID ~= "territory" then return end

    local mapName = game.GetMap()
    local configPath = "gangwarsrp/gamemode/config/maps/" .. mapName .. ".lua"
    if file.Exists(configPath, "LUA") then
        include(configPath)
        GWRP.Log("[TERRITORY] Loaded map config for " .. mapName, "info")
    else
        GWRP.Log("[TERRITORY] No map config for " .. mapName, "warn")
    end

    GWRP.Territory:LoadState()
end)

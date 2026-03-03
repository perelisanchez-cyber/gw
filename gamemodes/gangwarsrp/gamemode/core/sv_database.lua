-- GangWarsRP - Database System (Server Only)
-- SQLite database initialization, migrations, and helper functions

GWRP.DB = GWRP.DB or {}

-- Initialize database tables
function GWRP.DB:Initialize()
    sql.Begin()

    -- Players table
    sql.Query([[
        CREATE TABLE IF NOT EXISTS gwrp_players (
            steamid TEXT PRIMARY KEY,
            money INTEGER DEFAULT ]] .. GWRP.Config.StartingMoney .. [[,
            bank INTEGER DEFAULT ]] .. GWRP.Config.StartingBank .. [[,
            gang TEXT DEFAULT '',
            gang_rank INTEGER DEFAULT 0,
            job TEXT DEFAULT ']] .. GWRP.Config.DefaultJob .. [[',
            playtime INTEGER DEFAULT 0
        )
    ]])

    -- Gangs table
    sql.Query([[
        CREATE TABLE IF NOT EXISTS gwrp_gangs (
            name TEXT PRIMARY KEY,
            color TEXT DEFAULT '255,255,255',
            bank INTEGER DEFAULT 0,
            motd TEXT DEFAULT '',
            leader_steamid TEXT,
            created_at INTEGER
        )
    ]])

    -- Territories table
    sql.Query([[
        CREATE TABLE IF NOT EXISTS gwrp_territories (
            zone_id TEXT PRIMARY KEY,
            owner_gang TEXT DEFAULT '',
            captured_at INTEGER DEFAULT 0
        )
    ]])

    -- Inventory table
    sql.Query([[
        CREATE TABLE IF NOT EXISTS gwrp_inventory (
            steamid TEXT,
            slot INTEGER,
            item_id TEXT,
            amount INTEGER DEFAULT 1,
            PRIMARY KEY (steamid, slot)
        )
    ]])

    -- Transaction log
    sql.Query([[
        CREATE TABLE IF NOT EXISTS gwrp_transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            steamid TEXT,
            type TEXT,
            amount INTEGER,
            description TEXT,
            timestamp INTEGER
        )
    ]])

    sql.Commit()
    GWRP.Log("[DB] All tables created/verified", "info")
end

-- Ensure a player record exists in the database
function GWRP.DB:EnsurePlayer(ply)
    if not IsValid(ply) then return end

    local sid = ply:SteamID()
    local existing = self:Select("gwrp_players", {steamid = sid})

    if not existing or #existing == 0 then
        self:Insert("gwrp_players", {
            steamid = sid,
            money = GWRP.Config.StartingMoney,
            bank = GWRP.Config.StartingBank,
            gang = "",
            gang_rank = 0,
            job = GWRP.Config.DefaultJob,
            playtime = 0,
        })
        GWRP.Log(string.format("[DB] Created new player record for %s (%s)", ply:Nick(), sid), "info")
    end

    -- Load data onto player entity for fast access
    self:LoadPlayerData(ply)
end

-- Load player data from DB onto the player entity
function GWRP.DB:LoadPlayerData(ply)
    if not IsValid(ply) then return end

    local sid = ply:SteamID()
    local data = self:Select("gwrp_players", {steamid = sid})

    if data and data[1] then
        local row = data[1]
        ply:SetNWInt("GWRP_Money", tonumber(row.money) or GWRP.Config.StartingMoney)
        ply:SetNWInt("GWRP_Bank", tonumber(row.bank) or GWRP.Config.StartingBank)
        ply:SetNWString("GWRP_Job", row.job or GWRP.Config.DefaultJob)
        ply:SetNWString("GWRP_Gang", row.gang or "")
        ply:SetNWInt("GWRP_GangRank", tonumber(row.gang_rank) or 0)
        ply:SetNWInt("GWRP_Playtime", tonumber(row.playtime) or 0)
    end
end

-- Save player data from entity to DB
function GWRP.DB:SavePlayerData(ply)
    if not IsValid(ply) then return end

    local sid = ply:SteamID()
    self:Update("gwrp_players", {
        money = ply:GetNWInt("GWRP_Money", GWRP.Config.StartingMoney),
        bank = ply:GetNWInt("GWRP_Bank", GWRP.Config.StartingBank),
        job = ply:GetNWString("GWRP_Job", GWRP.Config.DefaultJob),
        gang = ply:GetNWString("GWRP_Gang", ""),
        gang_rank = ply:GetNWInt("GWRP_GangRank", 0),
        playtime = ply:GetNWInt("GWRP_Playtime", 0),
    }, {steamid = sid})
end

-- Sync player data to client via net message
function GWRP.DB:SyncPlayerData(ply)
    if not IsValid(ply) then return end

    net.Start("GWRP_PlayerDataSync")
        net.WriteInt(ply:GetNWInt("GWRP_Money", 0), 32)
        net.WriteInt(ply:GetNWInt("GWRP_Bank", 0), 32)
        net.WriteString(ply:GetNWString("GWRP_Job", GWRP.Config.DefaultJob))
        net.WriteString(ply:GetNWString("GWRP_Gang", ""))
        net.WriteUInt(ply:GetNWInt("GWRP_GangRank", 0), 8)
    net.Send(ply)
end

-- Log a transaction
function GWRP.DB:LogTransaction(steamid, transType, amount, description)
    self:Insert("gwrp_transactions", {
        steamid = steamid,
        type = transType,
        amount = amount,
        description = description,
        timestamp = os.time(),
    })
end

----------------------------------------------
-- Safe Query Helpers (enforced sanitization)
----------------------------------------------

-- Safe SELECT
function GWRP.DB:Select(tableName, conditions)
    local where = {}
    for col, val in pairs(conditions) do
        table.insert(where, col .. " = " .. sql.SQLStr(tostring(val)))
    end
    local query = "SELECT * FROM " .. tableName
    if #where > 0 then query = query .. " WHERE " .. table.concat(where, " AND ") end
    return sql.Query(query)
end

-- Safe INSERT
function GWRP.DB:Insert(tableName, data)
    local cols, vals = {}, {}
    for col, val in pairs(data) do
        table.insert(cols, col)
        table.insert(vals, sql.SQLStr(tostring(val)))
    end
    return sql.Query("INSERT INTO " .. tableName .. " (" .. table.concat(cols, ", ") .. ") VALUES (" .. table.concat(vals, ", ") .. ")")
end

-- Safe UPDATE
function GWRP.DB:Update(tableName, data, conditions)
    local set, where = {}, {}
    for col, val in pairs(data) do
        table.insert(set, col .. " = " .. sql.SQLStr(tostring(val)))
    end
    for col, val in pairs(conditions) do
        table.insert(where, col .. " = " .. sql.SQLStr(tostring(val)))
    end
    return sql.Query("UPDATE " .. tableName .. " SET " .. table.concat(set, ", ") .. " WHERE " .. table.concat(where, " AND "))
end

-- Safe DELETE (requires at least one condition for safety)
function GWRP.DB:Delete(tableName, conditions)
    local where = {}
    for col, val in pairs(conditions) do
        table.insert(where, col .. " = " .. sql.SQLStr(tostring(val)))
    end
    if #where == 0 then return false end -- never allow DELETE without WHERE
    return sql.Query("DELETE FROM " .. tableName .. " WHERE " .. table.concat(where, " AND "))
end

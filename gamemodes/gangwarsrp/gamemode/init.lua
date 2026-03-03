-- GangWarsRP - Server Entry Point
-- Auto-refresh safe: re-execution reloads modules without breaking state

-- Send client files
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

-- Core shared files for client
AddCSLuaFile("core/sh_config.lua")
AddCSLuaFile("core/sh_utils.lua")
AddCSLuaFile("core/sh_module_loader.lua")

-- Load shared
include("shared.lua")

-- Load server-only core files
include("core/sv_logging.lua")
include("core/sv_database.lua")
include("core/sv_commands.lua")

-- Initialize database tables on first server start
hook.Add("Initialize", "GWRP_ServerInit", function()
    GWRP.Log("[CORE] GangWarsRP v" .. GWRP.Version .. " initializing...", "info")
    GWRP.DB:Initialize()
    GWRP.Log("[CORE] Database initialized", "info")

    -- First-time module load happens here
    GWRP.Modules:LoadAll()
    GWRP.Log("[CORE] All modules loaded", "info")
end)

-- On auto-refresh, Initialize won't fire again, so reload modules directly.
-- Check if the server is already running (players exist or game has started)
if GWRP.Modules._initialized then
    GWRP.Log("[CORE] Auto-refresh detected, reloading...", "info")
    GWRP.Modules:LoadAll()
end

-- Player initial spawn: load data from database
hook.Add("PlayerInitialSpawn", "GWRP_PlayerInit", function(ply)
    GWRP.Log(string.format("[CORE] Player connected: %s (%s)", ply:Nick(), ply:SteamID()), "info")

    -- Create or load player data
    GWRP.DB:EnsurePlayer(ply)

    -- Sync data to client after a short delay to ensure client is ready
    timer.Simple(1, function()
        if not IsValid(ply) then return end
        GWRP.DB:SyncPlayerData(ply)
    end)
end)

-- Player disconnect: save data
hook.Add("PlayerDisconnected", "GWRP_PlayerDisconnect", function(ply)
    GWRP.Log(string.format("[CORE] Player disconnected: %s (%s)", ply:Nick(), ply:SteamID()), "info")
    GWRP.DB:SavePlayerData(ply)
end)

-- Periodic auto-save (timer.Create replaces existing timer with same name — reload safe)
timer.Create("GWRP_AutoSave", 300, 0, function()
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            GWRP.DB:SavePlayerData(ply)
        end
    end
    GWRP.Log("[CORE] Auto-save complete", "debug")
end)

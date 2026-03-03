# GangWarsRP - Garry's Mod Gamemode

## Project Overview

This is a custom Garry's Mod gamemode called **GangWarsRP**, a gang-based dark roleplaying experience. Players join or create gangs, claim territory, earn money through jobs and illegal activities, and wage war against rival gangs for dominance. The gamemode is built on top of the DarkRP framework concepts but is a **standalone gamemode** written from scratch in Lua.

**Key Design Principles:**
- **Fully modular** — Every system is a self-contained module that can be enabled/disabled via config without breaking other systems
- **F4 Menu driven** — The F4 menu is the primary player interface for all major actions (jobs, gangs, shops, inventory, settings). Chat commands exist as secondary shortcuts.
- **GitHub-ready** — The repo is structured for collaborative development with proper `.gitignore`, README, and release workflow

## Tech Stack

- **Language:** Lua (GLua - Garry's Mod Lua)
- **Engine:** Source Engine (Garry's Mod)
- **Networking:** Garry's Mod net library for client-server communication
- **Storage:** SQLite via `sql.Query()` for persistent player/gang data
- **UI:** Derma (Garry's Mod's VGUI framework)
- **Version Control:** Git / GitHub

---

## GitHub Repository Structure

```
gangwarsrp/                         -- Repository root
├── .gitignore                      -- Ignore .DS_Store, *.gma, *.cache, etc.
├── README.md                       -- Setup instructions, feature list, screenshots
├── LICENSE                         -- License file
├── CHANGELOG.md                    -- Version history
├── .github/
│   └── workflows/
│       └── release.yml             -- (Optional) Auto-package on tag push
├── gamemodes/gangwarsrp/
│   ├── gangwarsrp.txt              -- Gamemode metadata
│   └── gamemode/
│       ├── init.lua                -- Server entry point & module loader
│       ├── cl_init.lua             -- Client entry point & module loader
│       ├── shared.lua              -- Shared globals, GWRP table, net strings
│       ├── core/
│       │   ├── sh_module_loader.lua -- Module discovery, registration, enable/disable
│       │   ├── sv_database.lua     -- Database init, migrations, helpers
│       │   ├── sh_config.lua       -- Master config (module toggles + global settings)
│       │   ├── sh_utils.lua        -- Shared utility functions
│       │   ├── sv_logging.lua      -- Server-side logging system
│       │   └── sv_commands.lua     -- Chat command registration framework
│       ├── modules/
│       │   ├── f4menu/             -- THE CORE UI MODULE (always enabled)
│       │   │   ├── sh_module.lua   -- Module manifest
│       │   │   ├── cl_f4menu.lua   -- Main F4 menu frame & tab system
│       │   │   ├── cl_theme.lua    -- Shared Derma theme (colors, fonts, panels)
│       │   │   └── cl_tabs.lua     -- Tab registration API for other modules
│       │   ├── gangs/
│       │   │   ├── sh_module.lua   -- Module manifest (dependencies, toggle key)
│       │   │   ├── sv_gangs.lua    -- Gang CRUD, invites, ranks, wars (server)
│       │   │   ├── cl_gangs.lua    -- Gang F4 tab panel (client)
│       │   │   ├── cl_gang_hud.lua -- Gang info on HUD (client)
│       │   │   └── sh_gangs.lua    -- Shared gang enums/helpers
│       │   ├── territory/
│       │   │   ├── sh_module.lua
│       │   │   ├── sv_territory.lua
│       │   │   ├── cl_territory.lua -- Territory F4 tab (map overview)
│       │   │   ├── cl_territory_hud.lua
│       │   │   └── sh_territory.lua
│       │   ├── economy/
│       │   │   ├── sh_module.lua
│       │   │   ├── sv_economy.lua
│       │   │   ├── cl_economy.lua  -- Bank/wallet F4 tab
│       │   │   └── sh_economy.lua
│       │   ├── jobs/
│       │   │   ├── sh_module.lua
│       │   │   ├── sv_jobs.lua
│       │   │   ├── cl_jobs.lua     -- Job selection F4 tab
│       │   │   └── sh_jobs.lua
│       │   ├── inventory/
│       │   │   ├── sh_module.lua
│       │   │   ├── sv_inventory.lua
│       │   │   ├── cl_inventory.lua -- Inventory F4 tab
│       │   │   └── sh_inventory.lua
│       │   ├── hud/
│       │   │   ├── sh_module.lua
│       │   │   ├── cl_hud.lua      -- Main HUD overlay
│       │   │   ├── cl_scoreboard.lua
│       │   │   └── cl_notifications.lua
│       │   ├── police/
│       │   │   ├── sh_module.lua
│       │   │   ├── sv_police.lua
│       │   │   ├── cl_police.lua   -- Police actions F4 tab (warrants, wanted list)
│       │   │   └── sh_police.lua
│       │   ├── shops/
│       │   │   ├── sh_module.lua
│       │   │   ├── sv_shops.lua    -- Purchase validation, item spawning
│       │   │   ├── cl_shops.lua    -- Shop F4 tab (weapons, items, vehicles)
│       │   │   └── sh_shops.lua    -- Shop item definitions
│       │   └── admin/
│       │       ├── sh_module.lua
│       │       ├── sv_admin.lua
│       │       └── cl_admin.lua    -- Admin F4 tab (player list, bans, config)
│       ├── config/
│       │   ├── maps/               -- Per-map territory configs
│       │   │   ├── rp_downtown_v2.lua
│       │   │   └── rp_evocity_v33x.lua
│       │   ├── sh_jobs_config.lua  -- Job definitions
│       │   ├── sh_gangs_config.lua -- Default/preset gang definitions
│       │   ├── sh_weapons_config.lua
│       │   └── sh_shops_config.lua -- Shop item listings and prices
│       └── entities/
│           ├── entities/
│           │   ├── gwrp_gang_vault/
│           │   ├── gwrp_drug_lab/
│           │   ├── gwrp_money_printer/
│           │   ├── gwrp_capture_point/
│           │   └── gwrp_black_market/
│           └── weapons/
│               └── (custom weapons if any)
```

---

## Module System (CRITICAL)

Every feature is a **module**. Modules are self-contained folders under `modules/` with a `sh_module.lua` manifest file.

### Module Manifest (`sh_module.lua`)

Every module MUST have this file. It registers the module with the loader:

```lua
GWRP.Modules:Register({
    id = "gangs",                          -- Unique string ID
    name = "Gang System",                  -- Display name
    description = "Create and manage gangs, ranks, wars",
    version = "1.0.0",
    enabled = true,                        -- Default state (overridden by sh_config.lua)
    dependencies = {"economy"},            -- Other module IDs this requires
    soft_dependencies = {"territory"},     -- Optional: enhanced if present, works without
    
    -- Files to include (loader handles AddCSLuaFile + include)
    client = {
        "cl_gangs.lua",
        "cl_gang_hud.lua",
    },
    server = {
        "sv_gangs.lua",
    },
    shared = {
        "sh_gangs.lua",
    },

    -- F4 Menu tab registration (nil if no tab)
    f4_tab = {
        label = "Gangs",
        icon = "icon16/group.png",
        order = 30,                        -- Sort order in F4 menu
        panel_class = "GWRP_GangsPanel",   -- Derma panel to create
    },

    -- Chat commands this module registers
    commands = {
        {cmd = "gc", description = "Gang chat", usage = "/gc <message>"},
        {cmd = "gang", description = "Gang management", usage = "/gang <create|invite|leave|war> [args]"},
    },
})
```

### Module Loader (`sh_module_loader.lua`)

The loader:
1. Scans all folders in `modules/`
2. Loads each `sh_module.lua` manifest
3. Checks `sh_config.lua` for enable/disable overrides
4. Resolves dependency graph (hard deps must be enabled; soft deps are optional)
5. Loads modules in dependency order
6. Skips disabled modules entirely (no files included, no hooks registered)
7. Provides runtime API:

```lua
GWRP.Modules:IsEnabled("gangs")          -- Check if a module is active
GWRP.Modules:Get("gangs")                -- Get module table
GWRP.Modules:GetAll()                    -- All registered modules
GWRP.Modules:Disable("gangs")            -- Runtime disable (admin only, requires restart/reload)
GWRP.Modules:Enable("gangs")             -- Runtime enable
```

### Config Toggles (`sh_config.lua`)

```lua
GWRP.Config = {
    -- Module toggles (override manifest defaults)
    Modules = {
        f4menu      = true,   -- ALWAYS true, core module
        gangs       = true,
        territory   = true,
        economy     = true,
        jobs        = true,
        inventory   = true,
        hud         = true,
        police      = true,
        shops       = true,
        admin       = true,
    },

    -- Global settings
    StartingMoney       = 1000,
    SalaryInterval       = 300,    -- seconds
    MoneyDropOnDeath     = 0.10,   -- 10%
    MaxGangSize          = 15,
    GangCreationCost     = 5000,
    -- ... etc
}
```

### Cross-Module Communication

Modules must **never** directly reference another module's internals. Instead:

1. **Check before calling:** `if GWRP.Modules:IsEnabled("economy") then ... end`
2. **Use hooks for events:** `hook.Run("GWRP_PlayerEarnedMoney", ply, amount, source)` — any module can listen
3. **Use the shared API table:** Each module registers its public API on `GWRP.<ModuleName>` (e.g., `GWRP.Economy:AddMoney(ply, 500)`)
4. **Soft dependencies** gracefully degrade — e.g., territory gives bonus income only if economy module is enabled

---

## F4 Menu System

The F4 menu is the **primary player interface**. It is a core module (`f4menu`) that is always enabled.

### Architecture

- **Frame:** A single `DFrame` opened/closed by pressing F4 (`+menu` bind or `GM:OnSpawnMenuOpen()`)
- **Tab bar:** Left-side vertical tab strip. Each enabled module can register a tab via its manifest.
- **Content area:** Swaps Derma panels based on selected tab
- **Theme:** Consistent dark theme defined in `cl_theme.lua` — all modules use `GWRP.Theme` for colors, fonts, and panel constructors

### Tab Registration

Modules register their tab in `sh_module.lua` (see manifest above). The F4 menu reads all enabled modules' `f4_tab` fields and builds tabs in `order` sort.

### Default Tab Layout (when all modules enabled)

| Order | Tab       | Module    | Description                                    |
|-------|-----------|-----------|------------------------------------------------|
| 10    | Jobs      | jobs      | Browse and switch jobs by category             |
| 20    | Shop      | shops     | Buy weapons, items, entities, vehicles         |
| 30    | Gangs     | gangs     | Create/manage gang, view roster, declare war   |
| 40    | Territory | territory | Map overview of zones, ownership, capture status |
| 50    | Inventory | inventory | View/drop/use items                            |
| 60    | Bank      | economy   | Deposit/withdraw, wire transfer, transaction log |
| 70    | Police    | police    | (Police only) Warrants, wanted list, jail list  |
| 80    | Settings  | hud       | HUD customization, keybinds                    |
| 90    | Admin     | admin     | (Admin only) Player management, module toggles  |

### F4 Menu Behavior

- Press F4 to open, press F4 or Escape to close
- Remembers last active tab per session
- Tabs dynamically appear/disappear based on job (Police tab only for cops, Admin tab only for admins)
- Smooth open/close animation
- Search/filter in applicable tabs (job list, shop items)

### Chat Commands (Secondary Interface)

Chat commands still exist as shortcuts. They are registered per-module in the manifest and handled by `sv_commands.lua`:

```lua
-- Players can still use chat if they prefer
/job cop              -- Quick job switch
/gc Hey gang!         -- Gang chat
/give 500             -- Give money to player in crosshair
/drop 500             -- Drop money
/gang invite PlayerX  -- Invite to gang

-- Police commands
/warrant PlayerX Raiding  -- Issue warrant
/wanted PlayerX Murder     -- Set wanted
/lockdown                  -- (Mayor) Toggle lockdown
```

But the **F4 menu is always the recommended and primary way** to interact. Chat commands are convenience shortcuts.

---

## Core Systems

### 1. Gang System (module: `gangs`)
- Players can **create** a gang (costs money), **invite** others, and **manage ranks** (Leader, Officer, Member, Recruit)
- All managed through the **Gangs F4 tab** — create gang form, member list with promote/kick, war declaration panel
- Each gang has a name, color, MOTD, bank, and member roster
- Gang leaders can declare **war** on other gangs (mutual or hostile takeover)
- Gangs persist across server restarts via SQLite
- Max gang size is configurable (default: 15)
- Gang chat via `/gc` command or a chat channel toggle in the F4 gang tab
- **Depends on:** `economy`
- **Soft depends on:** `territory` (for territory war features)

### 2. Territory System (module: `territory`)
- The map is divided into **zones/territories** defined by coordinates in per-map config files
- Gangs capture territories by standing on a **capture point** entity for a set duration
- Owning territory grants passive income and access to zone-specific perks
- Territory wars: When two gangs contest the same zone, a timed battle begins
- **Territory F4 tab** shows a top-down map overview with colored zones, ownership, and capture status
- Territory state is saved and restored on server restart
- **Depends on:** `gangs`, `economy`

### 3. Economy System (module: `economy`)
- Players earn money from: salary (job-based), selling drugs, money printers, territory income, completing hits
- **Bank F4 tab** for deposit/withdraw, wire transfer to other players, transaction history
- Money drops on death (configurable percentage)
- No hard dependencies — this is a foundational module

### 4. Job/Class System (module: `jobs`)
- **Jobs F4 tab** shows all jobs in categories (Legal / Illegal) with descriptions, salary, loadout, and player count
- Click to switch job; server validates cooldowns and slot limits
- Jobs are split into **legal** and **illegal** categories:

**Legal:**
- Citizen (default), Police Officer, Police Chief, Mayor, Medic, Gun Dealer, Car Dealer

**Illegal:**
- Gang Member, Gang Leader, Hitman, Drug Dealer, Thief, Arms Dealer

- **Depends on:** `economy` (for salary)
- **Soft depends on:** `gangs` (Gang Member/Leader jobs locked behind gang membership)

### 5. Wanted/Police System (module: `police`)
- Police can set players as **wanted** with a reason
- **Police F4 tab** (visible only to police jobs) — wanted list, active warrants, jail roster
- Police can **arrest** wanted players → jail with configurable timer
- Mayor can issue **lockdowns** and set **laws** via the F4 tab
- Bail system accessible from F4 tab
- **Depends on:** `jobs`, `economy`

### 6. Shop System (module: `shops`)
- **Shop F4 tab** — browse weapons, tools, entities, and vehicles by category
- Searchable, with prices, icons, and descriptions
- Server validates purchases, spawns items/entities
- Separate sections: Weapons, Tools, Entities (money printers, drug labs), Vehicles
- **Depends on:** `economy`

### 7. Inventory System (module: `inventory`)
- Simple slot-based inventory (configurable size per job)
- **Inventory F4 tab** — grid view, drag-to-drop, use/equip buttons
- Items persist in SQLite
- Drop creates a world entity; pickup adds to inventory
- **Depends on:** `economy`

### 8. HUD System (module: `hud`)
- Clean, minimal HUD: Health, Armor, Money, Gang name, Job title, Wanted status
- Notification system for events (territory captured, gang war started, etc.)
- **Settings F4 tab** — toggle HUD elements, adjust scale, customize colors
- No hard dependencies — reads from other modules via `GWRP.Modules:IsEnabled()` checks

### 9. Admin System (module: `admin`)
- **Admin F4 tab** (superadmin only) — player list with kick/ban/goto, module enable/disable toggles, server config editor
- Admin commands also available via chat (`!ban`, `!kick`, etc.)
- No hard dependencies

---

## Security (CRITICAL — READ THIS FIRST)

GMod servers are constantly targeted by exploiters. Every system MUST be built with the assumption that **the client is hostile**. Exploiters will send malformed net messages, spam requests, manipulate timing, and try every angle to dupe items/money or crash the server. The codebase must be bulletproof by default.

### Golden Rule: NEVER Trust the Client

The server is the **single source of truth** for all game state. The client is a display layer and input device — nothing more. Every net message from a client is potentially forged, spoofed, or replayed.

### Net Message Security

Every single `net.Receive` handler on the server MUST follow this pattern:

```lua
net.Receive("GWRP_SomeAction", function(len, ply)
    -- 1. RATE LIMIT: Reject spam
    if not GWRP.Security:RateCheck(ply, "SomeAction", 1, 2) then return end -- max 1 call per 2 seconds
    
    -- 2. VALIDATE PLAYER STATE: Are they alive? Correct job? Not in jail? etc.
    if not IsValid(ply) or not ply:Alive() then return end
    
    -- 3. READ AND VALIDATE EVERY FIELD: Type check, range check, sanitize
    local amount = net.ReadUInt(32)
    if not amount or amount <= 0 or amount > 1000000 or amount ~= math.floor(amount) then return end
    
    local targetName = net.ReadString()
    if not targetName or #targetName > 64 or #targetName < 1 then return end
    
    -- 4. VALIDATE GAME LOGIC: Can they actually do this?
    if amount > ply:GetMoney() then return end
    
    -- 5. EXECUTE: Only now do the thing
    -- ...
    
    -- 6. LOG: Audit trail for suspicious activity
    GWRP.Log(string.format("[ECONOMY] %s (%s) transferred $%d", ply:Nick(), ply:SteamID(), amount), "info")
end)
```

**Net message rules:**
- ALWAYS validate `IsValid(ply)` first
- ALWAYS rate limit with `GWRP.Security:RateCheck(ply, actionID, maxCalls, windowSeconds)`
- ALWAYS type-check and range-check every value read from net messages
- ALWAYS verify the player has permission / is in the correct state to perform the action
- NEVER use `net.ReadString()` for entity references — use `net.ReadEntity()` and validate with `IsValid()`
- NEVER allow the client to specify monetary amounts for transactions that should be server-calculated (e.g., shop prices come from server config, NOT from what the client sends)
- ALWAYS cap string lengths: `local str = net.ReadString(); if #str > MAX_LEN then return end`
- NEVER read more data than expected — if a net message should have 2 fields, read exactly 2 fields

### Rate Limiting System

Build a centralized rate limiter that every net handler uses:

```lua
GWRP.Security = GWRP.Security or {}
GWRP.Security.RateLimits = {}

-- Returns true if action is allowed, false if rate limited
function GWRP.Security:RateCheck(ply, actionID, maxCalls, windowSeconds)
    local key = ply:SteamID64() .. "_" .. actionID
    local now = CurTime()
    local record = self.RateLimits[key]
    
    if not record then
        self.RateLimits[key] = {count = 1, reset = now + windowSeconds}
        return true
    end
    
    if now > record.reset then
        record.count = 1
        record.reset = now + windowSeconds
        return true
    end
    
    record.count = record.count + 1
    if record.count > maxCalls then
        GWRP.Log(string.format("[SECURITY] Rate limited %s (%s) on %s (%d/%d in %.1fs)", 
            ply:Nick(), ply:SteamID(), actionID, record.count, maxCalls, windowSeconds), "warn")
        return false
    end
    
    return true
end

-- Cleanup disconnected players periodically
timer.Create("GWRP_RateLimitCleanup", 60, 0, function()
    local now = CurTime()
    for key, record in pairs(GWRP.Security.RateLimits) do
        if now > record.reset + 30 then
            GWRP.Security.RateLimits[key] = nil
        end
    end
end)
```

**Recommended rate limits:**
- Economy transactions (give/drop/withdraw/deposit): 1 per 2 seconds
- Job switching: 1 per 10 seconds
- Gang actions (invite/kick/promote): 1 per 3 seconds
- Gang creation: 1 per 60 seconds
- Shop purchases: 1 per 1 second
- Chat commands: 3 per 5 seconds
- F4 menu data requests: 2 per 1 second
- Territory capture start: 1 per 10 seconds

### SQL Injection Prevention

**EVERY** value inserted into a SQL query MUST be sanitized. No exceptions.

```lua
-- WRONG — Vulnerable to SQL injection
sql.Query("SELECT * FROM gwrp_players WHERE steamid = '" .. ply:SteamID() .. "'")
sql.Query("UPDATE gwrp_gangs SET motd = '" .. userInput .. "' WHERE name = '" .. gangName .. "'")

-- CORRECT — Always use sql.SQLStr()
sql.Query("SELECT * FROM gwrp_players WHERE steamid = " .. sql.SQLStr(ply:SteamID()))
sql.Query("UPDATE gwrp_gangs SET motd = " .. sql.SQLStr(userInput) .. " WHERE name = " .. sql.SQLStr(gangName))
```

**Additional SQL rules:**
- Use `sql.SQLStr()` on EVERY dynamic value, even SteamIDs — never assume any input is safe
- Wrap write operations in transactions for atomicity: `sql.Begin()` / `sql.Commit()`
- Never concatenate user-supplied strings directly into queries
- Validate data types before query construction (numbers are numbers, strings are strings)
- Use helper functions that enforce sanitization (see Database Helpers section below)

### Dupe Prevention (Economy & Inventory)

Duping is the #1 exploit in RP gamemodes. Every transaction must be **atomic** and **server-authoritative**.

**Money duping prevention:**
```lua
-- WRONG — Race condition: two rapid requests can both pass the balance check
function GWRP.Economy:GiveMoney(sender, receiver, amount)
    if sender:GetMoney() >= amount then
        sender:AddMoney(-amount)
        receiver:AddMoney(amount)
    end
end

-- CORRECT — Atomic transaction with locking
function GWRP.Economy:GiveMoney(sender, receiver, amount)
    -- Validate
    if not IsValid(sender) or not IsValid(receiver) then return false, "Invalid player" end
    if sender == receiver then return false, "Cannot send to yourself" end
    if amount <= 0 or amount ~= math.floor(amount) then return false, "Invalid amount" end
    
    -- Atomic: read-check-write in one locked operation
    local senderMoney = sender:GetMoney()
    if senderMoney < amount then return false, "Insufficient funds" end
    
    -- Use a transaction flag to prevent concurrent execution
    if sender.gwrp_inTransaction then return false, "Transaction in progress" end
    sender.gwrp_inTransaction = true
    
    sql.Begin()
    local success = true
    success = success and sql.Query("UPDATE gwrp_players SET money = money - " .. amount .. " WHERE steamid = " .. sql.SQLStr(sender:SteamID()) .. " AND money >= " .. amount)
    if success ~= false then
        success = sql.Query("UPDATE gwrp_players SET money = money + " .. amount .. " WHERE steamid = " .. sql.SQLStr(receiver:SteamID()))
    end
    
    if success == false then
        sql.Query("ROLLBACK")
        sender.gwrp_inTransaction = nil
        return false, "Transaction failed"
    end
    
    sql.Commit()
    sender.gwrp_inTransaction = nil
    
    -- Update networked values from DB (server is truth)
    sender:SetMoney(senderMoney - amount)
    receiver:SetMoney(receiver:GetMoney() + amount)
    
    GWRP.Log(string.format("[ECONOMY] %s -> %s: $%d", sender:SteamID(), receiver:SteamID(), amount), "info")
    return true
end
```

**Key anti-dupe rules:**
- Money amounts MUST be integers — never allow floats (`amount ~= math.floor(amount)` check)
- All economy operations go through `GWRP.Economy` API — never modify money directly
- SQL `UPDATE ... SET money = money - X WHERE money >= X` is the atomic balance check — if the row isn't updated, the player didn't have enough
- Transaction flags prevent concurrent operations on the same player
- Log every transaction with both SteamIDs, amount, and timestamp
- The server recalculates totals from DB, never from client-reported values
- Entity spawning (money printers, drug labs) must check entity limits per player AND use cooldowns

**Inventory dupe prevention:**
- Moving/dropping/picking up items must lock the source slot during the operation
- Verify the item still exists in the source slot before completing any transfer
- Use SQL transactions for all inventory moves
- Entity pickup: remove world entity FIRST, then add to inventory (not the other way around)
- Entity drop: remove from inventory FIRST, then spawn entity (not the other way around)
- Never let the client specify slot IDs for critical operations — server assigns slots

### Entity Security

```lua
-- Every entity interaction must validate:
-- 1. Entity is valid and is the correct class
-- 2. Player is close enough (anti-teleport/reach exploit)
-- 3. Player owns the entity or has permission
-- 4. Action is rate limited

function GWRP.Security:ValidateEntityInteraction(ply, ent, requiredClass, maxDistance)
    if not IsValid(ply) or not IsValid(ent) then return false end
    if requiredClass and ent:GetClass() ~= requiredClass then return false end
    if ply:GetPos():DistToSqr(ent:GetPos()) > (maxDistance or 200) ^ 2 then return false end
    if ent:GetNWString("OwnerID", "") ~= ply:SteamID() and not ply:IsAdmin() then return false end
    return true
end
```

**Entity rules:**
- ALL entity interactions check distance (default: 200 units). Exploiters WILL try to interact with entities across the map.
- Entity ownership is stored as SteamID on the entity, verified server-side
- Max entity limits per player per entity type (e.g., max 3 money printers). Check count BEFORE spawning, not after.
- Entity value/money is stored server-side on the entity, NEVER sent from client
- Money printers / drug labs: the server calculates output amounts, client just sees the result
- Entities must clean up properly on removal (refund if applicable, remove from tracking tables)

### Input Sanitization

```lua
GWRP.Security = GWRP.Security or {}

-- Sanitize a string for display (strip control chars, limit length)
function GWRP.Security:SanitizeString(str, maxLen)
    if type(str) ~= "string" then return "" end
    str = str:gsub("[%c]", "")              -- Remove control characters
    str = str:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace
    if maxLen then str = str:sub(1, maxLen) end
    return str
end

-- Validate and clamp a number
function GWRP.Security:SanitizeNumber(num, min, max, mustBeInt)
    if type(num) ~= "number" then return nil end
    if num ~= num then return nil end           -- NaN check
    if num == math.huge or num == -math.huge then return nil end -- Infinity check
    if mustBeInt and num ~= math.floor(num) then return nil end
    return math.Clamp(num, min or 0, max or 2^31)
end

-- Validate a SteamID format
function GWRP.Security:ValidateSteamID(sid)
    if type(sid) ~= "string" then return false end
    return string.match(sid, "^STEAM_%d:%d:%d+$") ~= nil
end
```

### Permission Checks

```lua
-- Every action that requires a specific job, gang rank, or admin level:
function GWRP.Security:CanPerformAction(ply, requirements)
    if not IsValid(ply) then return false end
    
    if requirements.alive and not ply:Alive() then return false end
    if requirements.job and ply:GetJob() ~= requirements.job then return false end
    if requirements.jobCategory and not table.HasValue(requirements.jobCategory, ply:GetJob()) then return false end
    if requirements.gangRank and ply:GetGangRank() < requirements.gangRank then return false end
    if requirements.admin and not ply:IsAdmin() then return false end
    if requirements.superadmin and not ply:IsSuperAdmin() then return false end
    if requirements.notJailed and ply:IsJailed() then return false end
    if requirements.notCuffed and ply:IsCuffed() then return false end
    
    return true
end
```

### Logging & Audit Trail

Every significant action must be logged for admin review and exploit detection:

```lua
GWRP.LogLevels = {debug = 0, info = 1, warn = 2, error = 3, security = 4}

function GWRP.Log(msg, level)
    level = level or "info"
    local prefix = "[GWRP][" .. string.upper(level) .. "]"
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local formatted = string.format("%s [%s] %s", prefix, timestamp, msg)
    
    -- Always print to server console
    print(formatted)
    
    -- Security-level events also get written to file
    if GWRP.LogLevels[level] >= GWRP.LogLevels["warn"] then
        file.Append("gwrp/logs/" .. os.date("%Y-%m-%d") .. ".txt", formatted .. "\n")
    end
end
```

**What to log:**
- All money transactions (give, drop, pickup, shop purchase, salary, printer collect)
- All inventory transfers (pickup, drop, move, use)
- Gang creation, dissolution, war declarations
- Job changes
- Admin actions (kick, ban, teleport, noclip)
- Rate limit violations (potential exploit attempts)
- Failed permission checks (also potential exploit attempts)
- Entity spawns and removals
- Player connections and disconnections with SteamID

### Security Checklist for Every New Feature

Before any feature is considered complete, verify:

- [ ] All net.Receive handlers validate `IsValid(ply)`
- [ ] All net.Receive handlers are rate limited
- [ ] All net message fields are type-checked and range-checked
- [ ] All SQL queries use `sql.SQLStr()` on every dynamic value
- [ ] All money operations go through `GWRP.Economy` API (never direct modification)
- [ ] All money amounts are validated as positive integers
- [ ] All entity interactions check distance
- [ ] All entity interactions verify ownership/permission
- [ ] All actions check player state (alive, not jailed, correct job, etc.)
- [ ] No client-sent values are used for authoritative calculations (prices, amounts, etc.)
- [ ] All significant actions are logged with player SteamID
- [ ] String inputs are sanitized and length-capped
- [ ] Write operations use SQL transactions where atomicity matters
- [ ] Entity limits are enforced before spawning, not after
- [ ] The feature degrades gracefully if a dependency module is disabled

### Database Helper Functions (Enforced Sanitization)

To make it harder to accidentally write vulnerable queries, use these helpers everywhere instead of raw `sql.Query()`:

```lua
GWRP.DB = GWRP.DB or {}

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

-- Safe DELETE
function GWRP.DB:Delete(tableName, conditions)
    local where = {}
    for col, val in pairs(conditions) do
        table.insert(where, col .. " = " .. sql.SQLStr(tostring(val)))
    end
    if #where == 0 then return false end -- Safety: never allow DELETE without WHERE
    return sql.Query("DELETE FROM " .. tableName .. " WHERE " .. table.concat(where, " AND "))
end
```

Use `GWRP.DB:Select()`, `GWRP.DB:Insert()`, etc. everywhere. Raw `sql.Query()` should be extremely rare and always reviewed for injection.

---

## Coding Standards

- **Realm prefixes:** `sv_` = server only, `cl_` = client only, `sh_` = shared
- **Networking:** Use `net` library. Register all net strings in `shared.lua`. Validate ALL client input on the server. Never trust the client. See Security section above — every net.Receive MUST follow the validation pattern.
- **Database:** Use `GWRP.DB` helper functions for all queries. Raw `sql.Query()` only when absolutely necessary and always with `sql.SQLStr()`.
- **Hooks:** Use `hook.Add()` with unique identifiers prefixed with `GWRP_` (e.g., `GWRP_PlayerSpawn`)
- **Global table:** Store all shared functions/data under `GWRP = GWRP or {}` to avoid polluting the global namespace
- **Module APIs:** Each module exposes its public API on `GWRP.<ModuleName>` (e.g., `GWRP.Economy:AddMoney(ply, 500)`)
- **Config:** All tweakable values (prices, timers, limits, colors) go in config files — never hardcode magic numbers
- **Error handling:** Use `pcall` for risky operations; log errors with `GWRP.Log(msg, level)`
- **Performance:** Avoid `Think` hooks where timers suffice. Cache expensive lookups. Minimize net messages.
- **Comments:** Add brief comments explaining *why*, not *what*. Document all net message payloads.
- **Cross-module safety:** Always check `GWRP.Modules:IsEnabled("module_id")` before calling into another module's API
- **File size:** Keep files under 400 lines. Split large modules into multiple files.
- **Security-first:** Every new feature must pass the Security Checklist before being considered done. When in doubt, add more validation, not less.

---

## Database Schema (SQLite)

```sql
-- Players
CREATE TABLE IF NOT EXISTS gwrp_players (
    steamid TEXT PRIMARY KEY,
    money INTEGER DEFAULT 1000,
    bank INTEGER DEFAULT 0,
    gang TEXT DEFAULT '',
    gang_rank INTEGER DEFAULT 0,
    job TEXT DEFAULT 'citizen',
    playtime INTEGER DEFAULT 0
);

-- Gangs
CREATE TABLE IF NOT EXISTS gwrp_gangs (
    name TEXT PRIMARY KEY,
    color TEXT DEFAULT '255,255,255',
    bank INTEGER DEFAULT 0,
    motd TEXT DEFAULT '',
    leader_steamid TEXT,
    created_at INTEGER
);

-- Territories
CREATE TABLE IF NOT EXISTS gwrp_territories (
    zone_id TEXT PRIMARY KEY,
    owner_gang TEXT DEFAULT '',
    captured_at INTEGER DEFAULT 0
);

-- Inventory
CREATE TABLE IF NOT EXISTS gwrp_inventory (
    steamid TEXT,
    slot INTEGER,
    item_id TEXT,
    amount INTEGER DEFAULT 1,
    PRIMARY KEY (steamid, slot)
);

-- Transaction Log
CREATE TABLE IF NOT EXISTS gwrp_transactions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    steamid TEXT,
    type TEXT,
    amount INTEGER,
    description TEXT,
    timestamp INTEGER
);
```

---

## Priority Order for Implementation

1. **Core framework** — `shared.lua`, `init.lua`, `cl_init.lua`, module loader, config, database, utils, logging
2. **F4 Menu** — Core frame, tab system, theme — this is the backbone UI
3. **Economy** — Money, bank, salary, transactions, Bank F4 tab
4. **Jobs** — Job definitions, switching, loadouts, Jobs F4 tab
5. **Gangs** — Creation, invites, ranks, chat, wars, Gangs F4 tab
6. **HUD** — Health/armor/money overlay, notifications, Settings F4 tab
7. **Shops** — Item/weapon/entity purchasing, Shop F4 tab
8. **Territory** — Zone definitions, capture points, passive income, Territory F4 tab
9. **Police** — Wanted system, arrests, jail, warrants, Police F4 tab
10. **Inventory** — Item system, persistence, Inventory F4 tab
11. **Entities** — Money printers, drug labs, vault, black market, capture points
12. **Admin** — Admin commands, bans, module management, Admin F4 tab

---

## Git Workflow

- **Branch strategy:** `main` (stable) → `dev` (active development) → feature branches (`feature/gangs`, `feature/territory`, etc.)
- **Commits:** Conventional commits preferred (`feat: add gang creation`, `fix: territory capture timer`, `refactor: module loader`)
- **Tags:** Semantic versioning (`v1.0.0`, `v1.1.0`, etc.)
- **.gitignore** should exclude: `*.gma`, `*.cache`, `.DS_Store`, `__MACOSX/`, `*.db` (SQLite databases are runtime-generated)
- **README.md** should include: feature list, installation instructions (clone into `garrysmod/gamemodes/`), configuration guide, module list with descriptions, screenshots

---

## .gitignore

```
# OS
.DS_Store
Thumbs.db
__MACOSX/

# GMod
*.gma
*.cache

# SQLite (generated at runtime)
*.db
sv.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# Misc
*.log
```

---

## Notes for Claude Code

- Build one module at a time following the priority order. Always start with the module manifest (`sh_module.lua`).
- The module loader and F4 menu are the foundation — get those rock solid first before building feature modules.
- Every module must work independently when its dependencies are met. Disabling a module should never cause errors in other modules.
- When I say "add X", implement it as a module (or extend an existing one) following the established patterns.
- All player-facing actions go through the F4 menu first. Chat commands are secondary convenience shortcuts.
- If something is ambiguous, ask — don't guess at game design decisions.
- Keep file sizes manageable (<400 lines per file). Split large modules into multiple files.
- When creating UI, use `GWRP.Theme` for all colors, fonts, and panel styles.
- Test cross-module disable scenarios: e.g., if `gangs` is disabled, the `territory` module should either gracefully degrade or refuse to enable (dependency check).
- All work should be committed to the repo with meaningful commit messages.

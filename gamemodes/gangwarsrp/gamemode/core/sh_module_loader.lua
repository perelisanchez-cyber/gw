-- GangWarsRP - Module Loader
-- Discovers, validates, and loads modules in dependency order

GWRP.Modules = GWRP.Modules or {}
GWRP.Modules.Registered = GWRP.Modules.Registered or {}
GWRP.Modules.LoadOrder = GWRP.Modules.LoadOrder or {}

-- Register a module from its manifest
function GWRP.Modules:Register(manifest)
    if not manifest or not manifest.id then
        GWRP.Log("[MODULE] Attempted to register module with no ID", "error")
        return false
    end

    if self.Registered[manifest.id] then
        GWRP.Log("[MODULE] Module '" .. manifest.id .. "' already registered, skipping", "warn")
        return false
    end

    -- Apply config override for enabled state
    if GWRP.Config and GWRP.Config.Modules and GWRP.Config.Modules[manifest.id] ~= nil then
        manifest.enabled = GWRP.Config.Modules[manifest.id]
    end

    manifest.dependencies = manifest.dependencies or {}
    manifest.soft_dependencies = manifest.soft_dependencies or {}
    manifest.client = manifest.client or {}
    manifest.server = manifest.server or {}
    manifest.shared = manifest.shared or {}
    manifest.commands = manifest.commands or {}
    manifest.loaded = false

    self.Registered[manifest.id] = manifest
    GWRP.Log("[MODULE] Registered: " .. manifest.id .. " (" .. (manifest.name or "unnamed") .. ") [" .. (manifest.enabled and "enabled" or "disabled") .. "]", "debug")
    return true
end

-- Check if a module is enabled
function GWRP.Modules:IsEnabled(moduleID)
    local mod = self.Registered[moduleID]
    return mod ~= nil and mod.enabled == true and mod.loaded == true
end

-- Get a module's manifest
function GWRP.Modules:Get(moduleID)
    return self.Registered[moduleID]
end

-- Get all registered modules
function GWRP.Modules:GetAll()
    return self.Registered
end

-- Enable a module (requires reload to take effect)
function GWRP.Modules:Enable(moduleID)
    local mod = self.Registered[moduleID]
    if not mod then return false end
    mod.enabled = true
    GWRP.Log("[MODULE] Enabled: " .. moduleID .. " (reload required)", "info")
    return true
end

-- Disable a module (requires reload to take effect)
function GWRP.Modules:Disable(moduleID)
    local mod = self.Registered[moduleID]
    if not mod then return false end
    if moduleID == "f4menu" then
        GWRP.Log("[MODULE] Cannot disable core module: f4menu", "warn")
        return false
    end
    mod.enabled = false
    GWRP.Log("[MODULE] Disabled: " .. moduleID .. " (reload required)", "info")
    return true
end

-- Resolve dependency order using topological sort
function GWRP.Modules:ResolveDependencies()
    local sorted = {}
    local visited = {}
    local visiting = {} -- cycle detection

    local function visit(moduleID)
        if visited[moduleID] then return true end
        if visiting[moduleID] then
            GWRP.Log("[MODULE] Circular dependency detected involving: " .. moduleID, "error")
            return false
        end

        local mod = self.Registered[moduleID]
        if not mod then return false end
        if not mod.enabled then return true end -- skip disabled

        visiting[moduleID] = true

        -- Resolve hard dependencies first
        for _, depID in ipairs(mod.dependencies) do
            local dep = self.Registered[depID]
            if not dep then
                GWRP.Log("[MODULE] " .. moduleID .. " requires missing module: " .. depID, "error")
                mod.enabled = false
                visiting[moduleID] = nil
                return false
            end
            if not dep.enabled then
                GWRP.Log("[MODULE] " .. moduleID .. " requires disabled module: " .. depID .. ", disabling", "warn")
                mod.enabled = false
                visiting[moduleID] = nil
                return false
            end
            if not visit(depID) then
                mod.enabled = false
                visiting[moduleID] = nil
                return false
            end
        end

        -- Soft dependencies: just visit them if enabled, don't fail if missing
        for _, depID in ipairs(mod.soft_dependencies) do
            local dep = self.Registered[depID]
            if dep and dep.enabled then
                visit(depID)
            end
        end

        visiting[moduleID] = nil
        visited[moduleID] = true
        table.insert(sorted, moduleID)
        return true
    end

    for moduleID, _ in pairs(self.Registered) do
        visit(moduleID)
    end

    self.LoadOrder = sorted
    return sorted
end

-- Discover and register all modules from the modules/ directory
function GWRP.Modules:Discover()
    local basePath = "gangwarsrp/gamemode/modules/"
    local files, dirs = file.Find(basePath .. "*", "LUA")

    if not dirs then
        GWRP.Log("[MODULE] No module directories found", "warn")
        return
    end

    for _, dir in ipairs(dirs) do
        local manifestPath = "modules/" .. dir .. "/sh_module.lua"
        if file.Exists(basePath .. dir .. "/sh_module.lua", "LUA") then
            if SERVER then
                AddCSLuaFile(manifestPath)
            end
            include(manifestPath)
            GWRP.Log("[MODULE] Discovered module in: " .. dir, "debug")
        else
            GWRP.Log("[MODULE] Directory '" .. dir .. "' has no sh_module.lua, skipping", "warn")
        end
    end
end

-- Load all enabled modules in dependency order
function GWRP.Modules:LoadAll()
    GWRP.Log("[MODULE] Discovering modules...", "info")
    self:Discover()

    GWRP.Log("[MODULE] Resolving dependencies...", "info")
    local order = self:ResolveDependencies()

    GWRP.Log("[MODULE] Loading " .. #order .. " modules...", "info")
    for _, moduleID in ipairs(order) do
        self:LoadModule(moduleID)
    end

    GWRP.Log("[MODULE] Module loading complete", "info")
end

-- Load a single module's files
function GWRP.Modules:LoadModule(moduleID)
    local mod = self.Registered[moduleID]
    if not mod or not mod.enabled then return false end
    if mod.loaded then return true end

    local basePath = "modules/" .. moduleID .. "/"

    -- Load shared files
    for _, f in ipairs(mod.shared) do
        if SERVER then AddCSLuaFile(basePath .. f) end
        include(basePath .. f)
    end

    -- Load server files
    if SERVER then
        for _, f in ipairs(mod.server) do
            include(basePath .. f)
        end
    end

    -- Load client files
    if CLIENT then
        for _, f in ipairs(mod.client) do
            include(basePath .. f)
        end
    end

    if SERVER then
        -- AddCSLuaFile for client files so they get sent to clients
        for _, f in ipairs(mod.client) do
            AddCSLuaFile(basePath .. f)
        end
    end

    mod.loaded = true
    GWRP.Log("[MODULE] Loaded: " .. moduleID .. " v" .. (mod.version or "?"), "info")

    -- Fire hook so other systems know this module is ready
    hook.Run("GWRP_ModuleLoaded", moduleID, mod)
    return true
end

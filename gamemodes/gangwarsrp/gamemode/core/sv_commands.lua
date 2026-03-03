-- GangWarsRP - Chat Command Registration Framework (Server Only)

GWRP.Commands = GWRP.Commands or {}
GWRP.Commands.Registered = {}

-- Register a chat command
function GWRP.Commands:Register(cmd, callback, description, usage)
    cmd = string.lower(cmd)
    self.Registered[cmd] = {
        callback = callback,
        description = description or "",
        usage = usage or ("/" .. cmd),
    }
    GWRP.Log("[CMD] Registered command: /" .. cmd, "debug")
end

-- Process chat messages for commands
hook.Add("PlayerSay", "GWRP_ChatCommands", function(ply, text, teamChat)
    if not IsValid(ply) then return end

    -- Check if message starts with / or !
    local prefix = string.sub(text, 1, 1)
    if prefix ~= "/" and prefix ~= "!" then return end

    -- Rate limit chat commands
    local rl = GWRP.Config.RateLimits.ChatCommand
    if not GWRP.Security:RateCheck(ply, "ChatCommand", rl.max, rl.window) then
        GWRP.Notify(ply, "You're sending commands too fast!", 2)
        return ""
    end

    -- Parse command and arguments
    local parts = string.Explode(" ", string.sub(text, 2))
    local cmd = string.lower(parts[1] or "")
    local args = {}
    for i = 2, #parts do
        table.insert(args, parts[i])
    end

    -- Look up registered command
    local cmdData = GWRP.Commands.Registered[cmd]
    if cmdData then
        local success, err = pcall(cmdData.callback, ply, args, text)
        if not success then
            GWRP.Log(string.format("[CMD] Error in /%s by %s: %s", cmd, ply:SteamID(), err), "error")
            GWRP.Notify(ply, "An error occurred processing your command.", 3)
        end
        return "" -- suppress chat message
    end

    -- Unknown command starting with / — let it through as normal chat
end)

-- Register a help command
GWRP.Commands:Register("help", function(ply, args)
    GWRP.Notify(ply, "Available commands:", 0)
    for cmd, data in SortedPairs(GWRP.Commands.Registered) do
        GWRP.Notify(ply, data.usage .. " - " .. data.description, 0)
    end
end, "Show available commands", "/help")

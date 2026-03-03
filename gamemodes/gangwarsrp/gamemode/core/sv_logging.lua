-- GangWarsRP - Server-side Logging System

GWRP = GWRP or {}

GWRP.LogLevels = {
    debug    = 0,
    info     = 1,
    warn     = 2,
    error    = 3,
    security = 4,
}

-- Current minimum log level for console output
GWRP.MinLogLevel = GWRP.LogLevels.debug

function GWRP.Log(msg, level)
    level = level or "info"
    local levelNum = GWRP.LogLevels[level] or 1

    -- Skip messages below minimum level
    if levelNum < GWRP.MinLogLevel then return end

    local prefix = "[GWRP][" .. string.upper(level) .. "]"
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local formatted = string.format("%s [%s] %s", prefix, timestamp, msg)

    -- Always print to server console
    print(formatted)

    -- Warn and above also get written to file
    if levelNum >= GWRP.LogLevels.warn then
        -- Ensure log directory exists
        if not file.IsDir("gwrp", "DATA") then
            file.CreateDir("gwrp")
        end
        if not file.IsDir("gwrp/logs", "DATA") then
            file.CreateDir("gwrp/logs")
        end

        file.Append("gwrp/logs/" .. os.date("%Y-%m-%d") .. ".txt", formatted .. "\n")
    end
end

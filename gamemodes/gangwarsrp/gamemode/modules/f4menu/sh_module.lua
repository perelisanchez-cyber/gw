-- F4 Menu Module - Core UI (always enabled)

GWRP.Modules:Register({
    id = "f4menu",
    name = "F4 Menu",
    description = "Core F4 menu interface — tab system and shared theme",
    version = "1.0.0",
    enabled = true,
    dependencies = {},
    soft_dependencies = {},

    client = {
        "cl_theme.lua",
        "cl_tabs.lua",
        "cl_f4menu.lua",
    },
    server = {},
    shared = {},

    f4_tab = nil, -- Core module, no tab of its own
    commands = {},
})

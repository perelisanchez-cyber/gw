-- Territory Module Manifest

GWRP.Modules:Register({
    id = "territory",
    name = "Territory System",
    description = "Capture zones, passive income, gang wars over territory",
    version = "1.0.0",
    enabled = true,
    dependencies = {"gangs", "economy"},
    soft_dependencies = {},

    client = {
        "cl_territory.lua",
        "cl_territory_hud.lua",
    },
    server = {
        "sv_territory.lua",
    },
    shared = {
        "sh_territory.lua",
    },

    f4_tab = {
        label = "Territory",
        icon = "icon16/map.png",
        order = 40,
        panel_class = "GWRP_TerritoryPanel",
    },

    commands = {},
})

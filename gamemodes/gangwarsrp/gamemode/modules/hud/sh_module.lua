-- HUD Module Manifest

GWRP.Modules:Register({
    id = "hud",
    name = "HUD System",
    description = "Health, armor, money overlay, notifications, scoreboard",
    version = "1.0.0",
    enabled = true,
    dependencies = {},
    soft_dependencies = {},

    client = {
        "cl_hud.lua",
        "cl_scoreboard.lua",
        "cl_notifications.lua",
    },
    server = {},
    shared = {},

    f4_tab = {
        label = "Settings",
        icon = "icon16/cog.png",
        order = 80,
        panel_class = "GWRP_SettingsPanel",
    },

    commands = {},
})

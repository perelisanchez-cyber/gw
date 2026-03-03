-- Gangs Module Manifest

GWRP.Modules:Register({
    id = "gangs",
    name = "Gang System",
    description = "Create and manage gangs, ranks, wars",
    version = "1.0.0",
    enabled = true,
    dependencies = {"economy"},
    soft_dependencies = {"territory"},

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

    f4_tab = {
        label = "Gangs",
        icon = "icon16/group.png",
        order = 30,
        panel_class = "GWRP_GangsPanel",
    },

    commands = {
        {cmd = "gc", description = "Gang chat", usage = "/gc <message>"},
        {cmd = "gang", description = "Gang management", usage = "/gang <create|invite|leave|war> [args]"},
    },
})

-- Police Module Manifest

GWRP.Modules:Register({
    id = "police",
    name = "Police & Wanted System",
    description = "Warrants, arrests, jail, lockdowns, bail",
    version = "1.0.0",
    enabled = true,
    dependencies = {"jobs", "economy"},
    soft_dependencies = {},

    client = {
        "cl_police.lua",
    },
    server = {
        "sv_police.lua",
    },
    shared = {
        "sh_police.lua",
    },

    f4_tab = {
        label = "Police",
        icon = "icon16/shield.png",
        order = 70,
        panel_class = "GWRP_PolicePanel",
        -- Only visible to police jobs
        visible = function(ply)
            local job = ply:GetNWString("GWRP_Job", "")
            return job == "police" or job == "police_chief" or job == "mayor"
        end,
    },

    commands = {
        {cmd = "warrant", description = "Issue a warrant", usage = "/warrant <player> <reason>"},
        {cmd = "wanted", description = "Set player as wanted", usage = "/wanted <player> <reason>"},
        {cmd = "lockdown", description = "Toggle lockdown (Mayor only)", usage = "/lockdown"},
    },
})

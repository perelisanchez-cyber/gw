-- Admin Module Manifest

GWRP.Modules:Register({
    id = "admin",
    name = "Admin System",
    description = "Player management, bans, module toggles, server config",
    version = "1.0.0",
    enabled = true,
    dependencies = {},
    soft_dependencies = {},

    client = {
        "cl_admin.lua",
    },
    server = {
        "sv_admin.lua",
    },
    shared = {},

    f4_tab = {
        label = "Admin",
        icon = "icon16/shield_go.png",
        order = 90,
        panel_class = "GWRP_AdminPanel",
        -- Only visible to admins
        visible = function(ply)
            return ply:IsSuperAdmin()
        end,
    },

    commands = {},
})

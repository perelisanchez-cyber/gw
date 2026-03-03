-- Shops Module Manifest

GWRP.Modules:Register({
    id = "shops",
    name = "Shop System",
    description = "Buy weapons, items, entities, and vehicles",
    version = "1.0.0",
    enabled = true,
    dependencies = {"economy"},
    soft_dependencies = {},

    client = {
        "cl_shops.lua",
    },
    server = {
        "sv_shops.lua",
    },
    shared = {
        "sh_shops.lua",
    },

    f4_tab = {
        label = "Shop",
        icon = "icon16/cart.png",
        order = 20,
        panel_class = "GWRP_ShopsPanel",
    },

    commands = {
        {cmd = "buy", description = "Quick buy an item", usage = "/buy <itemname>"},
    },
})

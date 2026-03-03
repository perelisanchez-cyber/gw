-- Inventory Module Manifest

GWRP.Modules:Register({
    id = "inventory",
    name = "Inventory System",
    description = "Slot-based persistent inventory with drag and drop",
    version = "1.0.0",
    enabled = true,
    dependencies = {"economy"},
    soft_dependencies = {},

    client = {
        "cl_inventory.lua",
    },
    server = {
        "sv_inventory.lua",
    },
    shared = {
        "sh_inventory.lua",
    },

    f4_tab = {
        label = "Inventory",
        icon = "icon16/box.png",
        order = 50,
        panel_class = "GWRP_InventoryPanel",
    },

    commands = {},
})

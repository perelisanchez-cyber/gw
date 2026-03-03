-- Economy Module Manifest

GWRP.Modules:Register({
    id = "economy",
    name = "Economy System",
    description = "Wallet, bank, salary, and money transactions",
    version = "1.0.0",
    enabled = true,
    dependencies = {},
    soft_dependencies = {},

    client = {
        "cl_economy.lua",
    },
    server = {
        "sv_economy.lua",
    },
    shared = {
        "sh_economy.lua",
    },

    f4_tab = {
        label = "Bank",
        icon = "icon16/money.png",
        order = 60,
        panel_class = "GWRP_EconomyPanel",
    },

    commands = {
        {cmd = "give", description = "Give money to player you're looking at", usage = "/give <amount>"},
        {cmd = "drop", description = "Drop money on the ground", usage = "/drop <amount>"},
    },
})

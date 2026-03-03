-- GangWarsRP - Shop Item Listings and Prices
-- Loaded by the shops module to populate the shop

GWRP.Shops = GWRP.Shops or {}
GWRP.Shops.Items = {
    -- Weapons
    pistol = {
        name = "Pistol",
        category = "Weapons",
        price = 500,
        weapon = "weapon_pistol",
    },
    smg = {
        name = "SMG",
        category = "Weapons",
        price = 1500,
        weapon = "weapon_smg1",
    },
    shotgun = {
        name = "Shotgun",
        category = "Weapons",
        price = 2000,
        weapon = "weapon_shotgun",
    },
    magnum = {
        name = "Magnum .357",
        category = "Weapons",
        price = 2500,
        weapon = "weapon_357",
    },
    ar2 = {
        name = "Pulse Rifle",
        category = "Weapons",
        price = 3500,
        weapon = "weapon_ar2",
    },

    -- Entities
    money_printer = {
        name = "Money Printer",
        category = "Entities",
        price = 1000,
        entity = "gwrp_money_printer",
        maxPerPlayer = 3,
    },
    drug_lab = {
        name = "Drug Lab",
        category = "Entities",
        price = 1500,
        entity = "gwrp_drug_lab",
        maxPerPlayer = 2,
    },
}

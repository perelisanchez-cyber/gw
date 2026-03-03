-- GangWarsRP - Master Configuration
-- All tweakable values are defined here

GWRP = GWRP or {}

GWRP.Config = {
    -- Module toggles (override manifest defaults)
    Modules = {
        f4menu      = true,   -- ALWAYS true, core module
        gangs       = true,
        territory   = true,
        economy     = true,
        jobs        = true,
        inventory   = true,
        hud         = true,
        police      = true,
        shops       = true,
        admin       = true,
    },

    -- Economy
    StartingMoney       = 1000,
    StartingBank        = 0,
    SalaryInterval      = 300,     -- seconds between salary payments
    MoneyDropOnDeath    = 0.10,    -- 10% of wallet drops on death
    MaxMoney            = 10000000, -- $10M cap
    MaxBankBalance      = 50000000, -- $50M bank cap
    MinTransferAmount   = 1,
    MaxTransferAmount   = 1000000,

    -- Gangs
    MaxGangSize         = 15,
    GangCreationCost    = 5000,
    GangNameMinLen      = 3,
    GangNameMaxLen      = 24,
    GangMOTDMaxLen      = 256,

    -- Territory
    CaptureTime         = 60,      -- seconds to capture a zone
    TerritoryIncome     = 50,      -- income per territory per salary interval
    TerritoryIncomeInterval = 300, -- seconds between territory income ticks

    -- Jobs
    JobSwitchCooldown   = 10,      -- seconds between job switches
    DefaultJob          = "citizen",

    -- Police
    JailTime            = 120,     -- seconds
    MaxJailTime         = 600,     -- seconds
    BailBaseCost        = 500,
    WantedDuration      = 300,     -- seconds before wanted status expires

    -- Shops
    PurchaseCooldown    = 1,       -- seconds between purchases

    -- Inventory
    DefaultInventorySize = 20,     -- slots

    -- Entities
    MaxMoneyPrinters    = 3,       -- per player
    MaxDrugLabs         = 2,       -- per player
    EntityInteractDistance = 200,   -- units

    -- Security
    RateLimits = {
        EconomyTransaction  = {max = 1, window = 2},
        JobSwitch           = {max = 1, window = 10},
        GangAction          = {max = 1, window = 3},
        GangCreation        = {max = 1, window = 60},
        ShopPurchase        = {max = 1, window = 1},
        ChatCommand         = {max = 3, window = 5},
        F4MenuRequest       = {max = 2, window = 1},
        TerritoryCapture    = {max = 1, window = 10},
    },
}

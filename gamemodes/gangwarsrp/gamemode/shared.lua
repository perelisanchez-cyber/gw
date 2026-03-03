-- GangWarsRP - Shared Entry Point
-- Loaded on both server and client before init.lua / cl_init.lua

-- Global namespace
GWRP = GWRP or {}
GWRP.Version = "0.1.0"
GWRP.Name = "GangWarsRP"

-- Include core shared files
include("core/sh_config.lua")
include("core/sh_utils.lua")
include("core/sh_module_loader.lua")

-- Register all net strings (server only, but defined in shared for reference)
if SERVER then
    -- Core
    util.AddNetworkString("GWRP_PlayerDataSync")
    util.AddNetworkString("GWRP_Notification")

    -- F4 Menu
    util.AddNetworkString("GWRP_F4MenuOpen")
    util.AddNetworkString("GWRP_F4MenuRequest")

    -- Economy
    util.AddNetworkString("GWRP_MoneyUpdate")
    util.AddNetworkString("GWRP_BankDeposit")
    util.AddNetworkString("GWRP_BankWithdraw")
    util.AddNetworkString("GWRP_MoneyGive")
    util.AddNetworkString("GWRP_MoneyDrop")
    util.AddNetworkString("GWRP_TransactionLog")

    -- Jobs
    util.AddNetworkString("GWRP_JobSwitch")
    util.AddNetworkString("GWRP_JobUpdate")
    util.AddNetworkString("GWRP_JobList")

    -- Gangs
    util.AddNetworkString("GWRP_GangCreate")
    util.AddNetworkString("GWRP_GangInvite")
    util.AddNetworkString("GWRP_GangLeave")
    util.AddNetworkString("GWRP_GangKick")
    util.AddNetworkString("GWRP_GangPromote")
    util.AddNetworkString("GWRP_GangDemote")
    util.AddNetworkString("GWRP_GangChat")
    util.AddNetworkString("GWRP_GangWar")
    util.AddNetworkString("GWRP_GangUpdate")
    util.AddNetworkString("GWRP_GangList")

    -- Territory
    util.AddNetworkString("GWRP_TerritoryUpdate")
    util.AddNetworkString("GWRP_TerritoryCapture")

    -- Police
    util.AddNetworkString("GWRP_PoliceWarrant")
    util.AddNetworkString("GWRP_PoliceWanted")
    util.AddNetworkString("GWRP_PoliceArrest")
    util.AddNetworkString("GWRP_PoliceLockdown")
    util.AddNetworkString("GWRP_PoliceBail")

    -- Shops
    util.AddNetworkString("GWRP_ShopPurchase")
    util.AddNetworkString("GWRP_ShopList")

    -- Inventory
    util.AddNetworkString("GWRP_InventoryUpdate")
    util.AddNetworkString("GWRP_InventoryUse")
    util.AddNetworkString("GWRP_InventoryDrop")

    -- Admin
    util.AddNetworkString("GWRP_AdminAction")
    util.AddNetworkString("GWRP_AdminModuleToggle")
end

-- Shared enums
GWRP.GANG_RANK = {
    RECRUIT  = 0,
    MEMBER   = 1,
    OFFICER  = 2,
    LEADER   = 3,
}

GWRP.GANG_RANK_NAMES = {
    [0] = "Recruit",
    [1] = "Member",
    [2] = "Officer",
    [3] = "Leader",
}

GWRP.JOB_CATEGORY = {
    LEGAL   = "legal",
    ILLEGAL = "illegal",
}

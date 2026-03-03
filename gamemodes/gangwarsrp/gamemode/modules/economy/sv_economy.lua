-- GangWarsRP - Economy Server Logic
-- All money operations go through this API

GWRP.Economy = GWRP.Economy or {}

-- Add money to a player's wallet (server authoritative)
function GWRP.Economy:AddMoney(ply, amount)
    if not IsValid(ply) then return false, "Invalid player" end
    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxMoney, true)
    if not amount then return false, "Invalid amount" end

    local current = ply:GetMoney()
    local newAmount = math.min(current + amount, GWRP.Config.MaxMoney)
    ply:SetMoney(newAmount)

    GWRP.DB:Update("gwrp_players", {money = newAmount}, {steamid = ply:SteamID()})
    GWRP.DB:LogTransaction(ply:SteamID(), "earn", amount, "Added money")
    return true
end

-- Remove money from a player's wallet
function GWRP.Economy:TakeMoney(ply, amount)
    if not IsValid(ply) then return false, "Invalid player" end
    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxMoney, true)
    if not amount then return false, "Invalid amount" end
    if ply:GetMoney() < amount then return false, "Insufficient funds" end

    local newAmount = ply:GetMoney() - amount
    ply:SetMoney(newAmount)

    GWRP.DB:Update("gwrp_players", {money = newAmount}, {steamid = ply:SteamID()})
    return true
end

-- Transfer money between players (atomic, anti-dupe)
function GWRP.Economy:GiveMoney(sender, receiver, amount)
    if not IsValid(sender) or not IsValid(receiver) then return false, "Invalid player" end
    if sender == receiver then return false, "Cannot send to yourself" end
    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxTransferAmount, true)
    if not amount then return false, "Invalid amount" end
    if sender:GetMoney() < amount then return false, "Insufficient funds" end

    -- Transaction lock
    if sender.gwrp_inTransaction then return false, "Transaction in progress" end
    sender.gwrp_inTransaction = true

    sql.Begin()
    local success = sql.Query("UPDATE gwrp_players SET money = money - " .. amount ..
        " WHERE steamid = " .. sql.SQLStr(sender:SteamID()) .. " AND money >= " .. amount)

    if success ~= false then
        success = sql.Query("UPDATE gwrp_players SET money = money + " .. amount ..
            " WHERE steamid = " .. sql.SQLStr(receiver:SteamID()))
    end

    if success == false then
        sql.Query("ROLLBACK")
        sender.gwrp_inTransaction = nil
        return false, "Transaction failed"
    end

    sql.Commit()
    sender.gwrp_inTransaction = nil

    sender:SetMoney(sender:GetMoney() - amount)
    receiver:SetMoney(receiver:GetMoney() + amount)

    GWRP.DB:LogTransaction(sender:SteamID(), "give", -amount, "Gave to " .. receiver:SteamID())
    GWRP.DB:LogTransaction(receiver:SteamID(), "receive", amount, "Received from " .. sender:SteamID())
    GWRP.Log(string.format("[ECONOMY] %s -> %s: %s", sender:SteamID(), receiver:SteamID(), GWRP.FormatMoney(amount)), "info")
    return true
end

-- Bank deposit
function GWRP.Economy:Deposit(ply, amount)
    if not IsValid(ply) then return false, "Invalid player" end
    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxBankBalance, true)
    if not amount then return false, "Invalid amount" end
    if ply:GetMoney() < amount then return false, "Insufficient funds" end
    if ply:GetBank() + amount > GWRP.Config.MaxBankBalance then return false, "Bank balance limit reached" end

    ply:SetMoney(ply:GetMoney() - amount)
    ply:SetBank(ply:GetBank() + amount)

    GWRP.DB:SavePlayerData(ply)
    GWRP.DB:LogTransaction(ply:SteamID(), "deposit", amount, "Bank deposit")
    return true
end

-- Bank withdrawal
function GWRP.Economy:Withdraw(ply, amount)
    if not IsValid(ply) then return false, "Invalid player" end
    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxMoney, true)
    if not amount then return false, "Invalid amount" end
    if ply:GetBank() < amount then return false, "Insufficient bank balance" end

    ply:SetBank(ply:GetBank() - amount)
    ply:SetMoney(ply:GetMoney() + amount)

    GWRP.DB:SavePlayerData(ply)
    GWRP.DB:LogTransaction(ply:SteamID(), "withdraw", amount, "Bank withdrawal")
    return true
end

-- Net handlers
net.Receive("GWRP_BankDeposit", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "EconomyTransaction", GWRP.Config.RateLimits.EconomyTransaction.max, GWRP.Config.RateLimits.EconomyTransaction.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local amount = net.ReadUInt(32)
    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxBankBalance, true)
    if not amount then return end

    local ok, err = GWRP.Economy:Deposit(ply, amount)
    if ok then
        GWRP.Notify(ply, "Deposited " .. GWRP.FormatMoney(amount), 1)
    else
        GWRP.Notify(ply, err or "Deposit failed", 3)
    end
    GWRP.DB:SyncPlayerData(ply)
end)

net.Receive("GWRP_BankWithdraw", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "EconomyTransaction", GWRP.Config.RateLimits.EconomyTransaction.max, GWRP.Config.RateLimits.EconomyTransaction.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local amount = net.ReadUInt(32)
    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxMoney, true)
    if not amount then return end

    local ok, err = GWRP.Economy:Withdraw(ply, amount)
    if ok then
        GWRP.Notify(ply, "Withdrew " .. GWRP.FormatMoney(amount), 1)
    else
        GWRP.Notify(ply, err or "Withdrawal failed", 3)
    end
    GWRP.DB:SyncPlayerData(ply)
end)

net.Receive("GWRP_MoneyGive", function(len, ply)
    if not GWRP.Security:RateCheck(ply, "EconomyTransaction", GWRP.Config.RateLimits.EconomyTransaction.max, GWRP.Config.RateLimits.EconomyTransaction.window) then return end
    if not IsValid(ply) or not ply:Alive() then return end

    local amount = net.ReadUInt(32)
    local target = net.ReadEntity()

    amount = GWRP.Security:SanitizeNumber(amount, 1, GWRP.Config.MaxTransferAmount, true)
    if not amount then return end
    if not IsValid(target) or not target:IsPlayer() then return end
    if ply:GetPos():DistToSqr(target:GetPos()) > GWRP.Config.EntityInteractDistance ^ 2 then return end

    local ok, err = GWRP.Economy:GiveMoney(ply, target, amount)
    if ok then
        GWRP.Notify(ply, "Gave " .. GWRP.FormatMoney(amount) .. " to " .. target:Nick(), 1)
        GWRP.Notify(target, ply:Nick() .. " gave you " .. GWRP.FormatMoney(amount), 1)
    else
        GWRP.Notify(ply, err or "Transfer failed", 3)
    end
    GWRP.DB:SyncPlayerData(ply)
    GWRP.DB:SyncPlayerData(target)
end)

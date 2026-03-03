-- GangWarsRP - Main HUD Overlay

-- Hide default HUD elements
local hideElements = {
    CHudHealth = true,
    CHudBattery = true,
    CHudAmmo = true,
    CHudSecondaryAmmo = true,
    CHudSuitPower = true,
    CHudDamageIndicator = true,
}

hook.Add("HUDShouldDraw", "GWRP_HideDefaultHUD", function(name)
    if hideElements[name] then return false end
end)

-- Draw custom HUD
hook.Add("HUDPaint", "GWRP_MainHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local scrW, scrH = ScrW(), ScrH()
    local x, y = 20, scrH - 100
    local barW, barH = 200, 20

    -- Background panel
    draw.RoundedBox(6, x - 10, y - 10, barW + 20, 90, Color(20, 20, 25, 200))

    -- Health bar
    local hp = math.Clamp(ply:Health() / ply:GetMaxHealth(), 0, 1)
    draw.RoundedBox(4, x, y, barW, barH, Color(40, 40, 50, 255))
    draw.RoundedBox(4, x, y, barW * hp, barH, GWRP.Theme.Colors.Error)
    draw.SimpleText(ply:Health() .. " HP", "GWRP_Small", x + barW / 2, y + barH / 2, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Armor bar
    y = y + barH + 5
    local armor = math.Clamp(ply:Armor() / 100, 0, 1)
    draw.RoundedBox(4, x, y, barW, barH, Color(40, 40, 50, 255))
    draw.RoundedBox(4, x, y, barW * armor, barH, GWRP.Theme.Colors.Info)
    draw.SimpleText(ply:Armor() .. " AR", "GWRP_Small", x + barW / 2, y + barH / 2, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Money display
    y = y + barH + 8
    local money = ply:GetNWInt("GWRP_Money", 0)
    draw.SimpleText(GWRP.FormatMoney(money), "GWRP_BodyBold", x, y, GWRP.Theme.Colors.Money, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

    -- Job display
    local job = ply:GetNWString("GWRP_Job", "citizen")
    draw.SimpleText(string.upper(job), "GWRP_Small", x + barW, y + 2, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
end)

-- GangWarsRP - Settings Panel (F4 Tab)
-- Shows server info and player stats

local PANEL = {}

function PANEL:Init()
    self:DockPadding(15, 15, 15, 15)

    -- Server info section
    local serverHeader = vgui.Create("DLabel", self)
    serverHeader:SetFont("GWRP_Header")
    serverHeader:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    serverHeader:SetText("Server Info")
    serverHeader:Dock(TOP)
    serverHeader:SetTall(30)

    local infoPanel = vgui.Create("DPanel", self)
    infoPanel:Dock(TOP)
    infoPanel:SetTall(80)
    infoPanel:DockMargin(0, 5, 0, 15)
    infoPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, GWRP.Theme.Colors.BackgroundDark)

        draw.SimpleText("Gamemode: " .. GWRP.Name .. " v" .. GWRP.Version, "GWRP_Body", 15, 15, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Players: " .. #player.GetAll() .. "/" .. game.MaxPlayers(), "GWRP_Body", 15, 35, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Map: " .. game.GetMap(), "GWRP_Body", 15, 55, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    -- Player stats section
    local statsHeader = vgui.Create("DLabel", self)
    statsHeader:SetFont("GWRP_Header")
    statsHeader:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    statsHeader:SetText("Your Stats")
    statsHeader:Dock(TOP)
    statsHeader:SetTall(30)

    local statsPanel = vgui.Create("DPanel", self)
    statsPanel:Dock(TOP)
    statsPanel:SetTall(120)
    statsPanel:DockMargin(0, 5, 0, 15)
    statsPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, GWRP.Theme.Colors.BackgroundDark)

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local money = ply:GetNWInt("GWRP_Money", 0)
        local bank = ply:GetNWInt("GWRP_Bank", 0)
        local job = ply:GetNWString("GWRP_Job", "citizen")
        local gang = ply:GetNWString("GWRP_Gang", "")

        local jobDef = GWRP.Jobs and GWRP.Jobs.List and GWRP.Jobs.List[job]
        local jobName = jobDef and jobDef.name or job

        draw.SimpleText("Wallet: " .. GWRP.FormatMoney(money), "GWRP_Body", 15, 15, GWRP.Theme.Colors.Money, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Bank: " .. GWRP.FormatMoney(bank), "GWRP_Body", 15, 35, GWRP.Theme.Colors.Money, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Job: " .. jobName, "GWRP_Body", 15, 55, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Gang: " .. (gang ~= "" and gang or "None"), "GWRP_Body", 15, 75, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Playtime: " .. GWRP.FormatTime(ply:GetNWInt("GWRP_Playtime", 0)), "GWRP_Body", 15, 95, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    -- Loaded modules section
    local modsHeader = vgui.Create("DLabel", self)
    modsHeader:SetFont("GWRP_Header")
    modsHeader:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    modsHeader:SetText("Loaded Modules")
    modsHeader:Dock(TOP)
    modsHeader:SetTall(30)

    local modsPanel = vgui.Create("DPanel", self)
    modsPanel:Dock(TOP)
    modsPanel:SetTall(100)
    modsPanel:DockMargin(0, 5, 0, 0)
    modsPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, GWRP.Theme.Colors.BackgroundDark)

        local y = 10
        for id, mod in SortedPairs(GWRP.Modules:GetAll()) do
            if mod.enabled and mod.loaded then
                local col = GWRP.Theme.Colors.Success
                draw.SimpleText(mod.name or id, "GWRP_Small", 15, y, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                y = y + 18
            end
        end
    end
end

vgui.Register("GWRP_SettingsPanel", PANEL, "DPanel")

-- GangWarsRP - Economy Client (Bank F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    -- Title
    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Bank & Wallet")
    title:SizeToContents()

    -- Balance display
    self.balancePanel = vgui.Create("DPanel", self)
    self.balancePanel:SetPos(20, 50)
    self.balancePanel:SetSize(350, 80)
    self.balancePanel.Paint = function(s, w, h)
        GWRP.Theme:DrawPanel(0, 0, w, h, GWRP.Theme.Colors.Panel, GWRP.Theme.Colors.Border)

        local money = LocalPlayer():GetNWInt("GWRP_Money", 0)
        local bank = LocalPlayer():GetNWInt("GWRP_Bank", 0)

        draw.SimpleText("Wallet:", "GWRP_Body", 15, 20, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(GWRP.FormatMoney(money), "GWRP_Header", 100, 20, GWRP.Theme.Colors.Money, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        draw.SimpleText("Bank:", "GWRP_Body", 15, 50, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(GWRP.FormatMoney(bank), "GWRP_Header", 100, 50, GWRP.Theme.Colors.Info, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- Amount entry
    self.amountEntry = GWRP.Theme:CreateTextEntry(self, "Amount...", 20, 150, 200, 32)
    self.amountEntry:SetNumeric(true)

    -- Deposit button
    local depositBtn = GWRP.Theme:CreateButton(self, "Deposit", 230, 150, 100, 32)
    depositBtn.bgColor = GWRP.Theme.Colors.Success
    depositBtn.hoverColor = Color(100, 220, 140, 255)
    depositBtn.DoClick = function()
        local amount = tonumber(self.amountEntry:GetValue())
        if not amount or amount <= 0 then return end
        net.Start("GWRP_BankDeposit")
            net.WriteUInt(math.floor(amount), 32)
        net.SendToServer()
        self.amountEntry:SetValue("")
    end

    -- Withdraw button
    local withdrawBtn = GWRP.Theme:CreateButton(self, "Withdraw", 340, 150, 100, 32)
    withdrawBtn.DoClick = function()
        local amount = tonumber(self.amountEntry:GetValue())
        if not amount or amount <= 0 then return end
        net.Start("GWRP_BankWithdraw")
            net.WriteUInt(math.floor(amount), 32)
        net.SendToServer()
        self.amountEntry:SetValue("")
    end
end

vgui.Register("GWRP_EconomyPanel", PANEL, "DPanel")

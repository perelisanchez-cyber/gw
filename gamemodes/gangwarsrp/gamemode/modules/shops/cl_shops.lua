-- GangWarsRP - Shops Client (Shop F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Shop")
    title:SizeToContents()

    -- Search
    self.search = GWRP.Theme:CreateTextEntry(self, "Search items...", 20, 50, 300, 28)

    -- Item list
    self.itemList = vgui.Create("DScrollPanel", self)
    self.itemList:SetPos(20, 90)
    self.itemList:SetSize(self:GetWide() - 40, self:GetTall() - 110)

    self:PopulateItems()

    self.search.OnChange = function()
        self:PopulateItems(self.search:GetValue())
    end
end

function PANEL:PopulateItems(filter)
    self.itemList:Clear()
    filter = filter and string.lower(filter) or ""

    for itemID, item in SortedPairsByMemberValue(GWRP.Shops.Items, "category") do
        if filter == "" or string.find(string.lower(item.name or ""), filter, 1, true) then
            local btn = vgui.Create("DButton", self.itemList)
            btn:SetSize(self.itemList:GetWide() - 20, 45)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 4)
            btn:SetText("")

            btn.Paint = function(s, w, h)
                local bgCol = s:IsHovered() and GWRP.Theme.Colors.PanelHover or GWRP.Theme.Colors.Panel
                draw.RoundedBox(4, 0, 0, w, h, bgCol)
                draw.SimpleText(item.name or itemID, "GWRP_BodyBold", 12, 12, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(item.category or "", "GWRP_Small", 12, 30, GWRP.Theme.Colors.TextMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(GWRP.FormatMoney(item.price or 0), "GWRP_BodyBold", w - 12, h / 2, GWRP.Theme.Colors.Money, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            btn.DoClick = function()
                net.Start("GWRP_ShopPurchase")
                    net.WriteString(itemID)
                net.SendToServer()
            end
        end
    end
end

vgui.Register("GWRP_ShopsPanel", PANEL, "DPanel")

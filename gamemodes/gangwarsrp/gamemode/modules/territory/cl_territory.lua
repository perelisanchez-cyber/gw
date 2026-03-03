-- GangWarsRP - Territory Client (Territory F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Territory Map")
    title:SizeToContents()

    local info = vgui.Create("DLabel", self)
    info:SetPos(20, 50)
    info:SetFont("GWRP_Body")
    info:SetTextColor(GWRP.Theme.Colors.TextSecondary)
    info:SetText("Capture zones to earn passive income for your gang.")
    info:SizeToContents()

    -- Territory list
    local zoneList = vgui.Create("DScrollPanel", self)
    zoneList:SetPos(20, 85)
    zoneList:SetSize(self:GetWide() - 40, self:GetTall() - 105)

    for zoneID, zone in pairs(GWRP.Territory.Zones or {}) do
        local row = vgui.Create("DPanel", zoneList)
        row:SetSize(zoneList:GetWide() - 20, 40)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 4)

        row.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, GWRP.Theme.Colors.Panel)
            draw.SimpleText(zone.name or zoneID, "GWRP_BodyBold", 12, h / 2, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local owner = zone.owner or "Unclaimed"
            local ownerCol = owner == "Unclaimed" and GWRP.Theme.Colors.TextMuted or GWRP.Theme.Colors.Accent
            draw.SimpleText(owner, "GWRP_Body", w - 12, h / 2, ownerCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end
end

vgui.Register("GWRP_TerritoryPanel", PANEL, "DPanel")

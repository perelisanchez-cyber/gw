-- GangWarsRP - Police Client (Police F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Police Operations")
    title:SizeToContents()

    -- Wanted list
    local wantedLabel = vgui.Create("DLabel", self)
    wantedLabel:SetPos(20, 50)
    wantedLabel:SetFont("GWRP_BodyBold")
    wantedLabel:SetTextColor(GWRP.Theme.Colors.Warning)
    wantedLabel:SetText("Wanted Players")
    wantedLabel:SizeToContents()

    local wantedList = vgui.Create("DScrollPanel", self)
    wantedList:SetPos(20, 75)
    wantedList:SetSize(self:GetWide() - 40, 200)

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNWBool("GWRP_Wanted", false) then
            local row = vgui.Create("DPanel", wantedList)
            row:SetSize(wantedList:GetWide() - 20, 35)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 3)

            local pName = ply:Nick()
            local reason = ply:GetNWString("GWRP_WantedReason", "Unknown")
            row.Paint = function(s, pw, ph)
                draw.RoundedBox(4, 0, 0, pw, ph, GWRP.Theme.Colors.Panel)
                draw.SimpleText(pName, "GWRP_BodyBold", 10, ph / 2, GWRP.Theme.Colors.Error, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(reason, "GWRP_Small", pw - 10, ph / 2, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end
end

vgui.Register("GWRP_PolicePanel", PANEL, "DPanel")

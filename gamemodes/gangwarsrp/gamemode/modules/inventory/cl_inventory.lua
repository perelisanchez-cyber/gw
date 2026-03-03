-- GangWarsRP - Inventory Client (Inventory F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Inventory")
    title:SizeToContents()

    local info = vgui.Create("DLabel", self)
    info:SetPos(20, 50)
    info:SetFont("GWRP_Body")
    info:SetTextColor(GWRP.Theme.Colors.TextSecondary)
    info:SetText("Your items and equipment. Drag to drop, click to use.")
    info:SizeToContents()

    -- Grid placeholder
    -- TODO: Implement inventory grid with drag-and-drop
end

vgui.Register("GWRP_InventoryPanel", PANEL, "DPanel")

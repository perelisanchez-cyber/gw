-- GangWarsRP - Admin Client (Admin F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Admin Panel")
    title:SizeToContents()

    -- Player list
    local playersLabel = vgui.Create("DLabel", self)
    playersLabel:SetPos(20, 50)
    playersLabel:SetFont("GWRP_BodyBold")
    playersLabel:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    playersLabel:SetText("Online Players")
    playersLabel:SizeToContents()

    local playerList = vgui.Create("DScrollPanel", self)
    playerList:SetPos(20, 75)
    playerList:SetSize(self:GetWide() - 40, 200)

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            local row = vgui.Create("DPanel", playerList)
            row:SetSize(playerList:GetWide() - 20, 35)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 3)

            local pName = ply:Nick()
            local pJob = ply:GetNWString("GWRP_Job", "?")
            row.Paint = function(s, pw, ph)
                draw.RoundedBox(4, 0, 0, pw, ph, GWRP.Theme.Colors.Panel)
                draw.SimpleText(pName, "GWRP_Body", 10, ph / 2, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(pJob, "GWRP_Small", pw - 100, ph / 2, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            -- Kick button
            local kickBtn = GWRP.Theme:CreateButton(row, "Kick", row:GetWide() - 70, 5, 60, 25)
            kickBtn.bgColor = GWRP.Theme.Colors.Error
            kickBtn.hoverColor = Color(240, 90, 90, 255)
            kickBtn.DoClick = function()
                net.Start("GWRP_AdminAction")
                    net.WriteString("kick")
                    net.WriteEntity(ply)
                    net.WriteString("Kicked by admin")
                net.SendToServer()
            end
        end
    end

    -- Module toggles section
    local modLabel = vgui.Create("DLabel", self)
    modLabel:SetPos(20, 290)
    modLabel:SetFont("GWRP_BodyBold")
    modLabel:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    modLabel:SetText("Module Toggles (requires server reload)")
    modLabel:SizeToContents()

    local modList = vgui.Create("DScrollPanel", self)
    modList:SetPos(20, 315)
    modList:SetSize(self:GetWide() - 40, 150)

    for moduleID, mod in SortedPairs(GWRP.Modules:GetAll()) do
        local row = vgui.Create("DPanel", modList)
        row:SetSize(modList:GetWide() - 20, 30)
        row:Dock(TOP)
        row:DockMargin(0, 0, 0, 2)
        row.Paint = function(s, w, h)
            draw.RoundedBox(2, 0, 0, w, h, GWRP.Theme.Colors.Panel)
        end

        local lbl = vgui.Create("DLabel", row)
        lbl:SetPos(10, 0)
        lbl:SetSize(200, 30)
        lbl:SetFont("GWRP_Body")
        lbl:SetTextColor(GWRP.Theme.Colors.TextPrimary)
        lbl:SetText(mod.name or moduleID)

        local toggle = vgui.Create("DCheckBox", row)
        toggle:SetPos(row:GetWide() - 40, 7)
        toggle:SetSize(16, 16)
        toggle:SetChecked(mod.enabled)
        toggle.OnChange = function(s, val)
            if moduleID == "f4menu" then
                s:SetChecked(true)
                return
            end
            net.Start("GWRP_AdminModuleToggle")
                net.WriteString(moduleID)
                net.WriteBool(val)
            net.SendToServer()
        end
    end
end

vgui.Register("GWRP_AdminPanel", PANEL, "DPanel")

-- GangWarsRP - Gangs Client (Gangs F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Gangs")
    title:SizeToContents()

    -- Show create form or gang info based on membership
    if LocalPlayer():GetNWString("GWRP_Gang", "") == "" then
        self:ShowCreateForm()
    else
        self:ShowGangInfo()
    end
end

function PANEL:ShowCreateForm()
    local label = vgui.Create("DLabel", self)
    label:SetPos(20, 50)
    label:SetFont("GWRP_Body")
    label:SetTextColor(GWRP.Theme.Colors.TextSecondary)
    label:SetText("You are not in a gang. Create one for " .. GWRP.FormatMoney(GWRP.Config.GangCreationCost))
    label:SizeToContents()

    local nameEntry = GWRP.Theme:CreateTextEntry(self, "Gang name...", 20, 80, 250, 32)

    local createBtn = GWRP.Theme:CreateButton(self, "Create Gang", 280, 80, 120, 32)
    createBtn.DoClick = function()
        local name = nameEntry:GetValue()
        if #name < GWRP.Config.GangNameMinLen then return end
        net.Start("GWRP_GangCreate")
            net.WriteString(name)
        net.SendToServer()
    end
end

function PANEL:ShowGangInfo()
    local gangName = LocalPlayer():GetNWString("GWRP_Gang", "")
    local gangRank = LocalPlayer():GetNWInt("GWRP_GangRank", 0)

    local infoPanel = vgui.Create("DPanel", self)
    infoPanel:SetPos(20, 50)
    infoPanel:SetSize(400, 60)
    infoPanel.Paint = function(s, w, h)
        GWRP.Theme:DrawPanel(0, 0, w, h, GWRP.Theme.Colors.Panel, GWRP.Theme.Colors.Border)
        draw.SimpleText(gangName, "GWRP_Header", 15, 15, GWRP.Theme.Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText("Rank: " .. (GWRP.GANG_RANK_NAMES[gangRank] or "Unknown"), "GWRP_Body", 15, 38, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    -- Member list header
    local membersLabel = vgui.Create("DLabel", self)
    membersLabel:SetPos(20, 125)
    membersLabel:SetFont("GWRP_BodyBold")
    membersLabel:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    membersLabel:SetText("Online Members")
    membersLabel:SizeToContents()

    -- Online members list
    local memberList = vgui.Create("DScrollPanel", self)
    memberList:SetPos(20, 150)
    memberList:SetSize(400, 200)

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNWString("GWRP_Gang", "") == gangName then
            local row = vgui.Create("DPanel", memberList)
            row:SetSize(380, 30)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 2)

            local pName = ply:Nick()
            local pRank = GWRP.GANG_RANK_NAMES[ply:GetNWInt("GWRP_GangRank", 0)] or "?"
            row.Paint = function(s, w, h)
                draw.RoundedBox(2, 0, 0, w, h, GWRP.Theme.Colors.Panel)
                draw.SimpleText(pName, "GWRP_Body", 10, h / 2, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(pRank, "GWRP_Small", w - 10, h / 2, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    -- Leave button
    local leaveBtn = GWRP.Theme:CreateButton(self, "Leave Gang", 20, 370, 120, 32)
    leaveBtn.bgColor = GWRP.Theme.Colors.Error
    leaveBtn.hoverColor = Color(240, 90, 90, 255)
    leaveBtn.DoClick = function()
        net.Start("GWRP_GangLeave")
        net.SendToServer()
    end
end

vgui.Register("GWRP_GangsPanel", PANEL, "DPanel")

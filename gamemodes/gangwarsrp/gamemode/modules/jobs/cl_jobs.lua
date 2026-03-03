-- GangWarsRP - Jobs Client (Jobs F4 Tab)

local PANEL = {}

function PANEL:Init()
    self.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.Background)
    end

    local title = vgui.Create("DLabel", self)
    title:SetPos(20, 15)
    title:SetFont("GWRP_Header")
    title:SetTextColor(GWRP.Theme.Colors.TextPrimary)
    title:SetText("Jobs")
    title:SizeToContents()

    -- Search bar
    self.search = GWRP.Theme:CreateTextEntry(self, "Search jobs...", 20, 50, 300, 28)

    -- Job list
    self.jobList = vgui.Create("DScrollPanel", self)
    self.jobList:SetPos(20, 90)
    self.jobList:SetSize(self:GetWide() - 40, self:GetTall() - 110)

    self:PopulateJobs()

    self.search.OnChange = function()
        self:PopulateJobs(self.search:GetValue())
    end
end

function PANEL:PopulateJobs(filter)
    self.jobList:Clear()
    filter = filter and string.lower(filter) or ""

    for jobID, jobDef in SortedPairsByMemberValue(GWRP.Jobs.List, "category") do
        if filter == "" or string.find(string.lower(jobDef.name), filter, 1, true) then
            local btn = vgui.Create("DButton", self.jobList)
            btn:SetSize(self.jobList:GetWide() - 20, 50)
            btn:Dock(TOP)
            btn:DockMargin(0, 0, 0, 5)
            btn:SetText("")

            btn.Paint = function(s, w, h)
                local isCurrentJob = (LocalPlayer():GetNWString("GWRP_Job", "") == jobID)
                local bgCol
                if isCurrentJob then
                    bgCol = GWRP.Theme.Colors.AccentDark
                elseif s:IsHovered() then
                    bgCol = GWRP.Theme.Colors.PanelHover
                else
                    bgCol = GWRP.Theme.Colors.Panel
                end
                draw.RoundedBox(4, 0, 0, w, h, bgCol)

                local catCol = jobDef.category == GWRP.JOB_CATEGORY.LEGAL and GWRP.Theme.Colors.Success or GWRP.Theme.Colors.Error
                draw.SimpleText(jobDef.name, "GWRP_BodyBold", 12, 14, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(string.upper(jobDef.category or ""), "GWRP_Small", 12, 34, catCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                draw.SimpleText(GWRP.FormatMoney(jobDef.salary or 0) .. "/cycle", "GWRP_Body", w - 12, 25, GWRP.Theme.Colors.Money, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end

            btn.DoClick = function()
                net.Start("GWRP_JobSwitch")
                    net.WriteString(jobID)
                net.SendToServer()
            end
        end
    end
end

vgui.Register("GWRP_JobsPanel", PANEL, "DPanel")

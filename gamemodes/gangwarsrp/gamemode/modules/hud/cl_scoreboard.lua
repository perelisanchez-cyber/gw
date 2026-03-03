-- GangWarsRP - Custom Scoreboard
-- Shows player name, job, gang, money, and ping

local ScoreboardFrame = nil

hook.Add("ScoreboardShow", "GWRP_ScoreboardShow", function()
    if IsValid(ScoreboardFrame) then
        ScoreboardFrame:Show()
        ScoreboardFrame:MakePopup()
        return true
    end

    local scrW, scrH = ScrW(), ScrH()
    local frameW = math.min(750, scrW * 0.6)
    local frameH = math.min(500, scrH * 0.65)

    ScoreboardFrame = vgui.Create("DFrame")
    ScoreboardFrame:SetSize(frameW, frameH)
    ScoreboardFrame:Center()
    ScoreboardFrame:SetTitle("")
    ScoreboardFrame:SetDraggable(false)
    ScoreboardFrame:ShowCloseButton(false)
    ScoreboardFrame:MakePopup()

    ScoreboardFrame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, GWRP.Theme.Colors.Background)
        surface.SetDrawColor(GWRP.Theme.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        -- Header
        draw.RoundedBoxEx(8, 0, 0, w, 40, GWRP.Theme.Colors.Header, true, true, false, false)
        draw.SimpleText(GWRP.Name .. " - Scoreboard", "GWRP_Title", 15, 20, GWRP.Theme.Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        local count = #player.GetAll()
        draw.SimpleText(count .. " Player" .. (count ~= 1 and "s" or ""), "GWRP_Body", w - 15, 20, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- Column headers
    local headerPanel = vgui.Create("DPanel", ScoreboardFrame)
    headerPanel:SetPos(0, 40)
    headerPanel:SetSize(frameW, 28)
    headerPanel.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, GWRP.Theme.Colors.BackgroundDark)
        draw.SimpleText("Name", "GWRP_Small", 15, h / 2, GWRP.Theme.Colors.TextMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Job", "GWRP_Small", 250, h / 2, GWRP.Theme.Colors.TextMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Gang", "GWRP_Small", 420, h / 2, GWRP.Theme.Colors.TextMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Ping", "GWRP_Small", w - 15, h / 2, GWRP.Theme.Colors.TextMuted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- Scrollable player list
    local scroll = vgui.Create("DScrollPanel", ScoreboardFrame)
    scroll:SetPos(0, 68)
    scroll:SetSize(frameW, frameH - 68)

    local sbar = scroll:GetVBar()
    sbar:SetWide(4)
    sbar.Paint = function() end
    sbar.btnUp.Paint = function() end
    sbar.btnDown.Paint = function() end
    sbar.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(2, 0, 0, w, h, GWRP.Theme.Colors.Accent)
    end

    -- Store list reference for refresh
    ScoreboardFrame.playerList = scroll

    -- Build player rows
    local function RefreshPlayers()
        scroll:Clear()

        local players = player.GetAll()
        table.sort(players, function(a, b)
            return a:Nick() < b:Nick()
        end)

        for _, ply in ipairs(players) do
            if not IsValid(ply) then continue end

            local row = vgui.Create("DPanel", scroll)
            row:SetSize(frameW, 32)
            row:Dock(TOP)
            row:DockMargin(0, 0, 0, 1)

            local p = ply -- capture for paint closure
            row.Paint = function(s, w, h)
                if not IsValid(p) then return end

                local bgCol = s:IsHovered() and GWRP.Theme.Colors.PanelHover or GWRP.Theme.Colors.Panel
                draw.RoundedBox(0, 0, 0, w, h, bgCol)

                -- Name
                local nameCol = p == LocalPlayer() and GWRP.Theme.Colors.Accent or GWRP.Theme.Colors.TextPrimary
                draw.SimpleText(p:Nick(), "GWRP_Body", 15, h / 2, nameCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Job
                local job = p:GetNWString("GWRP_Job", "citizen")
                local jobDef = GWRP.Jobs and GWRP.Jobs.List and GWRP.Jobs.List[job]
                local jobName = jobDef and jobDef.name or job
                draw.SimpleText(jobName, "GWRP_Small", 250, h / 2, GWRP.Theme.Colors.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Gang
                local gang = p:GetNWString("GWRP_Gang", "")
                if gang ~= "" then
                    draw.SimpleText(gang, "GWRP_Small", 420, h / 2, GWRP.Theme.Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                else
                    draw.SimpleText("-", "GWRP_Small", 420, h / 2, GWRP.Theme.Colors.TextMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                -- Ping
                local ping = p:Ping()
                local pingCol = GWRP.Theme.Colors.Success
                if ping > 100 then pingCol = GWRP.Theme.Colors.Warning end
                if ping > 200 then pingCol = GWRP.Theme.Colors.Error end
                draw.SimpleText(ping .. "ms", "GWRP_Small", w - 15, h / 2, pingCol, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    RefreshPlayers()

    -- Refresh every 3 seconds while open
    timer.Create("GWRP_ScoreboardRefresh", 3, 0, function()
        if not IsValid(ScoreboardFrame) or not ScoreboardFrame:IsVisible() then
            timer.Remove("GWRP_ScoreboardRefresh")
            return
        end
        RefreshPlayers()
    end)

    return true
end)

hook.Add("ScoreboardHide", "GWRP_ScoreboardHide", function()
    if IsValid(ScoreboardFrame) then
        ScoreboardFrame:Hide()
    end
    timer.Remove("GWRP_ScoreboardRefresh")
    return true
end)

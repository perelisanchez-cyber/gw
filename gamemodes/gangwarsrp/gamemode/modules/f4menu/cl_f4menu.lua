-- GangWarsRP - Main F4 Menu Frame & Tab System

local F4Frame = nil
local ActiveTab = nil
local ActivePanel = nil
local LastTabID = nil -- remember last tab across open/close

-- Open/close the F4 menu
function GWRP.OpenF4Menu()
    if IsValid(F4Frame) then
        GWRP.CloseF4Menu()
        return
    end

    local scrW, scrH = ScrW(), ScrH()
    local frameW = math.min(900, scrW * 0.7)
    local frameH = math.min(600, scrH * 0.75)

    F4Frame = vgui.Create("DFrame")
    F4Frame:SetSize(frameW, frameH)
    F4Frame:Center()
    F4Frame:SetTitle("")
    F4Frame:SetDraggable(false)
    F4Frame:ShowCloseButton(false)
    F4Frame:MakePopup()
    F4Frame:SetKeyboardInputEnabled(true)

    -- Handle Escape inside the frame (PlayerButtonDown won't fire while popup has focus)
    F4Frame.OnKeyCodePressed = function(s, key)
        if key == KEY_ESCAPE or key == KEY_F4 then
            GWRP.CloseF4Menu()
        end
    end

    F4Frame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, GWRP.Theme.Colors.Background)
        surface.SetDrawColor(GWRP.Theme.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        -- Header bar
        draw.RoundedBoxEx(8, 0, 0, w, 40, GWRP.Theme.Colors.Header, true, true, false, false)
        draw.SimpleText(GWRP.Name, "GWRP_Title", 15, 20, GWRP.Theme.Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        -- Money display in header
        local money = LocalPlayer():GetNWInt("GWRP_Money", 0)
        draw.SimpleText(GWRP.FormatMoney(money), "GWRP_Header", w - 15, 20, GWRP.Theme.Colors.Money, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    -- Close button
    local closeBtn = vgui.Create("DButton", F4Frame)
    closeBtn:SetPos(frameW - 35, 8)
    closeBtn:SetSize(24, 24)
    closeBtn:SetText("")
    closeBtn.Paint = function(s, w, h)
        local col = s:IsHovered() and GWRP.Theme.Colors.Error or GWRP.Theme.Colors.TextSecondary
        draw.SimpleText("X", "GWRP_BodyBold", w / 2, h / 2, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        GWRP.CloseF4Menu()
    end

    -- Tab sidebar
    local tabBarW = 140
    local tabBar = vgui.Create("DPanel", F4Frame)
    tabBar:SetPos(0, 40)
    tabBar:SetSize(tabBarW, frameH - 40)
    tabBar.Paint = function(s, w, h)
        draw.RoundedBoxEx(0, 0, 0, w, h, GWRP.Theme.Colors.BackgroundDark, false, false, true, false)
        -- Right border
        surface.SetDrawColor(GWRP.Theme.Colors.Border)
        surface.DrawLine(w - 1, 0, w - 1, h)
    end

    -- Content area
    local contentPanel = vgui.Create("DPanel", F4Frame)
    contentPanel:SetPos(tabBarW, 40)
    contentPanel:SetSize(frameW - tabBarW, frameH - 40)
    contentPanel.Paint = function() end

    -- Build tabs from enabled modules
    local tabs = GWRP.F4Tabs:BuildTabList()
    local tabButtons = {}
    local tabY = 10

    for i, tab in ipairs(tabs) do
        if GWRP.F4Tabs:IsTabVisible(tab, LocalPlayer()) then
            local btn = vgui.Create("DButton", tabBar)
            btn:SetPos(5, tabY)
            btn:SetSize(tabBarW - 10, 36)
            btn:SetText("")
            btn.tabData = tab
            btn.isActive = false

            btn.Paint = function(s, w, h)
                local bgCol
                if s.isActive then
                    bgCol = GWRP.Theme.Colors.Accent
                elseif s:IsHovered() then
                    bgCol = GWRP.Theme.Colors.PanelHover
                else
                    bgCol = GWRP.Theme.Colors.BackgroundDark
                end
                draw.RoundedBox(4, 0, 0, w, h, bgCol)

                local textCol = s.isActive and GWRP.Theme.Colors.TextPrimary or GWRP.Theme.Colors.TextSecondary
                draw.SimpleText(tab.label, "GWRP_TabLabel", 12, h / 2, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            btn.DoClick = function(s)
                GWRP.F4SelectTab(s.tabData, contentPanel, tabButtons)
            end

            table.insert(tabButtons, btn)
            tabY = tabY + 40
        end
    end

    -- Select the last active tab, or the first tab
    local selectedTab = nil
    if LastTabID then
        for _, btn in ipairs(tabButtons) do
            if btn.tabData.moduleID == LastTabID then
                selectedTab = btn.tabData
                break
            end
        end
    end
    if not selectedTab and #tabButtons > 0 then
        selectedTab = tabButtons[1].tabData
    end
    if selectedTab then
        GWRP.F4SelectTab(selectedTab, contentPanel, tabButtons)
    end

    -- Animate open
    F4Frame:SetAlpha(0)
    F4Frame:AlphaTo(255, 0.15, 0)
end

-- Switch to a tab
function GWRP.F4SelectTab(tabData, contentPanel, tabButtons)
    -- Update button states
    for _, btn in ipairs(tabButtons) do
        btn.isActive = (btn.tabData.moduleID == tabData.moduleID)
    end

    -- Remove old content
    if IsValid(ActivePanel) then
        ActivePanel:Remove()
    end

    -- Create new tab panel
    LastTabID = tabData.moduleID
    ActiveTab = tabData

    if tabData.panel_class then
        ActivePanel = vgui.Create(tabData.panel_class, contentPanel)
        if IsValid(ActivePanel) then
            ActivePanel:SetPos(0, 0)
            ActivePanel:SetSize(contentPanel:GetWide(), contentPanel:GetTall())
        end
    end
end

-- Close the F4 menu
function GWRP.CloseF4Menu()
    if IsValid(F4Frame) then
        F4Frame:Remove()
    end
    F4Frame = nil
    ActivePanel = nil
    ActiveTab = nil

    -- Release mouse cursor back to the game
    gui.EnableScreenClicker(false)
    CloseDermaMenus()
end

-- F4 has no default GMod bind, so catch the raw key directly.
-- PlayerButtonDown fires when no VGUI panel has focus (i.e. menu is closed).
-- When the menu IS open, OnKeyCodePressed on the frame handles F4/Escape.
hook.Add("PlayerButtonDown", "GWRP_F4MenuOpen", function(ply, button)
    if button ~= KEY_F4 then return end
    if ply ~= LocalPlayer() then return end
    GWRP.OpenF4Menu()
end)

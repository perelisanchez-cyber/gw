-- GangWarsRP - Shared Derma Theme
-- All modules use GWRP.Theme for consistent styling

GWRP.Theme = GWRP.Theme or {}

-- Colors
GWRP.Theme.Colors = {
    Background      = Color(25, 25, 30, 245),
    BackgroundDark  = Color(18, 18, 22, 255),
    Panel           = Color(35, 35, 42, 255),
    PanelHover      = Color(45, 45, 55, 255),
    PanelActive     = Color(55, 55, 68, 255),
    Header          = Color(30, 30, 38, 255),
    Border          = Color(60, 60, 75, 255),
    Accent          = Color(130, 80, 220, 255),
    AccentHover     = Color(150, 100, 240, 255),
    AccentDark      = Color(90, 55, 160, 255),
    Success         = Color(80, 200, 120, 255),
    Warning         = Color(230, 180, 50, 255),
    Error           = Color(220, 70, 70, 255),
    Info            = Color(70, 150, 220, 255),
    TextPrimary     = Color(240, 240, 245, 255),
    TextSecondary   = Color(160, 160, 175, 255),
    TextMuted       = Color(100, 100, 115, 255),
    Money           = Color(100, 220, 100, 255),
}

-- Fonts (only create once; surface.CreateFont is idempotent in GMod but
-- we guard with a flag to avoid unnecessary work on auto-refresh)
if not GWRP.Theme._fontsCreated then
    surface.CreateFont("GWRP_Title", {
        font = "Roboto",
        size = 28,
        weight = 700,
    })

    surface.CreateFont("GWRP_Header", {
        font = "Roboto",
        size = 20,
        weight = 600,
    })

    surface.CreateFont("GWRP_Body", {
        font = "Roboto",
        size = 16,
        weight = 400,
    })

    surface.CreateFont("GWRP_BodyBold", {
        font = "Roboto",
        size = 16,
        weight = 600,
    })

    surface.CreateFont("GWRP_Small", {
        font = "Roboto",
        size = 13,
        weight = 400,
    })

    surface.CreateFont("GWRP_TabLabel", {
        font = "Roboto",
        size = 15,
        weight = 500,
    })

    GWRP.Theme._fontsCreated = true
end

-- Helper: draw a rounded box with border
function GWRP.Theme:DrawPanel(x, y, w, h, bgColor, borderColor)
    draw.RoundedBox(6, x, y, w, h, bgColor or self.Colors.Panel)
    if borderColor then
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(x, y, w, h, 1)
    end
end

-- Helper: create a styled button
function GWRP.Theme:CreateButton(parent, text, x, y, w, h)
    local btn = vgui.Create("DButton", parent)
    btn:SetPos(x, y)
    btn:SetSize(w, h)
    btn:SetText("")

    btn.label = text
    btn.bgColor = self.Colors.Accent
    btn.hoverColor = self.Colors.AccentHover

    btn.Paint = function(s, pw, ph)
        local col = s:IsHovered() and s.hoverColor or s.bgColor
        draw.RoundedBox(4, 0, 0, pw, ph, col)
        draw.SimpleText(s.label, "GWRP_BodyBold", pw / 2, ph / 2, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return btn
end

-- Helper: create a styled text entry
function GWRP.Theme:CreateTextEntry(parent, placeholder, x, y, w, h)
    local entry = vgui.Create("DTextEntry", parent)
    entry:SetPos(x, y)
    entry:SetSize(w, h)
    entry:SetPlaceholderText(placeholder or "")
    entry:SetFont("GWRP_Body")
    entry:SetTextColor(self.Colors.TextPrimary)

    entry.Paint = function(s, pw, ph)
        draw.RoundedBox(4, 0, 0, pw, ph, GWRP.Theme.Colors.BackgroundDark)
        surface.SetDrawColor(GWRP.Theme.Colors.Border)
        surface.DrawOutlinedRect(0, 0, pw, ph, 1)
        s:DrawTextEntryText(GWRP.Theme.Colors.TextPrimary, GWRP.Theme.Colors.Accent, GWRP.Theme.Colors.TextPrimary)
    end

    return entry
end

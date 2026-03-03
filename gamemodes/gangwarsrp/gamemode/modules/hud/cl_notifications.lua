-- GangWarsRP - Notification System

GWRP.Notifications = GWRP.Notifications or {}
GWRP.Notifications.Queue = {}

local NOTIF_COLORS = {
    [0] = GWRP.Theme and GWRP.Theme.Colors.Info or Color(70, 150, 220, 255),     -- info
    [1] = GWRP.Theme and GWRP.Theme.Colors.Success or Color(80, 200, 120, 255),  -- success
    [2] = GWRP.Theme and GWRP.Theme.Colors.Warning or Color(230, 180, 50, 255),  -- warning
    [3] = GWRP.Theme and GWRP.Theme.Colors.Error or Color(220, 70, 70, 255),     -- error
}

-- Show a notification
hook.Add("GWRP_ShowNotification", "GWRP_NotifDisplay", function(msg, notifType)
    table.insert(GWRP.Notifications.Queue, {
        text = msg,
        color = NOTIF_COLORS[notifType] or NOTIF_COLORS[0],
        time = CurTime(),
        duration = 4,
        alpha = 255,
    })

    -- Cap queue size
    while #GWRP.Notifications.Queue > 5 do
        table.remove(GWRP.Notifications.Queue, 1)
    end
end)

-- Render notifications
hook.Add("HUDPaint", "GWRP_NotifHUD", function()
    local scrW = ScrW()
    local y = 60

    for i = #GWRP.Notifications.Queue, 1, -1 do
        local notif = GWRP.Notifications.Queue[i]
        local elapsed = CurTime() - notif.time

        if elapsed > notif.duration then
            notif.alpha = notif.alpha - FrameTime() * 400
            if notif.alpha <= 0 then
                table.remove(GWRP.Notifications.Queue, i)
                continue
            end
        end

        local alpha = math.Clamp(notif.alpha, 0, 255)
        local bgCol = Color(25, 25, 30, alpha * 0.85)
        local textCol = Color(notif.color.r, notif.color.g, notif.color.b, alpha)
        local accentCol = Color(notif.color.r, notif.color.g, notif.color.b, alpha)

        surface.SetFont("GWRP_Body")
        local tw = surface.GetTextSize(notif.text)
        local boxW = tw + 30
        local boxX = scrW - boxW - 20

        draw.RoundedBox(4, boxX, y, boxW, 30, bgCol)
        draw.RoundedBox(2, boxX, y, 3, 30, accentCol)
        draw.SimpleText(notif.text, "GWRP_Body", boxX + 15, y + 15, textCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

        y = y + 35
    end
end)

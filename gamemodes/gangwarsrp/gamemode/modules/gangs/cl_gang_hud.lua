-- GangWarsRP - Gang HUD Overlay (gang name display)
-- Shows gang name near player name if HUD module handles it, otherwise standalone

hook.Add("HUDPaint", "GWRP_GangHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local gang = ply:GetNWString("GWRP_Gang", "")
    if gang == "" then return end

    -- Small gang indicator in top-left area (below HUD if present)
    draw.SimpleText("[" .. gang .. "]", "GWRP_Small", 10, 10, GWRP.Theme.Colors.Accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end)

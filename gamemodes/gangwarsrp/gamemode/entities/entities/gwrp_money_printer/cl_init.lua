-- GangWarsRP - Money Printer Entity (Client)

include("shared.lua")

function ENT:Draw()
    self:DrawModel()

    local pos = self:GetPos() + Vector(0, 0, 20)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Up(), -90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleText("Money Printer", "GWRP_Body", 0, -20, GWRP.Theme.Colors.TextPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        local stored = self:GetNWInt("GWRP_StoredMoney", 0)
        draw.SimpleText(GWRP.FormatMoney(stored), "GWRP_Header", 0, 10, GWRP.Theme.Colors.Money, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

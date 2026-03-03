-- GangWarsRP - Money Printer Entity (Server)

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/reciever01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then phys:Wake() end

    self:SetNWInt("GWRP_StoredMoney", 0)
    self:SetNWFloat("GWRP_PrintTime", CurTime() + 60)

    -- Print money periodically
    timer.Create("GWRP_Printer_" .. self:EntIndex(), 60, 0, function()
        if not IsValid(self) then return end
        local stored = self:GetNWInt("GWRP_StoredMoney", 0)
        local printAmount = 50 -- server-controlled amount
        self:SetNWInt("GWRP_StoredMoney", stored + printAmount)
        self:SetNWFloat("GWRP_PrintTime", CurTime() + 60)
    end)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if not GWRP.Security:ValidateEntityInteraction(activator, self, "gwrp_money_printer") then return end

    local stored = self:GetNWInt("GWRP_StoredMoney", 0)
    if stored <= 0 then return end

    if GWRP.Modules:IsEnabled("economy") then
        GWRP.Economy:AddMoney(activator, stored)
        GWRP.Notify(activator, "Collected " .. GWRP.FormatMoney(stored) .. " from printer", 1)
    end

    self:SetNWInt("GWRP_StoredMoney", 0)
    GWRP.Log(string.format("[ENTITY] %s collected %s from printer", activator:SteamID(), GWRP.FormatMoney(stored)), "info")
end

function ENT:OnRemove()
    timer.Remove("GWRP_Printer_" .. self:EntIndex())
end

ENT.Type = "anim"
ENT.Base = "base_entity"

ENT.PrintName = "Donut"
ENT.Author = "rtm516"
ENT.Category = "rtm516's stuff"
ENT.Spawnable = true
ENT.AdminOnly = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool",1,"PickedUp")
	self:NetworkVar("Float",1,"PickupTime")
end
ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName= "Monkey Ball"
ENT.Author= "BENIS TEAM"
ENT.Contact= "sndrec32exe@gmail.com"
ENT.Purpose= "Mombkey,,"
ENT.Instructions= "Use wisely."
ENT.Spawnable = true
ENT.AdminSpawnable = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool",1,"InPlay")
end
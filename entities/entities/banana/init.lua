AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/food/burger.mdl")
	self:PhysicsInit(MOVETYPE_NONE)
	self:SetSolid(MOVETYPE_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModelScale(4, 0)
end

function ENT:Think()
	for i, v in ipairs(player.GetAll()) do
		if v.ballEnt:IsValid() then
			if self:GetPos():Distance(v.ballEnt:GetPos()) <= 72 then
				self:Remove()
				-- banana collection code here pls
			end
		end
	end
	self:NextThink( CurTime() )
	return true
end

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:PhysicsInit(MOVETYPE_NONE)
	self:SetSolid(MOVETYPE_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetModelScale(4, 0)
	self:SetTrigger(true)
	self:UseTriggerBounds( true, 0 )
end

function ENT:Touch(ent)
	if ent:GetClass() == "ball" then
		print("hey")
		self:EmitSound("monkeyball/fx_banana.wav",80,100,0.5)
		self:GetOwner():AddMKBScore(1)
		self:Remove()
	end
end

function ENT:Think()
end

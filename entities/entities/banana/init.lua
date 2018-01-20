AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_junk/watermelon01.mdl")
	self:PhysicsInit(MOVETYPE_NONE)
	self:SetSolid(MOVETYPE_NONE)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
	self:SetModelScale(2, 0)
	self:SetTrigger(true)
	self:UseTriggerBounds( true, 16 )
	self:SetPickedUp(false)
	self:SetPickupTime(0)
end

function ENT:Touch(ent)
	if not self:GetPickedUp() and ent:GetClass() == "ball" then
		self:SetOwner(ent:GetOwner())
		self:EmitSound("monkeyball/fx_banana.wav",80,100,0.4)
		ent:GetOwner():AddMKBScore(10)
		self:SetPickedUp(true)
		self:SetPickupTime(CurTime())
		self:SetColor(Color(255,255,255,0))
		self:SetModelScale(0.01,1)
		timer.Simple(1, function()
			if self:IsValid() then
				self:Remove()
			end
		end)
	end
end

function ENT:Think()
end

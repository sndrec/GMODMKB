ENT.Type = "brush"
ENT.Base = "base_entity"

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetTrigger(true)
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "ball" then
		ent:GetOwner():SetNextLevelSpawn("bonus_start")
		ent:GetOwner():KillSilent()
		ent:GetOwner():Spawn()
		ent:Remove()
	end
end
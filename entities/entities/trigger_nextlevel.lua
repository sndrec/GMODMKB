ENT.Type = "brush"
ENT.Base = "base_entity"

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WORLD)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetTrigger(true)

	self.KeyValues = self.KeyValues or {}
end

function ENT:KeyValue(key, val)
	self.KeyValues = self.KeyValues or {}
	self.KeyValues[key] = val
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "ball" then
		//ent:GetOwner():SetTeam(TEAM_SPECTATOR)
		ent:GetOwner():SetNextLevelSpawn(self.KeyValues.target)
		ent:GetOwner():KillSilent()
		ent:GetOwner():Spawn()

		local relay = ents.FindByName(self.KeyValues.relay)[1]
		if (IsValid(relay)) then
			relay:Fire("Trigger")
		end

		ent:Remove()
	end
end
AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")

function ENT:Initialize( )
 
	self:SetModel( "models/props_trainstation/trashcan_indoor001b.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self.physObj = self:GetPhysicsObject()
end


function ENT:PhysicsCollide( data, physobj )

	if data.HitEntity:GetClass() == "br_ball" then
		local phys = data.HitEntity:GetPhysicsObject()
		local dir = (data.HitEntity:GetPos() - self:GetPos()):GetNormalized()
		dir.z = 0
		print(dir)
		local bumpVel = 600
		if phys:GetVelocity():Length() < 600 then
			phys:SetVelocity(dir * bumpVel)
		else
			phys:SetVelocity(dir * phys:GetVelocity():Length() * 1.25)
		end
	end

end

function ENT:Think()
end

function ENT:Use( activator, caller )
    return
end

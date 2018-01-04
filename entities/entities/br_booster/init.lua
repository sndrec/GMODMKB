AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")

function ENT:Initialize( )
	self:PhysicsInit( SOLID_NONE )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_NONE )
	if self.defined == nil then
		self.defined = false
	end
end

function ENT:DefineProperties(mins,maxs,dir,speed)

	self.mins = mins
	self.maxs = maxs
	self.dir = dir
	self.speed = speed
	self.defined = true

end

function ENT:Think()
	if self.defined then
		for i, v in ipairs(player.GetAll()) do
			local ball = v.ball
			if ball:IsValid() then
				if ball:GetPos():WithinAABox( self.mins, self.maxs ) then
					local phys = ball:GetPhysicsObject()
					phys:SetVelocity(phys:GetVelocity() + ((self.dir:Forward() * self.speed) * FrameTime()))
				end
			end
		end
	
		debugoverlay.Box( self.mins, Vector(0,0,0), self.maxs - self.mins, 0.02, Color( 255, 255, 255,20 ) )
		self:NextThink( CurTime() )
		return true
	end

end

function ENT:Use( activator, caller )
    return
end

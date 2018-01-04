AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")
util.AddNetworkString( "GetViewAngle" )
util.AddNetworkString( "SyncSkyCam" )

function ENT:Initialize( )
 
	self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
	self:PhysicsInitSphere( 25, "metal_bouncy" )
	self.physObj = self:GetPhysicsObject()
	self.groundTimer = 5
	self.spawnTime = CurTime()
	if CurSpawnAng then
		self.ballViewAng = CurSpawnAng
	end
	if (self.physObj:IsValid()) then
		self.physObj:Wake()
		self.physObj:SetMass( 200 )
		self.physObj:EnableGravity(false)
	end

	local skyCam = ents.FindByClass("sky_camera")[1]
	if skyCam and skyCam:IsValid() then
		net.Start("SyncSkyCam")
		net.WriteVector(skyCam:GetPos())
		net.Send(self:GetOwner())
	end
	self:SetCustomCollisionCheck(true)
	self:GetOwner():SetModelScale(0.75,0)

end


function ENT:PhysicsCollide( data, physobj )

	local oldVel = data.OurOldVelocity
	local hitNormal = data.HitNormal

	local dot = oldVel:Dot(hitNormal)

	if dot > 800 then
		print("large impact")
	elseif dot > 450 then
		print("med impact")
	elseif dot > 200 then
		print("small impact")
	end

	local impulse = dot * -1.5

	physobj:SetVelocity(oldVel + (impulse * hitNormal))
end

net.Receive( "GetViewAngle", function( len, pl )
	if ( IsValid( pl ) and pl:IsPlayer() ) then
		pl.ballEnt.ballViewAng = net.ReadAngle()
	end
end )

function ENT:Think()
	if not self:GetOwner():IsValid() then self:Remove() return end
	local pl = self:GetOwner()
	if pl:Health() <= 0 then
		self:Remove()
	end


	local plOldVel = pl:GetVelocity()
	local ballVel = self:GetVelocity()
	pl:SetVelocity(Vector(ballVel.x-plOldVel.x,ballVel.y-plOldVel.y,-plOldVel.z))

	--IN_BACK
	--IN_FORWARD
	--IN_MOVELEFT
	--IN_MOVERIGHT

	local onGround = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0,0,-40),
		filter = {self, pl}
		})

	if onGround.Hit then
		pl:SetPos(onGround.HitPos + Vector(0,0,32))
	else
		pl:SetPos(self:GetPos() + Vector(0,0,32))
	end

	--local hitColor = Color(255,0,0)
	--if onGround.Hit then
	--	hitColor = Color(0,255,0)
	--end
	--debugoverlay.Line( self:GetPos(), self:GetPos() + Vector(0,0,-40), 0.1, hitColor, true )
	--debugoverlay.Cross( onGround.HitPos, 16, 0.1, hitColor, true )

	local accelSpeed = 5
	if not onGround.Hit then
		accelSpeed = 5
	end

	local moveVector = Vector(0,0,0)
	local moveNormal = self:GetVelocity():Angle()
	moveNormal.p = 0

	local p = self.ballViewAng.p
	local y = self.ballViewAng.y
	local r = self.ballViewAng.r

	local tempVel = self:GetVelocity()
	if tempVel.z > 0 then
		tempVel.z = (tempVel.z / 2) - 50
	end

	p = math.ApproachAngle( p, tempVel:Angle().p, math.min(tempVel:Length() * (math.AngleDifference( p, tempVel:Angle().p ) / 180) * FrameTime(), 1000 * FrameTime()) )
	y = math.ApproachAngle( y, tempVel:Angle().y, math.min(tempVel:Length() * (math.AngleDifference( y, tempVel:Angle().y ) / 180) * FrameTime(), 1000 * FrameTime()) )
	r = math.ApproachAngle( r, tempVel:Angle().r, math.min(tempVel:Length() * (math.AngleDifference( r, tempVel:Angle().r ) / 180) * FrameTime(), 1000 * FrameTime()) )

	self.ballViewAng = Angle(p,y,r)

	local tempMove = self.ballViewAng
	tempMove.p = 0
	debugoverlay.Cross( self:GetPos() + tempMove:Forward() * 200, 16, 0.1, Color(255,255,255), true )

	moveVector = (self.moveData / 1000) * accelSpeed

	local oldEyeAng = pl:EyeAngles()
	local newEyeAng = self.ballViewAng
	pl:SetEyeAngles( Angle(oldEyeAng.p, newEyeAng.y, 0) )

	if onGround.Hit then
		local vel = self.physObj:GetVelocity()
		local frictionCoefficient = 0.70
		self.physObj:SetVelocity(vel / (1 + (frictionCoefficient * FrameTime())))
		--print("did friction")
		self.groundTimer = self.groundTimer + 1
		if self.groundTimer > 5 then
			self.groundTimer = 5
		end
	else
		self.groundTimer = 0
	end

	local gravDir = Vector(0,0,-9.8) + moveVector
	gravDir = gravDir:GetNormalized()
	self.physObj:SetVelocity(self.physObj:GetVelocity() + (gravDir * 1500 * FrameTime()))

	if self:GetPos():WithinAABox(propTable.goalVol.mins, propTable.goalVol.maxs) then
		self:GetOwner():ChatPrint("You beat the level.")
		self:Remove()
	end
	if self:GetPos().z < -7000 then
		self:Remove()
		timer.Simple(1, function()
			pl:SetTeam(TEAM_PLAYERS)
			pl:KillSilent()
			pl:Spawn()
		end)
	end
	self:NextThink( CurTime() )
	return true
end

function ENT:Use( activator, caller )
	return
end

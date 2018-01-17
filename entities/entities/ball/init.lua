AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")
util.AddNetworkString( "GetViewAngle" )
util.AddNetworkString( "SyncSkyCam" )
util.AddNetworkString( "Victory" )
resource.AddFile("maps/" .. game.GetMap() .. ".bsp")

function ENT:Initialize( )
 
	self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
	self:PhysicsInitSphere( 24, "gmod_ice" )
	self.physObj = self:GetPhysicsObject()
	self.groundTimer = 0
	self.spawnTime = CurTime()
	self.nextWarble = CurTime() + 0.5
	self.lastLanding = CurTime() + 1
	self.sparkTimer = CurTime() + 0.1
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
	self:GetOwner():SetModelScale(0.65,0)
	self:SetMaterial("models/props_lab/tank_glass002.vtf")
	self:SetColor(Color(200,255,255,255))
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)
    self:SetFriction(0.00001)

end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:PhysicsCollide( data, physobj )

	local oldVel = data.OurOldVelocity
	local hitNormal = data.HitNormal
	local newVel = physobj:GetVelocity()

	local dot = oldVel:Dot(hitNormal)
	if dot > 600 then
		local efdata = EffectData()
		efdata:SetOrigin(data.HitPos)
		efdata:SetRadius(25)
		efdata:SetNormal(-hitNormal)
		util.Effect("cball_bounce",efdata)
		local efdata2 = EffectData()
		efdata:SetMagnitude(2)
		efdata:SetRadius(2)
		efdata:SetScale(2)
		util.Effect("Sparks",efdata2)
		self:EmitSound("monkeyball/fx_ball_hit_hard.wav",80,math.random(95,105), 0.5)
	elseif dot > 400 then
		local efdata = EffectData()
		efdata:SetOrigin(data.HitPos)
		efdata:SetMagnitude(2)
		efdata:SetRadius(0.1)
		efdata:SetScale(2)
		efdata:SetNormal(-hitNormal)
		util.Effect("ElectricSpark",efdata)
		self:EmitSound("monkeyball/fx_ball_hit_med.wav",80,math.random(95,105), 0.5)
	elseif dot > 200 then
		self:EmitSound("monkeyball/fx_ball_hit_soft.wav",80,math.random(95,105), 0.5)
	end

	local mult = 0.25 + (math.min(math.max(dot - 200, 0), 500) / 2000)
	local impulse = dot * -mult

	physobj:SetVelocity(newVel + (impulse * hitNormal))
end

net.Receive( "GetViewAngle", function( len, pl )
	if IsValid( pl ) and pl:IsPlayer() and pl.ballEnt and pl.ballEnt:IsValid() then
		pl.ballEnt.ballViewAng = net.ReadAngle()
	end
end )

function ENT:CalcBallViewAng()
	local p = self.ballViewAng.p
	local y = self.ballViewAng.y
	local r = self.ballViewAng.r

	local tempVel = self:GetVelocity()
	if tempVel.z > 0 then
		tempVel.z = (tempVel.z / 1.5) - 50
	end
	if tempVel.z > -100 and tempVel.z < 100 then tempVel.z = 0 end
	local tempVelAngle = tempVel:Angle()

	if tempVel:Length() < 50 then
		tempVelAngle.p = 0
	end

	local len = tempVel:Length()
	local len2D = tempVel:Length()
	if CurTime() > self.spawnTime + 0.6 then
		tempVelAngle.p = math.Clamp(math.NormalizeAngle(tempVelAngle.p), -60, 60)
		p = math.ApproachAngle( p, tempVelAngle.p, math.max(len * math.abs(math.AngleDifference( p, tempVelAngle.p ) / 100) * FrameTime(), FrameTime() * math.abs(math.AngleDifference( p, tempVelAngle.p )) ) )
		offset = 1 - (math.sin((math.max(p, 0) / 120) * (math.pi / 2)) * 0.8)
	else
		p = -15
	end
	y = math.ApproachAngle( y, tempVelAngle.y, math.min(len2D * math.abs(math.AngleDifference( y, tempVelAngle.y ) / 45) * FrameTime(), 150 * FrameTime() ) )
	r = math.ApproachAngle( r, tempVelAngle.r, math.max(len2D * math.abs(math.AngleDifference( r, tempVelAngle.r ) / 180) * FrameTime(), 1 * FrameTime() ) )

	self.ballViewAng = Angle(p,y,r)
end

function ENT:Think()
	local pl = self:GetOwner()
	if not pl:IsValid() then self:Remove() return end
	if pl:Health() <= 0 then
		self:Remove()
	end
	self:CalcBallViewAng()
	if self.victory then
		if CurTime() < self.victoryTime + 1.75 then
			self.physObj:SetVelocity(self.physObj:GetVelocity() - (self.physObj:GetVelocity() * engine.TickInterval() * 3))
		else
			self.physObj:SetVelocity(self.physObj:GetVelocity() + Vector(0,0,2000 * engine.TickInterval()))
		end
		if CurTime() > self.victoryTime + 3.5 then
			net.Start("Victory")
			net.WriteBool(false)
			net.Send(pl)
			self:Remove()
		end
		self:NextThink( CurTime() )
		return true
	end

	local plOldVel = pl:GetVelocity()
	local ballVel = self:GetVelocity()
	pl:SetVelocity(Vector(ballVel.x-plOldVel.x,ballVel.y-plOldVel.y,-plOldVel.z))

	local onGround = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0,0,-40),
		filter = {self, pl}
		})

	pl:SetPos(self:GetPos() - Vector(0,0,23))

	local accelSpeed = 4.3
	local moveVector = Vector(0,0,0)
	local moveNormal = self:GetVelocity():Angle()
	moveNormal.p = 0

	local tempVel = self:GetVelocity()
	if tempVel.z > 0 then
		tempVel.z = (tempVel.z / 2) - 50
	end

	local tempMove = self.ballViewAng
	tempMove.p = 0
	debugoverlay.Cross( self:GetPos() + tempMove:Forward() * 200, 16, 0.1, Color(255,255,255), true )

	moveVector = self.moveData * accelSpeed

	local oldEyeAng = pl:EyeAngles()
	local newEyeAng = self.ballViewAng
	pl:SetEyeAngles( Angle(oldEyeAng.p, newEyeAng.y, 0) )

	local groundVel = Vector(0,0,0)

	if onGround.Hit then
		groundVel = onGround.Entity:GetVelocity()
		if self.groundTimer == 0 and CurTime() > self.lastLanding then
			self.lastLanding = CurTime() + 1
			self:EmitSound("monkeyball/fx_ball_initialroll.wav",75,100, 0.25)
			self:EmitSound("monkeyball/fx_ball_warble.wav",75,100, 0.35)
		end
		local vel = self.physObj:GetVelocity()
		local frictionCoefficient = 0.6
		self.physObj:SetVelocity(vel / (1 + (frictionCoefficient * engine.TickInterval())))
		self.groundTimer = self.groundTimer + engine.TickInterval()

		local speed = vel:Length()
		if CurTime() > self.nextWarble and self.groundTimer > 0.1 and speed > 100 then
			self:EmitSound("monkeyball/fx_ball_roll.wav",60,(speed * 0.075) + 50, 1)
			local warbleFormula = 1 / ((speed * 0.0036) + 1.5)
			self.nextWarble = CurTime() + warbleFormula
		end
		if self.groundTimer > 0.1 and speed > 950 and CurTime() > self.sparkTimer then
			self.sparkTimer = CurTime() + 0.05
			local inc = math.min((speed - 700) * 0.002, 1)
			local efdata = EffectData()
			efdata:SetOrigin(onGround.HitPos)
			efdata:SetMagnitude(1.4 + inc)
			efdata:SetRadius(1.4 + inc)
			efdata:SetScale(0.8 + inc)
			efdata:SetNormal(-vel:GetNormalized() * 10000)
			util.Effect("Sparks",efdata)
		end
	else
		self.groundTimer = 0
	end

	local gravDir = Vector(0,0,-9.8) + moveVector
	gravDir = gravDir:GetNormalized()
	self.physObj:SetVelocity(self.physObj:GetVelocity() + (gravDir * 1750 * engine.TickInterval()) + (groundVel * engine.TickInterval() * 0.65))

	local goalTrace = nil
	if not self.oldPos then
		self.oldPos = self:GetPos()
	else
		goalTrace = util.TraceLine({
			start = self.oldPos,
			endpos = self:GetPos(),
			collisiongroup = COLLISION_GROUP_PROJECTILE
		})
	end
	if goalTrace and goalTrace.Hit and goalTrace.Entity.goalTrigger then
		pl:ChatPrint("You beat the level.")
		local goal = goalTrace.Entity
		goal:EmitSound("monkeyball/fx_goaltape.wav",90,math.random(95,105), 1)
		for i, v in ipairs(player.GetAll()) do
			v:ChatPrint(pl:Nick() .. " beat the stage in " .. math.Round(roundInfo.curStageTime - (roundInfo.curTimer - CurTime()),2) - 1 .. " seconds.")
		end
		pl:ChatPrint("Your completion time from spawn was " .. math.Round(CurTime() - self.spawnTime, 2) - 0.60 .. " seconds.")
		WriteLeaderboardEntry(pl, roundInfo.curLevel, math.Round(CurTime() - self.spawnTime, 2) - 0.60)
		pl.victory = true
		self.victory = true
		self.victoryTime = CurTime()
		net.Start("Victory")
		net.WriteInt(1, 8)
		net.Send(pl)
		timer.Simple(1.75, function()
			net.Start("Victory")
			net.WriteInt(2, 8)
			net.Send(pl)
			self:EmitSound("monkeyball/fx_ball_woosh.wav",80,100, 0.4)
		end)
		timer.Simple(3.5, function()
			net.Start("Victory")
			net.WriteInt(0, 8)
			net.Send(pl)
		end)
	end

	self.oldPos = self:GetPos()
	if self:GetPos().z < roundInfo.fallOutZ then
		self:Remove()
		pl.nextSpawn = CurTime() + 1
	end
	self:NextThink( CurTime() )
	return true
end

function ENT:Use( activator, caller )
	return
end

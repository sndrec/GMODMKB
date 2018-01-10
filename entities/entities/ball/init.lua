AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")
util.AddNetworkString( "GetViewAngle" )
util.AddNetworkString( "SyncSkyCam" )

function ENT:Initialize( )
 
	self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
	self:PhysicsInitSphere( 24, "metal_bouncy" )
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

end

function ENT:PhysicsCollide( data, physobj )

	local oldVel = data.OurOldVelocity
	local hitNormal = data.HitNormal

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
		print("large impact")
		self:EmitSound("monkeyball/fx_ball_hit_hard.wav",80,math.random(95,105), 0.5)
	elseif dot > 400 then
		print("med impact")
		local efdata = EffectData()
		efdata:SetOrigin(data.HitPos)
		efdata:SetMagnitude(2)
		efdata:SetRadius(0.1)
		efdata:SetScale(2)
		efdata:SetNormal(-hitNormal)
		util.Effect("ElectricSpark",efdata)
		self:EmitSound("monkeyball/fx_ball_hit_med.wav",80,math.random(95,105), 0.5)
	elseif dot > 200 then
		print("small impact")
		self:EmitSound("monkeyball/fx_ball_hit_soft.wav",80,math.random(95,105), 0.5)
	end

	local mult = 1.25 + (math.min(math.max(dot - 200, 0), 500) / 2000)
	local impulse = dot * -mult

	physobj:SetVelocity(oldVel + (impulse * hitNormal))
end

net.Receive( "GetViewAngle", function( len, pl )
	if IsValid( pl ) and pl:IsPlayer() and pl.ballEnt and pl.ballEnt:IsValid() then
		pl.ballEnt.ballViewAng = net.ReadAngle()
	end
end )

function ENT:Think()
	local pl = self:GetOwner()
	if not pl:IsValid() then self:Remove() return end
	if pl:Health() <= 0 then
		self:Remove()
	end

	local plOldVel = pl:GetVelocity()
	local ballVel = self:GetVelocity()
	pl:SetVelocity(Vector(ballVel.x-plOldVel.x,ballVel.y-plOldVel.y,-plOldVel.z))

	local onGround = util.TraceLine({
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0,0,-40),
		filter = {self, pl}
		})

	pl:SetPos(self:GetPos() - Vector(0,0,25))

	local accelSpeed = 5
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

	moveVector = (self.moveData / 1000) * accelSpeed

	local oldEyeAng = pl:EyeAngles()
	local newEyeAng = self.ballViewAng
	pl:SetEyeAngles( Angle(oldEyeAng.p, newEyeAng.y, 0) )

	if onGround.Hit then
		if self.groundTimer == 0 and CurTime() > self.lastLanding then
			self.lastLanding = CurTime() + 1
			self:EmitSound("monkeyball/fx_ball_initialroll.wav",75,100, 0.25)
			self:EmitSound("monkeyball/fx_ball_warble.wav",75,100, 0.35)
		end
		local vel = self.physObj:GetVelocity()
		local frictionCoefficient = 0.60
		self.physObj:SetVelocity(vel / (1 + (frictionCoefficient * FrameTime())))
		self.groundTimer = self.groundTimer + FrameTime()

		local speed = vel:Length()
		if CurTime() > self.nextWarble and self.groundTimer > 0.1 and speed > 100 then
			self:EmitSound("monkeyball/fx_ball_roll.wav",60,(speed * 0.075) + 50, 1)
			local warbleFormula = 1 / ((speed * 0.0036) + 1.5)
			self.nextWarble = CurTime() + warbleFormula
			print( warbleFormula)
		end
		if self.groundTimer > 0.1 and speed > 700 and CurTime() > self.sparkTimer then
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
	self.physObj:SetVelocity(self.physObj:GetVelocity() + (gravDir * 1750 * FrameTime()))

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
	if goalTrace and goalTrace.Hit then
		pl:ChatPrint("You beat the level.")
		local goal = goalTrace.Entity
		goal:EmitSound("monkeyball/fx_goaltape.wav",90,math.random(95,105), 1)
		local effectData = EffectData()
		for i = 1, 4, 1 do
			effectData:SetOrigin(goal:GetPos() + Vector(0,0,60))
			util.Effect("balloon_pop",effectData)
		end
		for i, v in ipairs(player.GetAll()) do
			v:ChatPrint(pl:Nick() .. " beat the stage in " .. math.Round(roundInfo.curStageTime - (roundInfo.curTimer - CurTime()),2) .. " seconds.")
		end
		pl:ChatPrint("Your completion time from spawn was " .. math.Round(CurTime() - self.spawnTime, 2) - 0.60 .. " seconds.")
		pl.newPos = pl.ballEnt:GetPos() - (pl.ballEnt.ballViewAng:Forward() * 400) + Vector(0,0,80)
		self:Remove()
		pl:SetPos(pl.newPos)
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

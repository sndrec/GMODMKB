AddCSLuaFile( "cl_init.lua" ) -- Make sure clientside
AddCSLuaFile( "shared.lua" )  -- and shared scripts are sent.

include("shared.lua")

util.AddNetworkString("ServerDrawPos")
util.AddNetworkString("DoGoal")

function ENT:Initialize( )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self.partyBall = ents.Create("prop_physics")
	self.partyBall:SetModel("models/monkeyball/partyball.mdl")
	self.partyBall:SetPos(self:GetPos() + Vector(0,0,150))
	self.partyBall:SetAngles(self:GetAngles() + Angle(0,90,0))
	self.partyBall:Spawn()
	constraint.NoCollide(self.partyball,self)
	self.ballPhys = self.partyBall:GetPhysicsObject()
	self.ballPhys:EnableGravity(false)
end

function ENT:OnRemove()
	if self.partyBall and self.partyBall:IsValid() then
		self.partyBall:Remove()
	end
end

function ENT:DoGoal(pl)
	local plOldVel = pl:GetVelocity()
	pl:SetVelocity(Vector(-plOldVel.x,-plOldVel.y,-plOldVel.z))
	local clearTime = math.Round(CurTime() - pl.ballEnt.spawnTime, 2) - 0.60
	local timeFromRoundStart = math.Round(roundInfo.curStageTime - (roundInfo.curTimer - CurTime()),2) - 1
	local percentage = 0.5 + ((1 - (timeFromRoundStart / roundInfo.curStageTime)) * 0.5)
	print(percentage)
	pl:AddMKBScore(150 * self.goalType * percentage)
	pl:ChatPrint("You beat the level.")
	self:EmitSound("monkeyball/fx_goaltape.wav",90,math.random(95,105), 1)
	for i, v in ipairs(player.GetAll()) do
		v:ChatPrint(pl:Nick() .. " beat the stage in " .. math.Round(roundInfo.curStageTime - (roundInfo.curTimer - CurTime()),2) - 1 .. " seconds.")
	end
	CreateClientText(pl, "GOAL!", 4, "DermaScaleLarge", 0.5, 0.25, Color(150,255,150,255))
	CreateClientText(pl, clearTime .. " seconds", 4, "DermaScaleMed", 0.5, 0.35, Color(255,255,255,255))
	WriteLeaderboardEntry(pl, roundInfo.curLevel, clearTime)
	pl.victory = true
	pl.ballEnt.victory = true
	pl.ballEnt.victoryTime = CurTime()
	net.Start("Victory")
	net.WriteInt(1, 8)
	net.WriteInt(self.partyBall:EntIndex(), 16)
	net.Send(pl)
	timer.Simple(1.75, function()
		net.Start("Victory")
		net.WriteInt(2, 8)
		net.WriteInt(self.partyBall:EntIndex(), 16)
		net.Send(pl)
		pl.ballEnt:EmitSound("monkeyball/fx_ball_woosh.wav",80,100, 0.4)
	end)
	timer.Simple(3.5, function()
		net.Start("Victory")
		net.WriteInt(0, 8)
		net.WriteInt(self.partyBall:EntIndex(), 16)
		net.Send(pl)
	end)
end

function ENT:Think()
	local ballPos = self.ballPhys:GetPos()
	local ballAng = self.ballPhys:GetAngles()
	local forcePos = ballPos - (self.ballPhys:GetAngles():Up() * 43.75 * 2)
	ServerDrawPos(forcePos)
	self.ballPhys:ApplyForceOffset( Vector(0,0,-1000), forcePos )
	self.ballPhys:SetPos(self:GetPos() + (self:GetAngles():Up() * 150))
	self.ballPhys:SetAngles(Angle(ballAng.p, self:GetAngles().y - 90, ballAng.r))
	self:NextThink(CurTime())
	return true
end

function ServerDrawPos(pos)
	net.Start("ServerDrawPos")
	net.WriteVector(pos)
	net.Broadcast()
end
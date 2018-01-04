AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
	local scale = 3
	self:PhysicsInitSphere(15*scale, "default")
	//self:PhysicsInit(SOLID_VPHYSICS)
	//self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetModelScale(scale, 0)
	self:DrawShadow(false)

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
		phys:SetMass(50) //250
	end

	self:StartMotionController()
end

/*
function ENT:PhysicsUpdate()
	local ply = self:GetOwner()
	local ent = self
	local power = 8000*.5

	local aimYaw = Angle(0,ply:EyeAngles().y,0)
	local moveDir = Vector(0,0,0)
	local moved = false
	
	if (ply:KeyDown(IN_FORWARD)) then
		moveDir = moveDir + aimYaw:Forward()
		moved = true
	end
	if (ply:KeyDown(IN_BACK)) then
		moveDir = moveDir - aimYaw:Forward()
		moved = true
	end
	if (ply:KeyDown(IN_MOVERIGHT)) then
		moveDir = moveDir + aimYaw:Right()
		moved = true
	end
	if (ply:KeyDown(IN_MOVELEFT)) then
		moveDir = moveDir - aimYaw:Right()
		moved = true
	end

	if !moved then
		return
	end
	
	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then return end

	local center = ent:LocalToWorld(phys:GetMassCenter())

	moveDir:Normalize()

	phys:ApplyForceOffset(moveDir * power,center + Vector(0,0,1))
	phys:ApplyForceOffset(moveDir * -power,center + Vector(0,0,-1))
end
*/


/*
function ENT:PhysicsUpdate(phys)
	local ply = self:GetOwner()
	local ent = self
	local power = 300//8000*1

	//local phys = ent:GetPhysicsObject()
	//if !IsValid(phys) then return end

	local dir = 0

	local aimYaw = Angle(0,ply:EyeAngles().y,0)
	local moveDir = Vector(0,0,0)//phys:GetVelocity()//Vector(0,0,0)
	local moved = false
	
	if (ply:KeyDown(IN_FORWARD)) then
		moveDir = moveDir + aimYaw:Forward()
		moved = true
	end
	if (ply:KeyDown(IN_BACK)) then
		moveDir = moveDir - aimYaw:Forward()
		moved = true
	end
	if (ply:KeyDown(IN_MOVERIGHT)) then
		moveDir = moveDir + aimYaw:Right()
		moved = true
		dir = dir + 1
	end
	if (ply:KeyDown(IN_MOVELEFT)) then
		moveDir = moveDir - aimYaw:Right()
		moved = true
		dir = dir - 1
	end

	moveDir:Normalize()

	//moveDir = moveDir + self:GetNWVector("BoostVector", Vector(0, 0, 0))

	if !moved then
		return
	end

	local oldVel = phys:GetVelocity()

	local newVel = moveDir * power
	newVel.z = phys:GetVelocity().z

	local mult = 0.9

	if (!self:IsOnGround()) then
		mult = 0.8
	end

	local changed = false

	if newVel.x == 0 then
		newVel.x = oldVel.x * mult
		changed = true
	end

	if newVel.y == 0 then
		newVel.y = oldVel.y * mult
		changed = true
	end

	if (!changed) then
		newVel = newVel - ((aimYaw:Right() * (power/2))*dir)
	end

	phys:SetVelocity(newVel)
end
*/

/*
function ENT:PhysicsUpdate()
	local ply = self:GetOwner()
	local ent = self
	local power = 300//8000*.5

	local aimYaw = Angle(0,ply:EyeAngles().y,0)
	local moveDir = Vector(0,0,0)
	local moved = false
	
	if (ply:KeyDown(IN_FORWARD)) then
		moveDir = moveDir + aimYaw:Forward()
		moved = true
	end
	if (ply:KeyDown(IN_BACK)) then
		moveDir = moveDir - aimYaw:Forward()
		moved = true
	end
	if (ply:KeyDown(IN_MOVERIGHT)) then
		moveDir = moveDir + aimYaw:Right()
		moved = true
	end
	if (ply:KeyDown(IN_MOVELEFT)) then
		moveDir = moveDir - aimYaw:Right()
		moved = true
	end

	print(self.GettingPushed)

	if !moved or self.GettingPushed then
		return
	end
	
	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then return end

	local center = ent:LocalToWorld(phys:GetMassCenter())

	moveDir:Normalize()

	//phys:ApplyForceOffset(moveDir * power,center + Vector(0,0,1))
	//phys:ApplyForceOffset(moveDir * -power,center + Vector(0,0,-1))
	local newVel = moveDir * power
	local oldVel = phys:GetVelocity()
	newVel.z = oldVel.z

	local changed = false

	if newVel.x == 0 then
		newVel.x = oldVel.x * mult
		changed = true
	end

	if newVel.y == 0 then
		newVel.y = oldVel.y * mult
		changed = true
	end

	if (!changed) then
		newVel = newVel - ((aimYaw:Right() * (power/2))*dir)
	end

	phys:SetVelocity(LerpVector(0.5,oldVel,newVel))
end

function ENT:StartTouch(ent)
	if ent:GetClass() == "trigger_push" then
		self.GettingPushed = true
	end
end

function ENT:EndTouch(ent)
	if ent:GetClass() == "trigger_push" then
		self.GettingPushed = false
	end
end
*/

/*
function ENT:PhysicsUpdate()
	local ply = self:GetOwner()
	local ent = self
	local power = 1000//8000*.5

	local aimYaw = Angle(0,ply:EyeAngles().y,0)
	
	if (ply:KeyDown(IN_FORWARD)) then
		ent:SetLocalVelocity(aimYaw:Forward() * power)
	end
	if (ply:KeyDown(IN_BACK)) then
		ent:SetLocalVelocity(aimYaw:Forward() * -power)
	end
	if (ply:KeyDown(IN_MOVERIGHT)) then
		ent:SetLocalVelocity(aimYaw:Right() * power)
	end
	if (ply:KeyDown(IN_MOVELEFT)) then
		ent:SetLocalVelocity(aimYaw:Right() * -power)
	end
end
*/

function ENT:PhysicsSimulate(phys, deltatime)
	local ply = self:GetOwner()
	local ent = self
	local power = 300*50//8000*1

	local dir = 0

	local aimYaw = Angle(0,ply:EyeAngles().y,0)
	local moveDir = Vector(0,0,0)
	
	if (ply:KeyDown(IN_FORWARD)) then
		moveDir = moveDir + aimYaw:Forward()
	end
	if (ply:KeyDown(IN_BACK)) then
		moveDir = moveDir - aimYaw:Forward()
	end
	if (ply:KeyDown(IN_MOVERIGHT)) then
		moveDir = moveDir + aimYaw:Right()
	end
	if (ply:KeyDown(IN_MOVELEFT)) then
		moveDir = moveDir - aimYaw:Right()
	end

	moveDir:Normalize()

	local newVel = moveDir - Vector(0,0,0)

	return (newVel * power), (newVel * power), SIM_GLOBAL_FORCE

	//moveDir = moveDir + self:GetNWVector("BoostVector", Vector(0, 0, 0))

	/*
	if !moved then
		return
	end

	local oldVel = phys:GetVelocity()

	local newVel = moveDir * power
	newVel.z = phys:GetVelocity().z

	local mult = 0.9

	if (!self:IsOnGround()) then
		mult = 0.8
	end

	local changed = false

	if newVel.x == 0 then
		newVel.x = oldVel.x * mult
		changed = true
	end

	if newVel.y == 0 then
		newVel.y = oldVel.y * mult
		changed = true
	end

	if (!changed) then
		newVel = newVel - ((aimYaw:Right() * (power/2))*dir)
	end

	phys:SetVelocity(newVel)
	*/
end
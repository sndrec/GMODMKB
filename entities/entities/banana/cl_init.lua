include("shared.lua")

function ENT:Initialize()
	self.model = ClientsideModel("models/props_junk/watermelon01.mdl")
	self.model:SetNoDraw(true)
	self.model:SetModelScale(2,0)
	self.basePos = self:GetPos()
end

function ENT:Draw()
    local ang = self:GetAngles()
    if not self:GetPickedUp() then
    	self.model:SetPos(self.basePos + Vector(0,0,math.sin(CurTime() * 3) * 8))
    	self.model:SetAngles(Angle(0,(CurTime() * 180) % 360,0))
    	self.model.curPos = self.model:GetPos()
    	self.model.curAng = self.model:GetAngles()
    	self.model.lastEyePos = (self.model.curPos - _VIEWORIGIN):GetNormalized()
    	self.model.distSqr = (self.model.curPos - _VIEWORIGIN):LengthSqr()
    	self.model.lastEyeAngle = _VIEWANGLES
    elseif self.model:IsValid() and self:GetOwner() == LocalPlayer() then
    	self:SetRenderBounds(Vector(0,0,0),Vector(0,0,0),Vector(5000,5000,5000))
    	local lerp = math.sin((CurTime() - self:GetPickupTime()) * math.pi * 0.5)
    	local scorePos = _VIEWORIGIN + (EyeAngles():Forward() * 30) + (EyeAngles():Right() * -18) + (EyeAngles():Up() * -15)
    	print(lerp)
    	self.model:SetModelScale((1 - lerp) * 2, 0)
    	self.model:SetNoDraw(false)
    	local newDir = Vector(self.model.lastEyePos.x,self.model.lastEyePos.y,self.model.lastEyePos.z)
    	newDir:Rotate(_VIEWANGLES - self.model.lastEyeAngle)
    	self.model:SetPos(LerpVector(lerp,_VIEWORIGIN + (newDir * math.sqrt(self.model.distSqr)),scorePos))
    	self.model:SetAngles(self.model.curAng + Angle(0,lerp * 720, 0))
    else
    	self:SetNoDraw(true)
    end

    if self.model:IsValid() then
		self.model:DrawModel()
	end

end

function ENT:Think()
	if self:GetPickedUp() and CurTime() > self:GetPickupTime() + 1 then
		print("removing model")
    	self.model:Remove()
    end
end
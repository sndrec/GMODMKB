include("shared.lua")

function ENT:Initialize()
	self.model = ClientsideModel("models/props_junk/watermelon01.mdl")
	self.model:SetNoDraw(true)
	self.model:SetModelScale(1, 0)
end

function ENT:Draw()
	local pos = self:GetPos()
    local ang = self:GetAngles()

    local newPos = ang:Up() * (math.sin(CurTime() * 3) * 8)
    self.model:SetPos(pos + newPos)

    self.model:SetAngles(Angle(0,(CurTime() * 180) % 360,0))

	self.model:DrawModel()
end
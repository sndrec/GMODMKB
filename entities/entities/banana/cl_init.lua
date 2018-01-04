include("shared.lua")

function ENT:Initialize()
	self.model = ClientsideModel("models/food/burger.mdl")
	self.model:SetNoDraw(true)
	self.model:SetModelScale(4, 0)
end

function ENT:Draw()
	local pos = self:GetPos()
    local ang = self:GetAngles()

    local newPos = ang:Up() * (math.sin(CurTime() * 3) * 8)
    self.model:SetPos(pos + newPos)

    ang:RotateAroundAxis(ang:Up(), (CurTime() * 180) % 360)
    self.model:SetAngles(ang)

	self.model:DrawModel()
end
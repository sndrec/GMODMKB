include('shared.lua')

function ENT:Initialize()
	self:SetRenderBounds(Vector(-1024,-1024,-1024), Vector(1024,1024,1024), Vector(2048, 2048, 2048))
end

function ENT:Draw()
	if ClientBall:IsValid() then
		cam.Start3D(_VIEWORIGIN, _VIEWANGLES, 80)
		self:DrawModel()
		cam.End3D()
	else
		self:DrawModel()
	end
end

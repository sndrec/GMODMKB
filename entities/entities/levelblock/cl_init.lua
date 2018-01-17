include('shared.lua')

surface.CreateFont( "DermaHuge", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 72,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

surface.CreateFont( "DermaHuger", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 120,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
} )

function ENT:Initialize()
	self:SetRenderBounds(Vector(-1024,-1024,-1024), Vector(1024,1024,1024), Vector(2048, 2048, 2048))
end

function ENT:Draw()
	self.UIRenderAngle = self:GetAngles()
	self.UIRenderAngle:RotateAroundAxis(self:GetAngles():Forward(),90)
	self.UIRenderAngle:RotateAroundAxis(self:GetAngles():Up(),180)
	local time = string.FormattedTime( GetGlobalFloat( "worldtimer", 0 ) - CurTime(), "%00i:%02i:%02i" )
	self:DrawModel()
	cam.Start3D2D(self:GetPos() + (self:GetAngles():Up() * 26) + (self:GetAngles():Right() * -1),self.UIRenderAngle,0.25)
	if victory == 0 then
		surface.SetDrawColor(Color(80,80,150,255))
		surface.DrawRect( -160, -30, 320, 60 )
		surface.SetDrawColor(Color(180,180,180,255))
		surface.DrawRect( -160, -25, 320, 50 )
		draw.SimpleTextOutlined("GOAL","DermaHuge",0,0,Color(240,240,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(80,80,180))
	end
	draw.RoundedBox(32,-170, -570, 430, 130,Color(60,60,60,255))
	surface.SetDrawColor(Color(60,60,60,255))
	surface.DrawRect( 220, -530, 75, 90 )
	surface.DrawRect( 295, -500, 15, 60 )
	draw.SimpleTextOutlined(time,"DermaHuger",20, -505,Color(255,255,100),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0))
	cam.End3D2D()
end

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
	cam.Start3D2D(self:GetPos() + (self:GetAngles():Up() * 26 * 1.22) + (self:GetAngles():Right() * -1 * 1.22),self.UIRenderAngle,0.25)
	if victory == 0 then
		surface.SetDrawColor(Color(100,100,180,255))
		surface.DrawRect( -160 * 1.22, -30 * 1.22, 320 * 1.22, 60 * 1.22 )
		surface.SetDrawColor(Color(255,255,255,255))
		surface.DrawRect( -160 * 1.22, -25 * 1.22, 320 * 1.22, 50 * 1.22 )
		draw.SimpleTextOutlined("GOAL","DermaHuge",0,0,Color(240,240,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,3,Color(80,80,170))
	end
	draw.RoundedBox(32,-170 * 1.22, -570 * 1.22, 430 * 1.22, 130 * 1.22,Color(60,60,60,255))
	surface.SetDrawColor(Color(60,60,60,255))
	surface.DrawRect( 220 * 1.22, -530 * 1.22, 75 * 1.22, 90 * 1.22 )
	surface.DrawRect( 295 * 1.22, -500 * 1.22, 15 * 1.22, 60 * 1.22 )
	draw.SimpleTextOutlined(time,"DermaHuger",20 * 1.22, -505 * 1.22,Color(255,255,100),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0))
	cam.End3D2D()
end

LocalPlayer():ConCommand("r_3dsky 0")
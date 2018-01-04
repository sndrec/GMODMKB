function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudCrosshair", "CHudWeaponSelection"})do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "HUDShouldDrawHide", hidehud)


function draw.Heart(x, y, scale)
	scale = scale or 1
	local heart = {}

	for t=0,(2*scale*scale)*math.pi do
		table.insert(heart, {x=x+((4*math.pow(math.sin(t), 3))*-scale), y=y+((3*math.cos(t)-1.3*math.cos(2*t)-0.6*math.cos(3*t)-0.2*math.cos(4*t))*-scale)})
	end

	surface.DrawPoly(heart)
end

function GM:HUDPaint()
	local colors = {}
	colors.black = Color(0, 0, 0, 255)
	colors.blue = Color(0, 0, 255, 255)
	colors.brightred = Color(200, 30, 30, 255)
	colors.darkred = Color(0, 0, 70, 100)
	colors.darkblack = Color(0, 0, 0, 200)
	colors.gray1 = Color(0, 0, 0, 155)
	colors.gray2 = Color(51, 58, 51,100)
	colors.red = Color(255, 0, 0, 255)
	colors.white = Color(255, 255, 255, 255)
	colors.white1 = Color(255, 255, 255, 200)

	local LookEnt = LocalPlayer():GetEyeTrace().Entity
	if LookEnt:IsPlayer() then
		local pos = LookEnt:EyePos()

		pos.z = pos.z + 10
		pos = pos:ToScreen()
	
		local nick, plyTeam = LookEnt:Nick(), LookEnt:Team()
		draw.DrawText(nick, "Trebuchet24", pos.x + 1, pos.y + 1, colors.black, 1)
		draw.DrawText(nick, "Trebuchet24", pos.x, pos.y, team.GetColor(plyTeam) , 1)

		return true
	end
	if ClientBall ~= nil and ClientBall:IsValid() then
		draw.SimpleTextOutlined(math.Round(ClientBall:GetVelocity():Length() * 0.09144, 0) .. " KM/H","DermaLarge",ScrW() * 0.3,ScrH() * 0.7,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER,2,Color(0,0,0))
	end
	local time = string.FormattedTime( GetGlobalFloat( "worldtimer", 0 ) - CurTime(), "%02i:%02i:%02i" )
	draw.SimpleTextOutlined(time,"DermaLarge",ScrW()*0.5, ScrH()*0.1,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0))
end

function GM:InitPostEntity()
	RunConsoleCommand("cl_interp","0")
	RunConsoleCommand("cl_interp_ratio","0")
	RunConsoleCommand("rate","100000")
	RunConsoleCommand("cl_cmdrate","66")
	RunConsoleCommand("cl_updaterate","66")
	RunConsoleCommand("db_predrocket","0")
end

function GM:OnSpawnMenuOpen()
	return false
end


function GM:OnContextMenuOpen()
	return false
end
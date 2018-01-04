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

local worldMat = Material("monkeyball/icons8-globe-64.png", "mips smooth") // https://icons8.com/icon/63766/globe

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
	surface.SetFont("DermaLarge")

	if ClientBall ~= nil and ClientBall:IsValid() then
		local speedPlaceholderW, speedPlaceholderH = surface.GetTextSize("999 KM/H")
		draw.RoundedBoxEx(5, 0, ScrH() * 0.9-5, (speedPlaceholderW+20), speedPlaceholderH+10, Color(0, 0, 0, 200), false, true, false, true)
		draw.SimpleTextOutlined(math.Round(ClientBall:GetVelocity():Length() * 0.09144, 0) .. " KM/H","DermaLarge",speedPlaceholderW+10,ScrH() * 0.9,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_TOP,2,Color(0,0,0))
	end

	local timePlaceholderW, timePlaceholderH = surface.GetTextSize("99:99:99")

	draw.RoundedBoxEx(5, (ScrW()*0.5)-(timePlaceholderW+20), 0, (timePlaceholderW+20)*2, timePlaceholderH+10, Color(0, 0, 0, 200), false, false, true, true)

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetMaterial( worldMat )
	surface.DrawTexturedRect( (ScrW()*0.5)-(timePlaceholderW+20)+5, 5, timePlaceholderH, timePlaceholderH )
	surface.DrawTexturedRect( (ScrW()*0.5)-(timePlaceholderW+20)+(timePlaceholderW+20)*2-5-timePlaceholderH, 5, timePlaceholderH, timePlaceholderH )

	local lvlName = GetGlobalString("levelinfo", "MB_W1_L1")
	local lvlParts = string.Split(lvlName, "_")
	draw.SimpleTextOutlined(lvlParts[2] .. " - ".. lvlParts[3],"DermaLarge",ScrW()*0.5, 5, Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,Color(0,0,0))

	draw.RoundedBoxEx(5, (ScrW()*0.5)-((timePlaceholderW+20)/2), timePlaceholderH+10, timePlaceholderW+20, timePlaceholderH+10, Color(0, 0, 0, 200), false, false, true, true)

	local time = string.FormattedTime( GetGlobalFloat( "worldtimer", 0 ) - CurTime(), "%02i:%02i:%02i" )
	draw.SimpleTextOutlined(time,"DermaLarge",ScrW()*0.5, timePlaceholderH+5+10, Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,2,Color(0,0,0))
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
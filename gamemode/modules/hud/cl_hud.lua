function hidehud(name)
	for k, v in pairs({"CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudCrosshair", "CHudWeaponSelection"})do
		if name == v then return false end
	end
end
hook.Add("HUDShouldDraw", "HUDShouldDrawHide", hidehud)

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

surface.CreateFont( "DermaScaleSmall", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 0.033 * ScrH(),
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

surface.CreateFont( "DermaScaleMed", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 0.066 * ScrH(),
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

surface.CreateFont( "DermaScaleLarge", {
	font = "Roboto", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 0.1 * ScrH(),
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

function draw.Heart(x, y, scale)
	scale = scale or 1
	local heart = {}

	for t=0,(2*scale*scale)*math.pi do
		table.insert(heart, {x=x+((4*math.pow(math.sin(t), 3))*-scale), y=y+((3*math.cos(t)-1.3*math.cos(2*t)-0.6*math.cos(3*t)-0.2*math.cos(4*t))*-scale)})
	end

	surface.DrawPoly(heart)
end

local curScore = 0
local whiteMat = Material("vgui/white.vmt")

function GM:HUDPaint()

	for i, v in ipairs(player.GetAll()) do
		if v:Alive() and v:GetObserverMode() == OBS_MODE_NONE then
			render.SetLightingMode( 0 )
			if v ~= LocalPlayer() then
				local posTable = (v:GetPos() + Vector(0,0,30)):ToScreen()
				draw.SimpleTextOutlined(v:Nick(),"DermaLarge",posTable.x,posTable.y - 30,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0))	
			end
			if v.clientBall and v.clientBall:IsValid() then
				local crtWidth = ScrH() * 1.333
				local multiplier = 0.6
				local ratio = (((ScrW() / crtWidth) - 1) * multiplier) + 1
			cam.Start3D(EyePos(),EyeAngles(),ratio * 80)
			render.SetLightingMode( 1 )
				render.SetColorMaterial()
				render.DrawSphere(v.clientBall:GetPos(),26,32,32,Color(255,255,255,30))
				render.DrawSphere(v.clientBall:GetPos(),28,32,32,Color(255,255,255,30))
			cam.End3D()
			end
		end
	end
	render.SetLightingMode( 0 )

	if ClientBall ~= nil and ClientBall:IsValid() then
		draw.SimpleTextOutlined(math.Round(ClientBall:GetVelocity():Length() * 0.09144, 0) .. " KM/H","DermaScaleSmall",ScrW() * 0.3,ScrH() * 0.7,Color(255,255,255),TEXT_ALIGN_RIGHT,TEXT_ALIGN_CENTER,2,Color(0,0,0))
	else
		surface.SetDrawColor(0,0,0,255)
		surface.DrawRect((ScrW() * 0.5) - 2, (ScrH() * 0.5) - 2, 5, 5)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawRect((ScrW() * 0.5) - 1, (ScrH() * 0.5) - 1, 3, 3)
	end
	local time = string.FormattedTime( GetGlobalFloat( "worldtimer", 0 ) - CurTime(), "%02i:%02i:%02i" )
	draw.SimpleTextOutlined(time,"DermaScaleMed",ScrW()*0.5, ScrH()*0.1,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0))
	curScore = Lerp(((math.abs(LocalPlayer():GetMKBScore() - curScore)) + 35) * FrameTime() * 0.3,curScore,LocalPlayer():GetMKBScore())
	draw.SimpleTextOutlined("Score: " .. math.Round(curScore, 0),"DermaScaleMed",ScrW()*0.05, ScrH()*0.9,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_LEFT,2,Color(0,0,0))

	local size = ScrW() * 0.08
	local xPos = ScrW() * 0.25
	draw.RoundedBox(12, xPos - (size * 0.5), -12, size, size, Color(0, 0, 0, 100))
	draw.SimpleText("F3", "DermaLarge", xPos, size * 0.4, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("Leaderboards", "DermaDefault", xPos, (size * 0.4) + 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)


	local mouseJoyEnable = GetConVar( "mb_mousejoy" ):GetBool()
	if mouseJoyEnable then
		print("eyy")
		local mj = LocalPlayer():GetMouseJoy()
		cam.Start2D()
		render.SetColorMaterial()
		surface.SetDrawColor(0,0,0,100)
		surface.SetMaterial(whiteMat)
		local size = ScrH() * 0.15
		local visX = ScrW() - (size * 1.5)
		local visY = ScrH() - (size * 1.5)
		draw.Circle( visX, visY, size, size, 32 )
		surface.SetDrawColor(255,255,255,200)
		local x = mj.x * 0.00390625
		local y = mj.y * 0.00390625
		draw.Circle( visX + (x * size),  visY + (y * size), size * 0.04, size * 0.04, 8 )
		surface.SetDrawColor(255,80,80,200)
		draw.Circle( visX, visY, size * 0.05, size * 0.05, 12 )
		cam.End2D()
	end
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

net.Receive("CreateClientText", function()

	local textTable = {}
	textTable.text = net.ReadString()
	textTable.time = net.ReadFloat()
	textTable.spawnTime = CurTime()
	textTable.font = net.ReadString()
	textTable.x = net.ReadFloat()
	textTable.y = net.ReadFloat()
	textTable.color = net.ReadColor()
	table.insert(serverClientTextTable, textTable)

end)

serverClientTextTable = {}

net.Receive("CreateTip", function()

	--print("got tip")
	local textTable = {}
	textTable.text = net.ReadString()
	textTable.time = CurTime()
	table.insert(serverTipTextTable, textTable)

end)

serverTipTextTable = {}

hook.Add("HUDPaint", "DrawServerText", function()

	for i = #serverClientTextTable, 1, -1 do
		local fadeIn = math.min((CurTime() - serverClientTextTable[i].spawnTime) * 20, 1)
		local fadeOut = math.max(((CurTime() + 1) - serverClientTextTable[i].time) * 10, 0)
		local alpha = (fadeIn - fadeOut) * 255
		--print(fadeIn, fadeOut)
		draw.SimpleTextOutlined(serverClientTextTable[i].text,serverClientTextTable[i].font,ScrW() * serverClientTextTable[i].x,ScrH() * serverClientTextTable[i].y,Color(serverClientTextTable[i].color.r, serverClientTextTable[i].color.g, serverClientTextTable[i].color.b, alpha),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,2,Color(0,0,0, alpha))
		if CurTime() > serverClientTextTable[i].time then table.remove(serverClientTextTable, i) end
	end

end)

hook.Add("HUDPaint", "DrawTipText", function()

	local tipHeight = ScrH() * 0.3

	for i = #serverTipTextTable, 1, -1 do

		local slideIn = math.sin(math.min((CurTime() - serverTipTextTable[i].time) * 2, 1.571))
		local slideOut = math.sin(math.max((CurTime() - (serverTipTextTable[i].time + 5)) * 2, 0))
		local posX = -ScrW() + ((slideIn - slideOut) * ScrW())

		surface.SetFont( "DermaLarge" )
		local sx, sy = surface.GetTextSize( serverTipTextTable[i].text )
		local sx2, sy2 = surface.GetTextSize( "Tip:" )
		surface.SetDrawColor(0,0,0,160 * (slideIn - (slideOut * 3)))
		surface.DrawRect(0,tipHeight - (sy2 + 4) - 2,sx2 + 8,sy2 + 4)
		draw.SimpleText("Tip:","DermaLarge",2,tipHeight - (sy2 + 4),Color(255,255,255,255 * (slideIn - (slideOut * 3))),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		surface.SetDrawColor(0,0,0,160)
		surface.DrawRect(posX - 4,tipHeight - 2,sx + 8,sy + 4)
		draw.SimpleText(serverTipTextTable[i].text,"DermaLarge",posX,tipHeight,Color(255,255,255),TEXT_ALIGN_LEFT,TEXT_ALIGN_TOP)
		if CurTime() > serverTipTextTable[i].time + 5.5 then table.remove(serverTipTextTable, i) end
	end

end)
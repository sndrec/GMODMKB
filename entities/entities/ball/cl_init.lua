include('shared.lua')

skyCamPos = Vector(0,0,-14000)
_VIEWORIGIN = Vector(0,0,0)
_VIEWANGLES = Angle(0,0,0)
_VIEWANGLES_CLONE = Angle(0,0,0)
_ROTOFFSET = Angle(0,0,0)

function draw.Circle( x, y, radiusx, radiusy, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radiusx, y = y + math.cos( a ) * radiusy, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radiusx, y = y + math.cos( a ) * radiusy, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function ENT:OnRemove()

	--hook.Remove("PreDrawSkyBox", "A")
	--hook.Remove("PostDraw2DSkyBox", "A")
	--hook.Remove("PostDrawSkyBox", "A")

end

function ENT:Initialize()


	if self:GetOwner() == LocalPlayer() then
		self.rotAngle = Angle(0,0,0)
		self.spawnTime = CurTime()
		self.spawnPos = self:GetPos()
		ClientBall = self
		rotOffset = Angle(0,0,0)
		ballViewAng = Angle(0,0,0)
--	
--		local texture = GetRenderTarget('uniquert'..os.time(), 300, 300, false)
--		
--		local mat = CreateMaterial("uniquemat"..os.time(),"UnlitGeneric",{
--			['$basetexture'] = texture,
--		});		
--
--
--		local texture2 = GetRenderTarget('uniquert2'..os.time(), ScrW(), ScrH(), false)
--		
--		local mat2 = CreateMaterial("uniquemat2"..os.time(),"UnlitGeneric",{
--			['$basetexture'] = texture2,
--		});		
	end
	self:GetOwner():SetNoDraw(true)
	self:GetOwner().clientBall = self
	self.baseAngle = Angle(0,0,0)
	self.netTimer = CurTime() + 0.25

end

function ENT:Draw()

	local fakeVel = self:GetVelocity()
	self.baseAngle:RotateAroundAxis(-fakeVel:Angle():Right(),fakeVel:Length() * FrameTime() * 1.5)
	self:SetRenderAngles(self.baseAngle)
	if self:GetModelScale() ~= 1.75 then
		self:SetModelScale(1.75,0)
	end
	if self:GetOwner() == LocalPlayer() then
		local rotAngle = Angle(0,0,0)
		local rotAx = _VIEWANGLES_CLONE
		rotAx.p = 0
		rotAx.r = 0
		rotAngle:RotateAroundAxis(rotAx:Up(),_VIEWANGLES.y)
		rotAngle:RotateAroundAxis(rotAx:Forward(),_ROTOFFSET.r)
		rotAngle:RotateAroundAxis(rotAx:Right(),-_ROTOFFSET.p - ballViewAng.p - 15)
		self.rotAngle = rotAngle
		--cam.Start2D()
		--surface.SetDrawColor(0,0,0,150)
		--draw.Circle( 256, 256, 256, 256, 32 )
		--surface.SetDrawColor(255,255,255,255)
		--surface.DrawRect((self.SideMove * 2.56) + 256,(-self.ForwardMove * 2.56) + 256,8,8)
		--cam.End2D()
	else
		cam.Start2D()
		local posTable = (self:GetPos() + Vector(0,0,30)):ToScreen()
		draw.SimpleTextOutlined(self:GetOwner():Nick(),"DermaLarge",posTable.x,posTable.y - 30,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER,1,Color(0,0,0))
		cam.End2D()
	end
	self:DrawModel()

	if self:GetOwner().clientBall and self:GetOwner().clientBall == self and self:GetOwner().clientBall:IsValid() then
		self:GetOwner():SetPos(self:GetPos() - Vector(0,0,23))
		self:GetOwner():SetRenderOrigin(self:GetPos() - Vector(0,0,23))
		self:GetOwner():SetAngles(self:GetOwner():EyeAngles())
		self:GetOwner():DrawModel()
	end

end

function ENT:Think()
	if self:GetOwner() == LocalPlayer() and CurTime() > self.netTimer then
		self.netTimer = CurTime() + 0.05
		net.Start("GetViewAngle")
		net.WriteAngle(ballViewAng)
		net.SendToServer()
	end
end

local tiltIntensity = CreateConVar( "mb_tiltintensity", 0.15, FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE, "Intensity of world tilt when moving around the level." )
local camUp = CreateConVar( "mb_camUp", 50, FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE, "Upward camera offset" )
local camDistance = CreateConVar( "mb_camDistance", 200, FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE, "Camera Distance" )
victory = 0

net.Receive("Victory", function()
	victory = net.ReadInt(8)
end)

local function MyCalcView( pl, pos, angles, fov )
	local view = {}

	if victory == 1 then
		if ClientBall == nil or not ClientBall:IsValid() then return end

		local desiredAim = (ClientBall:GetPos() - _VIEWORIGIN):GetNormalized()
		local vel = ClientBall:GetVelocity()
		vel = -vel

		oldAng = desiredAim:Angle()
		newAng = LerpAngle(FrameTime() * math.min(vel:Length(), 750) * 0.01,oldAng,vel:Angle())

		_VIEWORIGIN = ClientBall:GetPos() - (newAng:Forward() * camDistance:GetFloat())
		_VIEWANGLES = newAng

		view.origin = _VIEWORIGIN
		view.angles = _VIEWANGLES
		view.fov = 80
		view.drawviewer = true
		return view
	elseif victory == 2 then
		if ClientBall == nil or not ClientBall:IsValid() then return end

		local desiredAim = (ClientBall:GetPos() - _VIEWORIGIN):GetNormalized()
		_VIEWANGLES = (desiredAim + (_VIEWANGLES:Forward() * 0.333)):Angle()

		view.origin = _VIEWORIGIN
		view.angles = _VIEWANGLES
		view.fov = 80
		view.drawviewer = true
		return view
	end
	local StartTime = GetGlobalFloat("LastStartTime", 0)

	if StartTime + 3.42 > CurTime() then
		local SpinCamOrigin = GetGlobalVector("SpinCamOrigin",Vector(0,0,0))
		local BallSpawnPos = GetGlobalVector("BallSpawnPos", Vector(0,0,0))
		local SpinCamDist = GetGlobalFloat("SpinCamDist", 1000)
		debugoverlay.Cross(SpinCamOrigin,32,0.05,Color( 255, 0, 0 ),true)
		local lerp = ((StartTime + 3.4) - CurTime()) / 3.4
		local smoothLerp = 1 - ((math.sin((math.Clamp(lerp * 1.5, 0, 1) * math.pi) - (math.pi * 0.5)) + 1) * 0.5)
		local smoothLerp2 = 1 - ((math.sin((math.Clamp(lerp * 1.1, 0, 1) * math.pi) - (math.pi * 0.5)) + 1) * 0.5)

		print(smoothLerp)
		local CamPosBase = SpinCamOrigin - (Angle(30,(lerp * 200) - 10,0):Forward() * ((SpinCamDist * 1) + (SpinCamDist * lerp * 0.25)))
		local CamAngle = Angle(30,(lerp * 200) - 10,0)
		local camupReal = camUp:GetFloat()
		local camsideReal = camDistance:GetFloat()

		local finalCamAngle = Angle(15,0,0)
		local finalCamPos = BallSpawnPos - ( finalCamAngle:Forward() * camsideReal) + ( finalCamAngle:Up() * camupReal ) - Vector(0,0,25)

		local lerpCamPos = LerpVector(smoothLerp2,CamPosBase,finalCamPos)
		local lerpCamAngle = LerpAngle(smoothLerp2,CamAngle,Angle(0,0,0))
		
		view.origin = lerpCamPos
		view.angles = lerpCamAngle
		view.fov = 80
		view.drawviewer = false
		return view
	elseif ClientBall == nil or not ClientBall:IsValid() then return end
	local ballVel = ClientBall:GetVelocity()

	rotOffset = Angle(rotOffset.p / ((10 * FrameTime()) + 1),rotOffset.y / ((16 * FrameTime()) + 1),rotOffset.r / ((16 * FrameTime()) + 1))
	
	if ClientBall.ForwardMove ~= nil then
		local rotP = -(ClientBall.ForwardMove * tiltIntensity:GetFloat() * 10) * FrameTime()
		local rotR = -(ClientBall.SideMove * tiltIntensity:GetFloat() * 10) * FrameTime()
	
		rotOffset = rotOffset + Angle(rotP,0,rotR)
	
		--print(ClientBall.ForwardMove, ClientBall.SideMove)
		--print(ClientBall.MoveData)
	end

	local p = ballViewAng.p
	local y = ballViewAng.y
	local r = ballViewAng.r

	--local tempAng1 = ballViewAng
	--local tempAng2 = LocalPlayer():EyeAngles()
	--tempAng2:Normalize()
	--tempAng1:Normalize()
	--if math.abs(math.abs(tempAng1.y) - math.abs(tempAng2.y)) > 5 then
	--	y = LocalPlayer():EyeAngles().y
	--end

	local tempVel = ballVel
	if tempVel.z > 0 then
		tempVel.z = (tempVel.z / 1.5) - 50
	end
	if tempVel.z > -100 and tempVel.z < 100 then tempVel.z = 0 end
	local tempVelAngle = tempVel:Angle()

	if tempVel:Length() < 50 then
		tempVelAngle.p = 0
	end

	local len = tempVel:Length()
	local len2D = tempVel:Length()
	local offset = 1
	if CurTime() > ClientBall.spawnTime + 0.6 then
		tempVelAngle.p = math.Clamp(math.NormalizeAngle(tempVelAngle.p), -60, 60)
		p = math.ApproachAngle( p, tempVelAngle.p, math.max(len * math.abs(math.AngleDifference( p, tempVelAngle.p ) / 100) * FrameTime(), FrameTime() * math.abs(math.AngleDifference( p, tempVelAngle.p )) ) )
		offset = 1 - (math.sin((math.max(p, 0) / 120) * (math.pi / 2)) * 0.8)
	else
		p = -15
	end
	y = math.ApproachAngle( y, tempVelAngle.y, math.min(len2D * math.abs(math.AngleDifference( y, tempVelAngle.y ) / 45) * FrameTime(), 150 * FrameTime() ) )
	r = math.ApproachAngle( r, tempVelAngle.r, math.max(len2D * math.abs(math.AngleDifference( r, tempVelAngle.r ) / 180) * FrameTime(), 1 * FrameTime() ) )

	local camupReal = camUp:GetFloat()
	local camsideReal = camDistance:GetFloat()
	local origin = ClientBall:GetPos()
	if CurTime() < ClientBall.spawnTime + 0.62 then
		origin = ClientBall.spawnPos + Vector(0,0,-200)
		camOffset = 0
	end
	debugoverlay.Cross(origin,16,0.1,Color( 255, 255, 255 ),true)
	local viewVec = origin - ( ClientBall.rotAngle:Forward() * camsideReal) + ( ClientBall.rotAngle:Up() * (camupReal * offset) )
	ballViewAng = Angle(p,y,r)
	view.origin = viewVec
	view.angles = Angle(0,ballViewAng.y,ballViewAng.r) + Angle(ClientBall.rotAngle.p,0,ClientBall.rotAngle.r)
	view.fov = 80
	view.drawviewer = true

	_VIEWORIGIN = view.origin
	_VIEWANGLES = ballViewAng + Angle(15,0,0)
	_VIEWANGLES_CLONE = ballViewAng + Angle(15,0,0)
	_ROTOFFSET = rotOffset

	return view
end

hook.Add( "CalcView", "MyCalcView", MyCalcView )
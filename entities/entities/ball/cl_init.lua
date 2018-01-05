include('shared.lua')

skyCamPos = Vector(0,0,-14000)


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
	self.baseAngle = Angle(0,0,0)

end

function ENT:Draw()

	local fakeVel = self:GetVelocity()
	self.baseAngle:RotateAroundAxis(-fakeVel:Angle():Right(),fakeVel:Length() * FrameTime() * 1.5)
	self:SetRenderAngles(self.baseAngle)
	if self:GetModelScale() ~= 1.8 then
		self:SetModelScale(1.8,0)
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
	end
	if ClientBall and ClientBall:IsValid() then
		cam.Start3D(_VIEWORIGIN, _VIEWANGLES, 80)
		self:DrawModel()
		cam.End3D()
	else
		self:DrawModel()
	end

end

function ENT:Think()
	if self:GetOwner() == LocalPlayer() then
		net.Start("GetViewAngle")
		net.WriteAngle(ballViewAng)
		net.SendToServer()
	end
end

local tiltIntensity = CreateConVar( "mb_tiltintensity", 0.15, FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE, "Intensity of world tilt when moving around the level." )
local camUp = CreateConVar( "mb_camUp", 70, FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE, "Upward camera offset" )
local camDistance = CreateConVar( "mb_camDistance", 120, FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE, "Camera Distance" )

local function MyCalcView( pl, pos, angles, fov )
	local view = {}

	--
	if ClientBall == nil or not ClientBall:IsValid() then return end
	local ballVel = ClientBall:GetVelocity()

	rotOffset = Angle(rotOffset.p / ((10 * FrameTime()) + 1),rotOffset.y / ((16 * FrameTime()) + 1),rotOffset.r / ((16 * FrameTime()) + 1))
	
	if ClientBall.ForwardMove ~= nil then
		local rotP = -(ClientBall.ForwardMove * tiltIntensity:GetFloat()) * FrameTime()
		local rotR = -(ClientBall.SideMove * tiltIntensity:GetFloat()) * FrameTime()
	
		rotOffset = rotOffset + Angle(rotP,0,rotR)
	
		--print(ClientBall.ForwardMove, ClientBall.SideMove)
		--print(ClientBall.MoveData)
	end

	pl:SetPos(ClientBall:GetPos() - Vector(0,0,32))

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
	if CurTime() < ClientBall.spawnTime + 0.6 then
		origin = ClientBall.spawnPos + Vector(0,0,-200)
		camOffset = 0
	end
	debugoverlay.Cross(origin,16,0.1,Color( 255, 255, 255 ),true)
	local viewVec = origin - ( ClientBall.rotAngle:Forward() * camsideReal) + ( ClientBall.rotAngle:Up() * (camupReal * offset) )
	ballViewAng = Angle(p,y,r)
	view.origin = viewVec
	view.angles = ballViewAng + Angle(15,0,0)
	view.fov = 80
	view.drawviewer = true

	_VIEWORIGIN = view.origin
	_VIEWANGLES = Angle(0,ballViewAng.y,ballViewAng.r) + Angle(ClientBall.rotAngle.p,0,ClientBall.rotAngle.r)
	_VIEWANGLES_CLONE = ballViewAng + Angle(15,0,0)
	_ROTOFFSET = rotOffset

	return view
end

hook.Add( "CalcView", "MyCalcView", MyCalcView )
function GM:Move(pl, move)
end

function GM:SetupMove(pl, mv, cmd)

	local x, y = (cmd:GetMouseX() * 1), (cmd:GetMouseY() * 1)

	local mouseJoy = pl:GetMouseJoy()
	mouseJoy.x = math.Clamp(mouseJoy.x + x, -256, 256)
	mouseJoy.y = math.Clamp(mouseJoy.y + y, -256, 256)
	local len = mouseJoy:LengthSqr()
	if len > 65536 then
		mouseJoy = mouseJoy:GetNormalized() * 256
	end
	pl:SetMouseJoy(mouseJoy)
	if cmd:KeyDown( IN_ATTACK ) then
		pl:SetMouseJoy(Vector(0,0,0))
	end

end

if CLIENT then
	CreateConVar( "mb_mousejoy", 0, FCVAR_ARCHIVE + FCVAR_CLIENTCMD_CAN_EXECUTE + FCVAR_USERINFO, "Enable pseudo-joystick controlled by the mouse." )
end

function GM:FinishMove( pl, move )
	move:SetMaxClientSpeed( 100 )
	--print(move:GetForwardSpeed(), move:GetSideSpeed(), move:GetUpSpeed())
	if SERVER then
		local mouseJoy = tobool(pl:GetInfo( "mb_mousejoy"))
		if not pl:Alive() and pl.ballEnt and pl.ballEnt:IsValid() then
			pl.ballEnt:Remove()
			pl.ballEnt = nil
			return
		end
		if pl.ballEnt ~= nil and pl.ballEnt:IsValid() then
			if CurTime() > pl.ballEnt.spawnTime + 0.62 then
				if mouseJoy then
					local mj = pl:GetMouseJoy()
					if mj:LengthSqr() < 100 then
						mj:Zero()
					end
					local nf = mj.y * -0.390625
					local ns = mj.x * 0.390625
					move:SetForwardSpeed(nf)
					move:SetSideSpeed(ns)
				end
				local forwardMove = math.Clamp(move:GetForwardSpeed() * 0.01 * 1.15, -1, 1)
				local sideMove = math.Clamp(move:GetSideSpeed() * 0.01 * 1.15, -1, 1)
				sideMove = (sideMove * 0.9) * (math.max(math.abs(forwardMove), 0.75) * 1.4)
				if forwardMove < 0 then
					forwardMove = forwardMove * math.max(math.abs(sideMove * 1.2), 0.66)
				end
				local baseMove = (pl.ballEnt.ballViewAng:Forward() * forwardMove) + (pl.ballEnt.ballViewAng:Right() * sideMove * 0.8)
				local modifier = math.sin(math.pi * baseMove:GetNormalized():Dot(pl.ballEnt.ballViewAng:Forward()))
				modifier = math.max((modifier * 0.5) + 1, 1)
				modifier = (modifier - 0.2) * 1.25
				--print(modifier)
				pl.ballEnt.moveData = baseMove * modifier
				move:SetAngles(pl.ballEnt.ballViewAng)
			else
				pl.ballEnt.moveData = Vector(0,0,0)
			end
		end
	elseif CLIENT then
		local mouseJoy = GetConVar( "mb_mousejoy" ):GetBool()
			if mouseJoy then
				local mj = pl:GetMouseJoy()
				local nf = mj.y * -0.390625
				local ns = mj.x * 0.390625
				move:SetForwardSpeed(nf)
				move:SetSideSpeed(ns)
			end
		if ClientBall ~= nil and ClientBall:IsValid() and CurTime() > ClientBall.spawnTime + 0.62 then
			if not pl:Alive() then
				ClientBall:Remove()
				ClientBall = nil
				return
			end
			ClientBall.MoveData = (ballViewAng:Forward() * move:GetForwardSpeed()) + (ballViewAng:Right() * move:GetSideSpeed())
			ClientBall.SideMove = move:GetSideSpeed()
			ClientBall.ForwardMove = move:GetForwardSpeed()
		end
	end
end

function GM:PlayerFootstep( pl, pos, foot, soundChoice, volume, filter )
	return true
end

function GM:PlayerNoClip( pl, state )
	return false
end
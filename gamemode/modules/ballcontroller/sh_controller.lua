function GM:Move(pl, move)
end

function GM:FinishMove( pl, move )
	move:SetMaxClientSpeed( 100 )
	--print(move:GetForwardSpeed(), move:GetSideSpeed(), move:GetUpSpeed())
	if SERVER then
		if not pl:Alive() and pl.ballEnt and pl.ballEnt:IsValid() then
			pl.ballEnt:Remove()
			pl.ballEnt = nil
			return
		end
		if pl.ballEnt ~= nil and pl.ballEnt:IsValid() then
			if CurTime() > pl.ballEnt.spawnTime + 0.62 then
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
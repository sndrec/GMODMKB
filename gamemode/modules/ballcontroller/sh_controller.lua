function GM:FinishMove( pl, move )
	move:SetMaxClientSpeed( 1000 )
	--print(move:GetForwardSpeed(), move:GetSideSpeed(), move:GetUpSpeed())
	if SERVER then
		if not pl:Alive() and pl.ballEnt then
			pl.ballEnt:Remove()
			pl.ballEnt = nil
			return
		end
		if pl.ballEnt ~= nil and pl.ballEnt:IsValid() then
			if CurTime() > pl.ballEnt.spawnTime + 0.65 then
				local baseMove = (pl.ballEnt.ballViewAng:Forward() * move:GetForwardSpeed()) + (pl.ballEnt.ballViewAng:Right() * move:GetSideSpeed() * 0.8)
				local modifier = math.sin(math.pi * baseMove:GetNormalized():Dot(pl.ballEnt.ballViewAng:Forward()))
				modifier = math.max((modifier * 0.5) + 1, 1)
				pl.ballEnt.moveData = baseMove * modifier
			else
				pl.ballEnt.moveData = Vector(0,0,0)
			end
		end
	elseif CLIENT then
		if ClientBall ~= nil and ClientBall:IsValid() and CurTime() > ClientBall.spawnTime + 0.65 then
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
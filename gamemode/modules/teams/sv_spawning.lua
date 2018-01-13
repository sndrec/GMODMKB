function GM:PlayerSpawn(pl)
	if not CurSpawnPos then return end
	if not pl.playing then
		pl:SetObserverMode(OBS_MODE_ROAMING)
		pl:SetPos(Vector(0,0,500))
		return
	end
	pl.nextSpawn = nil
	pl:SetObserverMode(OBS_MODE_NONE)
	pl:SetTeam(TEAM_PLAYERS)
	local ball = ents.Create("ball")
	local trace = util.TraceLine({
		start = CurSpawnPos,
		endpos = CurSpawnPos + Vector(0,0,-10000)
	})
	print(trace.HitPos)
	ball:SetPos(trace.HitPos + Vector(0,0,225))
	ball:SetAngles(CurSpawnAng)
	ball:SetOwner(pl)
	ball:SetCustomCollisionCheck( true )
	pl.ballEnt = ball
	ball:Spawn()
	ball.ballViewAng = CurSpawnAng
	pl:SetMaxSpeed( 100 )
	pl:SetWalkSpeed( 100 )
	pl:SetRunSpeed( 100 )
	ball:SetCustomCollisionCheck(true)

	--pl:SetRenderMode(RENDERMODE_NONE)
	pl:DeleteOnRemove(ball)

	--pl:Spectate(OBS_MODE_CHASE)
	--pl:SpectateEntity(ball)

	pl:SetMoveType(MOVETYPE_NONE)
	pl:SetSolid(SOLID_NONE)

	pl:GodEnable()
	pl:SetArmor(0)
	pl:StripWeapons()
	pl:RemoveAllAmmo()
	if pl:FlashlightIsOn() then
		pl:Flashlight(false)
	end
	for i, v in ipairs(ents.FindByModel("models/monkeyball/goalTrigger.mdl")) do
		constraint.NoCollide( pl.ballEnt, v, 0, 0 )
	end
	pl:SetModel("models/kleiner.mdl")
	pl:SetNoDraw(true)
end

function GM:PlayerInitialSpawn(pl)
	self:PlayerSpawnAsSpectator(pl)
end

function GM:PlayerDeathSound()
	return true
end

concommand.Add("spawn_ball", function(pl)
	for k,v in pairs(ents.FindByClass("ball")) do
		if v:GetOwner() == pl then
			v:Remove()
		end
	end
	pl:SetTeam(TEAM_PLAYERS)
	pl:KillSilent()
	pl:Spawn()
end)

concommand.Add("remove_ball", function(pl)
	for k,v in pairs(ents.FindByModel("models/XQM/Rails/gumball_1.mdl")) do
		v:Remove()
	end
end)

concommand.Add("pos_ball", function(pl, cmd, args)
	if table.Count(args) == 3 then
		pl:GetObserverTarget():SetPos(Vector(args[1], args[2], args[3]))
	end
end)

hook.Add("ShouldCollide", "ShouldCollideBall", function(ent1, ent2)
	if ((ent1:GetClass() == "ball") && (ent2:GetClass() == "ball")) then
		return false
	end
end)
local plyMeta = FindMetaTable("Player")

function plyMeta:UpdateSpectateEntity()
	if ((self.SpectateEntityID <= 0) or (self.SpectateEntityID > team.NumPlayers(TEAM_PLAYERS))) then
		self.SpectateEntityID = team.NumPlayers(TEAM_PLAYERS)
	end

	self:SetNWEntity("SpectatePlayer", team.GetPlayers(TEAM_PLAYERS)[self.SpectateEntityID])
end

hook.Add("KeyPress", "KeyPressSpectator", function(ply, key)
	if ply:Team() == TEAM_SPECTATOR then
		if (key == IN_JUMP && IsPlayersLeft()) then
			if ply:GetObserverMode() == OBS_MODE_CHASE then
				ply:UnSpectate()
				ply:Spectate(OBS_MODE_ROAMING)
			else
				ply:UnSpectate()
				ply:Spectate(OBS_MODE_CHASE)
				ply:UpdateSpectateEntity()
				ply:SpectateEntity(ply:GetSpectatePlayer():GetObserverTarget())
			end
		elseif (key == IN_ATTACK) then
			ply.SpectateEntityID = ply.SpectateEntityID + 1
			ply:UpdateSpectateEntity()
		elseif (key == IN_ATTACK2) then
			ply.SpectateEntityID = ply.SpectateEntityID - 1
			ply:UpdateSpectateEntity()
		end
	end
end)

hook.Add("PlayerInitialSpawn", "PlayerInitialSpawnSetupSpectate", function(ply)
	ply.SpectateEntityID = 1
	ply:UpdateSpectateEntity()
end)

hook.Add("Think", "ThinkSpectate", function()
	for _,ply in pairs(team.GetPlayers(TEAM_SPECTATOR)) do
		if ply:GetObserverMode() == OBS_MODE_CHASE then
			if !IsPlayersLeft() then
				ply:UnSpectate()
				ply:Spectate(OBS_MODE_ROAMING)
			elseif IsValid(ply:GetSpectatePlayer()) then
				ply:SpectateEntity(ply:GetSpectatePlayer():GetObserverTarget())
			end	
		end
	end
end)
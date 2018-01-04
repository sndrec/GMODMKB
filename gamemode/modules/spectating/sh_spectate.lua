local plyMeta = FindMetaTable("Player")

function plyMeta:GetSpectatePlayer()
	return self:GetNWEntity("SpectatePlayer")
end

function IsPlayersLeft()
	return (team.NumPlayers(TEAM_PLAYERS) >= 1)
end
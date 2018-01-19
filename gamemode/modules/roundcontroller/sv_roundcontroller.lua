STATE_WAITINGFORPLAYERS = 0
STATE_ROUNDSTARTING = 1
STATE_ROUNDACTIVE = 2
STATE_LEVELTRANSITION = 3
STATE_GAMEOVER = 4

local roundTimers = {}
roundTimers[STATE_WAITINGFORPLAYERS] = 1
roundTimers[STATE_LEVELTRANSITION] = 1

local startLevel = "MB_W1_L1"

-- high poly stage for testing: MB_W1_L28

roundInfo = {}
roundInfo.curLevel = startLevel
roundInfo.curState = STATE_WAITINGFORPLAYERS
roundInfo.curTimer = CurTime() + roundTimers[roundInfo.curState]
roundInfo.curStageTime = 0
roundInfo.stageCount = 0
roundInfo.fallOutZ = -2000

SetGlobalVector("SpinCamOrigin",Vector(0,0,0))
SetGlobalVector("BallSpawnPos", Vector(0,0,0))
SetGlobalFloat("SpinCamDist",0)

function GM:Tick()
	local pls = player.GetAll()
	if CurTime() > roundInfo.curTimer then
		local newLevelTimer = 60
		if propTable and propTable.levelTimer then
			newLevelTimer = propTable.levelTimer
		end
		if roundInfo.curState == STATE_WAITINGFORPLAYERS then
			LoadLevel(roundInfo.curLevel)
			roundInfo.curState = STATE_ROUNDSTARTING
			roundInfo.curTimer = CurTime() + 5
			for i, v in ipairs(pls) do
				v:ChatPrint("Current level: " .. roundInfo.curLevel)
				if v.ballEnt and v.ballEnt:IsValid() then
					v.ballEnt:Remove()
				end
				v:SetMKBScore(0)
				self:PlayerSpawnAsSpectator(v)
			end
		elseif roundInfo.curState == STATE_ROUNDACTIVE then
			roundInfo.curState = STATE_LEVELTRANSITION
			roundInfo.curTimer = CurTime() + roundTimers[STATE_LEVELTRANSITION]
			for i, v in ipairs(pls) do
				v:ChatPrint("Level complete.")
				if v.ballEnt and v.ballEnt:IsValid() then
					v.ballEnt:Remove()
				end
				v.nextSpawn = nil
				self:PlayerSpawnAsSpectator(v)
			end
		elseif roundInfo.curState == STATE_LEVELTRANSITION then
			for i, v in ipairs(pls) do
				if v.ballEnt and v.ballEnt:IsValid() then
					v.ballEnt:Remove()
				end
				v.nextSpawn = nil
				self:PlayerSpawnAsSpectator(v)
			end
			if propTable.nextLevel then
				roundInfo.curLevel = propTable.nextLevel
				LoadLevel(roundInfo.curLevel)
				roundInfo.curState = STATE_ROUNDSTARTING
				roundInfo.curTimer = CurTime() + 5
				for i, v in ipairs(pls) do
					v:ChatPrint("Current level: " .. roundInfo.curLevel)
				end
			else
				for i, v in ipairs(pls) do
					v:ChatPrint("World complete!")
				end
				roundInfo.stageCount = 0
				roundInfo.curTimer = CurTime() + 5
				roundInfo.curState = STATE_GAMEOVER
			end
		elseif roundInfo.curState == STATE_ROUNDSTARTING then
			roundInfo.stageCount = roundInfo.stageCount + 1
			-- HERE IS WHERE THE ROUND BEGINS --
			CreateClientText(nil, "Floor " .. roundInfo.stageCount, 4, "DermaScaleLarge", 0.5, 0.25, Color(255,255,255,255))
			CreateClientText(nil, "WR:", 5, "DermaScaleMed", 0.15, 0.1, Color(255,255,255))
			CreateClientText(nil, "___", 5, "DermaScaleMed", 0.15, 0.11, Color(255,255,255))
			local WRTable = RetrieveWR(roundInfo.curLevel)
			CreateClientText(nil, WRTable.clearTime .. "s by " .. WRTable.nick, 5, "DermaScaleSmall", 0.15, 0.165, Color(255,255,255))
			for i, v in ipairs(pls) do
				local PBTable = RetrievePB(roundInfo.curLevel, v)
				CreateClientText(v, "Personal Best", 5, "DermaScaleMed", 0.8, 0.1, Color(255,255,255))
				CreateClientText(v, "_____________", 5, "DermaScaleMed", 0.8, 0.11, Color(255,255,255))
				if type(PBTable) == "table" then
					CreateClientText(v, PBTable.clearTime .. "s", 5, "DermaScaleSmall", 0.8, 0.165, Color(255,255,255))
				else
					CreateClientText(v, "N/A", 5, "DermaScaleSmall", 0.8, 0.165, Color(255,255,255))
				end
			end
			if propTable.stageName then
				CreateClientText(nil, propTable.stageName, 4, "DermaScaleMed", 0.5, 0.75, Color(255,255,255,255))
			end
			roundInfo.curState = STATE_ROUNDACTIVE
			roundInfo.curTimer = CurTime() + newLevelTimer + 3
			roundInfo.curStageTime = newLevelTimer
			allCompleteTimer = 0
			lastStartTime = CurTime()
			SetGlobalFloat("LastStartTime", CurTime())
			local stagePieces = ents.FindByClass("sent_meshtools")
			local bounds = nil
			local origin = nil
			local dist = nil
			for i, v in ipairs(stagePieces) do
				v.spawnTime = CurTime()
				local mins, maxs = v:GetCollisionBounds()
				local tempx = mins.x
				local tempy = mins.y
				local tempz = mins.z
				mins.x = tempx
				mins.y = -tempz
				mins.z = tempy
				tempx = maxs.x
				tempy = maxs.y
				tempz = maxs.z
				maxs.x = tempx
				maxs.y = -tempz
				maxs.z = tempy
				origin = (mins + maxs) * 0.5
				bounds = origin + maxs
				dist = origin:Distance(maxs) * 2
				print(mins, maxs)
			end
			print("Starting Cam Info\n-------------")
			print(origin)
			print(dist)
			print("------------")
			SetGlobalVector("SpinCamOrigin",origin + Vector(0,0,-bounds.z * 0.5))
			local trace = util.TraceLine({
				start = CurSpawnPos,
				endpos = CurSpawnPos + Vector(0,0,-10000)
			})
			SetGlobalVector("BallSpawnPos", trace.HitPos)
			SetGlobalFloat("SpinCamDist", dist)
			roundInfo.fallOutZ = origin.z - (math.abs(bounds.z * 1.25) + 200)
			timer.Simple(3.4, function()
				for i, v in ipairs(pls) do
					v.nextSpawn = nil
					v.playing = true
					v:Spawn()
				end
			end)
		elseif roundInfo.curState == STATE_GAMEOVER then
			-- THIS IS JUST TEMPORARY FOR TESTING --
			roundInfo.curState = STATE_WAITINGFORPLAYERS
			roundInfo.curLevel = startLevel
			roundInfo.curTimer = CurTime() + roundTimers[roundInfo.curState]
			for i, v in ipairs(pls) do
				v:ChatPrint("Restarting world")
			end
		end
	end
	SetGlobalFloat( "worldtimer", roundInfo.curTimer )
	if roundInfo.curState == STATE_ROUNDACTIVE then
		local hasntCompleted = 0
		for i, v in ipairs(pls) do
			if v.ballEnt and v.ballEnt:IsValid() then
				hasntCompleted = hasntCompleted + 1
			else
				if v:GetObserverMode() == OBS_MODE_NONE then
					self:PlayerSpawnAsSpectator(v)
				end
			end
			if v:GetObserverMode() ~= OBS_MODE_NONE and v.nextSpawn and CurTime() > v.nextSpawn then
				v:Spawn()
				v.nextSpawn = nil
			end
		end
		if hasntCompleted == 0 and CurTime() > lastStartTime + 3 then
			if not allCompleteTimer then allCompleteTimer = 0 end
			allCompleteTimer = allCompleteTimer + FrameTime()
			if allCompleteTimer > 1 then
				roundInfo.curTimer = CurTime()
				for i, v in ipairs(pls) do
					v:ChatPrint("Everyone beat the level.")
				end
			end
		else
			allCompleteTimer = 0
		end
	end
end
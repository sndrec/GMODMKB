STATE_WAITINGFORPLAYERS = 0
STATE_ROUNDSTARTING = 1
STATE_ROUNDACTIVE = 2
STATE_LEVELTRANSITION = 3
STATE_GAMEOVER = 4

local roundTimers = {}
roundTimers[STATE_WAITINGFORPLAYERS] = 5
roundTimers[STATE_LEVELTRANSITION] = 5

local roundInfo = {}
roundInfo.curLevel = "MB_W1_L1"
roundInfo.curState = STATE_WAITINGFORPLAYERS
roundInfo.curTimer = CurTime() + roundTimers[roundInfo.curState]

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
				self:PlayerSpawnAsSpectator(v)
			end
		elseif roundInfo.curState == STATE_LEVELTRANSITION then
			for i, v in ipairs(pls) do
				if v.ballEnt and v.ballEnt:IsValid() then
					v.ballEnt:Remove()
				end
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
				roundInfo.curTimer = CurTime() + 5
				roundInfo.curState = STATE_GAMEOVER
			end
		elseif roundInfo.curState == STATE_ROUNDSTARTING then
			roundInfo.curState = STATE_ROUNDACTIVE
			roundInfo.curTimer = CurTime() + newLevelTimer
			for i, v in ipairs(pls) do
				v.playing = true
				v:Spawn()
			end
		elseif roundInfo.curState == STATE_GAMEOVER then
			-- THIS IS JUST TEMPORARY FOR TESTING --
			roundInfo.curState = STATE_WAITINGFORPLAYERS
			roundInfo.curLevel = "MB_W1_L1"
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
		if hasntCompleted == 0 then
			if not allCompleteTimer then allCompleteTimer = 0 end
			allCompleteTimer = allCompleteTimer + 1
			if allCompleteTimer > 120 then
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
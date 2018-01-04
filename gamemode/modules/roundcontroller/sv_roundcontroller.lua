STATE_WAITINGFORPLAYERS = 0
STATE_ROUNDACTIVE = 1
STATE_LEVELTRANSITION = 2
STATE_GAMEOVER = 3

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
			roundInfo.curState = STATE_ROUNDACTIVE
			roundInfo.curTimer = CurTime() + newLevelTimer
			for i, v in ipairs(pls) do
				v:ChatPrint("Current level: " .. roundInfo.curLevel)
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
			if propTable.nextLevel then
				roundInfo.curLevel = propTable.nextLevel
				LoadLevel(roundInfo.curLevel)
				roundInfo.curState = STATE_ROUNDACTIVE
				roundInfo.curTimer = CurTime() + newLevelTimer
				for i, v in ipairs(pls) do
					v:ChatPrint("Current level: " .. roundInfo.curLevel)
				end
			else
				for i, v in ipairs(pls) do
					v:ChatPrint("World complete!")
				end
				roundInfo.curTimer = CurTime() + 15
				roundInfo.curState = STATE_GAMEOVER
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
		end
		if hasntCompleted == 0 then
			 roundInfo.curTimer = CurTime()
			 for i, v in ipairs(pls) do
			 	v:ChatPrint("Everyone beat the level.")
			 end
		end
	end
end
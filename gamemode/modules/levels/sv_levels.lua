util.AddNetworkString("ClientBallSpawned")

function LoadLevel(tablename)
	DestroyLevel()
	curInstancedPropTable = {}
	local spikeTable = {}
	RunString(file.Read("proptables/" .. tablename .. ".txt","DATA"))
	CurSpawnPos = propTable.spawnData.pos
	CurSpawnAng = propTable.spawnData.ang
	spikeTable["models/platformmaster/1x1x1spike.mdl"] = true
	spikeTable["models/platformmaster/2x1x1spike.mdl"] = true
	spikeTable["models/platformmaster/2x2x1spike.mdl"] = true
	spikeTable["models/platformmaster/4x1x1spike.mdl"] = true
	spikeTable["models/platformmaster/4x2x1spike.mdl"] = true
	spikeTable["models/platformmaster/4x4x1spike.mdl"] = true
	for k, v in pairs(propTable) do
		if type(v) == "table" and v.model ~= nil then
			local newProp = ents.Create("levelblock")
			newProp:SetModel(v["model"])
			newProp:SetPos(v["pos"])
			newProp:SetAngles(v["angle"])
			newProp:SetMaterial("jumpbox")
			newProp:SetColor(Color(180,180,180))
			newProp:Spawn()
			newProp:PhysicsInitShadow(false,false)
			newProp:SetSolid(SOLID_VPHYSICS)
			local tempPhys = newProp:GetPhysicsObject()
			if tempPhys:IsValid() then
				tempPhys:SetMass(10000)
				tempPhys:SetMaterial("metal")
			end
			if type(v) == "table" then
				if not newProp.Vars then
					newProp.Vars = {}
				end
				for t, b in pairs(v) do
					if isnumber(k) then
						newProp.Vars[t] = b
					end
				end
			end
			if v["nocollide"] then
				newProp:SetSolid(SOLID_NONE)
			end
			if v["color"] then
				newProp:SetColor(v["color"])
			end
			if v["material"] then
				newProp:SetMaterial(v["material"])
			end
			if v["move"] then
				print("instancing moving prop")
				newProp.Vars["timerName"] = "movetimer" .. newProp:EntIndex()
				newProp.Vars["pos1"] = v["pos1"]
				newProp.Vars["pos2"] = v["pos2"]
				newProp.Vars["movetime"] = v["movetime"]
				newProp:SetPos(newProp.Vars["pos1"])
				local tempPhys = newProp:GetPhysicsObject()
				tempPhys:SetMass(500)
				tempPhys:EnableMotion(true)
				tempPhys:UpdateShadow(newProp.Vars["pos2"],newProp:GetAngles(),newProp.Vars["movetime"])
				if v["loop"] then
					local its = 0
					if newProp.Vars["starttime"] then
						timer.Simple(newProp.Vars["starttime"], function()
							timer.Create(newProp.Vars["timerName"], newProp.Vars["movetime"], 0, function()
								if its % 2 == 0 then
									tempPhys:UpdateShadow(newProp.Vars["pos1"],newProp:GetAngles(),newProp.Vars["movetime"])
								else
									tempPhys:UpdateShadow(newProp.Vars["pos2"],newProp:GetAngles(),newProp.Vars["movetime"])
								end
								its = its + 1
							end)
						end)
					else
						timer.Create(newProp.Vars["timerName"], newProp.Vars["movetime"], 0, function()
							if its % 2 == 0 then
								tempPhys:UpdateShadow(newProp.Vars["pos1"],newProp:GetAngles(),newProp.Vars["movetime"])
							else
								tempPhys:UpdateShadow(newProp.Vars["pos2"],newProp:GetAngles(),newProp.Vars["movetime"])
							end
							its = its + 1
						end)
					end
				elseif v["repeat"] then
					if newProp.Vars["starttime"] then
						timer.Simple(newProp.Vars["starttime"], function()
							timer.Create(newProp.Vars["timerName"], newProp.Vars["movetime"], 0, function()
								tempPhys:SetPos(newProp.Vars["pos1"])
								tempPhys:UpdateShadow(newProp.Vars["pos2"],newProp:GetAngles(),newProp.Vars["movetime"])
							end)
						end)
					else
						timer.Create(newProp.Vars["timerName"], newProp.Vars["movetime"], 0, function()
							tempPhys:SetPos(newProp.Vars["pos1"])
							tempPhys:UpdateShadow(newProp.Vars["pos2"],newProp:GetAngles(),newProp.Vars["movetime"])
						end)
					end
				else
					tempPhys:UpdateShadow(newProp.Vars["pos2"],newProp:GetAngles(),newProp.Vars["movetime"])
				end
			end
			table.insert(curInstancedPropTable, newProp)
		end
	end

	--hook.Add("Tick", "DebugShit", function()
	--	if propTable and propTable.goalVolume then
	--		debugoverlay.Box(Vector(0,0,0),propTable.goalVolume.mins, propTable.goalVolume.maxs,0.1,Color( 0, 255, 0, 10 ))
	--		debugoverlay.Box(Vector(0,0,0),propTable.spawnVolume.mins, propTable.spawnVolume.maxs,0.1,Color( 255, 255, 255, 10 ))
	--	end
	--end)
	for i, v in ipairs(player.GetAll()) do
		local trace = util.TraceLine({
			start = propTable.spawnData.pos,
			endpos = propTable.spawnData.pos + Vector(0,0,-10000)
		})
		print(trace.HitPos)
		v:Spawn()
		v:SetPos(trace.HitPos + Vector(0,0,12000))
		v:SetAngles(propTable.spawnData.ang)
		v:SetEyeAngles(propTable.spawnData.ang)
		--CreateNewBall(v)
	end
end

function DestroyLevel()
	if curInstancedPropTable then
		for k, v in pairs(curInstancedPropTable) do
			if v:IsValid() then
				if v.Vars["timerName"] and timer.Exists( v.Vars["timerName"] ) then
					timer.Remove( v.Vars["timerName"] )
				end
				v:Remove()
			end
		end
	end
	for i, v in ipairs(player.GetAll()) do
		if v.ballEnt and v.ballEnt:IsValid() then
			v.ballEnt:Remove()
		end
	end
end

RunConsoleCommand("sv_gravity","950")

--function CreateNewBall(pl)
--	local ball = ents.Create("ball")
--	ball:Spawn()
--	ball:SetPos(pl:GetPos())
--	pl.ballEnt = ball
--	net.Start("ClientBallSpawned")
--	net.WriteEntity(ball)
--	net.Send(pl)
--end
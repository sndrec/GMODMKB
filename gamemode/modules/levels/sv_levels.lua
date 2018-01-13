util.AddNetworkString("ClientBallSpawned")

function LoadLevel(tablename)
	DestroyLevel()
	curInstancedPropTable = {}
	RunString(file.Read("proptables/" .. tablename .. ".txt","DATA"))
	CurSpawnPos = propTable.spawnData.pos
	CurSpawnAng = propTable.spawnData.ang
	BasePos = Vector(0,0,0)
	for k, v in pairs(propTable.objects) do
		if type(v) == "string" and string.Left(v,4) == "http" then
			local newMesh = ents.Create("sent_meshtools")
			newMesh:Spawn()
			newMesh:LoadObjFromURL(v, true)
			table.insert(curInstancedPropTable, newMesh)
			if propTable.animations and propTable.animations[k] then
				tempTable1 = util.JSONToTable(file.Read("proptables/animations/" .. propTable.animations[k] .. ".json","DATA"))
				local tempTable2 = {}
				for n, i in pairs(tempTable1) do
					local tempTable3 = {}
					local tempx = i.pos[1]
					local tempy = i.pos[2]
					local tempz = i.pos[3]
					local tempp = i.rot[2]
					local tempya = -i.rot[3] + 180
					local tempr = i.rot[1]
					tempTable3.pos = Vector(tempx, tempy, tempz)
					tempTable3.ang = Angle(tempp,tempya,tempr)
					tempTable3.time = n
					table.insert(tempTable2, tempTable3)
				end
				table.sort(tempTable2,function(a, b) return a.time < b.time end)
				newMesh.animTable = tempTable2
			end
		end
	end
	for i, v in ipairs(propTable.goals) do
		local newGoal = ents.Create("levelblock")
		newGoal:SetPos(v.pos)
		newGoal:SetAngles(v.ang)
		newGoal:SetModel("models/monkeyball/goal.mdl")
		newGoal:Spawn()
		newGoal:PhysicsInitShadow(false, false)
		newGoal:SetMoveType(MOVETYPE_VPHYSICS)
		table.insert(curInstancedPropTable, newGoal)
		local newGoalTrigger = ents.Create("prop_physics")
		newGoalTrigger:SetPos(v.pos)
		newGoalTrigger:SetAngles(v.ang)
		newGoalTrigger:SetModel("models/monkeyball/goalTrigger.mdl")
		newGoalTrigger:Spawn()
		newGoalTrigger:PhysicsInitShadow(false, false)
		newGoalTrigger:SetMoveType(MOVETYPE_VPHYSICS)
		newGoalTrigger:SetCollisionGroup(COLLISION_GROUP_NONE)
		newGoalTrigger:SetNoDraw(true)
		newGoalTrigger.goalTrigger = true
		table.insert(curInstancedPropTable, newGoalTrigger)
	end
end

function DestroyLevel()
	if curInstancedPropTable then
		for k, v in pairs(curInstancedPropTable) do
			if v:IsValid() then
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

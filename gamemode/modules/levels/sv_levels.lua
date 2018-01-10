util.AddNetworkString("ClientBallSpawned")

function LoadLevel(tablename)
	DestroyLevel()
	curInstancedPropTable = {}
	RunString(file.Read("proptables/" .. tablename .. ".txt","DATA"))
	CurSpawnPos = propTable.spawnData.pos
	CurSpawnAng = propTable.spawnData.ang
	BasePos = Vector(0,0,0)
	for k, v in pairs(propTable) do
		if type(v) == "string" and string.Left(v,4) == "http" then
			local newMesh = ents.Create("sent_meshtools")
			newMesh:Spawn()
			newMesh:LoadObjFromURL(v, true)
			table.insert(curInstancedPropTable, newMesh)
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

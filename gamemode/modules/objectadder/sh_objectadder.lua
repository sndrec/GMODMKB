if SERVER then
	concommand.Add("mb_creategameobject",function(pl, cmd, args)
		print("oooh")
		if not pl:IsAdmin() then
			pl:ChatPrint("Only a server operator may use this concommand.")
			return
		end
	
		print("oh yeah boy")
		CreateGameObject(pl, args[1])
	
	end)
end

function CreateGameObject(pl, class)
	if CLIENT then return end
	print(pl, class)
	local trace = pl:GetEyeTrace()

	if class == "banana" then
		local pos = trace.HitPos + (trace.HitNormal * 40)
		local ent = ents.Create(class)
		ent:SetPos(pos)
		ent:Spawn()
		
		local appendString = "\npropTable.gameObjects[curGameObjects] = {}\n"
		appendString = appendString .. "propTable.gameObjects[curGameObjects].class = \"" .. class .. "\"\n"
		appendString = appendString .. "propTable.gameObjects[curGameObjects].pos = Vector(" .. math.Round(pos.x, 1) .. "," .. math.Round(pos.y, 1) .. "," .. math.Round(pos.z, 1) .. ")\n"
		appendString = appendString .. "curGameObjects = curGameObjects + 1\n"
		local stageConfig = file.Read("proptables/" .. roundInfo.curLevel .. ".txt","DATA")
		stageConfig = stageConfig .. appendString
		file.Write("proptables/" .. roundInfo.curLevel .. ".txt",stageConfig)
	end
end

if CLIENT then
	
end
util.AddNetworkString("RequestStages")
util.AddNetworkString("RequestSpecificStage")

function WriteLeaderboardEntry(pl, stage, time)
	local ID = pl:SteamID64()
	local filename = "leaderboards/LB_" .. stage .. ".txt"
	local newTable = {}
	if not file.Exists(filename,"DATA") then
		file.Write(filename,"")
	else
		newTable = util.JSONToTable(file.Read(filename,"DATA"))
	end

	local dontWrite = false
	
	for i = #newTable, 1, -1 do
		if newTable[i].steamID == ID then
			if newTable[i].clearTime < time then
				return
			else
				CreateClientText(pl, "New personal best!", 6, "DermaScaleSmall", 0.5, 0.8, Color(255,255,255,255))
				table.remove(newTable, i)
			end
		end
	end

	local tempTable = {}
	tempTable.steamID = ID
	tempTable.clearTime = time
	tempTable.nick = pl:Nick()
	table.insert(newTable, tempTable)
	table.sort(newTable, function(a, b) return a.clearTime < b.clearTime end)

	if newTable[1].steamID == ID then
		CreateClientText(nil, pl:Nick() .. " has set a new WR of " .. time .. " seconds!", 6, "DermaScaleSmall", 0.5, 0.9, Color(255,255,255,255))
		CreateClientText(pl, "You got a World Record!!!", 6, "DermaScaleMed", 0.5, 0.7, Color(255,255,255,255))
	else
		local place = 0
		for i, v in ipairs(newTable) do
			if v.steamID == ID then
				place = i
				break
			end
		end
		CreateClientText(pl, "Your time was #" .. place .. ".", 6, "DermaScaleSmall", 0.5, 0.7, Color(255,255,255,255))
	end


	local writeTable = util.TableToJSON(newTable,true)

	file.Write(filename,writeTable)

end

function SendStageList(pl)
	local files, directories = file.Find( "leaderboards/*.txt", "DATA" )
	local leaderboardTable = {}
	print("ah")
	for k, v in ipairs(files) do
		print(v)
		local tempTable = {}
		local start, endpos, str = string.find(v,"_", 5)
		tempTable.world = string.sub(v, start + 1, start + 2)
		start, endpos, str = string.find(v,"_", 8)
		local start2, endpos2, str2 = string.find(v,".txt")
		tempTable.stage = tonumber(string.sub(v, start + 2, start2 - 1))
		table.insert(leaderboardTable, tempTable)
	end

	table.sort(leaderboardTable, function(a, b) return a.stage < b.stage end)
	net.Start("RequestStages")
	net.WriteTable(leaderboardTable)
	net.Send(pl)
end

function SendStageLeaderboard(pl, world, floor)
	local filename = "leaderboards/LB_MB_" .. world .. "_L" .. floor .. ".txt"
	print(filename)
	local newTable = {}
	if not file.Exists(filename,"DATA") then
		pl:ChatPrint("No times for this stage yet.")
	else
		newTable = util.JSONToTable(file.Read(filename,"DATA"))
	end

	net.Start("RequestSpecificStage")
	net.WriteTable(newTable)
	net.Send(pl)
end

function RetrieveWR(stage)
	local filename = "leaderboards/LB_" .. stage .. ".txt"
	print(filename)
	local newTable = {}
	if not file.Exists(filename,"DATA") then
		for i, v in ipairs(player.GetAll()) do
			v:ChatPrint("No times for this stage yet.")
		end
	else
		newTable = util.JSONToTable(file.Read(filename,"DATA"))
	end

	return newTable[1]

end

function RetrievePB(stage, pl)
	local filename = "leaderboards/LB_" .. stage .. ".txt"
	print(filename)
	local newTable = {}
	if file.Exists(filename,"DATA") then
		newTable = util.JSONToTable(file.Read(filename,"DATA"))
	end

	local desiredEntry = nil

	for i, v in ipairs(newTable) do
		if v.steamID == pl:SteamID64() then
			desiredEntry = v
			break
		end
	end

	if desiredEntry == nil then
		desiredEntry = "N/A"
	end

	return desiredEntry
end


function SendStageLeaderboardSimple(pl, stage)
	local filename = "leaderboards/LB_" .. stage .. ".txt"
	print(filename)
	local newTable = {}
	if not file.Exists(filename,"DATA") then
		pl:ChatPrint("No times for this stage yet.")
	else
		newTable = util.JSONToTable(file.Read(filename,"DATA"))
	end

	net.Start("RequestSpecificStage")
	net.WriteTable(newTable)
	net.Send(pl)
end

net.Receive("RequestStages", function(len, pl)
	SendStageList(pl)
	SendStageLeaderboardSimple(pl, roundInfo.curLevel)
end)

net.Receive("RequestSpecificStage", function(len, pl)
	local world = net.ReadString()
	local floor = net.ReadInt(16)
	SendStageLeaderboard(pl, world, floor)
end)
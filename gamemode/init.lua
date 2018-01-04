AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("config/config.lua")

include('shared.lua')

resource.AddWorkshop("1175000472")
resource.AddWorkshop("999854920")

local function LoadModules()
	local root = GM.FolderName.."/gamemode/modules/"

	local _, folders = file.Find(root.."*", "LUA")

	for _, folder in SortedPairs(folders, true) do
		if table.HasValue(MINIGAMES.Config.DisabledModules, folder) then continue end
		
		for _, File in SortedPairs(file.Find(root .. folder .."/sh_*.lua", "LUA"), true) do
			AddCSLuaFile(root..folder .. "/" ..File)
			include(root.. folder .. "/" ..File)
		end

		for _, File in SortedPairs(file.Find(root .. folder .."/sv_*.lua", "LUA"), true) do
			include(root.. folder .. "/" ..File)
		end

		for _, File in SortedPairs(file.Find(root .. folder .."/cl_*.lua", "LUA"), true) do
			AddCSLuaFile(root.. folder .. "/" ..File)
		end
	end
end

MINIGAMES = MINIGAMES or {}
MINIGAMES.Config = MINIGAMES.Config or {}

include("config/config.lua")
LoadModules()
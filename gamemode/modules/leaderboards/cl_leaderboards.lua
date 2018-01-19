local stageListTable = {}
local currentDisplayedLeaderboard = {}

function OpenLeaderBoardMenu()
	leaderBoardMenu = vgui.Create("DFrame")
	leaderBoardMenu:SetSize(ScrW() * 0.75, ScrH() * 0.5)
	leaderBoardMenu:SetPos(ScrW() * 0.125, ScrH() * 0.25)
	leaderBoardMenu:MakePopup()
	net.Start("RequestStages")
	net.SendToServer()

	local scrollMenu = vgui.Create( "DScrollPanel", leaderBoardMenu )
	scrollMenu:SetPos(5, 25)
	scrollMenu:SetSize(ScrW() * 0.165,ScrH() * 0.45)


	function leaderBoardMenu:Think()
		if not self.tableInstanced then
			if #stageListTable >= 1 then
				self.tableInstanced = true
				for i, v in ipairs(stageListTable) do
					local butt = vgui.Create("DButton", scrollMenu)
					butt.world = v.world
					butt.stage = v.stage
					butt:SetPos(5, ((i - 1) * ScrH() * 0.05) + 5)
					butt:SetSize(ScrW() * 0.125, ScrH() * 0.045)
					butt:SetText(v.world .. " Floor " .. v.stage)
					butt.DoClick = function()
						net.Start("RequestSpecificStage")
						net.WriteString(butt.world)
						net.WriteInt(butt.stage, 16)
						net.SendToServer()
					end
				end
			end
		end
	end
end

net.Receive("RequestSpecificStage", function()
	local tempTable = net.ReadTable()
	for k, v in ipairs(currentDisplayedLeaderboard) do
		v:Remove()
	end
	currentDisplayedLeaderboard = {}
	local scrollMenu2 = vgui.Create( "DScrollPanel", leaderBoardMenu )
	scrollMenu2:SetPos((ScrW() * 0.165) + 20, 25)
	scrollMenu2:SetSize(ScrW() * 0.5,ScrH() * 0.45)
		table.insert(currentDisplayedLeaderboard, scrollMenu2)
	for i, v in ipairs(tempTable) do
		PrintTable(v)
		local text1 = vgui.Create("DLabel", scrollMenu2)
		local text2 = vgui.Create("DLabel", scrollMenu2)
		local text3 = vgui.Create("DLabel", scrollMenu2)
		local avatar = vgui.Create( "AvatarImage", scrollMenu2 )
		local height = ScrH() * 0.06
		avatar:SetSize( height, height )
		local curVerticalHeight = ((i - 1) * (height + 2)) + (ScrW() * 0.015)
		local horizPos = ScrW() * 0.1
		text1:SetText(v.nick)
		text2:SetText(v.clearTime .. "s")
		text3:SetText("#" .. i)
		text1:SetPos(horizPos + height + 4, curVerticalHeight)
		text2:SetPos(horizPos + height + 4, curVerticalHeight + (height * 0.5))
		text3:SetPos(ScrW() * 0.01, curVerticalHeight)
		text1:SetFont("DermaScaleSmall")
		text2:SetFont("DermaScaleSmall")
		text3:SetFont("DermaScaleMed")
		text1:SizeToContents()
		text2:SizeToContents()
		text3:SizeToContents()
		avatar:SetPos( horizPos, curVerticalHeight )
		avatar:SetSteamID(v.steamID)
		table.insert(currentDisplayedLeaderboard, text1)
		table.insert(currentDisplayedLeaderboard, text2)
		table.insert(currentDisplayedLeaderboard, text3)
		table.insert(currentDisplayedLeaderboard, avatar)
	end
end)

net.Receive("RequestStages", function()
	stageListTable = net.ReadTable()
	print("Got our table!")
end)

function GM:PlayerBindPress( ply, bind, pressed )
	if ( string.find( bind, "gm_showspare1" ) ) then 
		OpenLeaderBoardMenu()
	end
end
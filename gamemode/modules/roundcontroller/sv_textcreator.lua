util.AddNetworkString("CreateClientText")
util.AddNetworkString("CreateTip")

function CreateClientText(pl, text, time, font, posx, posy, color)
	net.Start("CreateClientText")
	net.WriteString(text)
	net.WriteFloat(CurTime() + time)
	net.WriteString(font)
	net.WriteFloat(posx)
	net.WriteFloat(posy)
	net.WriteColor(color)
	if pl == nil then
		net.Broadcast()
	else
		net.Send(pl)
	end
end

function CreateTip(pl, text)
	net.Start("CreateTip")
	net.WriteString(text)
	net.Send(pl)
end

function hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

concommand.Add("createscreentext",
	function(pl, cmd, args)
		CreateClientText(nil, 
			args[1], 
			tonumber(args[2]), 
			"DermaLarge", 
			tonumber(args[3]), 
			tonumber(args[4]), 
			Color(tonumber(args[5]), tonumber(args[6]), tonumber(args[7])))

	end)
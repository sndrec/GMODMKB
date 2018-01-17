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
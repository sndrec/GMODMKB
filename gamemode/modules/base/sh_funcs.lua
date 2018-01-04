local ply = FindMetaTable("Player")
--util.AddNetworkString("NotifySelectNET")

function ply:Hint(text, time)
	time = time or 5
	if SERVER then
		self:SendLua([[Notify("]]..text..[[", ]]..tostring(time)..[[)]])
		self:SendLua([[print("NOTIFICATION: ]]..text..[[")]])
	else
		Notify(text, tostring(time))
		print('NOTIFICATION: '..text)
	end
end

function ply:HintOption(text, time, func1, func2)
	time = time or 5
	if SERVER then
		self:SendLua([[NotifySelect("]]..text..[[", ]]..tostring(time)..[[, ]]..tostring(func1)..[[, ]]..tostring(func2)..[[)]])
		self:SendLua([[print("NOTIFICATION: ]]..text..[[")]])
	else
		NotifySelect(text, tostring(time), func1, func2)
		print('NOTIFICATION: '..text)
	end
end

if SERVER then
	concommand.Add("not", function(ply)
		for i=100,1,-1 do 
		   ply:Hint("You have earned "..math.random(75,100).."CMC", math.random(1,10))
		end
	end)

	concommand.Add("not1", function(ply)
		   ply:HintOption("You have earned "..math.random(75,100).."CMC", math.random(1,10), 'function() print("Yes") end', 'function() print("No") end')
	end)
end
if CLIENT then
	--net.Receive(,function callback)
	concommand.Add("not2", function(ply)
		   ply:HintOption("You have earned "..math.random(75,100).."CMC", math.random(1,10), function() print("Yes") end, function() print("No") end)
	end)
end

local sunSpawned = false

function CreateSun()

	local depthres = GetConVar("r_flashlightdepthres")

	if (depthres:GetInt() < 1024) then
		chat.AddText("You can get a nicer looking experience on this server by setting r_flashlightdepthres to 1024 or higher.")
		warned = true
		return
	end

	if (sunSpawned == false) then
		--print("spawned sun")
	
		local CSMColour = Color(255,255,255)
		local CSMAngle = Angle(39.3, 117.9, 0)
		local NearZ = 5000
		local FarZ = 15000
		local Brightness = 20
		local Pos = Vector(3468.464355, -6606.973145, 6168.266602)
	
		CSM1 = ProjectedTexture()
		CSM1:SetOrthographic(true, 2048, 2048, 2048, 2048)
		CSM1:SetColor(CSMColour)
		CSM1:SetTexture("sun/sun-128")
		CSM1:SetNearZ(NearZ)
		CSM1:SetFarZ(FarZ)
		CSM1:SetAngles(CSMAngle)
		CSM1:SetBrightness(Brightness)
		CSM1:SetPos(Pos + LocalPlayer():GetPos())
		CSM1:Update()
	
		CSM2 = ProjectedTexture()
		CSM2:SetOrthographic(true, 8192, 8192, 8192, 8192)
		CSM2:SetColor(CSMColour)
		CSM2:SetTexture("sun/sun-512")
		CSM2:SetNearZ(NearZ)
		CSM2:SetFarZ(FarZ)
		CSM2:SetAngles(CSMAngle)
		CSM2:SetBrightness(Brightness)
		CSM2:SetPos(Pos + LocalPlayer():GetPos())
		CSM2:Update()

		sunSpawned = true
	end

	hook.Add("Think", "ParentSun", function()

		if sunSpawned == true then
			CSM1:SetPos(Vector(3510.464355, -6630.973145, 6150.266602) + LocalPlayer():GetPos())
			CSM1:Update()
	
			CSM2:SetPos(Vector(3510.464355, -6630.973145, 6150.266602) + LocalPlayer():GetPos())
			CSM2:Update()	
		end
	end)

end
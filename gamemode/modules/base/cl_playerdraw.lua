skyCamPos = skyCamPos or Vector(0,0,-8000)

function GM:PreDrawSkyBox()
	if ClientBall and ClientBall:IsValid() then
		cam.Start3D(skyCamPos + (_VIEWORIGIN / 32), _VIEWANGLES, 80)
	end
end

function GM:PostDraw2DSkyBox()
	render.OverrideDepthEnable( true, false )
	surface.SetDrawColor(50,50,50,100)
	surface.DrawRect(0,0,ScrW(),ScrH())
	render.OverrideDepthEnable( false, false )
	if ClientBall and ClientBall:IsValid() then
		cam.End3D()
	end
	render.OverrideDepthEnable( true, false )
	cam.Start3D( Vector( 0, 0, 0 ), _VIEWANGLES )
		render.SetColorMaterial()
		render.DrawQuadEasy( _VIEWANGLES:Forward() * 128, -_VIEWANGLES:Forward(), 256, 256, Color( 200, 230, 255 ), 0 )
	cam.End3D()
	render.OverrideDepthEnable( false, false )
end

net.Receive("SyncSkyCam", function()
	skyCamPos = net.ReadVector()
end)
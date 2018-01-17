skyCamPos = skyCamPos or Vector(0,0,-8000)

function GM:PreDrawSkyBox()
	--if ClientBall and ClientBall:IsValid() then
	--	cam.Start3D(skyCamPos + (_VIEWORIGIN / 32), _VIEWANGLES, 80)
	--end
end

local SourceSkyname = GetConVar("sv_skyname"):GetString() --We need the source of the maps original skybox texture so we can manipulate it.
local SourceSkyPre  = {"lf","ft","rt","bk","dn","up",}
local SourceSkyMat  = {
    Material("skybox/"..SourceSkyname.."lf"),
    Material("skybox/"..SourceSkyname.."ft"),
    Material("skybox/"..SourceSkyname.."rt"),
    Material("skybox/"..SourceSkyname.."bk"),
    Material("skybox/"..SourceSkyname.."dn"),
    Material("skybox/"..SourceSkyname.."up"),
}


function GM:PostDraw2DSkyBox()
	if ClientBall and ClientBall:IsValid() then
		render.OverrideDepthEnable( true, false )
		cam.Start3D( Vector( 0, 0, 0 ), _VIEWANGLES )
			render.SetMaterial(SourceSkyMat[3])
			render.DrawQuadEasy( Vector(128,0,0), Vector(-1,0,0), 256, 256, Color( 255, 255, 255 ), 180 )
			render.SetMaterial(SourceSkyMat[4])
			render.DrawQuadEasy( Vector(0,128,0), Vector(0,-1,0), 256, 256, Color( 255, 255, 255 ), 180 )
			render.SetMaterial(SourceSkyMat[1])
			render.DrawQuadEasy( Vector(-128,0,0), Vector(1,0,0), 256, 256, Color( 255, 255, 255 ), 180 )
			render.SetMaterial(SourceSkyMat[2])
			render.DrawQuadEasy( Vector(0,-128,0), Vector(0,1,0), 256, 256, Color( 255, 255, 255 ), 180 )
			render.SetMaterial(SourceSkyMat[5])
			render.DrawQuadEasy( Vector(0,0,-128), Vector(0,0,1), 256, 256, Color( 255, 255, 255 ), 0 )
			render.SetMaterial(SourceSkyMat[6])
			render.DrawQuadEasy( Vector(0,0,128), Vector(0,0,-1), 256, 256, Color( 255, 255, 255 ), 0 )
		cam.End3D()
		render.OverrideDepthEnable( false, false )
	end
end


net.Receive("SyncSkyCam", function()
	skyCamPos = net.ReadVector()
end)
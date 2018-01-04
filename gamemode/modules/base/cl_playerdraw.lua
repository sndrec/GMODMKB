function GM:PrePlayerDraw( pl )
	cam.Start3D(_VIEWORIGIN, _VIEWANGLES, 80)
end

function GM:PostPlayerDraw( pl )
	cam.End3D()
end
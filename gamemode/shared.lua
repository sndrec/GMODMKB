GM.Name 	= "Super Monkey Ball"
GM.Author 	= "Az"
GM.Email 	= ""
GM.Website 	= ""

DeriveGamemode("sandbox")
include("sh_meshtools.lua")

function GM:Initialize()
	self.BaseClass.Initialize(self)
end


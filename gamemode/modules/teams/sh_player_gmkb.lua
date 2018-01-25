local PLAYER = {}

PLAYER.DisplayName			= "Default Class"

PLAYER.WalkSpeed			= 100
PLAYER.RunSpeed				= 100
PLAYER.CrouchedWalkSpeed	= 0.5
PLAYER.DuckSpeed			= 0
PLAYER.UnDuckSpeed			= 0
PLAYER.JumpPower			= 270
PLAYER.CanUseFlashlight		= false
PLAYER.MaxHealth			= 100
PLAYER.StartHealth			= 100
PLAYER.StartArmor			= 0
PLAYER.DropWeaponOnDie		= false
PLAYER.TeammateNoCollide	= true
PLAYER.AvoidPlayers			= false
PLAYER.UseVMHands			= true

function PLAYER:SetupDataTables()
end

function PLAYER:Init()
end

function PLAYER:Spawn()
end

function PLAYER:Loadout()
end

function PLAYER:SetModel()

	local cl_playermodel = self.Player:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	self.Player:SetModel( modelname )

end

function PLAYER:CalcView( view )
end

function PLAYER:ShouldDrawLocal()
end

function PLAYER:StartMove( cmd, mv )
end

function PLAYER:Move( mv )
end

function PLAYER:FinishMove( mv )
end

function PLAYER:ViewModelChanged( vm, old, new )
end

function PLAYER:PreDrawViewModel( vm, weapon )
end

function PLAYER:PostDrawViewModel( vm, weapon )
end

function PLAYER:GetHandsModel()

	local playermodel = player_manager.TranslateToPlayerModelName( self.Player:GetModel() )
	return player_manager.TranslatePlayerHands( playermodel )

end

player_manager.RegisterClass( "player_mkb", PLAYER, "player_default" )

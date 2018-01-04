-----------------------------------------------------------------------
-- Meshtools
-- Created by shadowscion
--
-- Credits:
--  Vercas ( vnet )
--  MDave ( smd decoder )
-----------------------------------------------------------------------

meshtools = meshtools or {}
meshtools.MeshCache = meshtools.MeshCache or {}

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile( "meshtools/modules/vnet.lua" )
    AddCSLuaFile( "meshtools/modules/decode.lua" )
    AddCSLuaFile( "meshtools/libraries/export.lua" )
    AddCSLuaFile( "meshtools/libraries/import.lua" )

    util.AddNetworkString( "meshtools.start_export" )
end

include( "meshtools/modules/vnet.lua" )
include( "meshtools/modules/decode.lua" )
include( "meshtools/libraries/export.lua" )
include( "meshtools/libraries/import.lua" )
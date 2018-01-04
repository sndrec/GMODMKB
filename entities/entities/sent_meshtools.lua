-----------------------------------------------------------------------
-- Meshtools Base Entity
-----------------------------------------------------------------------

AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Dynamic Mesh"
ENT.Author = "shadowscion"
ENT.Category = "Mesh Tools"

ENT.Spawnable = true
ENT.AdminOnly = false

local meshtools = meshtools

-----------------------------------------------------------------------
-- Meshtools Base Entity Shared
-----------------------------------------------------------------------

function ENT:Initialize()
        self:DrawShadow( false )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_NONE )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetAngles(Angle(0, 0, 90))

        if CLIENT then
            // Doesnt allways render - hacky fix anyway
            self:SetRenderBounds(Vector(0, 0, 0), Vector(0, 0, 0), Vector(32768, 32768, 32768))
        end

        self.Mesh = {
            CRC = nil,
            Loaded = false,
            Phys = false,
            Matrix = Matrix(),
            defaultMat = Material("models/wireframe"),
            Material = {["check.001"] = Material( "monkeyball/tex1_256x256_m_1f5fc1b864fb09a4_14" ), ["wood"] = Material( "wood.png", "noclamp smooth mips" ), ["check"] = Material( "floor.png", "noclamp smooth mips" ), ["Material.001"] = Material("monkeyball/tex1_256x256_m_593cb191329c9ee5_14")},
            Mesh = {},
        }
        
        //https://share.rtm516.co.uk/floor.png
        //https://share.rtm516.co.uk/wood.png


        //obj: https://share.rtm516.co.uk/lvl55.obj
        //mtl: https://share.rtm516.co.uk/lvl55.mtl
        self:LoadObjFromURL("https://share.rtm516.co.uk/lvl1.obj", true)
end

-----------------------------------------------------------------------
-- Meshtools Base Entity Serverside
-----------------------------------------------------------------------

if SERVER then

    function ENT:SpawnFunction( Ply, Trace, Class )
        if not Trace.Hit then return end

        local Ent = ents.Create( Class )

        Ent:SetPos( Trace.HitPos + Trace.HitNormal*100 )
        Ent:Spawn()
        Ent:Activate()

        return Ent
    end

end
-----------------------------------------------------------------------
-- Meshtools Base Entity Clientside
-----------------------------------------------------------------------


local meshCache = meshtools.MeshCache

function ENT:LoadObjFromFile( filepath, forceReload )
    self.Mesh.Loaded = false
    self.Mesh.CRC = meshtools.LoadObjFromFile( filepath, forceReload )
end

function ENT:LoadObjFromURL( url, forceReload )
    http.Fetch(url, function(body)
        local tmpFilepath = "tmp_obj_download.dat"
        file.Write(tmpFilepath, body)
        self:LoadObjFromFile(tmpFilepath, forceReload)
    end)
end

function ENT:Think()
    if self.Mesh.Phys then return true end
    if self.Mesh.CRC && meshCache[self.Mesh.CRC] then
        self:PhysicsFromMesh(meshCache[self.Mesh.CRC].all)
		self:GetPhysicsObject():EnableCollisions( true );
		self:GetPhysicsObject():EnableMotion( false );
		self:EnableCustomCollisions(true)
        self.Mesh.Phys = true
    end
end

if SERVER then
    hook.Remove( "PlayerInitialSpawn", "spawn_map" )
    hook.Add( "PlayerInitialSpawn", "spawn_map", function()
        local alivePlayers = 0
        for k,v in pairs(player.GetAll()) do
            if v:Alive() then
                alivePlayers = alivePlayers + 1
            end
        end
        if alivePlayers != player.GetCount() then return end
        if map then return end
        map = ents.Create("sent_meshtools")
        map:SetPos(Vector(0, 16000, 0))
        map:Spawn()
        map:Activate()
    end)
    hook.Remove( "PlayerSpawn", "spawn_point" )
    hook.Add( "PlayerSpawn", "spawn_point", function(ply)
        ply:SetPos(Vector(0, 16000, 0))
    end )
end

if not CLIENT then return end
function ENT:ShouldDraw()
    if not self.Mesh then return false end

    if self.Mesh.Loaded then return true end
    if self.Mesh.CRC then
        if meshCache[self.Mesh.CRC] then
            for k,v in pairs(meshCache[self.Mesh.CRC]) do
                if k == "all" then continue end
                self.Mesh.Mesh[k] = Mesh()
                self.Mesh.Mesh[k]:BuildFromTriangles( v )
            end
            self.Mesh.Loaded = true
        end
        return false
    end
end

function ENT:Draw()
    if not self:ShouldDraw() then return end

    self.Mesh.Matrix:SetTranslation( self:GetPos() )
    self.Mesh.Matrix:SetAngles( self:GetAngles() )

    render.SetLightingMode( 1 )
    render.OverrideDepthEnable(true, true)

    for k,v in pairs(self.Mesh.Mesh) do
        render.SetMaterial(self.Mesh.Material[k] || self.Mesh.defaultMat)
        cam.PushModelMatrix( self.Mesh.Matrix )
            v:Draw()
        cam.PopModelMatrix()
    end

    render.SetLightingMode( 0 )
    render.OverrideDepthEnable(false, false)
end


hook.Remove( "HUDPaint", "meshtools.LoadOverlay" )
hook.Add( "HUDPaint", "meshtools.LoadOverlay", function()
    local bc = Color( 175, 175, 175, 135 )
    local tc = Color( 225, 225, 225, 255 )

    for _, ent in pairs( ents.FindByClass( "sent_meshtools" ) ) do
        if not ent.Mesh then continue end
        if ent.Mesh.Loaded then continue end

        local scr = ( ent:GetPos() + Vector( 0, 0, 20 ) ):ToScreen()
        draw.WordBox( 6, scr.x, scr.y, "Loading...", "DermaDefault", bc, tc )
    end
end )
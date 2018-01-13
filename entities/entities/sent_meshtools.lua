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

local matTable = {}
matTable["W1"] = {}
matTable["W1"]["check"] = Material("monkeyball/tex1_256x256_m_5fa7688318397a55_14.png", "noclamp smooth mips")
matTable["W1"]["check2"] = Material("monkeyball/tex1_256x256_m_5e303c7e6163e11b_14_mip1.png", "noclamp smooth mips")
matTable["W1"]["check3"] = Material("monkeyball/tex1_256x256_m_6be1f1d9f4769ab4_14.png", "noclamp smooth mips")
matTable["W1"]["fill"] = Material("monkeyball/tex1_256x256_m_f6cb8c76c35f0e99_14.png", "noclamp smooth mips")
matTable["W1"]["wood"] = Material("monkeyball/tex1_256x256_m_f6cb8c76c35f0e99_14.png", "noclamp smooth mips")
matTable["W1"]["detail"] = Material("monkeyball/tex1_256x128_m_1f1b668f7d005e49_14.png", "noclamp smooth mips")
matTable["W1"]["detail2"] = Material("monkeyball/13.png", "noclamp smooth mips")
matTable["W1"]["detail3"] = Material("monkeyball/tex1_256x256_m_053618233250036d_14.png", "noclamp smooth mips")
matTable["W1"]["trim"] = Material("monkeyball/tex1_256x64_m_ac3f639aec944ccb_14.png", "noclamp smooth mips")

function ENT:Initialize()
        self:DrawShadow( false )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_NONE )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetAngles(Angle(0, 0, 90))

        if CLIENT then
            self:SetRenderBounds(Vector(0, 0, 0), Vector(0, 0, 0), Vector(32768, 32768, 32768))
        end
        self:AddEFlags(EFL_FORCE_CHECK_TRANSMIT)

        self.Mesh = {
            CRC = nil,
            Loaded = false,
            Phys = false,
            Matrix = Matrix(),
            defaultMat = Material("models/wireframe"),
            Material = matTable["W1"],
            Mesh = {},
        }
        
        //https://share.rtm516.co.uk/floor.png
        //https://share.rtm516.co.uk/wood.png


        //obj: https://share.rtm516.co.uk/lvl55.obj
        //mtl: https://share.rtm516.co.uk/lvl55.mtl
end

-----------------------------------------------------------------------
-- Meshtools Base Entity Serverside
-----------------------------------------------------------------------

function ENT:SetupDataTables()

    self:NetworkVar( "Vector", 0, "RealPos" );
    self:NetworkVar( "Angle", 0, "RealAng" );

end

if SERVER then

    function ENT:UpdateTransmitState()
        return TRANSMIT_ALWAYS
    end

    util.AddNetworkString( "RequestMesh" )

    net.Receive("RequestMesh", function(len, pl)
        local ent = Entity(net.ReadInt(16))
        net.Start("MeshURL")
        net.WriteInt(ent:EntIndex(), 16)
        net.WriteString(ent.currentMesh)
        net.Send(pl)
    end)

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
    self.currentMesh = url
    if file.Exists(string.Left(string.Right(url,10), 6) .. ".dat","DATA") then
        local tmpFilepath = string.Left(string.Right(url,10), 6) .. ".dat"
        self:LoadObjFromFile(tmpFilepath, forceReload)
    else
        http.Fetch(url, function(body)
            print("Here is our URL:")
            print(url)
            local tmpFilepath = string.Left(string.Right(url,10), 6) .. ".dat"
            print("Here is our temporary file path:")
            print(tmpFilepath)
            file.Write(tmpFilepath, body)
            self:LoadObjFromFile(tmpFilepath, forceReload)
        end)
    end
    if SERVER then
        net.Start("MeshURL")
        net.WriteInt(self:EntIndex(), 16)
        net.WriteString(url)
        net.Broadcast()
    end
end

net.Receive("MeshURL", function()
    local ent = net.ReadInt(16)
    local url = net.ReadString()
    print("receiving mesh url")
    print(url)
    timer.Simple(0.5,function()
        Entity(ent):LoadObjFromURL(url)
    end)
end)


function ENT:Think()
    if SERVER and self.animTable and self.spawnTime then
        if not self.shadowInitialized then
            self:MakePhysicsObjectAShadow(false, false)
            self.shadowInitialized = true
            self.currentItem = 1
            self.lastTime = 0
            self.nextFrameTime = CurTime() + self.animTable[1].time
        end
        if CurTime() > self.nextFrameTime then
            self.lastPos = self.animTable[self.currentItem].pos
            self.lastAng = self.animTable[self.currentItem].ang
            self.lastTime = self.animTable[self.currentItem].time / 60
            self.currentItem = self.currentItem + 1
            self.nextFrameTime = CurTime() + ((self.animTable[self.currentItem].time / 60) - self.lastTime)
            --print("Keyframe " .. self.currentItem)
            --print(self.lastTime, self.nextFrameTime, CurTime())
            --print(self.animTable[self.currentItem].pos, self.animTable[self.currentItem].ang)
            --print(self:GetPhysicsObject():GetPos(), self:GetPhysicsObject():GetAngles())
            local time = ((self.animTable[self.currentItem].time / 60) - self.lastTime)
            print("ah")
        end
        local lerp = 1 - (self.nextFrameTime - CurTime()) / ((self.animTable[self.currentItem].time / 60) - self.lastTime)
        local newPos = LerpVector(lerp,self.lastPos,self.animTable[self.currentItem].pos)
        local newAng = LerpAngle(lerp,self.lastAng,self.animTable[self.currentItem].ang)
        self:GetPhysicsObject():UpdateShadow(newPos, newAng + Angle(0,0,90), FrameTime() )
        self:SetRealPos(newPos)
        self:SetRealAng(newAng)
    end
    self:NextThink(CurTime())

    if self.Mesh.Phys then return true end
    if self.Mesh.CRC && meshCache[self.Mesh.CRC] then
        if SERVER then
            self:PhysicsFromMesh(meshCache[self.Mesh.CRC].all)
		    self:GetPhysicsObject():EnableCollisions( true );
		    self:GetPhysicsObject():EnableMotion( false );
		    self:EnableCustomCollisions(true)
        end
        self.Mesh.Phys = true
    end
end

if not CLIENT then return end
function ENT:ShouldDraw()
    if not self.requestTimer then self.requestTimer = CurTime() + 2 end
    if not self.Mesh then return false end
    if self.Mesh.Loaded then 
        return true 
    else
        if CurTime() > self.requestTimer then
            self.requestTimer = CurTime() + 2
            net.Start("RequestMesh")
            net.WriteInt(self:EntIndex(), 16)
            net.SendToServer()
        end
    end
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

    self:SetRenderBounds(Vector(0, 0, 0), Vector(0, 0, 0), Vector(32768, 32768, 32768))
    self.Mesh.Matrix:SetTranslation( self:GetRealPos() )
    self.Mesh.Matrix:SetAngles( self:GetRealAng() + Angle(0,0,90) )
    
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
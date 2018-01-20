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
matTable["W1"]["check"] = Material("monkeyball/tex1_256x256_m_1f5fc1b864fb09a4_14.png", "noclamp smooth mips")
matTable["W1"]["check2"] = Material("monkeyball/tex1_256x256_m_4d8e09666f490043_14.png", "noclamp smooth mips")
matTable["W1"]["check3"] = Material("monkeyball/tex1_256x256_m_4d8e09666f490043_14.png", "noclamp smooth mips")
matTable["W1"]["fill"] = Material("monkeyball/tex1_256x256_m_14dc2d9b3d102149_14.png", "noclamp smooth mips")
matTable["W1"]["wood"] = Material("monkeyball/tex1_256x256_m_14dc2d9b3d102149_14.png", "noclamp smooth mips")
matTable["W1"]["detail"] = Material("monkeyball/tex1_256x128_m_059147f31afd9c4e_14.png", "noclamp smooth mips")
matTable["W1"]["detail2"] = Material("monkeyball/tex1_256x64_m_ab77fed98fc3bd77_14.png", "noclamp smooth mips")
matTable["W1"]["detail3"] = Material("monkeyball/tex1_128x128_m_7b3fa64e7038b75e_14.png", "noclamp smooth mips")
matTable["W1"]["trim"] = Material("monkeyball/tex1_256x64_m_ab77fed98fc3bd77_14.png", "noclamp smooth mips")

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
        timer.Simple(3, function()
            if self.children then
                for i, v in ipairs(self.children) do
                    v.basePos = v:GetPos()
                    v.baseAngles = v:GetAngles()
                    v.parentDiff = (v:GetPos() - self:GetPos())
                    v.baseDir = v.parentDiff:GetNormalized()
                    v.baseDist = v.parentDiff:Length()
                    print("oh")
                end
            end
        end)
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
            self.baseAngle = self.animTable[self.currentItem].ang
        end
        if CurTime() > self.nextFrameTime then
            if not self.animTable[self.currentItem] then
                self.currentItem = 1
            end
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
            local physAng = Angle(self.animTable[self.currentItem].ang.p, self.animTable[self.currentItem].ang.y, self.animTable[self.currentItem].ang.r)
            self:GetPhysicsObject():UpdateShadow(self.animTable[self.currentItem].pos, 
                physAng, 
                self.nextFrameTime - CurTime() )
            if self.collisionObject then
                self.collisionObject:GetPhysicsObject():UpdateShadow(self.animTable[self.currentItem].pos, 
                physAng, 
                self.nextFrameTime - CurTime() )
            end
        end
        local lerp = 1 - (self.nextFrameTime - CurTime()) / ((self.animTable[self.currentItem].time / 60) - self.lastTime)
        local newPos = LerpVector(lerp,self.lastPos,self.animTable[self.currentItem].pos)
        local newAng = LerpAngle(lerp,self.lastAng,self.animTable[self.currentItem].ang)
        self:SetRealPos(newPos)
        self:SetRealAng(newAng)
        if self.children then
            for i, v in ipairs(self.children) do
                local newChildDir = Vector(v.baseDir.x, v.baseDir.y,v.baseDir.z)
                local newChildAng = v.baseDir:Angle()
                local firstAng = (newAng - self.baseAngle)
                local secondAng = Angle(v.baseAngles.p,v.baseAngles.y,v.baseAngles.r)
                secondAng:RotateAroundAxis(firstAng:Right(), firstAng.p)
                secondAng:RotateAroundAxis(firstAng:Up(), firstAng.y)
                secondAng:RotateAroundAxis(firstAng:Forward(), firstAng.r)
                local finalAng = secondAng
                --finalAng:RotateAroundAxis(finalAng:Right(),90)
                newChildDir:Rotate(newAng)
                v:GetPhysicsObject():UpdateShadow(self:GetPos() + (newChildDir * v.baseDist), finalAng, FrameTime())
            end
        end
        --self.collisionObject:SetPos(newPos)
        --self.collisionObject:SetAngles(physAng)
    end
    self:NextThink(CurTime())

    if self.Mesh.Phys then return true end
    if self.Mesh.CRC && meshCache[self.Mesh.CRC] then
        if SERVER then
            if not self.collider then
                self:PhysicsFromMesh(meshCache[self.Mesh.CRC].all)
                self:GetPhysicsObject():EnableCollisions( true )
                self:GetPhysicsObject():EnableMotion( false )
                self:EnableCustomCollisions(true)
            else
                self.collisionObject = ents.Create("prop_physics")
                print(self.collider)
                self.collisionObject:SetModel(self.collider)
                self.collisionObject:Spawn()
                self.collisionObject:PhysicsInitShadow(false, false)
                local tempPhys = self.collisionObject:GetPhysicsObject()
                local myPhys = tempPhys:GetMeshConvexes()
                for i, v in ipairs(myPhys) do
                    for n, p in ipairs(v) do
                        myPhys[i][n] = Vector(p.pos)
                    end
                end
                self.collisionObject:SetCustomCollisionCheck(true)
                self.collisionObject:SetNoDraw(true)
                self:PhysicsInitMultiConvex(myPhys)
                self:GetPhysicsObject():EnableCollisions( false )
                self:GetPhysicsObject():EnableMotion( false )
                self:EnableCustomCollisions(false)
                timer.Simple(3, function()
                   for i, v in ipairs(ents.GetAll()) do
                       if v:GetClass() ~= "ball" and v:GetClass() ~= "logic_collision_pair" then
                           constraint.NoCollide( self.collisionObject, v, 0, 0 )
                           print("nocollide")
                       end
                   end
                end)
            end
        end
        self.Mesh.Phys = true
    end
end

function ENT:OnRemove()
    if self.collisionObject then
        self.collisionObject:Remove()
    end
end

if not CLIENT then return end
function ENT:ShouldDraw()
    if not self.requestTimer then self.requestTimer = CurTime() + 3 end
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
    --self:SetRenderBounds(Vector(0, 0, 0), Vector(0, 0, 0), Vector(32768, 32768, 32768))
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


--hook.Remove( "HUDPaint", "meshtools.LoadOverlay" )
--hook.Add( "HUDPaint", "meshtools.LoadOverlay", function()
--    local bc = Color( 175, 175, 175, 135 )
--    local tc = Color( 225, 225, 225, 255 )
--
--    for _, ent in pairs( ents.FindByClass( "sent_meshtools" ) ) do
--        if not ent.Mesh then continue end
--        if ent.Mesh.Loaded then continue end
--
--        local scr = ( ent:GetPos() + Vector( 0, 0, 20 ) ):ToScreen()
--        draw.WordBox( 6, scr.x, scr.y, "Loading...", "DermaDefault", bc, tc )
--    end
--end )
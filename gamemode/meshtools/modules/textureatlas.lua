
/*

    A script to combine all textures of a group of props into a texture atlas.
    I had planned to use this for my meshtools project, as meshes can only
    use one material, but I did not forsee that without a custom shader, you can't
    repeat textures using an atlas.

*/

if not CLIENT then return end

local function nodeFind( self, w, h )
    if self.used then return nodeFind( self.right, w, h ) or nodeFind( self.down, w, h )
    elseif w <= self.w and h <= self.h then return self
    else return nil end
end

local function nodeSplit( self, w, h )
    self.used = true
    self.down = { x = self.x, y = self.y + h, w = self.w, h = self.h - h }
    self.right = { x = self.x + w, y = self.y, w = self.w - w, h = h }
    return self
end

local function nodeGrowRight( self, w, h )
    self.root = {
        used = true,
        x = 0,
        y = 0,
        w = self.root.w + w,
        h = self.root.h,
        down = self.root,
        right = { x = self.root.w, y = 0, w = w, h = self.root.h },
    }

    local node = nodeFind( self.root, w, h )
    if node then return nodeSplit( node, w, h ) else return nil end
end

local function nodeGrowDown( self, w, h )
    self.root = {
        used = true,
        x = 0,
        y = 0,
        w = self.root.w,
        h = self.root.h + h,
        down = { x = 0, y = self.root.h, w = self.root.w, h = h },
        right = self.root,
    }

    local node = nodeFind( self.root, w, h )
    if node then return nodeSplit( node, w, h ) else return nil end
end

local function nodeGrow( self, w, h )
    local canGrowDown = w <= self.root.w
    local canGrowRight = h <= self.root.h
    local shouldGrowDown = canGrowDown and self.root.w >= self.root.h + h
    local shouldGrowRight = canGrowRight and self.root.h >= self.root.w + w

    if shouldGrowRight then return nodeGrowRight( self, w, h )
    elseif shouldGrowDown then return nodeGrowDown( self, w, h )
    elseif canGrowRight then return nodeGrowRight( self, w, h )
    elseif canGrowDown then return nodeGrowDown( self, w, h )
    else return nil end
end

-- returns atlas, width, height
function MT_PackTextures( tbl )
    if #tbl <= 0 then return false end

    local sorted = {}
    for _, path in pairs( tbl ) do
        local tex = Material( path )
        sorted[#sorted + 1] = { tex = tex, w = tex:Width(), h = tex:Height() }
    end
    table.sort( sorted, function( a, b ) return math.max( a.w, a.h ) > math.max( b.w, b.h ) end )

    local pack = {
        tex = sorted,
        root = { x = 0, y = 0, w = sorted[1].w, h = sorted[1].h }
    }

    local node
    for _, tex in ipairs( pack.tex ) do
        node = nodeFind( pack.root, tex.w, tex.h )
        if node then tex.fit = nodeSplit( node, tex.w, tex.h )
        else tex.fit = nodeGrow( pack, tex.w, tex.h ) end
    end

    local ret = {}
    for _, node in pairs( pack.tex ) do
        if not node.fit then continue end

        ret[#ret + 1] = {
            tex = CreateMaterial( node.tex:GetName() .. "EX", "UnlitGeneric", {
                ["$ignorez"] = 1,
                ["$vertexcolor"] = 1,
                ["$vertexalpha"] = 1,
                ["$nolid"] = 1,
                ["$basetexture"] = node.tex:GetString( "$basetexture" ),
            } ),
            x = node.fit.x,
            y = node.fit.y,
            w = node.w,
            h = node.h,
        }
    end

    return ret, pack.root.w, pack.root.h
end

-- returns table of texture paths
function MT_GetTextures( tbl )
    local ret = {}
    for _, ent in pairs( tbl ) do
        if ent:GetClass() ~= "prop_physics" then continue end

        local tex = ent:GetMaterial()
        if tex ~= "" then ret[tex] = true continue end
        ret[ent:GetMaterials()[1]] = true
    end

    return table.GetKeys( ret )
end

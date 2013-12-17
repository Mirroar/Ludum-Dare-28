--[[

]]
TextureAtlas = class()

--[[
Creates a new TextureAtlas object based on a tileset.

@param baseFile (string): path to a valid image file
]]
function TextureAtlas:construct(baseFile)
    self:SetBaseFile(baseFile)
    self.spriteIndex = {}
end

--[[
Sets a new tileset for this TextureAtlas.
TODO: Any sprites based on this TextureAtlas will now use the new image file and retain their coordinates.

@param baseFile (string): path to a valid image file
]]
function TextureAtlas:SetBaseFile(baseFile)
    self.AssertArgumentType(baseFile, "string")

    self.baseFileName = baseFile
    self.fullImage = love.graphics.newImage(baseFile)
    self.fullImage:setFilter("linear", "nearest")
end

--[[
Get the currently used Tileset image.

@return (Image): the Image object currently used by this TextureAtlas
]]
function TextureAtlas:GetBaseFile()
    return self.fullImage
end

--[[
Get the path to the currently used tileset image.

@return (Image): the Image object currently used by this TextureAtlas
]]
function TextureAtlas:GetBaseFileName()
    return self.baseFileName
end

function TextureAtlas:DefineSprite(identifier, x, y, w, h)
    self.AssertArgumentType(x, "number")
    self.AssertArgumentType(y, "number")
    self.AssertArgumentType(w, "number")
    self.AssertArgumentType(h, "number")

    self.spriteIndex[identifier] = {
        quad = love.graphics.newQuad(x, y, w, h, self.fullImage:getWidth(), self.fullImage:getHeight()),
        width = w,
        height = h,
    }
end

function TextureAtlas:GetQuad(identifier)
    assert(self.spriteIndex[identifier])

    return self.spriteIndex[identifier].quad
end

function TextureAtlas:DrawSprite(identifier, x, y, rotation, scale)
    assert(self.spriteIndex[identifier])

    if not rotation then rotation = 0 end
    if not scale then scale = 1 end
    if not x then x = 0 end
    if not y then y = 0 end
    local spriteObject = self.spriteIndex[identifier]
    self.AssertArgumentType(x, "number")
    self.AssertArgumentType(y, "number")

    love.graphics.drawq(self:GetBaseFile(), spriteObject.quad, math.floor(x), math.floor(y), rotation / 180 * math.pi, scale, scale)
end
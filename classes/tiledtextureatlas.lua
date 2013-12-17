
TiledTextureAtlas = class(TextureAtlas)

function TiledTextureAtlas:construct(...)
    self._base.construct(self, ...)

    self.xSize = 16
    self.ySize = 16
    self.xPadding = 0
    self.yPadding = 0
    self.xOffset = 0
    self.yOffset = 0
end

function TiledTextureAtlas:SetTileSize(xSize, ySize)
    self.xSize = xSize
    self.ySize = ySize
end

function TiledTextureAtlas:SetTilePadding(xPadding, yPadding)
    self.xPadding = xPadding
    self.yPadding = yPadding
end

function TiledTextureAtlas:SetTileOffset(xOffset, yOffset)
    self.xOffset = xOffset
    self.yOffset = yOffset
end

function TiledTextureAtlas:DefineTile(identifier, x, y)
    self:DefineSprite(identifier, self.xOffset + (self.xPadding + self.xSize) * (x - 1), self.yOffset + (self.yPadding + self.ySize) * (y - 1), self.xSize, self.ySize)
end
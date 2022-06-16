-- tiled map class that works with any number of dimensions
Map = class()

function Map:isTransparent(tileType)
    return tileType == nil or tileType == 'entrance' or tileType == 'exit'
end

function Map:construct(...)
    print("init map")
    self.tileset = nil
    self.dimensions = #{...}
    self:SetSize(...)
    self.xTileSize = {}
    self.yTileSize = {}
    for i = 1, self.dimensions do
        self.xTileSize[i] = 16
        self.yTileSize[i] = 16
    end
    self.yTileSize[1] = 0
    if self.dimensions > 1 then
        self.xTileSize[2] = 0
    end
end

function Map:SetSize(...)
    if not self.tiles then self.tiles = {} end

    self:_SetSizeRecursive(self.tiles, self.dimensions, ...)
end

function Map:_SetSizeRecursive(table, dimension, size, ...)
    for i = 1, size do
        if dimension == 1 then
            table[i] = CreateTile()
        else
            table[i] = {}
            self:_SetSizeRecursive(table[i], dimension - 1, ...)
        end
    end

    --TODO: reduce table if size is less than before
end

function Map:GetSize(dimension)
    return self:_GetSizeRecursive(dimension or 1, self.tiles)
end

function Map:_GetSizeRecursive(dimension, table)
    if dimension == 1 then
        return #table
    else
        return self:_GetSizeRecursive(dimension - 1, table[1])
    end
end

function Map:GetTile(...)
    return self:_GetTileRecursive(self.tiles, self.dimensions, ...)
end

function Map:_GetTileRecursive(table, dimension, coord, ...)
    if dimension == 1 then
        return table[coord]
    else
        return self:_GetTileRecursive(table[coord], dimension - 1, ...)
    end
end

function Map:SetTile(...)
    return self:_SetTileRecursive(self.tiles, self.dimensions, ...)
end

function Map:_SetTileRecursive(table, dimension, coord, ...)
    if dimension == 1 then
        table[coord] = select(1, ...)
    else
        self:_SetTileRecursive(table[coord], dimension - 1, ...)
    end
end

function Map:SetTileset(tileset)
    self.AssertArgumentType(tileset, TextureAtlas)

    self.tileset = tileset
end

function Map:SetTileOffset(dimension, xOffset, yOffset)
    self.xTileSize[dimension] = xOffset
    self.yTileSize[dimension] = yOffset
end

function Map:GetScreenPosition(...)
    local coords = {...}
    local x, y = 0, 0
    for i = 1, self.dimensions do
        x = x + self.xTileSize[i] * (coords[i] - 1)
        y = y + self.yTileSize[i] * (coords[i] - 1)
    end

    return x, y
end

-- given a screen position, find tiles that are on that position
function Map:GetTileCoordinates(x, y, validityCallback)
    --TODO: create a better solution than brute-forcing it!
    return self:_GetTileCoordinatesRecursive()
end

function Map:_GetTileCoordinatesRecursive(dimension)
end

function Map:draw()
    self.AssertArgumentType(self.tileset, TextureAtlas)
    self.randomRadius = math.random(90, 100)
    if game.hasHelmet then
        self.randomRadius = 100 + self.randomRadius / 3 -- higher radius and less flickering
    end
    self.randomRadius = self.randomRadius * game.lightRadius

    self:_DrawRecursive(self.tiles, 1, 0, 0)
end

function Map:_DrawRecursive(table, dimension, currentX, currentY, tileX)
    for i = 1, #table do
        if dimension == self.dimensions then
            local tileType = table[i].tileType
            if tileType then
                -- tile brightness depends on distance to player
                local dx = player:GetX() * 16 - currentX - 16
                local dy = player:GetY() * 16 - currentY - 16
                local distance = math.sqrt(dx * dx + dy * dy)
                local brightness = (1 - (distance / self.randomRadius))
                local tileBrightness = table[i].brightness

                if game.state ~= 'ingame' then
                    brightness = brightness / 3
                    tileBrightness = tileBrightness / 2
                end

                if brightness > 0 or tileBrightness > 0 then
                    SetTileBrightness(table[i], brightness)
                    love.graphics.setColor(math.max(brightness, tileBrightness / 16), math.max(brightness, tileBrightness / 16), math.max(brightness, 3 * tileBrightness / 8), 1)
                    if tileType == game.goal.tileType then
                        self.tileset:DrawSprite("dirt2", currentX, currentY)
                    end
                    self.tileset:DrawSprite(tileType, currentX, currentY)

                    if not self:isTransparent(tileType) then
                        local tileY = i
                        if tileY > 1 and self:isTransparent(self:GetTile(tileX, tileY - 1).tileType) then
                            self.tileset:DrawSprite("border_down", currentX, currentY - 16)
                        end
                        if tileY < self:GetHeight() and self:isTransparent(self:GetTile(tileX, tileY + 1).tileType) then
                            self.tileset:DrawSprite("border_up", currentX, currentY + 16)
                        end
                        if tileX > 1 and self:isTransparent(self:GetTile(tileX - 1, tileY).tileType) then
                            self.tileset:DrawSprite("border_left", currentX - 16, currentY)
                        end
                        if tileX < self:GetWidth() and self:isTransparent(self:GetTile(tileX + 1, tileY).tileType) then
                            self.tileset:DrawSprite("border_right", currentX + 16, currentY)
                        end
                    end
                end
            end
        else
            self:_DrawRecursive(table[i], dimension + 1, currentX, currentY, i)
        end
        currentX = currentX + self.xTileSize[dimension]
        currentY = currentY + self.yTileSize[dimension]
    end
end

function SetTileType(self, tileType)
    self.tileType = tileType
    self.hp = 1
    if tileType then
        self.hp = tileData[tileType].hp or 1
    end
end

function CreateTile(tileType)
    local tile = {
        brightness = 0,
    }
    SetTileType(tile, tileType)

    return tile
end

function DamageTile(self, damage)
    damage = damage or 1
    self.hp = self.hp - damage
    if self.hp <= 0 then
        local rest = -self.hp
        SetTileType(self, tileData[self.tileType].transform)
        return rest
    end
end

function SetTileBrightness(self, b)
    b = b or 0
    if b > self.brightness then
        self.brightness = b
    end
end
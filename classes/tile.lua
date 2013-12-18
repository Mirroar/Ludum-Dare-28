Tile = class()

function Tile:construct(tileType)
    self:SetType(tileType)
    self.brightness = 0
end

function Tile:SetType(tileType)
    self.tileType = tileType
    self.hp = 1
    if tileType then
        self.hp = tileData[tileType].hp or 1
    end
end

function Tile:GetType()
    return self.tileType
end

function Tile:Damage(damage)
    damage = damage or 1
    self.hp = self.hp - damage
    if self.hp <= 0 then
        local rest = -self.hp
        self:SetType(tileData[self:GetType()].transform)
        return rest
    end
end

function Tile:SetBrightness(b)
    b = b or 0
    if b > self.brightness then
        self.brightness = b
    end
end

function Tile:GetBrightness()
    return self.brightness
end

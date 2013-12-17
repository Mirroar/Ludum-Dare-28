local durabilityMap = {
    ['dirt+'] = 2,
    ['dirt++'] = 3,
    ['dirt+++'] = 4,
    ['skeleton'] = 2,
    ['emerald'] = 5,
    ['tikimask'] = 15,
    ['goldidol'] = 15,
    ['goldscepter'] = 15,
    ['holygrail'] = 15,
    ['fountain'] = 15,
}

local transformationMap = {
    ['dirt+'] = 'dirt',
    ['dirt++'] = 'dirt+',
    ['dirt+++'] = 'dirt++',
    ['exit_wall'] = 'exit',
}

Tile = class()

function Tile:construct(tileType)
    self:SetType(tileType)
    self.brightness = 0
end

function Tile:SetType(tileType)
    self.tileType = tileType
    self.hp = 1
    self.durability = durabilityMap[self.tileType] or 1
end

function Tile:GetType()
    return self.tileType
end

function Tile:Damage(damage)
    damage = damage or 1
    self.hp = self.hp - (damage / self.durability)
    if self.hp <= 0 then
        local rest = -self.hp * self.durability
        self:SetType(transformationMap[self:GetType()])
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

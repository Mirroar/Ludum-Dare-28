Player = class()

function Player:construct(x, y)
    print("init player")
    self.x = x or 1
    self.y = y or 1
    self.animation = nil
    self.animTime = 0
    self.facing = "right"
end

function Player:SetFacing(facing)
    self.facing = facing
end

function Player:SetX(x)
    self.x = x
end

function Player:SetY(y)
    self.y = y
end

function Player:GetX()
    return self.x
end

function Player:GetY()
    return self.y
end

function Player:SetPosition(x, y)
    self:SetX(x)
    self:SetY(y)
    game.steps = game.steps + 1
end

function Player:SetAnimation(animation)
    self.animation = animation
    self.animTime = 0
end

local animationDirections = {
    up = {0, -1},
    down = {0, 1},
    right = {1, 0},
    left = {-1, 0},
}

function Player:GetAnimationPosition()
    if not self.animation then return 0, 0 end
    if string.find(self.animation, 'move_') == 1 and self.animTime < 0.2 then
        local direction = string.sub(self.animation, 6)
        local offsetDir = self.animTime * 5 - 1
        local offsetX = offsetDir * animationDirections[direction][1]
        local offsetY = offsetDir * animationDirections[direction][2] + (self.animTime - 0.1) * (self.animTime - 0.1) * 10 - 0.1
        return offsetX, offsetY
    elseif string.find(self.animation, 'hit_') == 1 and self.animTime < 0.2 then
        local direction = string.sub(self.animation, 5)
        local offsetDir = self.animTime * 5
        if self.animTime > 0.075 then
            offsetDir = -self.animTime * 3 + 0.585
        end
        local offsetX = offsetDir * animationDirections[direction][1]
        local offsetY = offsetDir * animationDirections[direction][2] + (self.animTime - 0.1) * (self.animTime - 0.1) * 10 - 0.1

        return offsetX, offsetY
    end

    return 0, 0
end

function Player:draw()
    love.graphics.push()
    local dir = 1
    if self.facing == 'left' then
        love.graphics.translate(16, 0)
        love.graphics.scale(-1, 1)
        dir = -1
    end
    local offsetX, offsetY = self:GetAnimationPosition()
    if game.drillDurability > 0 then
        textures:DrawSprite("player_drill", dir *(self.x + offsetX - 1) * 16, (self.y + offsetY - 1) * 16)
    else
        textures:DrawSprite("player", dir *(self.x + offsetX - 1) * 16, (self.y + offsetY - 1) * 16)
    end

    if game.hasHelmet then
        textures:DrawSprite("player_helmet", dir * (self.x + offsetX - 1) * 16, (self.y + offsetY - 1) * 16)
    end
    if game.hasDucktape and game.drillDurability <= 0 then
        textures:DrawSprite("player_ducktape", dir * (self.x + offsetX - 1) * 16, (self.y + offsetY - 1) * 16)
    end
    if game.hasAmulet then
        textures:DrawSprite("player_amulet", dir * (self.x + offsetX - 1) * 16, (self.y + offsetY - 1) * 16)
    end
    if game.hasChain then
        textures:DrawSprite("player_chain", dir * (self.x + offsetX - 1) * 16, (self.y + offsetY - 1) * 16)
    end
    if game.hasCape then
        textures:DrawSprite("player_cape", dir * (self.x + offsetX - 1) * 16, (self.y + offsetY - 1) * 16)
    end
    love.graphics.pop()
end

function Player:update(dt)
    self.animTime = self.animTime + dt
end
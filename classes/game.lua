Game = class()

    -- Kid Icarus
    -- Urn containing a powerful living being (pokéball)
    -- Ancient mechanism
    -- fountain of youth
    -- Holy grail
    -- Goblet of Fire
    -- Emperor Yian-Xin's loose change
    -- Cleopatra's Undergarments
    -- Kittens / Nyan Cat - pocket Sphynx
    -- TRex
    -- Doge
local goalConditions = {
    {
        name = "the Mask of Zuul",
        tileType = 'tikimask',
        basic = true,
    },
    {
        name = "the Idol of Garana",
        tileType = 'goldidol',
        basic = true,
    },
    {
        name = "the Scepter of Dha'Li",
        tileType = 'goldscepter',
        basic = true,
    },
    {
        name = "the Holy Grail",
        tileType = 'holygrail',
        basic = true,
    },
    {
        name = "the Fountain of Youth",
        tileType = 'fountain',
        basic = true,
    },
}

function Game:construct(state)
    self.state = state or "ingame"
    self.points = 0
    self.steps = 0
    self.maxDepth = 1
    self.durability = 150
    self.drillDurability = 0
    self.durabilityDrain = 1
    self.power = 1
    self.xOffset = 0
    self.yOffset = 0
    self.hasHelmet = false
    self.hasDucktape = false
    self.hasAmulet = false
    self.hasChain = false
    self.hasCape = false
    self.currentLevel = 1
    self.lightRadius = 1
    self.goal = goalConditions[math.random(1, #goalConditions)]
end

function Game:calculateScore()
    return self.points * 10 - self.steps + self.maxDepth * 2
end

function Game:AlterMap()
    self.lightRadius = 1
    if (math.random(1, 10)) == 1 and self.currentLevel > 2 then
        -- dark level
        self.lightRadius = 0.6
        log:insert("Something is eating away at the light", nil, "down", true)
    elseif (math.random(1, 10)) == 1 and self.currentLevel > 2 then
        -- cave-y level
        log:insert("There seems to be more of a natural cave here...", nil, "info", true)
        for x = 1, map:GetWidth() do
            for y = 1, map:GetHeight() do
                local tileType = map:GetTile(x, y):GetType()
                if tileType and tileType:sub(1, 4) == 'dirt' then
                    local distance = math.sqrt((x - map:GetWidth() / 2) * (x - map:GetWidth() / 2) + (y - map:GetHeight() / 2) * (y - map:GetHeight() / 2))
                    if math.random(1, map:GetWidth() / 3) > distance + 3 then
                        map:GetTile(x, y):SetType(nil)
                    end
                end
            end
        end
    end

    if self.goal.basic and self.currentLevel == 10 then
        -- find exit tile and replace it with the goal item
        for x = 1, map:GetWidth() do
            for y = 1, map:GetHeight() do
                if map:GetTile(x, y):GetType() == 'exit_wall' then
                    map:GetTile(x, y):SetType(self.goal.tileType)

                    -- create tough walls around it
                    local radius = 4
                    for x2 = -radius, radius do
                        for y2 = -radius, radius do
                            if (x2 ~= 0 or y2 ~= 0) and
                                x + x2 >= 1 and x + x2 <= map:GetWidth() and
                                y + y2 >= 1 and y + y2 <= map:GetHeight()
                            then
                                if (x2*x2 + y2*y2 < (radius-0.5)*(radius-0.5)) then
                                    map:GetTile(x + x2, y + y2):SetType("dirt+++")
                                elseif (x2*x2 + y2*y2 < (radius+0.5)*(radius+0.5)) then
                                    map:GetTile(x + x2, y + y2):SetType("dirt++")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
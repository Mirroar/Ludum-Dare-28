require('classes/class')
require('classes/textureatlas')
require('classes/tiledtextureatlas')
require('classes/tile')
require('classes/map')
require('classes/player')
require('classes/game')
require('classes/log')
require('classes/menu')
require('classes/particle')

require('lib/tserial')

function angle(x)
    -- helper function that makes sure angles are always between 0 and 360
    return x % 360
end

function lerp(min, max, percentile)
    -- linear interpolation between min and max
    return min + (max - min) * math.max(0, math.min(1, percentile))
end

function lerpAngle(min, max, percentile)
    -- linear interpolation for angles
    min = angle(min)
    max = angle(max)

    if min > max then
        -- switch everything around to make sure min is always less than max (necessary for next step)
        local temp = max
        max = min
        min = temp
        percentile = 1 - percentile
    end

    if math.abs(min - max) > 180 then
        -- interpolate in the opposite (shorter) direction by putting max on the other side of min
        max = max - 360
    end

    return angle(lerp(min, max, percentile))
end

-- randomly returns one of the numbered table's elements
function ChooseOne(table)
    if #table <= 0 then return nil end
    return table[math.random(1, #table)]
end

-- counts the number of elements in a table, optionally filtered by a callback
function Count(table, callback)
    local count = 0
    for k, v in pairs(table) do
        if not callback or callback(k, v) then
            count = count + 1
        end
    end
    return count
end




local zoom = 2
local tempName
local highscorePosition
local highscorePositionTarget
local goalX, goalY, timer, goalZoom

persistent = {
    playerName = "player",
    discoveredTiles = {},
    firstTime = true,
}
highscores = {}
sounds = {}

-- general-purpose information about every type of tile in the game
local tileData = {
    -- basic tiles
    ['dirt'] = {
        points = 0,
        messages = {},
        name = "Dirt",
        description = "Plain and simple.",
    },
    ['dirt+'] = {
        points = 0,
        messages = {},
        name = "Gravel",
        description = "Not quite as easy as dirt, but just as useless.",
    },
    ['dirt++'] = {
        points = 1,
        messages = {},
        name = "Loose stones",
        description = "They make it more difficult to dig through. Contains some value.",
    },
    ['dirt+++'] = {
        points = 2,
        messages = {},
        name = "Strong stone",
        description = "Very difficult to dig through. Try to avoid doing that.",
    },

    -- special level tiles
    ['entry'] = {
        points = 0,
        messages = {},
    },
    ['exit'] = {
        points = 0,
        messages = {},
    },
    ['exit_wall'] = {
        points = 0,
        messages = {},
        name = "A hole",
        description = "Leads deeper underground.",
    },

    -- valuables
    ['skeleton'] = {
        points = 10,
        messages = {"Wow, a skeleton! Wonder how long he's been down here..."},
        name = "Skeleton",
        description = "The remains of a human. Some scientists might be interested.",
    },
    ['fossil'] = {
        points = 15,
        messages = {"Alright, prehistoric snails!"},
        name = "Fossil",
        description = "An ancient organism, encrusted in stone.",
    },
    ['tablet'] = {
        points = 30,
        messages = {"You see a finely crafted stone tablet. On it are two drarves. The dwarves are digging."},
        name = "Stone Tablet",
        description = "Fine craftsmanship. Considering the low-tech tools available at the time.",
    },
    ['emerald'] = {
        points = 50,
        messages = {"Shiny!"},
        name = "Gem",
        description = "Precious and fragile, needs special handling when dog out.",
    },

    -- powerups
    ['ducktape'] = {
        points = 1,
        messages = {"Buried duck tape, seriously?!"},
        name = "Duck Tape",
        description = "Referred to as \"Duct Tape\" by our ancient forefathers. Rumored to have mystical repairing properties. Can be used multiple times.",
    },
    ['helmet'] = {
        points = 5,
        messages = {"This should help me see better."},
        name = "Mining Helmet",
        description = "Even the batteries are still intact. Very useful!",
    },
    ['ring'] = {
        points = 20,
        messages = {"You do not simply dig a ring out of a mountain!"},
        name = "One Ring",
        description = "Because nobody really needs two rings. Increases your power. Can be used multiple times.",
    },
    ['amulet'] = {
        points = 60,
        messages = {"It fits snugly around my neck. Bring on the bling!"},
        name = "Golden Amulet",
        description = "Magical or not, this is bound to be valuable! Helps you treat your pick better.",
    },
    ['chain'] = {
        points = 10,
        messages = {"I got nothing...", "It's too long for my neck? Still shiny, still taking it!"},
        name = "Silver Chain",
        description = "A bit too big to carry comfortably. Helps you treat your pick better.",
    },
    ['cape'] = {
        points = 20,
        messages = {"A fine garment!"},
        name = "Blue Cape",
        description = "Look like a superhero! Increases your power.",
    },
    ['drill'] = {
        points = 10,
        messages = {"Vrooooom!", "Hey dirt, here comes your spiral doom!"},
        name = "Battery-Powered Drill",
        description = "Superpowers! For a short while at least, and you don't have to use your pick.",
    },

    -- game enders / goal type stuff
    ["tikimask"] = {
        points = 0,
        messages = {},
        name = "Mask of Zuul",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
    },
    ["goldidol"] = {
        points = 0,
        messages = {},
        name = "Idol of Garana",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
    },
    ["goldscepter"] = {
        points = 0,
        messages = {},
        name = "Scepter of Dha'Li",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
    },
    ["holygrail"] = {
        points = 0,
        messages = {},
        name = "Holy Grail",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
    },
    ["fountain"] = {
        points = 0,
        messages = {},
        name = "Fountain of Youth",
        description = "Buried since time immemorial, this artifact can now be seen in a musem thanks to you!",
    },
}

local newGame
local function LoadTextures()
    textures = TiledTextureAtlas("images/exported.png")

    textures:DefineTile("player", 1, 1)
    textures:DefineTile("player_drill", 2, 1)
    textures:DefineTile("player_helmet", 3, 1)
    textures:DefineTile("player_ducktape", 4, 1)
    textures:DefineTile("player_amulet", 5, 1)
    textures:DefineTile("player_chain", 6, 1)
    textures:DefineTile("player_cape", 7, 1)

    textures:DefineTile("dirt", 1, 2)
    textures:DefineTile("dirt+", 2, 2)
    textures:DefineTile("dirt++", 3, 2)
    textures:DefineTile("dirt+++", 4, 2)
    textures:DefineTile("skeleton", 5, 2)
    textures:DefineTile("emerald", 6, 2)
    textures:DefineTile("ducktape", 7, 2)
    textures:DefineTile("helmet", 8, 2)

    textures:DefineTile("ring", 1, 3)
    textures:DefineTile("amulet", 2, 3)
    textures:DefineTile("chain", 3, 3)
    textures:DefineTile("entrance", 4, 3)
    textures:DefineTile("exit", 5, 3)
    textures:DefineTile("exit_wall", 6, 3)
    textures:DefineTile("tablet", 7, 3)
    textures:DefineTile("fossil", 8, 3)

    textures:DefineTile("cape", 1, 4)
    textures:DefineTile("dirt2", 2, 4)
    textures:DefineTile("dirt3", 3, 4)
    textures:DefineTile("drill", 7, 4)
    textures:DefineTile("button", 8, 4)

    textures:DefineTile("info", 1, 5)
    textures:DefineTile("warning", 2, 5)
    textures:DefineTile("up", 3, 5)
    textures:DefineTile("down", 4, 5)
    textures:DefineTile("particle1", 5, 5)
    textures:DefineTile("particle2", 6, 5)
    textures:DefineTile("particle3", 7, 5)
    textures:DefineTile("particle4", 8, 5)

    textures:DefineTile("tikimask", 1, 6)
    textures:DefineTile("goldidol", 2, 6)
    textures:DefineTile("goldscepter", 3, 6)
    textures:DefineTile("holygrail", 4, 6)
    textures:DefineTile("fountain", 5, 6)

    textures:DefineTile("border_up", 1, 7)
    textures:DefineTile("border_down", 2, 7)
    textures:DefineTile("border_left", 3, 7)
    textures:DefineTile("border_right", 4, 7)
end

local function LoadSounds()
    sounds = {
        destroy = {
            love.audio.newSource("sounds/Destroy1.wav", "static"),
            love.audio.newSource("sounds/Destroy2.wav", "static"),
            love.audio.newSource("sounds/Destroy3.wav", "static"),
            love.audio.newSource("sounds/Destroy4.wav", "static"),
        },
        step = {
            love.audio.newSource("sounds/Step1.wav", "static"),
            love.audio.newSource("sounds/Step2.wav", "static"),
            love.audio.newSource("sounds/Step3.wav", "static"),
        },
        hit = {
            love.audio.newSource("sounds/Hit1.wav", "static"),
            love.audio.newSource("sounds/Hit2.wav", "static"),
            love.audio.newSource("sounds/Hit3.wav", "static"),
            love.audio.newSource("sounds/Hit4.wav", "static"),
            love.audio.newSource("sounds/Hit5.wav", "static"),
            love.audio.newSource("sounds/LongHit1.wav", "static"),
            love.audio.newSource("sounds/LongHit2.wav", "static"),
            love.audio.newSource("sounds/LongHit3.wav", "static"),
            love.audio.newSource("sounds/LongHit4.wav", "static"),
        },
        menu = {
            love.audio.newSource("sounds/Menu.wav", "static"),
        },
        menu_confirm = {
            love.audio.newSource("sounds/UFO.wav", "static"),
        },
        powerup = {
            love.audio.newSource("sounds/UFO.wav", "static"),
        },
    }
end

function PlaySound(id)
    if sounds[id] then
        local sound = sounds[id][math.random(1, #sounds[id])]
        love.audio.rewind(sound)
        love.audio.play(sound)
    end
end

local function LoadHighscores()
    if love.filesystem.isFile("highscores.lua") then
        highscores = Tserial.unpack(love.filesystem.read("highscores.lua"), true)
    end
end

local function SaveHighscores()
    love.filesystem.write("highscores.lua", Tserial.pack(highscores))
end

local function LoadPersistent()
    if love.filesystem.isFile("persistent.lua") then
        persistentTemp = Tserial.unpack(love.filesystem.read("persistent.lua"), true)
        if persistentTemp then
            persistent = persistentTemp
        end
    end
end

local function SavePersistent()
    love.filesystem.write("persistent.lua", Tserial.pack(persistent))
end

local function InitMenu()
    menu = Menu()
    menu:AddItem("Start game", function()
        newGame()
    end)
    menu:AddItem("Change Name", function()
        tempName = persistent.playerName
        game.state = "changename"
    end)
    menu:AddItem("Highscores", function()
        game.state = "highscores"
        highscorePosition = 0
        highscorePositionTarget = 0
    end)
    menu:AddItem("Stuff you found", function()
        game.state = "achievements"
        highscorePosition = 0
        highscorePositionTarget = 0
    end)
    menu:AddItem("Exit", function()
        love.event.quit()
    end)
end

local function GenerateLevel()
    map = Map(20 + game.currentLevel * 2, 20 + game.currentLevel * 2)
    map:SetTileset(textures)
    map.GetTile = function(self, x, y) return self.tiles[x][y] end
    map.GetWidth = function(self) return self:GetSize(1) end
    map.GetHeight = function(self) return self:GetSize(2) end

    for x = 1, map:GetWidth() do
        for y = 1, map:GetHeight() do
            map:GetTile(x, y):SetType('dirt')
            if (math.random(1, 20 + game.currentLevel * 5)) > 30 then
                map:GetTile(x, y):SetType('dirt3')
            end
            if (math.random(1, 20 + game.currentLevel * 5)) > 60 then
                map:GetTile(x, y):SetType('dirt2')
            end

            if math.random(100 + game.currentLevel * 5) > 80 then
                map:GetTile(x, y):SetType('dirt+')
            end
            if math.random(100 + game.currentLevel * 5) > 95 then
                map:GetTile(x, y):SetType('dirt++')
            end
            if math.random(100 + game.currentLevel * 5) > 110 then
                map:GetTile(x, y):SetType('dirt+++')
            end

            -- valuable stuff
            if math.random(1000 + game.currentLevel * 10) > 997 then
                map:GetTile(x, y):SetType('skeleton')
            end
            if math.random(1000 + game.currentLevel * 10) > 1005 then
                map:GetTile(x, y):SetType('fossil')
            end
            if math.random(1000 + game.currentLevel * 10) > 1020 then
                map:GetTile(x, y):SetType('tablet')
            end
            if math.random(10000 + game.currentLevel * 10) > 9985 then
                map:GetTile(x, y):SetType('emerald')
            end

            -- powerups
            if math.random(10000) > 9975 then
                map:GetTile(x, y):SetType('ducktape')
            end
            if math.random(10000 + game.currentLevel * 10) > 9980 then
                map:GetTile(x, y):SetType('ring')
            end
            if math.random(10000) > 9980 and game.currentLevel >= 5 then
                map:GetTile(x, y):SetType('amulet')
            end
            if math.random(10000) > 9955 and game.currentLevel >= 2 then
                map:GetTile(x, y):SetType('chain')
            end
            if math.random(10000) > 9980 and game.currentLevel >= 7 then
                map:GetTile(x, y):SetType('cape')
            end
            if math.random(10000) > 9990 and game.currentLevel >= 4 then
                map:GetTile(x, y):SetType('drill')
            end
        end
    end
    -- place helmets in level 3, 5 and 7
    if (game.currentLevel == 3 or game.currentLevel == 5 or game.currentLevel == 7) then
        for i = 1, math.ceil(game.currentLevel / 2) do
            map:GetTile(math.random(1, map:GetWidth()), math.random(1, map:GetHeight())):SetType("helmet")
        end
    end

    -- last but not least, place an exit tile randomly in one of the corners
    map:GetTile(
        math.random(0, 1) * (map:GetWidth() - 10) + math.random(3, 7),
        math.random(0, 1) * (map:GetWidth() - 10) + math.random(3, 7)
    ):SetType('exit_wall')
    player = Player(math.floor(map:GetWidth() / 2), math.floor(map:GetHeight() / 2))
    map:GetTile(player:GetX(), player:GetY()):SetType("entrance")

    -- allow game controller to alter the level (to place goal tiles, etc)
    game:AlterMap()
end

newGame = function(state)
    game = Game(state or "ingame")
    if (state == "menu") then
        InitMenu()
    end

    log = Log(5)
    log:insert("You have discovered an unknown cave, and rumor has it "..game.goal.name, nil, "info", true)
    log:insert("lies buried deep under it. You only had time to bring one pick, but if you can use it to", nil, nil, true)
    log:insert("dig up your target, your archeology \"friends\" will never be able to doubt you again!", nil, nil, true)
    log:insert()

    GenerateLevel()
end

function love.load()
    love.filesystem.setIdentity("daretodig")
    love.graphics.setNewFont(12)
    LoadTextures()
    LoadSounds()
    LoadHighscores()
    LoadPersistent()

    particles = Particle()

    newGame("menu")
    if persistent.firstTime then
        game.state = 'changename'
        tempName = persistent.playerName
    end
end

local function AddHighscore()
    table.insert(highscores, {
        name = persistent.playerName,
        score = game:calculateScore(),
    })
    table.sort(highscores, function(a, b) return a.score > b.score end)
end

function love.keypressed(key, isrepeat)
    if game.state == "ingame" then
        local targetX = nil
        local targetY = nil
        local px, py

        if key == 'up' and player:GetY() > 1 then
            targetX = player:GetX()
            targetY = player:GetY() - 1
            px = targetX * 16 - 8
            py = targetY * 16
            dir = key
        elseif key == 'down' and player:GetY() < map:GetHeight() then
            targetX = player:GetX()
            targetY = player:GetY() + 1
            px = targetX * 16 - 8
            py = targetY * 16 - 16
            dir = key
        elseif key == 'left' and player:GetX() > 1 then
            targetX = player:GetX() - 1
            targetY = player:GetY()
            px = targetX * 16
            py = targetY * 16 - 8
            dir = key
            player:SetFacing('left')
        elseif key == 'right' and player:GetX() < map:GetWidth() then
            targetX = player:GetX() + 1
            targetY = player:GetY()
            px = targetX * 16 - 16
            py = targetY * 16 - 8
            player:SetFacing('right')
            dir = key
        elseif key == 'return' and map:GetTile(player:GetX(), player:GetY()):GetType() == 'exit' then
            game.currentLevel = game.currentLevel + 1
            game.maxDepth = game.currentLevel
            log:insert()
            if game.durability < 100 then
                log:insert("I spent a bit of time taking care of my pickaxe. It seems more durable.", nil, 'up')
                game.durability = lerp(game.durability, 100, 0.6)
            end
            log:insert("Okay, this is level "..game.currentLevel.." of this cave, I think...", nil, 'info')
            GenerateLevel()
        end

        if targetX and targetY then
            local targetType = map:GetTile(targetX, targetY):GetType()
            if not map:isTransparent(targetType) then
                -- solid tile
                for i = 1, 10 do
                    particles:insertDirt(px, py, math.random(-30, 30), math.random(-30, 30))
                end
                local power = game.power
                if game.drillDurability > 0 then
                    power = 10
                end
                local destroyed = map:GetTile(targetX, targetY):Damage(power)

                if not destroyed then
                    PlaySound("hit")
                else
                    PlaySound("destroy")
                    while destroyed do
                        if tileData[targetType].points or tileData[targetType].messages then
                            game.points = game.points + (tileData[targetType].points or 0)
                            log:insert(ChooseOne(tileData[targetType].messages), tileData[targetType].points, targetType)
                        end
                        if not persistent.discoveredTiles[targetType] then
                            persistent.discoveredTiles[targetType] = {
                                count = 0,
                            }
                        end
                        persistent.discoveredTiles[targetType].count = persistent.discoveredTiles[targetType].count + 1

                        -- special tile mining effects
                        if targetType == "dirt+++" then
                            if math.random(1, 5) == 1 then
                                log:insert("You permanently damage your pickage on the hard stone wall.", nil, "down", true)
                                game.durabilityDrain = 1.05 * game.durabilityDrain
                            end
                        elseif targetType == "ducktape" then
                            game.durability = game.durability + 20
                            game.hasDucktape = true
                            log:insert("You restore some of your pick's durability.", nil, "up", true)
                            PlaySound('powerup')
                        elseif targetType == "helmet" then
                            if not game.hasHelmet then
                                game.hasHelmet = true
                                log:insert("Your light radius has increased.", nil, "up", true)
                                PlaySound('powerup')
                            end
                        elseif targetType == "ring" then
                            game.power = game.power + 0.3
                            log:insert("You can see the weak spots in the walls better now", nil, "up", true)
                            PlaySound('powerup')
                        elseif targetType == "amulet" then
                            if not game.hasAmulet then
                                log:insert("Your feel calm.", nil, "up", true)
                                game.durabilityDrain = game.durabilityDrain * 0.9
                                game.hasAmulet = true
                                PlaySound('powerup')
                            end
                        elseif targetType == "chain" then
                            if not game.hasChain then
                                log:insert("Your feel power flowing through your veins", nil, "up", true)
                                game.power = game.power + 0.5
                                game.hasChain = true
                                PlaySound('powerup')
                            end
                        elseif targetType == "cape" then
                            if not game.hasCape then
                                game.hasCape = true
                                log:insert("Your feel soothed.", nil, "up", true)
                                game.durabilityDrain = game.durabilityDrain * 0.85
                                PlaySound('powerup')
                            end
                        elseif targetType == "drill" then
                            if game.drillDurability > 0 then
                                log:insert("You use this drill's battery to power up your own", nil, "up", true)
                                game.drillDurability = game.drillDurability + 5
                            end
                            game.drillDurability = game.drillDurability + 10
                            PlaySound('powerup')
                        elseif targetType == game.goal.tileType then
                            -- OH MA GERD
                            game.points = game.points + 500
                            game.state = "win"
                            timer = 0
                            goalX = (targetX * 16 - 16 + game.xOffset) * zoom
                            goalY = (targetY * 16 - 16 + game.yOffset) * zoom
                            goalZoom = zoom
                            AddHighscore()
                            SaveHighscores()
                            SavePersistent()
                        end

                        if not map:isTransparent(map:GetTile(targetX, targetY):GetType()) then
                            targetType = map:GetTile(targetX, targetY):GetType()
                            destroyed = map:GetTile(targetX, targetY):Damage(destroyed)
                        else
                            destroyed = false
                        end
                    end
                end

                if map:isTransparent(map:GetTile(targetX, targetY):GetType()) then
                    -- tile is now empty, move into it
                    player:SetPosition(targetX, targetY)
                    player:SetAnimation("move_"..dir)
                else
                    player:SetAnimation("hit_"..dir)
                end

                if game.drillDurability > 0 then
                    game.drillDurability = game.drillDurability - 1 * game.durabilityDrain
                else
                    local temp = game.durability
                    game.durability = game.durability - 1 * game.durabilityDrain
                    if temp > 10 and game.durability <= 10 then
                        log:insert("Uh-oh, looks like my pickaxe is about to break...", nil, "warning")
                    end
                end
            else
                player:SetPosition(targetX, targetY)
                player:SetAnimation("move_"..dir)
                PlaySound('step')
            end
        end
    elseif game.state == 'menu' then
        menu:keypressed(key, isrepeat)
    elseif game.state == 'win' then
        if key == 'return' then
            newGame('menu')
        end
    elseif game.state == 'changename' then
        if key == 'return' then
            persistent.playerName = tempName
            SavePersistent()
            game.state = "menu"
            persistent.firstTime = false
        elseif key == 'escape' then
            game.state = "menu"
            persistent.firstTime = false
        elseif key == 'backspace' then
            tempName = string.sub(tempName, 1, string.len(tempName) - 1)
        elseif string.find("1234567890 abcdefghijklmniopqrstuvwxyz", key) then
            if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                key = key:upper()
            end
            tempName = tempName..key
        end
    elseif game.state == 'gameover' then
        if key == ' ' then
            newGame('ingame')
        elseif key == 'return' then
            newGame('menu')
        end
    elseif game.state == 'highscores' or game.state == 'achievements' then
        if key == "return" or key == "escape" then
            game.state = "menu"
        end
    end
end

function love.update(delta)
    if game.durability <= 0 and game.state == "ingame" then
        -- end the game
        game.state = "gameover"

        AddHighscore()
        SaveHighscores()
        SavePersistent()
    elseif game.state == "win" then
        goalZoom = lerp(goalZoom, 10, delta)
        goalX = lerp(goalX, love.graphics.getWidth() / 2 - 10 * 16 / 2, delta)
        goalY = lerp(goalY, love.graphics.getHeight() / 2 - 10 * 16 / 2, delta)
        timer = timer + delta
    elseif game.state == "menu" then
        menu:update(delta)
    elseif game.state == "highscores" or game.state=="achievements" then
        if love.keyboard.isDown('up') then
            highscorePositionTarget = highscorePositionTarget - delta * 500
            if highscorePositionTarget < 0 then
                highscorePositionTarget = 0
            end
        elseif love.keyboard.isDown('down') then
            highscorePositionTarget = highscorePositionTarget + delta * 500
            if game.state == "highscores" then
                if highscorePositionTarget > #highscores * 20 then
                    highscorePositionTarget = #highscores * 20
                end
            elseif game.state == "achievements" then
                if highscorePositionTarget > Count(tileData, function(k, v) return v.description end) * 50 - love.graphics.getHeight() + 100 then
                    highscorePositionTarget = Count(tileData, function(k, v) return v.description end) * 50 - love.graphics.getHeight() + 100
                end
            end
        end

        highscorePosition = lerp(highscorePosition, highscorePositionTarget, delta * 8)
    end
    player:update(delta)
    particles:update(delta)
end

function love.draw()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.clear()

    -- draw map and player
    love.graphics.push()
    love.graphics.scale(zoom)

    local screenMargin = 280
    if player:GetX() * 16 + game.xOffset > love.graphics.getWidth() / zoom - screenMargin / zoom then
        game.xOffset = lerp(game.xOffset, love.graphics.getWidth() / zoom - player:GetX() * 16 - screenMargin / zoom, 0.1)
    end
    if player:GetY() * 16 + game.yOffset > love.graphics.getHeight() / zoom - screenMargin / zoom then
        game.yOffset = lerp(game.yOffset, love.graphics.getHeight() / zoom - player:GetY() * 16 - screenMargin / zoom, 0.1)
    end
    if player:GetX() * 16 + game.xOffset < screenMargin / zoom then
        game.xOffset = lerp(game.xOffset, screenMargin / zoom - player:GetX() * 16, 0.1)
    end
    if player:GetY() * 16 + game.yOffset < screenMargin / zoom then
        game.yOffset = lerp(game.yOffset, screenMargin / zoom - player:GetY() * 16, 0.1)
    end
    --if (game.yOffset > 0) then
    --    game.yOffset = 0
    --end
    love.graphics.translate(game.xOffset, game.yOffset)

    love.graphics.setColorMode('modulate')
    map:draw()
    love.graphics.setColor(255, 255, 255, 255)
    if game.state ~= "ingame" then
        love.graphics.setColor(128, 128, 128, 255)
    end
    player:draw()
    particles:draw()
    love.graphics.pop()

    if game.state == 'gameover' then
        love.graphics.push()
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.printf("GAME OVER!", 0, 100, love.graphics.getWidth(), "center")
        love.graphics.printf("Total Score: "..game:calculateScore(), 0, 120, love.graphics.getWidth(), "center")
        love.graphics.printf("Press <Space> to restart or <Enter> to go to the menu", 0, 150, love.graphics.getWidth(), "center")

        love.graphics.printf("Highscores:", 0, 200, love.graphics.getWidth(), "center")
        for i = 1, math.min(10, #highscores) do
            if highscores[i].name == persistent.playerName and highscores[i].score == game:calculateScore() then
                love.graphics.setColor(128, 255, 255, 255)
            else
                love.graphics.setColor(255, 255, 255, 255)
            end
            love.graphics.printf(i..". "..highscores[i].name.." - "..highscores[i].score, 0, 200 + i * 20, love.graphics.getWidth(), "center")
        end

        love.graphics.pop()
    end

    if game.state == 'ingame' then
        -- draw durability meter
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Durability: ", 10, 10)
        love.graphics.setColor(255, math.min(255, 255 * game.durability / 100), math.min(255, 255 * game.durability / 100))
        local width = love.graphics.getFont():getWidth("Durability: ")
        love.graphics.rectangle("fill", 10 + width, 10, game.durability, 12)
        love.graphics.setColor(128, 128, 255)
        love.graphics.rectangle("fill", 10 + game.durability + width, 10, game.drillDurability, 12)

        -- stats
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.print("Steps taken: "..game.steps, 10, 30)
        love.graphics.print("Current level: "..game.maxDepth, 10, 50)
        love.graphics.print("Valuable Stuff: "..game.points, 10, 70)

        love.graphics.printf("Goal: Find "..game.goal.name.." in the depths of the cave", 10, 10, love.graphics.getWidth() - 20, "right")

        -- level exit notice
        if (map:GetTile(player:GetX(), player:GetY()):GetType() == 'exit') then
            love.graphics.printf("There is a hole here. Press <Enter> to go to the next level", 0, 100, love.graphics.getWidth(), "center")
        end
    end

    if game.state == "ingame" or game.state == "gameover" then
        -- message log
        love.graphics.push()
        love.graphics.translate(10, love.graphics.getHeight() - 5 * 20 - 10)
        log:draw()
        love.graphics.pop()
    end

    love.graphics.setColor(255, 255, 255, 255)
    if game.state == "menu" or game.state == "changename" then
        love.graphics.setNewFont(64)
        love.graphics.setColor(0, 0, 0, 255)
        love.graphics.printf("Dare to Dig!", 5, 5 + 100, love.graphics.getWidth(), "center")
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.printf("Dare to Dig!", 0, 100, love.graphics.getWidth(), "center")
        love.graphics.setNewFont(12)
    end

    if game.state == "menu" then
        love.graphics.push()
        love.graphics.translate(0, 200)
        menu:draw()
        love.graphics.pop()
    elseif game.state == "win" then
        -- draw goal item
        love.graphics.setColor(255, 255, 255, 255 / 20 * goalZoom)
        for i = 1, 10 do
            local angle = (i * math.pi/5 + goalZoom - timer / 2) % (math.pi * 2)
            love.graphics.arc(
                "fill",
                goalX + 8 * goalZoom,
                goalY + 8 * goalZoom,
                love.graphics.getWidth(),
                angle,
                angle + math.pi/100 * goalZoom
            )
        end
        love.graphics.setColor(255, 255, 255, 255)
        textures:DrawSprite(game.goal.tileType, goalX, goalY, 0, goalZoom)

        if timer > 5 then
            local alpha = math.min(timer - 5, 2) / 2
            love.graphics.setNewFont(32)
            love.graphics.setColor(0, 0, 0, 255 * alpha)
            love.graphics.printf("Congratulations!", 3, 3+love.graphics.getHeight() / 2 + 10 * 10, love.graphics.getWidth(), "center")
            love.graphics.setColor(255, 255, 255, 255 * alpha)
            love.graphics.printf("Congratulations!", 0, love.graphics.getHeight() / 2 + 10 * 10, love.graphics.getWidth(), "center")
            love.graphics.setNewFont(12)
        end
        if timer > 7 then
            local alpha = math.min(timer - 7, 1)
            love.graphics.setNewFont(24)
            love.graphics.setColor(0, 0, 0, 255 * alpha)
            love.graphics.printf("You have found "..game.goal.name.."! Your deeds shall always be remembered!", 2, 2+love.graphics.getHeight() / 2 + 10 * 10 + 40, love.graphics.getWidth(), "center")
            love.graphics.setColor(255, 255, 255, 255 * alpha)
            love.graphics.printf("You have found "..game.goal.name.."! Your deeds shall always be remembered!", 0, love.graphics.getHeight() / 2 + 10 * 10 + 40, love.graphics.getWidth(), "center")

            love.graphics.setColor(0, 0, 0, 255 * alpha)
            love.graphics.printf("Final Score: "..game:calculateScore(), 2, 2+love.graphics.getHeight() / 2 - 10 * 10 - 40, love.graphics.getWidth(), "center")
            love.graphics.setColor(255, 255, 255, 255 * alpha)
            love.graphics.printf("Final Score: "..game:calculateScore(), 0, love.graphics.getHeight() / 2 - 10 * 10 - 40, love.graphics.getWidth(), "center")

            love.graphics.setNewFont(16)
            love.graphics.setColor(0, 0, 0, 255 * alpha)
            love.graphics.printf("Press <Enter> to return to menu", 2, 2+love.graphics.getHeight() / 2 - 10 * 10 - 10, love.graphics.getWidth(), "center")
            love.graphics.setColor(255, 255, 255, 255 * alpha)
            love.graphics.printf("Press <Enter> to return to menu", 0, love.graphics.getHeight() / 2 - 10 * 10 - 10, love.graphics.getWidth(), "center")
            love.graphics.setNewFont(12)
        end
    elseif game.state == "changename" then
        love.graphics.printf("Please enter your name.", 0, 200, love.graphics.getWidth(), "center")
        love.graphics.printf("Enter up to 20 alphanumeric characters.", 0, 220, love.graphics.getWidth(), "center")
        love.graphics.printf("Press <Enter> to confirm, <Esc> to cancel", 0, 250, love.graphics.getWidth(), "center")
        love.graphics.printf(tempName.."|", 0, 300, love.graphics.getWidth(), "center")
    elseif game.state == "highscores" then
        if #highscores <= 0 then
            love.graphics.printf("There are no highscores yet. Get playing!", 0, 100, love.graphics.getWidth(), "center")
        end
        for i, item in ipairs(highscores) do
            love.graphics.printf(i..". "..highscores[i].name.." - "..highscores[i].score, 0, 200 + i * 20 - highscorePosition, love.graphics.getWidth(), "center")
        end
    elseif game.state == "achievements" then
        -- sort by num found or something
        local achievementSort = {} -- TODO: init once when achievement screen is accessed
        for tileType, _ in pairs(tileData) do
            table.insert(achievementSort, tileType)
        end
        table.sort(achievementSort, function(a, b)
            local aFound = persistent.discoveredTiles[a] and persistent.discoveredTiles[a].count or 0
            local bFound = persistent.discoveredTiles[b] and persistent.discoveredTiles[b].count or 0

            return aFound > bFound
        end)

        local i = 0
        for _, tileType in ipairs(achievementSort) do
            local item = tileData[tileType]
            if item.description then
                i = i + 1
                local showType = "dirt"
                local name = "???"
                local text = ""
                local count = ""
                if persistent.discoveredTiles[tileType] then
                    showType = tileType
                    name = item.name
                    text = item.description
                    count = persistent.discoveredTiles[tileType].count
                end
                textures:DrawSprite(showType, 50, i * 50 - highscorePosition, 0, 2)
                love.graphics.setColor(0, 0, 0, 255)
                love.graphics.setColorMode("modulate")
                love.graphics.printf(count, 51, i * 50 + 1 - highscorePosition, 30, "right")
                love.graphics.setColor(255, 255, 255, 255)
                love.graphics.setColorMode("replace")
                love.graphics.printf(count, 50, i * 50 - highscorePosition, 30, "right")
                love.graphics.printf(name, 90, i * 50 - highscorePosition, love.graphics.getWidth() - 90 - 50, "left")
                love.graphics.printf(text, 90, i * 50 + 16 - highscorePosition, love.graphics.getWidth() - 90 - 50, "left")
            end
        end
    end
end
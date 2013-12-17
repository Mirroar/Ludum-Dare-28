Menu = class()

function Menu:construct()
    self.items = {}
    self.animTimer = 0
    self.activeItem = 1
end

function Menu:AddItem(title, callback)
    table.insert(self.items, {
        title = title,
        callback = callback,
    })
end

function Menu:update(delta)
    self.animTimer = self.animTimer + delta
end

function Menu:keypressed(key, isrepeat)
    if key == 'up' then
        if self.activeItem <= 1 then
            self.activeItem = #self.items
        else
            self.activeItem = self.activeItem - 1
        end
        PlaySound("menu")
    elseif key == 'down' then
        if self.activeItem >= #self.items then
            self.activeItem = 1
        else
            self.activeItem = self.activeItem + 1
        end
        PlaySound("menu")
    elseif key == 'return' then
        self.items[self.activeItem].callback()
        PlaySound("menu_confirm")
    end
end

function Menu:draw()
    for i, item in ipairs(self.items) do
        love.graphics.printf(item.title, 0, (i - 1) * 20, love.graphics.getWidth(), "center")
        if i == self.activeItem then
            local offset = 80 + math.sin(self.animTimer * 5) * 7
            love.graphics.push()
            love.graphics.translate(love.graphics.getWidth() / 2, 0)
            textures:DrawSprite("player", -offset, (i - 1) * 20)
            love.graphics.scale(-1, 1)
            textures:DrawSprite("player", -offset, (i - 1) * 20)
            love.graphics.pop()
        end
    end
end
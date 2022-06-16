Log = class()

function Log:construct(numLines)
    self.numLines = numLines or 5
    self.lines = {}
end

function Log:insert(text, points, tileIcon, noEscape)
    local padding = '"'
    if noEscape then padding = '' end
    table.insert(self.lines, {
        text = text and padding..text..padding,
        points = points,
        tileIcon = tileIcon,
    })
end

function Log:draw()
    love.graphics.setColor(1, 1, 1, 1)
    local count = math.max(0, self.numLines - #self.lines)
    for i = math.max(1, #self.lines - self.numLines + 1), #self.lines do
        local line = self.lines[i]
        if line.points then
            love.graphics.print("+"..line.points, 20, count * 20)
        end
        if line.text then
            love.graphics.print(line.text, 60, count * 20)
        end
        if line.tileIcon then
            textures:DrawSprite(line.tileIcon, 0, count * 20)
        end

        count = count + 1
    end
end

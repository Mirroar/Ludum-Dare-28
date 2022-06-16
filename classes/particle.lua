Particle = class()

function Particle:construct()
    self.particles = {}
end

function Particle:insertDirt(x, y, vx, vy)
    table.insert(self.particles, {
        x = x,
        y = y,
        z = 3 + math.random(-50, 50) / 10, -- height
        vx = vx,
        vy = vy,
        vz = 0,
        g = -200, -- gravity acceleration
        decay = 1, -- rate of decay
        alpha = 255,
        texture = "particle"..(5 - math.floor(math.sqrt(math.random(1, 16))))
    })
end

function Particle:update(delta)
    for i, particle in ipairs(self.particles) do
        particle.x = particle.x + particle.vx * delta
        particle.y = particle.y + particle.vy * delta
        particle.z = particle.z + particle.vz * delta + particle.g * delta * delta / 2
        particle.vz = particle.vz + delta * particle.g

        if particle.z < 0 then
            particle.z = -particle.z
            particle.vx = 0.8 * particle.vx
            particle.vy = 0.8 * particle.vy
            particle.vz = -0.8 * particle.vz
        end
        particle.alpha = lerp(particle.alpha, 0, delta * particle.decay)
    end

    -- prune vanishing particles
    for i = #self.particles, 1, -1 do
        if math.random(1, 100) > self.particles[i].alpha then
            table.remove(self.particles, i)
        end
    end
end

function Particle:draw()
    for _, particle in pairs(self.particles) do
        love.graphics.setColor(1, 1, 1, particle.alpha / 255)
        --love.graphics.point(particle.x, particle.y - particle.z)
        textures:DrawSprite(particle.texture, particle.x, particle.y - particle.z)
    end
end

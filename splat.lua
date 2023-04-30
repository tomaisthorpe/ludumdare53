local Class = require("hump.class")

local Splat = Class {
    init = function(self, x, y)
        local poop = love.graphics.newImage("assets/poop.png")

        local ps = love.graphics.newParticleSystem(poop, 32)
        ps:setParticleLifetime(0.5, 1)
        ps:setEmissionRate(10)
        ps:setSizeVariation(1)
        ps:setSizes(1, 0.1)
        ps:setSpeed(-100, 100)
        ps:setLinearAcceleration(-100, -50, 100, 100)
        ps:setColors(1, 1, 1, 1, 1, 1, 1, 0)
        ps:setRotation(0, math.pi * 2)
        ps:setEmitterLifetime(0.2)

        ps:pause()

        self.ps = ps
    end,
}

function Splat:update(dt)
    self.ps:update(dt)
end

function Splat:draw()
    love.graphics.draw(self.ps, 0, 0)
end

function Splat:poopAt(x, y)
    self.ps:moveTo(x, y)
    self.ps:reset()
    self.ps:start()
end

return Splat

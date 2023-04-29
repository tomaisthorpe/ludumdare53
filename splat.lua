local Class = require("hump.class")

local Splat = Class {
    init = function(self, x, y)
        local poop = love.graphics.newImage("assets/poop.png")

        local ps = love.graphics.newParticleSystem(poop, 32)
        ps:setParticleLifetime(1, 2)
        ps:setEmissionRate(10)
        ps:setSizeVariation(1)
        ps:setSizes(1, 0.1)
        ps:setSpeed(-100, 100)
        ps:setLinearAcceleration(-100, -50, 100, 100)
        ps:setColors(1, 1, 1, 1, 1, 1, 1, 0)
        ps:setRotation(0, math.pi * 2)

        self.ps = ps
    end,
}

function Splat:update(dt)
    self.ps:update(dt)
end

function Splat:draw()
    love.graphics.draw(self.ps, 400, 600)
end

return Splat

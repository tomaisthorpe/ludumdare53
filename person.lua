local Class = require("hump.class")
local Poop = require("poop")

local Person = Class {
    init = function(self, game, world, x, y)
        self.game = game
        self.world = world
        self.image = love.graphics.newImage("assets/person.png")

        self.object = world:newRectangleCollider(x-32, y-96/2, 64, 96)
        self.object:setCollisionClass('Person')
        self.object:setObject(self)
        self.object:setFixedRotation(true)
        self.object:setLinearDamping(10)
    end,
    goingRight = true,
    dead = false,
    speed = 5,
}

function Person:destroy()
    if self.dead == false and self.object then
        self.object:destroy()
        self.dead = true
    end

end

function Person:getX()
    return self.object:getX()
end

function Person:getY()
    return self.object:getY()
end

function Person:update(dt)
end

function Person:draw()
    if self.dead then
        return
    end

    love.graphics.push()

    love.graphics.translate(self:getX(), self:getY())
    love.graphics.setColor(1, 1, 1)

    if not self.goingRight then
        love.graphics.scale(-1, 1)
    end

    love.graphics.translate(-32, -96/2)

    love.graphics.draw(self.image)

    love.graphics.pop()
end

return Person

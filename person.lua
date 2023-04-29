local Class = require("hump.class")
local config = require("config")

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
    speed = 10,


    frame = 0,
    fps = 10,
    timer = 0,
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
    if self.object:enter('Poop') then
        local collision = self.object:getEnterCollisionData('Poop')
        local object = collision.collider:getObject()

        if object then
            object:destroy()
            self.game:addHit()
        end
    end

    if self.object:getX() < 0 or self.object:getX() > config.levelWidth then
        self:destroy()
    end

    self.object:setLinearVelocity(30, 0)

    self.timer = self.timer + dt

    if self.timer > 1 / self.fps then
        self.frame = self.frame + 1
        if self.frame > 7 then self.frame = 0 end

        self.timer = 0
    end
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

    love.graphics.scale(4, 4)

    local quad = love.graphics.newQuad((self.frame + 1) * 16, 0, 16, 24, self.image:getWidth(), self.image:getHeight())

    love.graphics.draw(self.image, quad)

    love.graphics.pop()
end

return Person

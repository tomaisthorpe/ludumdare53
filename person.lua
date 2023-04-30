local Class = require("hump.class")
local config = require("config")

local Person = Class {
    init = function(self, game, world, x, y, goingRight)
        self.game = game
        self.world = world
        self.image = love.graphics.newImage("assets/person.png")
        self.splat = love.graphics.newImage("assets/person-splat.png")
        self.goingRight = goingRight

        self.object = world:newRectangleCollider(x, y - 45, 48, 96)
        self.object:setCollisionClass('Person')
        self.object:setObject(self)
        self.object:setFixedRotation(true)
        self.object:setLinearDamping(10)
    end,
    dead = false,
    speed = 40,
    walkingSpeed = 40,
    runningSpeed = 100,

    hits = 0,

    frame = 0,
    baseFPS = 10,
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

function Person:getFPS()
    return self.baseFPS * (self.speed / self.walkingSpeed)
end

function Person:getY()
    return self.object:getY()
end

function Person:update(dt)
    if self.dead then
        return
    end

    if self.object:enter('Poop') then
        local collision = self.object:getEnterCollisionData('Poop')
        local object = collision.collider:getObject()

        if object then
            object:destroy()
            self.game:addHit()
        end

        self.hits = self.hits + 1
        self.speed = self.runningSpeed
    end

    if self.object:getX() < -100 or self.object:getX() > config.levelWidth + 100 then
        if self.hits == 0 then
            self.game:damage()
        end

        self:destroy()
        return
    end

    local speed = self.speed
    if not self.goingRight then
        speed = speed * -1
    end
    self.object:setLinearVelocity(speed, 0)


    self.timer = self.timer + dt

    if self.timer > 1 / self:getFPS() then
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

    love.graphics.translate(-24, -96 / 2)

    love.graphics.scale(4, 4)

    local quad = love.graphics.newQuad((self.frame + 1) * 12, 0, 12, 24, self.image:getWidth(), self.image:getHeight())

    love.graphics.draw(self.image, quad)

    if self.hits > 0 then
        local sQuad = love.graphics.newQuad((math.min(self.hits, 6) - 1) * 12, 0, 12, 24, self.splat:getWidth(),
            self.splat:getHeight())
        love.graphics.draw(self.splat, sQuad)
    end

    love.graphics.pop()
end

return Person

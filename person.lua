local Class = require("hump.class")
local config = require("config")

local Person = Class {
    init = function(self, game, world, x, y, goingRight, type)
        self.game = game
        self.world = world
        self.type = type

        local tc = config.people[type]
        self.tc = tc

        self.baseFPS = tc.baseFPS
        self.speed = tc.speed

        self.image = love.graphics.newImage(tc.image)
        self.splat = love.graphics.newImage("assets/person-splat.png")
        self.goingRight = goingRight

        self.object = world:newRectangleCollider(x, y - (tc.height / 2), tc.width, tc.height)
        self.object:setCollisionClass('Person')
        self.object:setObject(self)
        self.object:setFixedRotation(true)
        self.object:setLinearDamping(10)
    end,
    dead = false,

    hits = 0,

    frame = 0,
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
    return self.baseFPS * (self.speed / self.tc.speed)
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
        self.speed = self.tc.afterHitSpeed
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
        if self.frame > self.tc.frames then self.frame = 0 end

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

    love.graphics.translate((-self.tc.width / 2) + self.tc.imageOffset, -self.tc.height / 2)

    love.graphics.scale(4, 4)


    print((self.frame + self.tc.frameOffset) * self.tc.imageWidth)
    local quad = love.graphics.newQuad((self.frame + self.tc.frameOffset) * self.tc.imageWidth, 0, self.tc.imageWidth, self.tc.imageHeight, self.image:getWidth(), self.image:getHeight())

    love.graphics.draw(self.image, quad)

    if self.hits > 0 then
        love.graphics.translate(self.tc.splatOffset, 0)
        local sQuad = love.graphics.newQuad((math.min(self.hits, 6) - 1) * 12, 0, 12, 24, self.splat:getWidth(),
            self.splat:getHeight())
        love.graphics.draw(self.splat, sQuad)
    end

    love.graphics.pop()
end

return Person

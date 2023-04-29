local Class = require("hump.class")
local Poop = require("poop")

local Player = Class {
    init = function(self, game, world, x, y)
        self.game = game
        self.world = world
        self.image = love.graphics.newImage("assets/pigeon.png")

        self.object = world:newCircleCollider(x, y, 16)
        self.object:setCollisionClass('Player')
        self.object:setObject(self)
        self.object:setFixedRotation(true)
    end,
    goingRight = true,
    dead = false,
    destroyed = false,
    lift = -750,
    glide = 250,
    flapForce = -200,
    flapRate = 1,
    lastFlap = -100,
    maxVX = 200,

    frame = 0,
    fps = 20,
    timer = 0,

    poopRate = 1,
    lastPoop = -100,
}

function Player:destroy()
    if not self.destroyed then
        self.object:destroy()
        self.destroyed = true
    end

end

function Player:getX()
    return self.object:getX()
end

function Player:getY()
    return self.object:getY()
end

function Player:update(dt)
    if love.keyboard.isDown("left") then
        self.goingRight = false
    end

    if love.keyboard.isDown("right") then
        self.goingRight = true
    end

    local fx = self.glide
    if not self.goingRight then
        fx = fx * -1
    end

    self.object:applyForce(fx, self.lift)

    local vx, vy = self.object:getLinearVelocity()
    self.object:setLinearVelocity(math.min(vx, self.maxVX), vy)

    if love.keyboard.isDown("space") then
        self:poop()
    end


    self.timer = self.timer + dt

    if self.timer > 1 / self.fps then
        self.frame = self.frame + 1
        if self.frame > 11 then self.frame = 0 end

        self.timer = 0
    end
end

function Player:flap()
    if self.lastFlap >= love.timer.getTime() - self.flapRate then
        return
    end

    self.object:applyLinearImpulse(0, self.flapForce)
    self.lastFlap = love.timer.getTime()
end

function Player:poop()
    if self.lastPoop >= love.timer.getTime() - self.poopRate then
        return
    end

    self.lastPoop = love.timer.getTime()

    local vx, vy = self.object:getLinearVelocity()
    local poop = Poop(self.game, self.world, self:getX(), self:getY(), vx, vy)
    self.game:addEntity(poop)

end

function Player:draw()
    if self.dead then
        return
    end

    love.graphics.push()

    love.graphics.translate(self:getX(), self:getY())
    love.graphics.setColor(1, 1, 1)

    if not self.goingRight then
        love.graphics.scale(-1, 1)
    end

    love.graphics.translate(-16, -16)
    love.graphics.scale(2, 2)

    local quad = love.graphics.newQuad(self.frame * 16, 0, 16, 16, self.image:getWidth(), self.image:getHeight())

    love.graphics.draw(self.image, quad)

    love.graphics.pop()
end

return Player

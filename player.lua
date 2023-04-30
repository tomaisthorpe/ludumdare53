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
    glide = 950,
    flapForce = -240,
    flapRate = 0.5,
    lastFlap = -100,
    maxVX = 250,
    maxVY = 100,

    animationTime = 11 / 30,

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
    if self.object:enter('Solid') then
        self.game:gameOver('floor')
        return
    end

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.goingRight = false
    end

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.goingRight = true
    end

    local fx = self.glide
    if not self.goingRight then
        fx = fx * -1
    end

    self.object:applyForce(fx, self.lift)

    local vx, vy = self.object:getLinearVelocity()
    self.object:setLinearVelocity(
        math.max(self.maxVX * -1, math.min(vx, self.maxVX)),
        math.max(self.maxVY * -1, math.min(vy, self.maxVY)))

    if love.keyboard.isDown("space") then
        self:poop()
    end

    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self:flap()
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
    local offset = -7
    if not self.goingRight then
        offset = offset * -1
    end
    local poop = Poop(self.game, self.world, self:getX() + offset, self:getY() + 5, vx, vy)
    self.game:addEntity(poop)

    self.game:playDrop()

    self.game.totalPoops = self.game.totalPoops + 1
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

    local frame = 11
    if self.lastFlap >= love.timer.getTime() - self.animationTime then
        frame = math.floor(((love.timer.getTime() - self.lastFlap) / self.animationTime) * 11)
    end

    local quad = love.graphics.newQuad(frame * 16, 0, 16, 16, self.image:getWidth(), self.image:getHeight())

    love.graphics.draw(self.image, quad)

    love.graphics.pop()
end

return Player

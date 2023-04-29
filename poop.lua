local Class = require("hump.class")

local Poop = Class {
    init = function(self, game, world, x, y, vx, vy)
        self.game = game
        self.object = world:newCircleCollider(x, y, 8)
        self.object:setCollisionClass('Poop')
        self.object:setLinearVelocity(vx, vy)
        self.object:setBullet(true)

        self.dead = false
        self.lifetime = 10
    end,
}


function Poop:getX()
    return self.object:getX()
end

function Poop:getY()
    return self.object:getY()
end

function Poop:update(dt)
    if self.object:enter('Solid') then
        self:destroy()
        return
    end

    self.lifetime = self.lifetime - dt
    if self.lifetime <= 0 then
        self:destroy()
        return
    end
end

function Poop:destroy()
    if self.dead == false and self.object then
        self.object:destroy()
        self.dead = true
    end
end

function Poop:draw()
    love.graphics.push()

    love.graphics.setColor(1, 1, 1)
    love.graphics.translate(self:getX(), self:getY())
    love.graphics.circle('fill', 0, 0, 4)
    love.graphics.pop()
end

return Poop

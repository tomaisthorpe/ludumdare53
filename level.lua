local Class = require("hump.class")
local Person = require("person")
local config = require("config")

local Level = Class {
    init = function(self, game, world)
        self.game = game
        self.world = world

        self.background = love.graphics.newImage('assets/level.png')
        self.foreground = love.graphics.newImage('assets/level-foreground.png')
    end,
    lastPerson = 0,
    personRate = 5,
}

function Level:update(dt)
    if self.lastPerson >= love.timer.getTime() - self.personRate then
        return
    end

    self.lastPerson = love.timer.getTime()

    local person = Person(self.game, self.world, 16, config.levelHeight - 18)
    self.game:addPerson(person)
end

function Level:generate()
    -- TODO currently can't remove this
    local obj = self.world:newRectangleCollider(0, 900 - 18, 2100, 18)
    obj:setCollisionClass('Solid')
    obj:setType('static')

    -- local person = Person(self.game, self.world, 500, 300)
    -- self.game:addPerson(person)
end

function Level:drawBackground()
    love.graphics.push()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.background)
    love.graphics.pop()
end

function Level:drawForeground()
    love.graphics.push()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.foreground)
    love.graphics.pop()
end

return Level

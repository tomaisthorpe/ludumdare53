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
    lastPerson = -5,
    personRate = 5,
}

function Level:update(dt)
    if self.lastPerson >= love.timer.getTime() - self.personRate then
        return
    end

    self.lastPerson = love.timer.getTime()

    local goingRight = true
    local x = -75
    if love.math.random(0, 1) == 1 then
        goingRight = false
        x = config.levelWidth + 75
    end

    local person = Person(self.game, self.world, x, config.levelHeight - 18 - 36, goingRight, 3)
    self.game:addPerson(person)
end

local boundary = function(world, x, y, w, h, class)
    local wall = world:newRectangleCollider(x, y, w, h)
    wall:setCollisionClass(class)
    wall:setType('static')
    wall:setFriction(0)

    return wall
end

function Level:generate()
    -- TODO currently can't remove this
    local bottom = boundary(self.world, -150, 900 - 19, config.levelWidth + 300, 19, 'Solid')
    local top = boundary(self.world, 0, 0, config.levelWidth, 18, 'Boundary')
    local left = boundary(self.world, 0, 0, 20, config.levelHeight, 'Boundary')
    local right = boundary(self.world, config.levelWidth - 20, 0, 20, config.levelHeight, 'Boundary')

    self.boundaries = { top, bottom, left, right }
end

function Level:drawBackground()
    love.graphics.push()
    love.graphics.setColor(1, 1, 1)
    love.graphics.scale(4, 4)
    love.graphics.draw(self.background)
    love.graphics.pop()
end

function Level:drawForeground()
    -- love.graphics.push()
    -- love.graphics.setColor(1, 1, 1)
    -- love.graphics.draw(self.foreground)
    -- love.graphics.pop()
end

return Level

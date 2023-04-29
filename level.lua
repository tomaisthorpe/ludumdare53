local Class = require("hump.class")
local Person = require("person")

local Level = Class {
    init = function(self, game, world)
        self.game = game
        self.world = world

    end,
}

function Level:generate()
    -- TODO currently can't remove this
    local obj = self.world:newRectangleCollider(-100, 300, 4000, 40)
    obj:setCollisionClass('Solid')
    obj:setType('static')


    local person = Person(self.game, self.world, 500, 300)
    self.game:addPerson(person)
end

return Level

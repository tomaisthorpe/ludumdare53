local config = require("config")
local Camera = require("Camera")
local wf = require("windfield")
local Player = require("player")
local Level = require("level")
local Splat = require("splat")

local Game = {
  translate = { 0, 0 },
  scaling = 1,
}

function Game:init()
  -- Window setup
  Game:calculateScaling()

  self.font = love.graphics.newFont('assets/sharetech.ttf', 16)
end

function Game:enter()
  self.world = wf.newWorld(0, 0, true)
  self.world:setGravity(0, 700)
  self.world:addCollisionClass('Solid')
  self.world:addCollisionClass('Boundary')
  self.world:addCollisionClass('Player')
  self.world:addCollisionClass('Person', { ignores = { 'Player', 'Person', 'Boundary' } })
  self.world:addCollisionClass('Poop', { ignores = { 'Player', 'Person' } })


  self.camera = Camera(0, 0, 800, 600)
  self.camera:setFollowStyle("LOCKON")
  self.camera:setBounds(0, 0, config.levelWidth, config.levelHeight)

  self.player = Player(self, self.world, 200, 800)
  self.entities = {}
  self.people = {}
  self.hits = 0

  self.level = Level(self, self.world)
  self.level:generate()

  -- self.splat = Splat()
end

function Game:addPerson(person)
  table.insert(self.people, person)
end

function Game:addEntity(entity)
  table.insert(self.entities, entity)
end

function Game:addHit()
  self.hits = self.hits + 1
end

function Game:update(dt)
  self.camera:update(dt)
  self.camera:follow(self.player:getX(), self.player:getY())

  self.world:update(dt)
  self.player:update(dt)
  self.level:update(dt)
  -- self.splat:update(dt)

  for i, e in ipairs(self.entities) do
    if e.dead then
      table.remove(self.entities, i)
    else
      e:update(dt)
    end
  end

  for i, e in ipairs(self.people) do
    if e.dead then
      table.remove(self.people, i)
    else
      e:update(dt)
    end
  end
end

function Game:draw()
  love.graphics.push()
  love.graphics.translate(Game.translate[1], Game.translate[2])
  love.graphics.scale(Game.scaling)

  love.graphics.setColor(1, 1, 1)

  love.graphics.setColor(0, 0, 0)
  love.graphics.rectangle("fill", 0, 0, 800, 600)

  self:drawGame()
  self:drawUI()

  love.graphics.pop()

  -- Draw borders
  love.graphics.setColor(config.borderColor[1], config.borderColor[2], config.borderColor[3])
  love.graphics.rectangle("fill", 0, 0, Game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), Game.translate[2])
  love.graphics.rectangle("fill", love.graphics.getWidth() - Game.translate[1], 0, Game.translate[1],
    love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - Game.translate[2], love.graphics.getWidth(),
    Game.translate[2])
end

function Game:drawGame()
  self.camera:attach()
  self.level:drawBackground()

  self.player:draw()

  for _, e in ipairs(self.entities) do
    if not e.dead then
      e:draw()
    end
  end

  for _, e in ipairs(self.people) do
    if not e.dead then
      e:draw()
    end
  end

  -- self.splat:draw()

  self.level:drawForeground()

  if config.physicsDebug then
    self.world:draw(1)
  end

  self.camera:detach()

end

function Game:drawUI()
  love.graphics.push()

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(self.font)

  love.graphics.printf("Hits: ".. self.hits, 16, 16, 200, "left")

  love.graphics.pop()
end

function Game:getMousePosition()
  local mx, my = love.mouse.getPosition()

  mx = (mx - self.translate[1]) / self.scaling
  my = (my - self.translate[2]) / self.scaling

  local cx, cy = self.camera:toWorldCoords(mx, my)

  return mx, my, cx, cy
end

function Game:resize()
  love.window.setMode(800, 600)
  Game:calculateScaling()
end

function Game:calculateScaling()
  local minEdge = love.graphics.getHeight()
  if minEdge < love.graphics.getWidth() then
    Game.scaling = minEdge / 600
    Game.translate = { (love.graphics.getWidth() - (800 * Game.scaling)) / 2, 0 }
  else
    Game.scaling = love.graphics.getWidth() / 800
  end
end

function Game:keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end

return Game

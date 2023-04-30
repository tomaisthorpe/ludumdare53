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
  self.largeFont = love.graphics.newFont('assets/sharetech.ttf', 24)
  self.arrow = love.graphics.newImage('assets/arrow.png')
end

function Game:enter()
  self:setupGame()
end

function Game:setupGame()
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

  self.player = Player(self, self.world, 200, 500)
  self.entities = {}
  self.people = {}
  self.hits = 0

  self.level = Level(self, self.world)
  self.level:generate()

  -- self.splat = Splat()
  --
  self.isGameOver = false
  self.gameOverReason = ''

  self.lifeForce = 1
end

function Game:damage()
  self.lifeForce = self.lifeForce - config.damagePerPerson
  if self.lifeForce < 0 then
    self.lifeForce = 0
    self:gameOver("dead")
  end
end

function Game:gameOver(reason)
  self.isGameOver = true
  self.gameOverReason = reason
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
  if self.isGameOver then
    return
  end
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

  for _, e in ipairs(self.entities) do
    if not e.dead then
      e:draw()
    end
  end

  self.player:draw()

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

  love.graphics.setFont(self.largeFont)
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.printf("Hits: " .. self.hits, config.uiSizing.margin, config.uiSizing.margin + 1, 200, "left")

  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("Hits: " .. self.hits, config.uiSizing.margin, config.uiSizing.margin, 200, "left")

  self:drawArrows()

  self:drawBar("Life Force", config.windowWidth - config.uiSizing.lifeForceWidth - config.uiSizing.margin, config.uiSizing.margin, config.uiSizing.lifeForceWidth,
    config.uiPalette.lifeForce, self.lifeForce)

  if self.isGameOver then
    love.graphics.setFont(self.font)
    love.graphics.printf("Game over", 16, 200, 200, "left")
  end

  love.graphics.pop()
end

function Game:drawBar(label, x, y, width, color, value)
  love.graphics.push()

  love.graphics.translate(x, y)

  love.graphics.setLineWidth(config.uiSizing.strokeWidth)
  local level = (width - config.uiSizing.barPadding * 2) * value

  love.graphics.setColor(color)

  love.graphics.rectangle("line", 0, 0, width, config.uiSizing.barHeight)
  love.graphics.rectangle("fill", config.uiSizing.barPadding, config.uiSizing.barPadding, level,
    config.uiSizing.barHeight - config.uiSizing.barPadding * 2)

  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.setFont(self.font)
  love.graphics.printf(label, 5, 4, 200)

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(self.font)
  love.graphics.printf(label, 5, 3, 200)

  love.graphics.pop()
end

function Game:drawArrows()
  love.graphics.push()

  love.graphics.translate(400, 150)

  local gap = 150
  local leftArrow = false
  local rightArrow = false

  local minX = self.camera.x - 400
  local maxX = self.camera.x + 400

  for _, e in ipairs(self.people) do
    if e.dead == false then
      local x = e:getX()

      if e.hits == 0 then
        if x < minX and x > 0 then
          leftArrow = true
        end

        if x > maxX and x < config.levelWidth then
          rightArrow = true
        end
      end
    end
  end

  if leftArrow then
    love.graphics.push()
    love.graphics.scale(-1, 1)
    love.graphics.translate(gap, 0)
    love.graphics.draw(self.arrow)
    love.graphics.pop()
  end

  if rightArrow then
    love.graphics.push()
    love.graphics.translate(gap, 0)
    love.graphics.draw(self.arrow)
    love.graphics.pop()
  end

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

  if key == "space" and self.isGameOver then
    self.isGameOver = false
    self:setupGame()
  end
end

return Game

local config = require("config")
local Camera = require("Camera")
local wf = require("windfield")
local Player = require("player")
local Level = require("level")
local Splat = require("splat")

local Game = {
  translate = { 0, 0 },
  scaling = 1,
  playSound = true,
}

function Game:init()
  -- Window setup
  Game:calculateScaling()

  self.font = love.graphics.newFont('assets/sharetech.ttf', 16)
  self.largeFont = love.graphics.newFont('assets/sharetech.ttf', 24)
  self.xlFont = love.graphics.newFont('assets/sharetech.ttf', 42)
  self.arrow = love.graphics.newImage('assets/arrow.png')

  self.splatSounds = {
    love.audio.newSource('assets/splat1.wav', 'static'),
    love.audio.newSource('assets/splat2.wav', 'static'),
  }

  self.dropSound = love.audio.newSource('assets/drop.wav', 'static')

  love.audio.setVolume(0.8)
end

function Game:enter()
  self:setupGame()
end

function Game:playSplat()
  local choice = love.math.random(1, 2)


  if self.playSound then
    love.audio.play(self.splatSounds[choice])
  end
end

function Game:playDrop()
  if self.playSound then
    love.audio.play(self.dropSound)
  end
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

  self.player = Player(self, self.world, 850, 400)
  self.player.lastPoop = love.timer.getTime()
  self.entities = {}
  self.people = {}
  self.hits = 0
  self.totalPoops = 0

  self.level = Level(self, self.world)
  self.level:generate()

  -- self.splat = Splat()
  --
  self.isGameOver = false
  self.gameOverReason = 'floor'

  self.paused = true

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
  self.camera:update(dt)
  self.camera:follow(self.player:getX(), self.player:getY())
  if self.isGameOver or self.paused then
    return
  end
  -- self.camera:update(dt)
  -- self.camera:follow(self.player:getX(), self.player:getY())

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

  self:drawBar("Life Force", config.windowWidth - config.uiSizing.lifeForceWidth - config.uiSizing.margin,
    config.uiSizing.margin, config.uiSizing.lifeForceWidth,
    config.uiPalette.lifeForce, self.lifeForce)

  love.graphics.pop()

  if self.isGameOver then
    self:drawGameOver()
  end

  if self.paused or self.isGameOver then
    self:drawInstructions()
  end
end

function Game:drawInstructions()
  love.graphics.push()

  local inWidth = 350
  local inHeight = 300
  local inX = config.uiSizing.margin
  local inY = config.windowHeight - inHeight - config.uiSizing.margin
  local padding = config.uiSizing.margin / 2

  self:drawDialog(inX, inY, inWidth, inHeight)

  love.graphics.push()
  love.graphics.translate(inX, inY)
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.setFont(self.largeFont)

  love.graphics.printf("Instructions", padding, padding, inWidth, "left")

  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.translate(0, 30)
  love.graphics.setFont(self.font)

  love.graphics.printf("Poop on every person walking past. Letting someone pass unpooped depletes your life force! Game gets harder the longer to play. Some people may put up an umbrella if you get too close."
    , padding, padding, inWidth - padding * 2, "left")

  love.graphics.translate(0, 120)

  love.graphics.printf("Left/right to change direction", padding, padding, inWidth, "left")

  love.graphics.translate(0, 24)
  love.graphics.printf("Up to flap your wings", padding, padding, inWidth, "left")

  love.graphics.translate(0, 24)
  love.graphics.printf("Space to poop", padding, padding, inWidth, "left")

  love.graphics.translate(0, 24)
  love.graphics.printf("M to toggle sounds", padding, padding, inWidth, "left")

  love.graphics.translate(0, 30)
  love.graphics.setFont(self.largeFont)
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.printf("Press space to start", padding, padding + 1, inWidth - padding * 2, "center")
  love.graphics.setColor(config.uiPalette.lifeForce)
  love.graphics.printf("Press space to start", padding, padding, inWidth - padding * 2, "center")
  --   love.graphics.printf("Total poops:", padding, padding, statsWidth, "left")
  --   love.graphics.printf(""..self.totalPoops, 0, padding, statsWidth - padding, "right")

  --   local accuracy = 0
  --   if self.totalPoops > 0 then
  --     accuracy = math.ceil((self.hits / self.totalPoops) * 100)
  --   end

  --   love.graphics.translate(0, 24)
  --   love.graphics.printf("Accuracy:", padding, padding, statsWidth, "left")
  --   love.graphics.printf(""..accuracy.."%", 0, padding, statsWidth - padding, "right")
  --   love.graphics.pop()

  love.graphics.pop()
  love.graphics.pop()

end

function Game:drawGameOver()
  love.graphics.push()
  love.graphics.setFont(self.xlFont)
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.printf("GAME OVER", 0, 151, 800, "center")
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf("GAME OVER", 0, 150, 800, "center")

  local reason = 'You hit the floor! Remember to flap.'
  if reason == 'dead' then
    reason = 'You let too many people leave unpooped!'
  end

  love.graphics.setFont(self.largeFont)
  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.printf(reason, 0, 201, 800, "center")
  love.graphics.setColor(config.uiPalette.lifeForce)
  love.graphics.printf(reason, 0, 200, 800, "center")


  local statsWidth = 250
  local statsHeight = 120
  local statsX = config.windowWidth - statsWidth - config.uiSizing.margin
  local statsY = config.windowHeight - statsHeight - config.uiSizing.margin
  local padding = config.uiSizing.margin / 2

  self:drawDialog(statsX, statsY, statsWidth, statsHeight)

  love.graphics.push()
  love.graphics.translate(statsX, statsY)
  love.graphics.setColor(0.3, 0.3, 0.3)
  love.graphics.setFont(self.largeFont)

  love.graphics.printf("Stats", padding, padding, statsWidth, "left")

  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.translate(0, 30)
  love.graphics.setFont(self.font)

  love.graphics.printf("Poops on target:", padding, padding, statsWidth, "left")
  love.graphics.printf("" .. self.hits, 0, padding, statsWidth - padding, "right")

  love.graphics.translate(0, 24)
  love.graphics.printf("Total poops:", padding, padding, statsWidth, "left")
  love.graphics.printf("" .. self.totalPoops, 0, padding, statsWidth - padding, "right")

  local accuracy = 0
  if self.totalPoops > 0 then
    accuracy = math.ceil((self.hits / self.totalPoops) * 100)
  end

  love.graphics.translate(0, 24)
  love.graphics.printf("Accuracy:", padding, padding, statsWidth, "left")
  love.graphics.printf("" .. accuracy .. "%", 0, padding, statsWidth - padding, "right")
  love.graphics.pop()

  love.graphics.pop()
end

function Game:drawDialog(x, y, width, height)

  love.graphics.push()
  love.graphics.setColor(config.uiPalette.dialogShadow)
  love.graphics.rectangle("fill", x - 1, y + 1, width + 2, height, 2)

  love.graphics.setColor(config.uiPalette.dialog)
  love.graphics.rectangle("fill", x, y, width, height, 2)

  love.graphics.setLineWidth(1)
  love.graphics.setColor(config.uiPalette.dialogStroke)
  love.graphics.rectangle("line", x, y, width, height, 2)

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

  if key == "space" then
    if self.isGameOver then
      self.isGameOver = false
      self:setupGame()
    end

    if self.paused then
      self.paused = false
      self.player.lastPoop = love.timer.getTime()
    end
  end

  if key == "m" then
    if self.playSound then
      self.playSound = false
    else
      self.playSound = true
    end
  end
end

return Game

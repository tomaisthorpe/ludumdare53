local config = require("config")
local Camera = require("Camera")
local wf = require("windfield")
local Player = require("player")

local Game = {
  translate = {0, 0},
  scaling = 1,
}

function Game:init()
  -- Window setup
  Game:calculateScaling()
end

function Game:enter()
  self.world = wf.newWorld(0, 0, true)
  self.world:setGravity(0, 512)
  self.world:addCollisionClass('Solid')
  self.world:addCollisionClass('Player')

  local obj = self.world:newRectangleCollider(-100, 300, 4000, 40)
  obj:setType('static')

  self.camera = Camera(0, 0, 800, 600)
  self.camera:setFollowStyle("LOCKON")

  self.player = Player(self, self.world, 100, 100)
end

function Game:update(dt)
  self.camera:update(dt)
  self.camera:follow(self.player:getX(), self.player:getY())

  self.world:update(dt)
  self.player:update(dt)
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
  love.graphics.rectangle("fill", love.graphics.getWidth() - Game.translate[1], 0, Game.translate[1], love.graphics.getHeight())
  love.graphics.rectangle("fill", 0, love.graphics.getHeight() - Game.translate[2], love.graphics.getWidth(), Game.translate[2])
end

function Game:drawGame()
  self.camera:attach()
  self.player:draw()

  if config.physicsDebug then
    self.world:draw(1)
  end

  self.camera:detach()

end

function Game:drawUI()
  love.graphics.push()

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
     Game.translate = {(love.graphics.getWidth() - (800 * Game.scaling)) / 2, 0}
  else
    Game.scaling = love.graphics.getWidth() / 800
  end
end

function Game:keypressed(key)
  if key == "escape" then 
    love.event.quit()
  end

  if key == "up" then
    self.player:flap()
  end
end

return Game

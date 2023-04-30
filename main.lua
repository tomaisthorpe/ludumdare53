local Gamestate = require("hump.gamestate")

local config = require("config")
local Game = require("game")

function love.load()
  Gamestate.registerEvents()
  love.window.setMode(800, 600)
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setFullscreen(config.fullscreen)

  Gamestate.switch(Game)
  love.window.setTitle("Pigeon Splat")
end

function setupWindow()
  love.window.setMode(800, 600)
end

local config = {
  physicsDebug = false,
  fullscreen = true,

  borderColor = { 9 / 255, 18 / 255, 26 / 255 },
  windowWidth = 800,
  windowHeight = 600,

  levelWidth = 2100,
  levelHeight = 900,

  damagePerPerson = 0.1,

  uiSizing = {
    margin = 16,
    strokeWidth = 2,
    barPadding = 2,
    barHeight = 26,
    lifeForceWidth = 500,
  },

  uiPalette = {
    lifeForce = { 0.941, 0.557, 0.298 }, -- orange
    dialog = { 0.761, 0.761, 0.8 },
    dialogStroke = { 0.6, 0.6, 0.65 },
    dialogShadow = { 0.761, 0.761, 0.8, 0.5 },
  },
}

return config

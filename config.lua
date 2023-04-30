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

  people = {
    {
      image = 'assets/person.png',
      imageWidth = 12,
      imageHeight = 24,
      width = 48,
      height = 96,
      baseFPS = 10,
      frames = 7,
      speed = 40,
      afterHitSpeed = 100,
      frameOffset = 1,
      imageOffset = 0,
      splatOffset = 0,
    },
    {
      image = 'assets/person-running.png',
      imageWidth = 12,
      imageHeight = 24,
      width = 48,
      height = 96,
      baseFPS = 10,
      frames = 7,
      speed = 150,
      afterHitSpeed = 290,
      frameOffset = 1,
      imageOffset = 0,
      splatOffset = 0,
    },
    {
      image = 'assets/person-scooter.png',
      imageWidth = 16,
      imageHeight = 25,
      width = 46,
      height = 100,
      baseFPS = 10,
      frames = 4,
      speed = 165,
      afterHitSpeed = 290,
      frameOffset = 0,
      imageOffset = -6,
      splatOffset = 2,
    },
    {
      hasUmbrella = true,
      image = 'assets/person-umbrella.png',
      imageWidth = 12,
      imageHeight = 24,
      width = 48,
      height = 96,
      baseFPS = 10,
      frames = 7,
      speed = 40,
      afterHitSpeed = 100,
      frameOffset = 1,
      imageOffset = 0,
      splatOffset = 0,
    },
  },


  chances = {
    person = function() return 1 end,
    running = function(c) return 0.05 * c + 0.1 end,
    scooter = function(c) return 0.02 * c end,
    umbrella = function(c) return 0.03 * c + 0.1 end,
  },

  personRate = function(c)
    local rate = -0.07 * c + 5
    if rate < 2 then
      return 2
    end

    return rate
  end,

  umbrellaDistance = 150,
  maxChances = 10,
}

return config

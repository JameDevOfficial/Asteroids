local M = {}

M.DEBUG = false

M.ship = {}
M.ship.size = { w = 50, h = 50 } -- w, h in px
M.ship.color = { 0.5, 1, 1 }
M.ship.screenPadding = 25
M.ship.projectileSpeed = 100 -- in pixels, when to make it teleport

M.comet = {}
M.comet.spawnChance = 5  -- %
M.comet.spawnDelay = 0.7 -- ms
M.comet.speed = 100      -- ms

M.collision = {}
M.collision.ship = 1
M.collision.comet = 2
M.collision.projectile = 4

M.fonts = {}
M.fonts.quirkyRobot = "assets/fonts/QuirkyRobot.ttf"
return M;

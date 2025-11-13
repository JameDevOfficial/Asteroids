local M = {}

M.DEBUG = true

M.ship = {}
M.ship.size = { w = 50, h = 50 } -- w, h in px
M.ship.screenPadding = 25
M.ship.projectileSpeed = 100 -- in pixels, when to make it teleport 

M.comet = {}
M.comet.spawnChance = 20 -- %
M.comet.spawnDelay = 0.1 -- ms
M.comet.speed = 50 -- ms
return M;

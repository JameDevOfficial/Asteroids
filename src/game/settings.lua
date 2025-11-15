local M = {}

M.DEBUG = true

M.ship = {}
M.ship.size = { w = 50, h = 50 } -- w, h in px
M.ship.screenPadding = 25
M.ship.projectileSpeed = 100     -- in pixels, when to make it teleport

M.comet = {}
M.comet.spawnChance = 10 -- %
M.comet.spawnDelay = 0.5 -- ms
M.comet.speed = 75       -- ms

M.collision = {}
M.collision.ship = 1
M.collision.comet = 2
M.collision.projectile = 4
return M;

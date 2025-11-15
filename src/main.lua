Settings = require("game.settings")
UI = require("game.ui");
Ship = require("sprites.ship")
Comet = require("sprites.comet")

IsPaused = false
Screen = {}
PlayerShip = Ship
Comets = {}
World = love.physics.newWorld(0, 0, true)
Game = {
    state = "unloaded" -- unloaded, loading, <menu, game, lost>
}

function love.load()
    -- Important Inits
    Screen = UI.windowResized()
    Game.state = "game"

    -- Sprites
    PlayerShip = Ship:new({
        world = World
    })
end

function love.update(dt)
    World:update(dt)
    PlayerShip:checkMovement(dt)
    PlayerShip:update(dt)
    Comet.spawnCometRandom(dt)
    for i, comet in ipairs(Comets) do
        comet:update()
    end
end

function love.draw()
    UI.drawFrame()
    PlayerShip:render()


    if Settings.DEBUG == true then
        UI.drawDebug()
    end
    for i, v in ipairs(Comets) do
        v:render()
    end
end

function love.resize()
    Screen = UI.windowResized()
end

function love.keypressed(key, scancode, isrepeat)
    local dt = love.timer.getDelta()
    if key == "f5" then
        Settings.DEBUG = not Settings.DEBUG
    end
    if key == "space" then
        PlayerShip:shoot(love.timer.getDelta())
    end
end

function love.keyreleased(key, scancode)

end

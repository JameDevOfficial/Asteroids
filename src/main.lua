Settings = require("game.settings")
UI = require("game.ui");
Ship = require("sprites.ship")

IsPaused = false
Screen = {}
PlayerShip = Ship
World = love.physics.newWorld(0,0,true)
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
    Ship:checkMovement(dt)
end

function love.draw()
    UI.drawFrame()
    PlayerShip:render()


    if Settings.DEBUG == true then
        UI.drawDebug()
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
end

function love.keyreleased(key, scancode)

end
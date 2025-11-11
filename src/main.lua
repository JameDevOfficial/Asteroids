Settings = require("game.settings")
UI = require("game.ui");


IsPaused = false
Screen = {}


function love.load()

end

function love.update(dt)

end

function love.draw()
    if Settings.DEBUG == true then
        UI.drawDebug()
    end
end

function love.resize()
    Screen = UI.windowResized()
end

function love.keypressed(key, scancode, isrepeat)
    if key == "f5" then
        Settings.DEBUG = not Settings.DEBUG
    end
end

function love.keyreleased(key, scancode)

end
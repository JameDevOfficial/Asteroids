Settings = require("game.settings")
UI = require("game.ui");
Ship = require("sprites.ship")
Comet = require("sprites.comet")

IsPaused = true
Screen = {}
Player = {
    ship = nil,
    points = 0,

}
Comets = {}
World = love.physics.newWorld(0, 0, true)

function love.load()
    -- Important Inits
    Screen = UI.windowResized()
    World:setCallbacks(BeginContact, EndContact, PreSolve, PostSolve)

    -- Sprites
    Player.ship = Ship:new({
        world = World
    })
end

function love.update(dt)
    if IsPaused then return end
    World:update(dt)
    Player.ship:checkMovement(dt)
    Player.ship:update(dt)
    Comet.spawnCometRandom(dt)
    for i, comet in ipairs(Comets) do
        comet:update()
    end
end

function love.draw()
    if IsPaused == false then
        UI.drawFrame()
    else
        UI.drawMenu()
    end
    Player.ship:render()


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
    if IsPaused then return end
    local dt = love.timer.getDelta()
    if key == "f5" then
        Settings.DEBUG = not Settings.DEBUG
    end
    if key == "space" then
        Player.ship:shoot(love.timer.getDelta())
    end
end

function love.keyreleased(key, scancode)

end

function BeginContact(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
    if (u1.type == "projectile" and u2.type == "comet") or
        (u2.type == "projectile" and u1.type == "comet") then
        if u1.destroy then u1:destroy() end
        if u2.destroy then u2:destroy() end
        Player.points = Player.points + 1
    end
    if (u1.type == "ship" and u2.type == "comet") or
        (u2.type == "ship" and u1.type == "comet") then
        IsPaused = true
    end
    print("Contact")
end

function EndContact(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

function PreSolve(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

function PostSolve(a, b, coll, normalimpulse, tangentimpulse)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
end

---@diagnostic disable: param-type-mismatch
Settings = require("game.settings")
UI = require("game.ui");
Ship = require("sprites.ship")
Comet = require("sprites.comet")

IsPaused = true
Screen = {}
Player = {
    ship = nil,
    points = 0,
    lives = Settings.ship.startLives

}
Comets = {}
World = love.physics.newWorld(0, 0, true)
Game = {}

function Game.reset()
    for i = #Comets, 1, -1 do
        local c = Comets[i]
        if c and c.destroy then c:destroy() end
        Comets[i] = nil
    end
    Comets = {}
    Comet.timer = 0

    if Player.ship and Player.ship.destroy then
        Player.ship:destroy()
        Player.ship = nil
    end
    if World and World.destroy then
        World:destroy()
        World = nil
    end
    Player.points = 0
    collectgarbage("collect")
    -- new world
    World = love.physics.newWorld(0, 0, true)
    World:setCallbacks(BeginContact, EndContact, PreSolve, PostSolve)
    Player.ship = Ship:new({
        world = World
    })
    Player.lives = Settings.ship.startLives
end

function love.load()
    -- Important Inits
    Screen = UI.windowResized()
    World:setCallbacks(BeginContact, EndContact, PreSolve, PostSolve)

    -- Sprites
    Player.ship = Ship:new({
        world = World
    })
    collectgarbage("restart")
    collectgarbage("setpause", 120)
    ---@diagnostic disable-next-line: param-type-mismatch
    collectgarbage("setstepmul", 200)
end

function love.update(dt)
    if IsPaused then
        collectgarbage("step", 512)

        -- step physics so comets move in the menu
        if World then World:update(dt) end

        Comet.spawnCometRandom(dt)
        for i, comet in ipairs(Comets) do
            comet:update()
        end
        Player.ship:checkBounds(dt)
        return
    end
    if Player.ship.respawn and Player.ship.respawn == true then
        Player.ship:destroy()
        Player.ship = Ship:new({
            world = World
        })
        Player.ship.respawn = false
    end
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
        for i, v in ipairs(Comets) do
            v:render()
        end
    end
    Player.ship:render()
    for i, v in ipairs(Comets) do
        v:render()
    end

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
    if IsPaused then
        if key == "return" then
            Game.reset()
            IsPaused = false
        end
        return
    end
    local dt = love.timer.getDelta()

    if key == "space" then
        Player.ship:shoot(love.timer.getDelta())
    end
end

function love.keyreleased(key, scancode)

end

function BeginContact(a, b, coll)
    local u1 = a:getUserData()
    local u2 = b:getUserData()
    local t1 = u1 and u1.type
    local t2 = u2 and u2.type

    if (t1 == "projectile" and t2 == "comet") or
        (t2 == "projectile" and t1 == "comet") then
        if u1 and u1.destroy then u1:destroy() end
        if u2 and u2.destroy then u2:destroy() end
        Player.points = Player.points + 1
    end
    if Player.ship.safeTime <= 0 then
        if (t1 == "ship" and t2 == "comet") or
            (t2 == "ship" and t1 == "comet") then
            Player.lives = Player.lives - 1
            Player.ship.respawn = true
            if Player.lives == 0 then
                IsPaused = true
            end
        end
    end
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

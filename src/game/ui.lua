local UI = {}

local fontDefault = love.graphics.newFont(20)
local font30 = love.graphics.newFont(30)
local font50 = love.graphics.newFont(50)

fontDefault:setFilter("nearest", "nearest")
font30:setFilter("nearest", "nearest")
font50:setFilter("nearest", "nearest")

UI.drawFrame = function()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.setColor(1, 1, 1)

    local text = string.format("Points: %d", Player.points)
    local width = fontDefault:getWidth(text)
    love.graphics.print(text, Screen.X - width - 10, 10)
end

UI.drawDebug = function()
    if Settings.DEBUG == true then
        love.graphics.setFont(fontDefault)
        love.graphics.setColor(1, 1, 1, 1)

        local y = fontDefault:getHeight() + 10

        -- FPS
        local fps = love.timer.getFPS()
        local fpsText = string.format("FPS: %d", fps)
        love.graphics.print(fpsText, 10, y)
        y = y + fontDefault:getHeight()

        -- Performance
        local stats = love.graphics.getStats()
        local usedMem = collectgarbage("count")
        local perfText = string.format(
            "Memory: %.2f MB\n" ..
            "GC Pause: %d%%\n" ..
            "Draw Calls: %d\n" ..
            "Canvas Switches: %d\n" ..
            "Texture Memory: %.2f MB\n" ..
            "Images: %d\n" ..
            "Fonts: %d\n",
            usedMem / 1024,
            collectgarbage("count") > 0 and collectgarbage("count") / 7 or 0,
            stats.drawcalls,
            stats.canvasswitches,
            stats.texturememory / 1024 / 1024,
            stats.images,
            stats.fonts
        )
        love.graphics.print(perfText, 10, y)
        y = y + fontDefault:getHeight() * 8

        -- Game
        local dt = love.timer.getDelta()
        local avgDt = love.timer.getAverageDelta()
        local projCount = (Player and Player.ship and Player.ship.projectiles and type(Player.ship.projectiles) == "table") and
            #Player.ship.projectiles or 0
        local numComets = (type(Comets) == "table") and #Comets or 0
        local posX, posY = 0, 0
        local velX, velY = 0, 0
        local shipAngle = 0
        if Player and Player.ship and Player.ship.body then
            posX, posY = Player.ship.body:getPosition()
            velX, velY = Player.ship.body:getLinearVelocity()
            shipAngle = Player.ship.body:getAngle()
        end
        local playerText = string.format(
            "Game Paused: %s\n" ..
            "Delta Time: %.4fs (%.1f ms)\n" ..
            "Avg Delta: %.4fs (%.1f ms)\n" ..
            "Time: %.2fs\n" ..
            "Comets: %d\n" ..
            "Projectiles: %d\n" ..
            "Ship X:%d Y:%d\n" ..
            "Ship Velocity X:%d Y:%d\n" ..
            "Ship Rotation: %d",
            tostring(IsPaused),
            dt, dt * 1000,
            avgDt, avgDt * 1000,
            love.timer.getTime(),
            numComets,
            projCount,
            posX, posY,
            velX, velY,
            shipAngle
        )
        love.graphics.print(playerText, 10, y)
        y = y + fontDefault:getHeight() * 10

        -- System Info
        local renderer = love.graphics.getRendererInfo and love.graphics.getRendererInfo() or ""
        local systemText = string.format(
            "OS: %s\nGPU: %s",
            love.system.getOS(),
            select(4, love.graphics.getRendererInfo()) or 0
        )
        love.graphics.print(systemText, 10, y)
    end
end

function UI.drawNeonPolyline(points, color, intensity, width)
    color = color or { 1, 1, 1 }
    intensity = intensity or 5
    width = width or 2

    love.graphics.setBlendMode("add")
    for i = intensity, 1, -1 do
        local a = (i / intensity) * 0.02
        love.graphics.setColor(color[1], color[2], color[3], a)
        love.graphics.setLineWidth(width + i)
        love.graphics.polygon("line", points)
    end
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(color[1], color[2], color[3], 1)
    love.graphics.setLineWidth(width)
    love.graphics.polygon("line", points)
end

UI.windowResized = function()
    local screen = {
        X = 0,
        Y = 0,
        centerX = 0,
        centerY = 0,
        minSize = 0,
        topLeft = { X = 0, Y = 0 },
        topRight = { X = 0, Y = 0 },
        bottomLeft = { X = 0, Y = 0 },
        bottomRight = { X = 0, Y = 0 }
    }
    screen.X, screen.Y = love.graphics.getDimensions()
    screen.minSize = (screen.Y < screen.X) and screen.Y or screen.X
    screen.centerX = screen.X / 2
    screen.centerY = screen.Y / 2

    local half = screen.minSize / 2
    screen.topLeft.X = screen.centerX - half
    screen.topLeft.Y = screen.centerY - half
    screen.topRight.X = screen.centerX + half
    screen.topRight.Y = screen.centerY - half
    screen.bottomRight.X = screen.centerX + half
    screen.bottomRight.Y = screen.centerY + half
    screen.bottomLeft.X = screen.centerX - half
    screen.bottomLeft.Y = screen.centerY + half

    return screen
end

return UI;

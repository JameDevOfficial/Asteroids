local comet = {}
comet.__index = comet

comet.timer = 0

comet.spawnCometRandom = function(dt)
    comet.timer = comet.timer + dt
    if comet.timer < Settings.comet.spawnDelay then return end
    local spawn = math.random(1, 100)
    if spawn > Settings.comet.spawnChance then return end


    local newComet = Comet:new({ world = World })
    table.insert(Comets, newComet)
    comet.timer = 0
end

local function generateRandomMeteorShape(w, h, minR, maxR)
    local points = math.random(5, 8)
    local angleStep = (math.pi * 2) / points
    local shape = {}

    for i = 0, points - 1 do
        local angle = i * angleStep
        local radRand = love.math.random(minR, maxR) / 50
        local rad = math.min(w, h) / 2 * radRand

        local x = math.cos(angle) * rad
        local y = math.sin(angle) * rad
        table.insert(shape, x)
        table.insert(shape, y)
    end

    return shape
end

function comet:new(opts)
    opts        = opts or {}
    local o     = setmetatable({}, self)
    o.type      = "comet"
    o.sizeClass = opts.sizeClass or 1 -- 1 big, 2 medium, 3 small
    o.size      = opts.size or Settings.ship.size
    o.color     = opts.color or { 1, 1, 1, 1 }
    if not opts.position then
        local randPos = math.random(1, 2)
        if randPos == 1 then
            o.position = { x = math.random(0, Screen.X), y = (math.random(1, 2) == 1 and 0 or Screen.Y) }
        else
            o.position = { x = (math.random(1, 2) == 1 and 0 or Screen.X), y = math.random(0, Screen.Y) }
        end
    else
        o.position = opts.position
    end

    o.velocity       = opts.velocity or { x = 0, y = 0 }
    o.rotation       = opts.rotation or 0
    o.offset         = opts.offset or { x = 0, y = 0 }
    o.scale          = opts.scale or { w = 1, y = 1 }

    local w_2        = o.size.w / 2
    local h_2        = o.size.h / 2

    local minR, maxR = 25, 150
    local scales     = { 1.0, 0.55, 0.3 }
    local scale      = scales[o.sizeClass] or 1.0
    o.size           = opts.size or {
        w = math.max(8, math.floor(Settings.ship.size.w * scale)),
        h = math.max(8, math.floor(Settings.ship.size.h * scale))
    }

    o.shape          = generateRandomMeteorShape(o.size.w, o.size.h, minR, maxR)

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        ---@diagnostic disable-next-line: deprecated
        o.fixture = love.physics.newPolygonShape(unpack(o.shape))
        o.collision = love.physics.newFixture(o.body, o.fixture)
        o.collision:setUserData(o)
        o.collision:setFilterData(Settings.collision.comet, Settings.collision.ship + Settings.collision.projectile, 0)
        o.body:setAngle(o.rotation)

        local targetX = Screen.centerX + math.random(-200, 200)
        local targetY = Screen.centerY + math.random(-200, 200)
        ---@diagnostic disable-next-line: deprecated
        local angle = math.atan2(targetY - o.position.y, targetX - o.position.x)

        angle = angle + math.rad(math.random(-30, 30))
        o.body:setLinearVelocity(math.cos(angle) * Settings.comet.speed, math.sin(angle) * Settings.comet.speed)
        o.body:setAngularVelocity(math.random(-2, 2))
    else
        error("Missing World for spawning comet")
    end
    return o
end

function comet:handleCollision()
    local x, y = self.body:getPosition()
    if self.sizeClass == 1 then
        local newComets = math.random(1, 2)
        for i = 1, newComets, 1 do
            local angle = math.rad(math.random(0, 359))
            local velocity = {
                x = math.cos(angle) * Settings.comet.explosionSpeed,
                y = math.sin(angle) * Settings.comet.explosionSpeed
            }
            local newComet = Comet:new({
                world = World,
                sizeClass = 2,
                position = { x = x, y = y },
                velocity = velocity
            })
            table.insert(Comets, newComet)
        end
        self:destroy()
    elseif self.sizeClass == 2 then
        local newComets = math.random(1, 2)
        for i = 1, newComets, 1 do
            local angle = math.rad(math.random(0, 359))
            local velocity = {
                x = math.cos(angle) * Settings.comet.explosionSpeed,
                y = math.sin(angle) * Settings.comet.explosionSpeed
            }
            local newComet = Comet:new({
                world = World,
                sizeClass = 3,
                position = { x = x, y = y },
                velocity = velocity
            })
            table.insert(Comets, newComet)
        end
        self:destroy()
    elseif self.sizeClass == 3 then
        self:destroy()
    end
end

function comet:destroy()
    if self.collision then
        self.collision:destroy()
        self.collision = nil
    end
    if self.body then
        self.body:destroy()
        self.body = nil
    end

    if Comets then
        for i = 1, #Comets do
            if Comets[i] == self then
                table.remove(Comets, i)
                break
            end
        end
    end
end

function comet:render()
    if not self.body then return end
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    love.graphics.polygon("line", self.shape)

    if Settings.DEBUG then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(0, 0, 30, 0)
    end

    love.graphics.pop()
end

function comet:update()
    if not self.body then return end
    if self.collisionHappened then
        self:handleCollision()
        self.collisionHappened = nil
        if not self.body then return end
    end

    if self.body:getX() > Screen.X + Settings.ship.screenPadding then
        self:destroy()
    elseif self.body:getX() < -Settings.ship.screenPadding then
        self:destroy()
    elseif self.body:getY() > Screen.Y + Settings.ship.screenPadding then
        self:destroy()
    elseif self.body:getY() < -Settings.ship.screenPadding then
        self:destroy()
    end
end

return comet

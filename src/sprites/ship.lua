local ship = {}
ship.__index = ship

function ship:new(opts)
    opts          = opts or {}
    local o       = setmetatable({}, self)
    o.type        = "ship"
    o.size        = opts.size or Settings.ship.size
    o.color       = opts.color or { 1, 1, 1, 1 }
    o.position    = opts.position or { x = Screen.centerX, y = Screen.centerY }
    o.velocity    = opts.velocity or { x = 0, y = 0 }
    o.damping     = opts.damping or 0.5
    o.rotation    = opts.rotation or 0
    o.offset      = opts.offset or { x = 0, y = 0 }
    o.scale       = opts.scale or { w = 1, y = 1 }
    o.projectiles = {}

    local w_2     = o.size.w / 2
    local h_2     = o.size.h / 2

    o.shape       = {
        w_2, 0,
        -w_2, -h_2,
        -(o.size.w / 4), 0,
        -w_2, h_2
    }

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        o.body:setLinearDamping(o.damping)
        ---@diagnostic disable-next-line: deprecated
        o.fixture = love.physics.newPolygonShape(unpack(o.shape))
        o.collision = love.physics.newFixture(o.body, o.fixture)
        o.collision:setUserData(o)
        o.collision:setFilterData(Settings.collision.ship, Settings.collision.comet, 0)
        o.body:setAngle(o.rotation)
    end
    return o
end

function ship:checkMovement(dt)
    if Game.state == "game" then
        if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
            self:applyThrust(500)
        end

        if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
            self:rotate(-dt * 3)
        end

        if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
            self:rotate(dt * 3)
        end
    end
end

function ship:shoot(dt)
    local projectile = {}
    projectile.type = "projectile"
    projectile.size = { w = 25, h = 3 }
    projectile.body = love.physics.newBody(World, self.body:getX(), self.body:getY(), "dynamic")
    projectile.fixture = love.physics.newRectangleShape(projectile.size.w, projectile.size.h)
    projectile.collision = love.physics.newFixture(projectile.body, projectile.fixture)
    projectile.collision:setUserData(projectile)
    projectile.collision:setFilterData(Settings.collision.projectile, Settings.collision.comet, 0)
    local ship = self

    function projectile:destroy()
        if self.body then
            self.body:destroy()
            self.body = nil
        end
        for i, p in ipairs(ship.projectiles) do
            if p == self then
                table.remove(ship.projectiles, i)
                break
            end
        end
    end

    local angle = self.body:getAngle()
    projectile.body:setAngle(angle)

    local forceX = math.cos(angle) * Settings.ship.projectileSpeed
    local forceY = math.sin(angle) * Settings.ship.projectileSpeed
    projectile.body:applyLinearImpulse(forceX, forceY)

    table.insert(self.projectiles, projectile)
end

function ship:render()
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    UI.drawNeonPolyline(self.shape, Settings.ship.color, 16, 2)
    if Settings.DEBUG then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.line(0, 0, 30, 0)
    end

    love.graphics.pop()



    for _, projectile in ipairs(self.projectiles) do
        love.graphics.push()
        love.graphics.translate(projectile.body:getX(), projectile.body:getY())
        love.graphics.rotate(projectile.body:getAngle())
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", -projectile.size.w / 2, -projectile.size.h / 2, projectile.size.w,
            projectile.size.h)
        love.graphics.pop()
    end
end

function ship:destroy()
    if self.body then
        self.body:destroy()
        self.body = nil
    end

    Ship = nil
end

function ship:update(dt)
    if not self.body then return end
    if self.body:getX() > Screen.X + Settings.ship.screenPadding then
        self.body:setPosition(-Settings.ship.screenPadding, self.body:getY())
    end
    if self.body:getX() < -Settings.ship.screenPadding then
        self.body:setPosition(Screen.X + Settings.ship.screenPadding, self.body:getY())
    end
    if self.body:getY() > Screen.Y + Settings.ship.screenPadding then
        self.body:setPosition(self.body:getX(), -Settings.ship.screenPadding)
    end
    if self.body:getY() < -Settings.ship.screenPadding then
        self.body:setPosition(self.body:getX(), Screen.Y + Settings.ship.screenPadding)
    end

    for i = #self.projectiles, 1, -1 do
        local p = self.projectiles[i]
        if p.body then
            local x, y = p.body:getX(), p.body:getY()

            if x < -50 or x > Screen.X + 50 or y < -50 or y > Screen.Y + 50 then
                p:destroy()
            end
        end
    end
end

function ship:applyThrust(force)
    if self.body then
        local angle = self.body:getAngle()
        local forceX = math.cos(angle) * force
        local forceY = math.sin(angle) * force
        self.body:applyForce(forceX, forceY)
    end
end

function ship:rotate(amount)
    if self.body then
        self.body:setAngle(self.body:getAngle() + amount)
    else
        self.rotation = self.rotation + amount
    end
end

return ship

local ship = {}
ship.__index = ship

function ship:new(opts)
    opts       = opts or {}
    local o    = setmetatable({}, self)
    o.size     = opts.size or Settings.ship.size
    o.color    = opts.color or { 1, 1, 1, 1 }
    o.position = opts.position or { x = Screen.centerX, y = Screen.centerY }
    o.velocity = opts.velocity or { x = 0, y = 0 }
    o.damping  = opts.damping or 0.5
    o.rotation = opts.rotation or 0
    o.offset   = opts.offset or { x = 0, y = 0 }
    o.scale    = opts.scale or { w = 1, y = 1 }

    local w_2  = o.size.w / 2
    local h_2  = o.size.h / 2

    o.shape    = {
        w_2, 0,
        -w_2, -h_2,
        -(o.size.w / 4), 0,
        -w_2, h_2
    }

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        o.body:setLinearDamping(o.damping)
        o.fixture = love.physics.newPolygonShape(unpack(o.shape))
        o.collsion = love.physics.newFixture(o.body, o.fixture)
        o.collsion:setUserData(o)
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

function ship:render()
    love.graphics.push();
    love.graphics.setLineWidth(2)
    love.graphics.translate(self.body:getX(), self.body:getY())
    love.graphics.rotate(self.body:getAngle())
    love.graphics.setColor(self.color)
    love.graphics.polygon("line", self.shape)
    love.graphics.pop()
end

function ship:update(dt)
    if not self.body then return end 
    if self.body:getX() > Screen.X + Settings.ship.screenPadding then
        self.body:setPosition(-Settings.ship.screenPadding, self.body:getY())
    end
    if self.body:getX() < - Settings.ship.screenPadding then
        self.body:setPosition(Screen.X + Settings.ship.screenPadding, self.body:getY())
    end
    if self.body:getY() > Screen.Y + Settings.ship.screenPadding then
        self.body:setPosition(self.body:getX(), -Settings.ship.screenPadding)
    end
    if self.body:getY() < - Settings.ship.screenPadding then
        self.body:setPosition(self.body:getX(), Screen.Y + Settings.ship.screenPadding)
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

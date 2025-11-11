local ship = {}

function ship:new(opts)
    opts    = opts or {}
    local o = setmetatable({}, self)
    o.size  = opts.size or Settings.ship.size
    o.color = opts.color or {1,1,1,1}
    o.position = opts.position or {x = Screen.centerX, y = Screen.centerY}
    o.velocity = opts.velocity or {x = 0,y = 0}
    o.damping = opts.damping or 0.5
    o.rotation = opts.rotation or 0
    o.offset = opts.offset or {x = 0, y = 0}
    o.scale = opts.scale or {w = 1, y = 1}

    local w_2 = o.size.w / 2
    local h_2 = o.size.h / 2

    o.shape = {
        w_2, 0,
        -w_2, -h_2,
        -w_2, h_2
    }

    if opts.world then
        o.body = love.physics.newBody(opts.world, o.position.x, o.position.y, "dynamic")
        o.body:setLinearDamping(o.damping)
        o.fixture = love.physics.newPolygonShape(table.unpack(o.shape))
        o.collsion = love.physics.newFixture(o.body, o.fixture)
        o.collsion:setUserData(o)
        o.body:setAngle(o.rotation)
    end
    return o
end

function ship:render()

end

function ship:update()

end
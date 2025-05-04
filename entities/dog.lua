-- entities/dog.lua
-- Dog entity implementation

local Vector = require("libs.vector")
local DogConfig = require("config.dog_config")
local DogBehavior = require("systems.behavior.dog_behavior")

local Dog = {}
Dog.__index = Dog

-- Create a new dog
function Dog.new(x, y)
  return setmetatable({
    pos = Vector.new(x or 0, y or 0),
    vel = Vector.new(0, 0), -- Velocity vector
    dir = 0,                -- Direction in radians (0 = right, pi/2 = down)
    active = true,
    radius = DogConfig.RADIUS
  }, Dog)
end

-- Apply force to dog
function Dog:applyForce(forceX, forceY, dt)
  DogBehavior.applyForce(self, forceX, forceY, dt)
end

-- Toggle dog active state
function Dog:toggle()
  DogBehavior.toggle(self)
end

-- Update dog physics
function Dog:update(dt)
  DogBehavior.update(self, dt)
end

-- Draw the dog and its influence area
function Dog:draw()
  -- Draw influence area
  if self.active then
    -- Influence radius
    love.graphics.setColor(1, 0, 0, 0.1)
    love.graphics.circle("fill", self.pos.x, self.pos.y, self.radius)
  end

  -- Draw dog
  love.graphics.setColor(1, 0, 0)
  love.graphics.circle("fill", self.pos.x, self.pos.y, 8)
  love.graphics.setColor(1, 0.7, 0.7)
  love.graphics.circle("line", self.pos.x, self.pos.y, 10)

  -- Draw direction indicator (nose)
  if self.active then
    love.graphics.setColor(1, 1, 1)
    local noseLength = 12
    local noseX = self.pos.x + math.cos(self.dir) * noseLength
    local noseY = self.pos.y + math.sin(self.dir) * noseLength
    love.graphics.line(self.pos.x, self.pos.y, noseX, noseY)
  end
end

return Dog

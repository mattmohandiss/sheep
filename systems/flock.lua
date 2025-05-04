-- systems/flock.lua
-- Flock management system

local Vector = require("libs.vector")
local Sheep = require("entities.sheep")
local FlockConfig = require("config.flock_config")

local Flock = {}
Flock.__index = Flock

-- Create a new flock
function Flock.new()
  local flock = setmetatable({
    sheep = {},                                  -- Array of sheep
    herdDirection = Vector.random(-1, 1, -1, 1), -- Current drift direction
    changeTimer = 0                              -- Timer for direction changes
  }, Flock)

  -- Initialize the flock
  flock:initialize()

  return flock
end

-- Initialize sheep in a circular formation
function Flock:initialize()
  -- Calculate center and radius
  local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
  local radius = math.min(love.graphics.getWidth(), love.graphics.getHeight()) * FlockConfig.INITIAL_RADIUS_FACTOR

  -- Create sheep in a loose circular formation
  for i = 1, FlockConfig.FLOCK_SIZE do
    local angle = math.random() * math.pi * 2
    local distance = math.random() * radius
    local x = centerX + math.cos(angle) * distance
    local y = centerY + math.sin(angle) * distance

    table.insert(self.sheep, Sheep.new(x, y))
  end
end

-- Update flock logic
function Flock:update(dog, dt)
  -- Update flock direction periodically
  self:updateHerdDirection(dt)

  -- Update each sheep
  for _, sheep in ipairs(self.sheep) do
    sheep:update(self.sheep, dog, dt)
  end
end

-- Update herd direction with periodic changes
function Flock:updateHerdDirection(dt)
  self.changeTimer = self.changeTimer + dt

  if self.changeTimer > FlockConfig.DIRECTION_CHANGE_TIME then
    self.changeTimer = 0

    -- Calculate a small change to current direction for smooth transitions
    local angle = math.random() *
        (FlockConfig.DIRECTION_CHANGE_ANGLE_MAX - FlockConfig.DIRECTION_CHANGE_ANGLE_MIN) +
        FlockConfig.DIRECTION_CHANGE_ANGLE_MIN

    -- Convert current direction to angle, adjust, and convert back
    local currentMag = self.herdDirection:magnitude()

    if currentMag > 0 then
      -- Rotate current direction by the angle
      local oldX, oldY = self.herdDirection.x, self.herdDirection.y
      self.herdDirection.x = oldX * math.cos(angle) - oldY * math.sin(angle)
      self.herdDirection.y = oldX * math.sin(angle) + oldY * math.cos(angle)

      -- Normalize the direction
      self.herdDirection = self.herdDirection:normalize()
    else
      -- If no direction, create a new one
      self.herdDirection = Vector.random(-1, 1, -1, 1):normalize()
    end
  end
end

-- Draw the flock
function Flock:draw()
  -- Draw each sheep
  for _, sheep in ipairs(self.sheep) do
    sheep:draw()
  end

  -- Draw herd direction indicator
  love.graphics.setColor(0.3, 0.6, 0.3, 0.5)
  local centerX, centerY = love.graphics.getWidth() / 2, 30
  love.graphics.circle("fill", centerX, centerY, 5)

  local dirEndX = centerX + self.herdDirection.x * 20
  local dirEndY = centerY + self.herdDirection.y * 20

  love.graphics.line(centerX, centerY, dirEndX, dirEndY)
end

return Flock

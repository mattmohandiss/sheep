-- entities/sheep.lua
-- Sheep entity implementation

local Vector = require("libs.vector")
local SheepConfig = require("config.sheep_config")
local Movement = require("systems.behavior.movement")
local SheepBehavior = require("systems.behavior.sheep_behavior")

local Sheep = {}
Sheep.__index = Sheep

-- Create a new sheep entity
function Sheep.new(x, y)
  return setmetatable({
    pos = Vector.new(x, y),
    vel = Vector.random(-1, 1, -1, 1),

    -- Behavioral state
    stressed = 0,
    state = "grazing",
    isLeader = math.random() < SheepConfig.LEADER_CHANCE,
  }, Sheep)
end

-- Update sheep logic
function Sheep:update(flock, dog, dt)
  -- Update state and get distance to dog
  local _, dogDist = SheepBehavior.determineState(self, dog, dt)

  -- Get forces that affect sheep movement
  local forces = SheepBehavior.calculateForces(self, flock, dog)

  -- Calculate new velocity change from forces
  local velocityChange = SheepBehavior.applyMovement(self, forces, dog, dogDist, dt)
  
  -- Apply velocity with momentum
  Movement.applyVelocity(self, velocityChange)

  -- Calculate appropriate speed limit
  local maxSpeed = SheepBehavior.calculateSpeedLimit(self, dogDist, dog)
  
  -- Apply speed limit
  Movement.limitSpeed(self, maxSpeed)
  
  -- Ensure minimum speed
  Movement.ensureMinSpeed(self, SheepConfig.MIN_SPEED[self.state])

  -- Update position with screen wrapping
  Movement.updatePosition(self, dt)
end

-- Draw the sheep
function Sheep:draw()
  -- Determine color based on state
  local color

  if self.isLeader then
    -- Leaders are slightly larger and more distinct
    if self.state == "grazing" then
      color = { 0.9, 1.0, 0.9 }
    elseif self.state == "alert" then
      color = { 0.9, 1.0, 0.6 }
    elseif self.state == "fleeing" then
      color = { 1.0, 0.7, 0.7 }
    end

    -- Draw leader sheep
    love.graphics.setColor(unpack(color))
    love.graphics.circle("fill", self.pos.x, self.pos.y, 6)
  else
    -- Regular sheep
    if self.state == "grazing" then
      color = { 1.0, 1.0, 1.0 }
    elseif self.state == "alert" then
      color = { 1.0, 1.0, 0.7 }
    elseif self.state == "fleeing" then
      color = { 1.0, 0.8, 0.8 }
    end

    -- Draw regular sheep
    love.graphics.setColor(unpack(color))
    love.graphics.circle("fill", self.pos.x, self.pos.y, 5)
  end

  -- Draw direction indicator when stressed
  if self.stressed > 0.2 then
    local mag = self.vel:magnitude()
    if mag > 0 then
      local headingX = self.pos.x + self.vel.x / mag * 8
      local headingY = self.pos.y + self.vel.y / mag * 8
      love.graphics.line(self.pos.x, self.pos.y, headingX, headingY)
    end
  end
end

return Sheep

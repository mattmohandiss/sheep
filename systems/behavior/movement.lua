-- systems/behavior/movement.lua
-- Common movement physics for all entities

local Vector = require("libs.vector")
local AnimalConfig = require("config.animal_config")
local GameConfig = require("config.game_config")

local Movement = {}

-- Update entity position based on velocity
function Movement.updatePosition(entity, dt)
  -- Calculate new position
  entity.pos.x = (entity.pos.x + entity.vel.x * dt) % love.graphics.getWidth()
  entity.pos.y = (entity.pos.y + entity.vel.y * dt) % love.graphics.getHeight()
end

-- Apply velocity changes with persistence/momentum
function Movement.applyVelocity(entity, newVel)
  entity.vel = entity.vel * AnimalConfig.VELOCITY_PERSISTENCE + newVel
end

-- Limit speed to a maximum value
function Movement.limitSpeed(entity, maxSpeed)
  local speed = entity.vel:magnitude()
  if speed > maxSpeed and speed > 0 then
    entity.vel = entity.vel * (maxSpeed / speed)
  end
end

-- Handle boundary collisions
function Movement.handleBoundaries(entity)
  local width, height = love.graphics.getDimensions()
  local buffer = GameConfig.BOUNDARY_BUFFER
  local bounceFactor = AnimalConfig.BOUNCE_ENERGY_FACTOR

  if entity.pos.x < buffer then
    entity.pos.x = buffer
    entity.vel.x = math.abs(entity.vel.x) * bounceFactor -- Bounce with reduced energy
  elseif entity.pos.x > width - buffer then
    entity.pos.x = width - buffer
    entity.vel.x = -math.abs(entity.vel.x) * bounceFactor -- Bounce with reduced energy
  end

  if entity.pos.y < buffer then
    entity.pos.y = buffer
    entity.vel.y = math.abs(entity.vel.y) * bounceFactor -- Bounce with reduced energy
  elseif entity.pos.y > height - buffer then
    entity.pos.y = height - buffer
    entity.vel.y = -math.abs(entity.vel.y) * bounceFactor -- Bounce with reduced energy
  end
end

-- Ensure minimum movement speed
function Movement.ensureMinSpeed(entity, minSpeed)
  local velMag = entity.vel:magnitude()
  if velMag < minSpeed and velMag > 0.001 then
    entity.vel = entity.vel * (minSpeed / velMag)
  elseif velMag <= 0.001 then
    -- If stopped, give a small random push
    entity.vel = Vector.random(-1, 1, -1, 1) * (minSpeed * 0.5)
  end
end

-- Apply drag/friction to velocity
function Movement.applyDrag(entity, dragCoefficient, dt)
  local dragFactor = 1 - math.min(dragCoefficient * dt, 0.9)
  entity.vel = entity.vel * dragFactor
end

-- Update direction to face velocity
function Movement.updateDirection(entity, rotationSpeed, dt, minVelocity)
  minVelocity = minVelocity or 10 -- Default threshold for rotation
  
  if entity.vel:magnitude() > minVelocity then
    local targetDir = math.atan2(entity.vel.y, entity.vel.x)
    local diff = (targetDir - entity.dir)

    -- Handle angle wrapping for shortest rotation
    if diff > math.pi then diff = diff - 2 * math.pi end
    if diff < -math.pi then diff = diff + 2 * math.pi end

    entity.dir = entity.dir + diff * math.min(rotationSpeed * dt, 1)
  end
end

return Movement

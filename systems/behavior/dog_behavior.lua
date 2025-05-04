-- systems/behavior/dog_behavior.lua
-- Dog-specific behavior system

local Vector = require("libs.vector")
local DogConfig = require("config.dog_config")
local Movement = require("systems.behavior.movement")

local DogBehavior = {}

-- Apply force to dog
function DogBehavior.applyForce(dog, forceX, forceY, dt)
  if not dog.active then return end

  -- Add force to velocity
  dog.vel.x = dog.vel.x + forceX * dt
  dog.vel.y = dog.vel.y + forceY * dt

  -- Limit velocity to max speed
  local speed = dog.vel:magnitude()
  if speed > DogConfig.MAX_SPEED then
    dog.vel = dog.vel:normalize() * DogConfig.MAX_SPEED
  end
end

-- Toggle dog active state
function DogBehavior.toggle(dog)
  dog.active = not dog.active

  if not dog.active then
    -- Move dog far away when inactive
    dog.pos.x = -1000
    dog.pos.y = -1000
    dog.vel.x, dog.vel.y = 0, 0
  end
end

-- Update dog physics
function DogBehavior.update(dog, dt)
  if not dog.active then return false end

  -- Apply drag/friction
  Movement.applyDrag(dog, DogConfig.DRAG, dt)

  -- Update position based on velocity
  dog.pos = dog.pos + (dog.vel * dt)

  -- Update direction to face velocity
  Movement.updateDirection(dog, DogConfig.ROTATION_SPEED, dt)

  -- Handle boundary collisions
  Movement.handleBoundaries(dog)
  
  return true
end

return DogBehavior

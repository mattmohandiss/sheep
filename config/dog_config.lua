-- config/dog_config.lua
-- Dog-specific settings

local DogConfig = {
  RADIUS = 500,              -- Radius of influence
  MAX_SPEED = 300,           -- Maximum speed (pixels per second)
  ACCELERATION = 800,        -- Acceleration rate
  DRAG = 2,                  -- Drag/friction coefficient
  ROTATION_SPEED = 8         -- How quickly dog rotates to face direction
}

return DogConfig

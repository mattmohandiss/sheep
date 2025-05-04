-- config/flock_config.lua
-- Flock configuration

local FlockConfig = {
  FLOCK_SIZE = 100,                       -- Number of sheep in the flock
  INITIAL_RADIUS_FACTOR = 0.15,           -- Initial flock radius as a factor of screen size
  DIRECTION_CHANGE_TIME = 5,              -- Seconds between random direction changes
  DIRECTION_CHANGE_ANGLE_MAX = math.pi / 4, -- Maximum angle change (45 degrees)
  DIRECTION_CHANGE_ANGLE_MIN = -math.pi / 8 -- Minimum angle change (-22.5 degrees)
}

return FlockConfig

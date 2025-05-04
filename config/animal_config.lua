-- config/animal_config.lua
-- Shared animal configurations

local AnimalConfig = {
  -- Common movement parameters
  VELOCITY_PERSISTENCE = 0.5, -- Constant momentum factor
  
  -- Screen bounds parameters
  BOUNCE_ENERGY_FACTOR = 0.5  -- Energy retained after collision with boundary
}

return AnimalConfig

-- systems/input.lua
-- Input handling system

local DogConfig = require("config.dog_config")

local Input = {}

-- Initialize input handlers
function Input.init(dog)
  -- Store reference to dog for keypress handlers
  Input.dog = dog
end

-- Update based on keyboard input
function Input.update(dt)
  if not Input.dog or not Input.dog.active then
    return
  end

  -- Apply forces based on arrow key input
  local forceX, forceY = 0, 0
  local acceleration = DogConfig.ACCELERATION

  -- Check arrow keys for direction input
  if love.keyboard.isDown("up") then
    forceY = -acceleration
  end
  if love.keyboard.isDown("down") then
    forceY = acceleration
  end
  if love.keyboard.isDown("left") then
    forceX = -acceleration
  end
  if love.keyboard.isDown("right") then
    forceX = acceleration
  end

  -- Apply the calculated force
  Input.dog:applyForce(forceX, forceY, dt)

  -- Update dog physics
  Input.dog:update(dt)
end

-- Key pressed handler
function Input.keypressed(key)
  if key == "space" and Input.dog then
    -- Toggle dog active state
    Input.dog:toggle()
  end
end

return Input

-- systems/render.lua
-- Rendering utilities

local RenderConfig = require("config.render_config")

local Render = {}

-- Initialize rendering settings
function Render.init()
  love.graphics.setBackgroundColor(unpack(RenderConfig.BACKGROUND_COLOR))
end

-- Draw center reference point
function Render.drawCenterMarker()
  love.graphics.setColor(unpack(RenderConfig.CENTER_MARKER_COLOR))
  local centerX, centerY = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2
  love.graphics.circle("fill", centerX, centerY, RenderConfig.CENTER_MARKER_SIZE)
end

-- Draw instructions text
function Render.drawInstructions()
  love.graphics.setColor(unpack(RenderConfig.TEXT_COLOR))
  love.graphics.print(
    "Arrows: Move Dog | Space: Toggle Dog",
    RenderConfig.TEXT_PADDING,
    RenderConfig.TEXT_PADDING
  )
end

-- Draw everything in the scene
function Render.draw(flock, dog)
  -- Clear the screen
  love.graphics.clear()

  -- Draw the center marker
  Render.drawCenterMarker()

  -- Draw the flock (includes direction indicator)
  flock:draw()

  -- Draw the dog
  dog:draw()

  -- Draw instructions
  Render.drawInstructions()
end

return Render

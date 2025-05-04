-- main.lua
-- Main entry point for Sheep Herding Simulation

if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

-- Import our modules
local Vector = require("libs.vector")
local Sheep = require("entities.sheep")
local Dog = require("entities.dog")
local Flock = require("systems.flock")
local Render = require("systems.render")
local Input = require("systems.input")

-- Game state
local flock
local dog

-- LÖVE callbacks

-- Initialization
function love.load()
  -- Randomize
  math.randomseed(os.time())

  -- Initialize rendering system
  Render.init()

  -- Create a dog at screen center
  dog = Dog.new(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

  -- Create a new flock
  flock = Flock.new()

  -- Initialize input handlers
  Input.init(dog)

  -- Set window title
  love.window.setTitle("Sheep Herding Simulation")
end

-- Update game state
function love.update(dt)
  -- Handle input (update dog position) with dt for physics
  Input.update(dt)

  -- Update flock behavior
  flock:update(dog, dt)
end

-- Draw all entities
function love.draw()
  Render.draw(flock, dog)
end

-- Handle key presses
function love.keypressed(key)
  Input.keypressed(key)

  -- Handle escape key to quit
  if key == "escape" then
    love.event.quit()
  end
end

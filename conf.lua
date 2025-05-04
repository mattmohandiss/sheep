-- conf.lua
-- LÖVE configuration

function love.conf(t)
    t.title = "Sheep Herding Simulation" -- The title of the window
    t.version = "11.4"                   -- The LÖVE version this game was made for
    t.window.width = 1600                -- The window width
    t.window.height = 1200               -- The window height

    -- For debugging
    t.console = false -- Attach a console for print output

    -- Disable unused modules to save memory
    t.modules.joystick = false -- We don't use joystick
    t.modules.physics = false  -- We don't use physics
    t.modules.video = false    -- We don't use video
    t.modules.thread = false   -- We don't use threads
    t.modules.audio = false    -- We don't use audio
end

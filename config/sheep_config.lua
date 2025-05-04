-- config/sheep_config.lua
-- Sheep-specific settings

local SheepConfig = {
    -- General parameters
    LEADER_CHANCE = 0.07, -- Slightly increased leader chance for more dynamic group behavior
    ALONE_THRESHOLD = 2, -- Reduced threshold to make sheep more sensitive to isolation
    NEIGHBOR_RADIUS = 150, -- Distance to check for neighbors

    -- Dog reaction parameters
    ALERT_RANGE = 500,        -- Distance to become alert of dog
    FLEE_RANGE = 380,         -- Distance to start fleeing from dog
    FLEE_INTENSITY_BASE = 10.0, -- Base multiplier for flee force
    FLEE_INTENSITY_CURVE = 2.8, -- Power curve for flee intensity
    FLEE_INTENSITY_MAX = 20.0, -- Maximum flee intensity
    PUSH_RANGE = 300,         -- Range for immediate velocity push
    PUSH_MULTIPLIER = 40,     -- Strength of push

    -- Movement parameters
    MIN_SPEED = {
        grazing = 8,
        alert = 20,
        fleeing = 50
    },

    -- Interaction distances
    SEPARATION_DISTANCE = {
        grazing = 20, -- Slightly larger separation when grazing for more natural spacing
        alert = 20,
        fleeing = 30
    },

    INTERACTION_RADIUS = {
        grazing = 200, -- Increased interaction radius for more dynamic grazing behavior
        alert = 175,
        fleeing = 180
    },

    -- State definitions
    STATES = {
        grazing = {
            speed = 30,
            max_speed = 120,
            weights = {
                separation = 0.8,
                alignment = 1.5,
                cohesion = 3.0,
                drift = 1.0,
                seek = 3.0, -- when alone
                flee = 0, -- calculated dynamically
                herd = 0.5
            }
        },

        alert = {
            speed = 70,
            max_speed = 200,
            weights = {
                separation = 0.7,
                alignment = 2.0,
                cohesion = 2.0,
                drift = 0.5,
                seek = 2.0, -- when alone
                flee = 5.0, -- base value, calculated dynamically
                herd = 1.0
            }
        },

        fleeing = {
            speed = 120,
            max_speed = 300,
            weights = {
                separation = 0.5,
                alignment = 1.0,
                cohesion = 0.5,
                drift = 0.0,
                seek = 0.0,
                flee = 25.0, -- High flee weight
                herd = 1.5
            }
        }
    }
}

return SheepConfig

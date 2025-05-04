-- systems/behavior/sheep_behavior.lua
-- Sheep-specific behavior system

local Vector = require("libs.vector")
local SheepConfig = require("config.sheep_config")

local SheepBehavior = {}

-- Determine sheep state based on proximity to dog
function SheepBehavior.determineState(sheep, dog, dt)
  -- Calculate distance to the dog
  local dogVec = sheep.pos - dog.pos
  local dogDist = dogVec:magnitude()
  local oldState = sheep.state
  
  -- Update state based on dog proximity
  if dogDist < SheepConfig.FLEE_RANGE then
    sheep.state = "fleeing"
    -- Fast stress increase with no hesitation
    sheep.stressed = math.min(sheep.stressed + dt * 3.0, 1.0)
  elseif dogDist < SheepConfig.ALERT_RANGE then
    sheep.state = "alert"
    -- Moderate stress increase
    sheep.stressed = math.min(sheep.stressed + dt * 1.5, 0.7)
  else
    sheep.state = "grazing"
    sheep.stressed = math.max(sheep.stressed - dt * 0.5, 0)
  end
  
  return sheep.state, dogDist
end

-- Calculate all forces affecting the sheep
function SheepBehavior.calculateForces(sheep, flock, dog)
  local forces = {
    separation = Vector.new(), -- Keep distance from other sheep
    alignment = Vector.new(),  -- Align with other sheep direction
    cohesion = Vector.new(),   -- Stay with the group
    flee = Vector.new(),       -- Run from dog
    herd = Vector.new(),       -- Move with other fleeing sheep
    drift = Vector.new(),      -- Natural drift direction
    seek = Vector.new()        -- Seek back to flock if alone
  }

  -- Get the global herd direction if it exists
  local globalHerdDirection = nil
  if flock.herdDirection then
    globalHerdDirection = flock.herdDirection
  end

  -- Count nearby sheep to detect if alone
  local neighbors = SheepBehavior.countNeighbors(sheep, flock)
  local isAlone = neighbors.count < SheepConfig.ALONE_THRESHOLD

  -- Calculate center of the flock
  local flockCenter = SheepBehavior.calculateFlockCenter(sheep, flock)

  -- Apply natural herd drift when grazing or alert (with reduced effect when alert)
  if sheep.state == "grazing" or sheep.state == "alert" then
    if globalHerdDirection then
      -- Use the global herd direction from flock if available
      forces.drift = SheepBehavior.calculateDrift(sheep, globalHerdDirection)
    else
      -- Fall back to local direction if global not available
      forces.drift = SheepBehavior.calculateDrift(sheep, neighbors.herdDirection)
    end
  end

  -- Calculate forces from interactions with other sheep
  SheepBehavior.calculateSheepInteractionForces(sheep, forces, flock, isAlone, flockCenter)

  -- Calculate force to flee from dog
  forces.flee = SheepBehavior.calculateFleeDogForce(sheep, dog)

  return forces
end

-- Count how many sheep are nearby
function SheepBehavior.countNeighbors(sheep, flock)
  local count = 0
  local herdDirection = Vector.new()

  for _, other in ipairs(flock) do
    if other ~= sheep then
      local dist = sheep.pos:distance(other.pos)
      if dist < SheepConfig.NEIGHBOR_RADIUS then
        count = count + 1
        herdDirection = herdDirection + other.vel
      end
    end
  end

  return { count = count, herdDirection = herdDirection }
end

-- Calculate center position of the entire flock
function SheepBehavior.calculateFlockCenter(sheep, flock)
  local center = Vector.new()
  local count = 0

  for _, other in ipairs(flock) do
    if other ~= sheep then
      center = center + other.pos
      count = count + 1
    end
  end

  if count > 0 then
    center = center / count
  end

  return center
end

-- Calculate natural drift direction
function SheepBehavior.calculateDrift(sheep, herdDirection)
  -- Add more natural grazing behavior with randomized micro-movements
  if sheep.state == "grazing" then
    -- Introduce more complex drift for grazing
    local randomDrift = Vector.random(-0.3, 0.3, -0.3, 0.3)
    local headingVariation = Vector.random(-0.2, 0.2, -0.2, 0.2)
    
    if herdDirection then
      -- Apply slight variations to herd direction when grazing
      if sheep.isLeader then
        return (herdDirection * 1.2 + randomDrift + headingVariation):normalize()
      else
        return (herdDirection + randomDrift * 0.5 + headingVariation * 0.3):normalize()
      end
    else
      -- More pronounced random movement when no global direction exists
      return (randomDrift + headingVariation):normalize()
    end
  elseif herdDirection then
    -- Existing logic for non-grazing states
    if sheep.isLeader then
      return herdDirection * 1.5
    else
      return herdDirection
    end
  else
    -- Minimal random drift for other states
    return Vector.random(-0.1, 0.1, -0.1, 0.1)
  end
end

-- Calculate all forces from interactions with other sheep
function SheepBehavior.calculateSheepInteractionForces(sheep, forces, flock, isAlone, flockCenter)
  -- Force accumulators
  local separation = Vector.new()
  local alignment = Vector.new()
  local cohesion = Vector.new()
  local herd = Vector.new()

  -- Count for averaging
  local countSep, countAli, countCoh, countHerd = 0, 0, 0, 0

  -- Grazing-specific behavior parameters
  local grazingHeadDown = sheep.grazingTimer and sheep.grazingTimer < 5  -- Head down for grazing
  local slowGrazingMovement = sheep.grazingTimer and sheep.grazingTimer >= 5 and sheep.grazingTimer < 8

  -- Loop through all sheep
  for _, other in ipairs(flock) do
    if other ~= sheep then
      local toOther = other.pos - sheep.pos
      local dist = toOther:magnitude()

      -- Leadership factor
      local leaderFactor = other.isLeader and 1.5 or 1.0

      -- Separation - keep distance from close sheep
      local sepDist = SheepConfig.SEPARATION_DISTANCE[sheep.state]
      if dist < sepDist and dist > 0 then
        local separationForce = toOther:normalize()
        
        -- Reduce separation force when grazing and head is down
        if sheep.state == "grazing" and grazingHeadDown then
          separationForce = separationForce * 0.3
        end
        
        separation = separation - separationForce
        countSep = countSep + 1
      end

      -- Interaction radius changes based on state
      local interactRadius = SheepConfig.INTERACTION_RADIUS[sheep.state]
      if dist < interactRadius then
        -- Alignment - follow direction of others
        local alignmentForce = other.vel * leaderFactor
        
        -- Reduce alignment when grazing with head down
        if sheep.state == "grazing" and grazingHeadDown then
          alignmentForce = alignmentForce * 0.5
        end
        
        alignment = alignment + alignmentForce
        countAli = countAli + 1

        -- Cohesion - stay with the group (stronger when grazing)
        if sheep.state ~= "fleeing" then
          -- Slow, gentle cohesion when grazing and head is down
          local cohesionForce = other.pos
          if sheep.state == "grazing" and slowGrazingMovement then
            cohesionForce = cohesionForce * 0.7
          end
          
          cohesion = cohesion + cohesionForce
          countCoh = countCoh + 1
        end

        -- Herding - flee together in same direction
        if sheep.state == "fleeing" and other.state == "fleeing" then
          herd = herd + other.vel
          countHerd = countHerd + 1
        end
      end
    end
  end

  -- Average and normalize forces
  if countSep > 0 then
    forces.separation = (separation / countSep):normalize()
  end

  if countAli > 0 then
    forces.alignment = (alignment / countAli):normalize()
  end

  if countCoh > 0 then
    forces.cohesion = ((cohesion / countCoh) - sheep.pos):normalize()
  end

  if countHerd > 0 then
    forces.herd = (herd / countHerd):normalize()
  end

  -- If alone, seek back to the flock
  if isAlone and flockCenter:magnitude() > 0 then
    forces.seek = (flockCenter - sheep.pos):normalize()
  end

  return forces
end

-- Calculate force to flee from dog
function SheepBehavior.calculateFleeDogForce(sheep, dog)
  local flee = Vector.new()
  local dogVec = sheep.pos - dog.pos
  local dogDist = dogVec:magnitude()

  if dogDist < dog.radius then
    -- Normalize the vector away from dog
    dogVec = dogVec:normalize()

    -- Calculate intensity based on inverse square of distance
    -- This creates a smooth, continuous increase in repulsion as sheep get closer to the dog
    local fleeIntensity = 1.0

    -- Calculate intensity with inverse square formula (higher intensity as distance decreases)
    -- We add a small value (5) to prevent division by near-zero values
    fleeIntensity = SheepConfig.FLEE_INTENSITY_BASE *
        (1 / ((dogDist + 5) / 50)) ^ SheepConfig.FLEE_INTENSITY_CURVE

    -- Cap the maximum intensity
    fleeIntensity = math.min(fleeIntensity, SheepConfig.FLEE_INTENSITY_MAX)

    flee = dogVec * fleeIntensity

    -- Apply immediate velocity push with smooth scaling based on distance
    local pushFactor = math.max(0, (SheepConfig.PUSH_RANGE - dogDist) / SheepConfig.PUSH_RANGE) *
        SheepConfig.PUSH_MULTIPLIER
    if pushFactor > 0 then
      sheep.vel = sheep.vel + (dogVec * pushFactor)
    end
  end

  return flee
end

-- Calculate weights for different forces based on state
function SheepBehavior.calculateForceWeights(sheep, dogDist, dog)
  local weights = {
    separation = 1.0,
    alignment = 1.0,
    cohesion = 2.5,
    flee = 0,
    herd = 0,
    drift = 0,
    seek = 0
  }

  -- Get base weights from the current state
  local stateWeights = SheepConfig.STATES[sheep.state].weights
  for k, v in pairs(stateWeights) do
    weights[k] = v
  end

  -- Handle being alone
  if sheep.isAlone and weights.seek > 0 then
    weights.seek = weights.seek -- Keep seek weight from state config
  else
    weights.seek = 0            -- Not alone, no need to seek
  end

  -- Adjust flee weight based on dog distance if in grazing or alert state
  if sheep.state ~= "fleeing" and dogDist < dog.radius then
    -- Scale flee weight based on distance
    weights.flee = weights.flee + (dog.radius - dogDist) / 100 * 2
  end

  return weights
end

-- Apply movement with varying speed limits
function SheepBehavior.applyMovement(sheep, forces, dog, dogDist, dt)
  -- Determine force weights based on state
  local weights = SheepBehavior.calculateForceWeights(sheep, dogDist, dog)

  -- Manage grazing timer for natural movement patterns
  sheep.grazingTimer = sheep.grazingTimer or 0
  sheep.grazingTimer = sheep.grazingTimer + dt

  -- Reset grazing timer periodically to simulate natural grazing behavior
  if sheep.grazingTimer > 10 then
    sheep.grazingTimer = 0
  end

  -- Calculate weighted velocity change
  local newVel = Vector.new()
  
  -- Modify velocity calculation for more natural grazing
  if sheep.state == "grazing" then
    -- When head is down (first 5 seconds), move very slowly
    if sheep.grazingTimer < 5 then
      newVel = forces.drift * 0.2  -- Minimal movement
    -- When head is up (next 3 seconds), move with slight randomness
    elseif sheep.grazingTimer < 8 then
      newVel = newVel + (
        forces.separation * weights.separation * 0.5 +
        forces.alignment * weights.alignment * 0.7 +
        forces.cohesion * weights.cohesion * 0.6 +
        forces.drift * weights.drift
      ) * dt * 0.5
    -- Normal grazing movement
    else
      newVel = newVel + (
        forces.separation * weights.separation +
        forces.alignment * weights.alignment +
        forces.cohesion * weights.cohesion +
        forces.flee * weights.flee +
        forces.herd * weights.herd +
        forces.drift * weights.drift +
        forces.seek * weights.seek
      ) * dt * (1 + sheep.stressed)
    end
  else
    -- Existing logic for non-grazing states
    newVel = newVel + (
      forces.separation * weights.separation +
      forces.alignment * weights.alignment +
      forces.cohesion * weights.cohesion +
      forces.flee * weights.flee +
      forces.herd * weights.herd +
      forces.drift * weights.drift +
      forces.seek * weights.seek
    ) * dt * (1 + sheep.stressed)
  end

  return newVel
end

-- Calculate the appropriate speed limit for the sheep based on state and dog proximity
function SheepBehavior.calculateSpeedLimit(sheep, dogDist, dog)
  local stateConfig = SheepConfig.STATES[sheep.state]
  local currentMaxSpeed = stateConfig.speed

  -- Adjust speed based on state and dog proximity
  if sheep.state == "grazing" or sheep.state == "alert" then
    -- Speed up when dog approaches
    if dogDist < dog.radius then
      -- Calculate speed increase based on dog proximity
      local maxStateSpeed = stateConfig.max_speed
      currentMaxSpeed = currentMaxSpeed + (maxStateSpeed - currentMaxSpeed) *
          (1 - math.min(dogDist / dog.radius, 1.0)) * 1.5
    end
  elseif sheep.state == "fleeing" then
    -- Use max speed for fleeing
    currentMaxSpeed = stateConfig.max_speed

    -- Boost speed when dog is very close
    if dogDist < SheepConfig.PUSH_RANGE then
      local boostFactor = 1.0 + (SheepConfig.PUSH_RANGE - dogDist) / SheepConfig.PUSH_RANGE * 2.0
      currentMaxSpeed = currentMaxSpeed * boostFactor
    end
  end

  return currentMaxSpeed
end

return SheepBehavior

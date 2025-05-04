-- libs/vector.lua
-- Vector2D utility for handling vector operations

local Vector = {}
Vector.__index = Vector

-- Create a new vector
function Vector.new(x, y)
  return setmetatable({ x = x or 0, y = y or 0 }, Vector)
end

-- Vector addition
function Vector:add(v)
  return Vector.new(self.x + v.x, self.y + v.y)
end

-- Vector subtraction
function Vector:sub(v)
  return Vector.new(self.x - v.x, self.y - v.y)
end

-- Vector multiplication by scalar
function Vector:mul(s)
  return Vector.new(self.x * s, self.y * s)
end

-- Vector division by scalar
function Vector:div(s)
  if s ~= 0 then
    return Vector.new(self.x / s, self.y / s)
  else
    return Vector.new(0, 0) -- Prevent division by zero
  end
end

-- Vector magnitude (length)
function Vector:magnitude()
  return math.sqrt(self.x ^ 2 + self.y ^ 2)
end

-- Vector normalization (unit vector)
function Vector:normalize()
  local mag = self:magnitude()
  if mag > 0 then
    return self:div(mag)
  else
    return Vector.new(0, 0)
  end
end

-- Distance between two vectors
function Vector:distance(v)
  local dx = self.x - v.x
  local dy = self.y - v.y
  return math.sqrt(dx * dx + dy * dy)
end

-- Dot product
function Vector:dot(v)
  return self.x * v.x + self.y * v.y
end

-- Linear interpolation between vectors
function Vector:lerp(v, t)
  return self:add((v - self):mul(t))
end

-- Create a random vector within given bounds
function Vector.random(xmin, xmax, ymin, ymax)
  return Vector.new(
    math.random() * (xmax - xmin) + xmin,
    math.random() * (ymax - ymin) + ymin
  )
end

-- Convert to string for debugging
function Vector:__tostring()
  return "(" .. self.x .. ", " .. self.y .. ")"
end

-- Operator overloads for more natural vector math
function Vector.__add(a, b)
  return Vector.new(a.x + b.x, a.y + b.y)
end

function Vector.__sub(a, b)
  return Vector.new(a.x - b.x, a.y - b.y)
end

function Vector.__mul(a, b)
  if type(a) == "number" then
    return Vector.new(a * b.x, a * b.y)
  elseif type(b) == "number" then
    return Vector.new(a.x * b, a.y * b)
  else
    return a.x * b.x + a.y * b.y -- dot product
  end
end

function Vector.__div(a, b)
  if type(b) == "number" and b ~= 0 then
    return Vector.new(a.x / b, a.y / b)
  else
    return Vector.new(0, 0) -- Prevent division by zero
  end
end

function Vector.__eq(a, b)
  return a.x == b.x and a.y == b.y
end

return Vector

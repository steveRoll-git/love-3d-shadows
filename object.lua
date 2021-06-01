local love = love
local lg = love.graphics

local lmath = require "lmath"
local mat4 = lmath.matrix4

local object = {}
object.__index = object

function object.new(mesh)
  local self = setmetatable({mesh = mesh}, object)
  self.transform = mat4.new()
  self.color = {1,1,1}
  return self
end

function object:draw()
  lg.getShader():send("model", self.transform)
  lg.setColor(self.color)
  lg.draw(self.mesh)
end

return object


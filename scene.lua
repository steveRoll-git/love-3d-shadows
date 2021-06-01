local love = love
local lg = love.graphics

local lmath = require "lmath"

local mat4 = lmath.matrix4
local vec3 = lmath.vector3
local zero = vec3.new()

local scene = {}
scene.__index = scene

function scene.new(objects)
  local self = setmetatable({}, scene)

  self.lightingShader = lg.newShader("shaders/lighting.frag", "shaders/shader.vert")
  self.justDepthShader = lg.newShader("shaders/justDepth.frag", "shaders/shader.vert")

  self.camera = {
    transform = mat4.new(),
    rotation = vec3.new(),

    projection = mat4.new():set_perspective(60, lg.getWidth()/lg.getHeight(), 0.1, 100),
    view = mat4.new(),
  }

  self.lightingShader:send("projection", self.camera.projection)

  self.sunDirection = vec3.new(0.7, -0.9, -0.6):normalize()
  self.sunPosition = vec3.new(1, 0, 1) -- not literally the position of the sun, rather the point which it should focus on
  self.sunDistance = 15 -- the distance of the sun camera from the position


  self.shadowViewSize = 25 / 2
  self.shadowProjection = mat4.new():set_orthographic(-self.shadowViewSize, self.shadowViewSize, self.shadowViewSize, -self.shadowViewSize, 0.1, 50)
  self.shadowView = mat4.new()

  self:updateShadowView()

  self.lightingShader:send("shadowProjection", self.shadowProjection)
  self.justDepthShader:send("projection", self.shadowProjection)

  local shadowResolution = 4096
  self.shadowMap = lg.newCanvas(shadowResolution, shadowResolution, {format = "depth24", readable = true})
  self.shadowCanvasSettings = {depthstencil = self.shadowMap}
  self.lightingShader:send("shadowMap", self.shadowMap)

  self.objects = objects or {}

  return self
end

function scene:updateShadowView()
  self.lightingShader:send("sunDirection", {self.sunDirection:unpack()})
  self.shadowView
    :set_look(self.sunDirection:unpack())
    :set_position((self.sunPosition - self.sunDirection * self.sunDistance):unpack())
    :inverse()
  self.lightingShader:send("shadowView", self.shadowView) 
  self.justDepthShader:send("view", self.shadowView)
end

function scene:drawObjects()
  for _, o in ipairs(self.objects) do
    o:draw()
  end
end

function scene:draw()
  self.camera.transform:set_euler(0, self.camera.rotation.y, 0):rotate_euler(self.camera.rotation.x, 0, 0)

  love.graphics.setDepthMode("less", true)

  lg.setShader(self.justDepthShader)
  lg.setCanvas(self.shadowCanvasSettings)
  love.graphics.setMeshCullMode("front")
  lg.clear()
  self:drawObjects()
  lg.setCanvas()

  lg.setShader(self.lightingShader)
  love.graphics.setMeshCullMode("back")
  self.camera.view:set(self.camera.transform:unpack()):inverse()
  self.lightingShader:send("view", self.camera.view)

  self:drawObjects()

  lg.setShader()
  love.graphics.setDepthMode("always", false)
end

return scene


local lg = love.graphics
local math = math
local min = math.min
local max = math.max
local pi = math.pi

local loadObj = require "wavefrontLoader"

local object = require "object"

local scene = require "scene"

local vertexFormat = {
  {"VertexPosition", "float", 3},
  {"VertexNormal", "float", 3},
  {"VertexTexCoord", "float", 2},
}

local function createObject(objPath)
  local vertices, indices = loadObj(love.filesystem.read(objPath))
  local mesh = lg.newMesh(vertexFormat, vertices, "triangles", "static")
  mesh:setVertexMap(indices)
  return object.new(mesh)
end

local monke = createObject("models/suzanne.obj")
monke.transform:set_euler(0, -pi/2, 0)
monke.color = {0.8, 0.2, 0.1}
local room = createObject("models/ruins.obj")
local sphere = createObject("models/sphere.obj")
sphere.transform:set_position(6, 2, 1)
sphere.color = {0.1, 0.2, 1}
local blocks = createObject("models/blocks.obj")
blocks.transform:set_position(5, 0, -5)
blocks.color = {0.9, 0.1, 0.1}
local cube = createObject("models/cube.obj")
cube.transform:set_position(6, 0, 1)
cube.transform:set_euler(0, -0.2, 0)
cube.color = {0.2, 1, 0.6}
local loveCube = createObject("models/lovecube.obj")
loveCube.transform:set_position(5, 0, 3)
loveCube.transform:set_euler(0, -pi/2 + 0.2, 0)
loveCube.mesh:setTexture(lg.newImage("images/loveHeart.png"))
local cylinder = createObject("models/cylinder.obj")
cylinder.transform:set_position(5, 0, 5)
cylinder.color = {0.6, 0.1, 1}

local floorImg = lg.newImage("images/floor.png")
floorImg:setWrap("repeat")
room.mesh:setTexture(floorImg)

local theScene = scene.new({monke, room, sphere, blocks, cube, loveCube, cylinder})

local moveSpeed = 4
local cameraPosition = {x=2, y=3, z=7}

love.mouse.setRelativeMode(true)

lg.setBackgroundColor(0.2, 0.5, 0.8)

function love.update(dt)
  local forwardMul = 0
  if love.keyboard.isDown("w") then
    forwardMul = -1
  elseif love.keyboard.isDown("s") then
    forwardMul = 1
  end
  forwardMul = forwardMul * moveSpeed * dt
  cameraPosition.x = cameraPosition.x + math.sin(theScene.camera.rotation.y) * forwardMul
  cameraPosition.z = cameraPosition.z + math.cos(theScene.camera.rotation.y) * forwardMul

  local sideMul = 0
  if love.keyboard.isDown("a") then
    sideMul = -1
  elseif love.keyboard.isDown("d") then
    sideMul = 1
  end
  sideMul = sideMul * moveSpeed * dt
  cameraPosition.x = cameraPosition.x + math.cos(-theScene.camera.rotation.y) * sideMul
  cameraPosition.z = cameraPosition.z + math.sin(-theScene.camera.rotation.y) * sideMul

  local verticalMul = 0
  if love.keyboard.isDown("lshift") then
    verticalMul = -1
  elseif love.keyboard.isDown("space") then
    verticalMul = 1
  end
  verticalMul = verticalMul * moveSpeed * dt
  cameraPosition.y = cameraPosition.y + verticalMul

  theScene.camera.transform:set_position(cameraPosition.x, cameraPosition.y, cameraPosition.z)

  monke.transform:set_position(-0.3, 1, 0.6 + math.sin(love.timer.getTime()) * 3)
  --monke.transform:set_euler(0, love.timer.getTime(), 0)
end

local mouseSensitivity = 0.003
function love.mousemoved(x, y, dx, dy)
  if love.mouse.isDown(2) then
    theScene.sunDirection.z = theScene.sunDirection.z + dx / 100
    theScene.sunDirection.x = theScene.sunDirection.x - dy / 100
    theScene.sunDirection:normalize()
    theScene:updateShadowView()
    return
  end
  if love.mouse.getRelativeMode() then
    local camera = theScene.camera
    camera.rotation.y = camera.rotation.y - dx * mouseSensitivity
    camera.rotation.x = camera.rotation.x - dy * mouseSensitivity
    camera.rotation.x = min(max(camera.rotation.x, -pi/2), pi/2)
  end
end

function love.keypressed(k)
  if k == "escape" then
    love.event.quit()
  end
  if k == "`" then
    love.mouse.setRelativeMode(not love.mouse.getRelativeMode())
  end
end

function love.draw()
  theScene:draw()

  --UI stuff here
  --lg.draw(shadowMap, 0, shadowResolution, 0, 1, -1)
end

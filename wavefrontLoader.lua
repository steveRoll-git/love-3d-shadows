local function tableNum(t)
  for i, n in ipairs(t) do
    t[i] = tonumber(n)
  end
  return t
end

function split(s, sep)
  local result = {}
  for res in s:gmatch("[^"..sep.."]+") do table.insert(result, res) end
  return result
end

local function loadObj(data)
  local coords = {}
  local textureCoords = {}
  local normals = {}
  
  local vertices = {}
  local indices = {}
  
  for line in data:gmatch("[^\n]+") do
    if line:sub(1,1) ~= "#" then
      local firstSpace = line:find(" ")
      local command = line:sub(1, firstSpace - 1)
      local opString = line:sub(firstSpace+1, #line)
      local ops = split(opString, " ")
      
      if command == "v" then
        table.insert(coords, tableNum(ops))
      elseif command == "vt" then
        local texCoords = tableNum(ops)
        --idk why the y coordinate is flipped in the first place
        texCoords[2] = 1 - texCoords[2]
        table.insert(textureCoords, texCoords)
      elseif command == "vn" then
        table.insert(normals, tableNum(ops))
      elseif command == "f" then
        local last = #vertices + 1
        for _, vert in ipairs(ops) do
          local point = {}
          local indices = tableNum(split(vert, "/"))

          for _, vCoord in ipairs(coords[indices[1]]) do
            table.insert(point, vCoord)
          end
          for _, vNormal in ipairs(normals[indices[3]]) do
            table.insert(point, vNormal)
          end
          for _, vTexCoord in ipairs(textureCoords[indices[2]]) do
            table.insert(point, vTexCoord)
          end

          table.insert(vertices, point)
        end
        table.insert(indices, last + 2)
        table.insert(indices, last)
        table.insert(indices, last + 1)
        if #ops == 4 then
          table.insert(indices, last + 3)
          table.insert(indices, last)
          table.insert(indices, last + 2)
        end
      end
    end
  end
  
  return vertices, indices
end

return loadObj
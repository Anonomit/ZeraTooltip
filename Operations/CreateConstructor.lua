
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local tinsert   = table.insert
local tblRemove = table.remove
local tblSort   = table.sort
local tblConcat = table.concat


function Addon:CreateConstructor(tooltipData)
  local constructor = {numLines = tooltipData.numLines}
  
  local merge         = {}
  local moves         = {}
  local pads          = {}
  local recolorLefts  = {}
  local recolorRights = {}
  local rewordLefts   = {}
  local rewordRights  = {}
  local hideLefts     = {}
  local hideRights    = {}
  
  if self:GetOption("constructor", "doValidation") then
    constructor.validation = {}
    for _, line in ipairs(tooltipData) do
      constructor.validation[line.i] = line.realTextLeft
    end
  end
  
  local extraMoves = {}
  if tooltipData.extraLines then
    tblSort(tooltipData.extraLines, function(a, b) return a[2] > b[2] end)
    
    constructor.addLines = {}
    
    for i, line in ipairs(tooltipData.extraLines) do
      tinsert(constructor.addLines, line)
      extraMoves[line[2] + 1] = true
    end
  end
  
  -- hide left (also hides right)
  for i = #tooltipData, 1, -1 do
    local line = tooltipData[i]
    if line.hide then
      hideLefts[line.i] = true
      merge[line.i] = true
      tblRemove(tooltipData, i)
    end
  end
  
  assert(#tooltipData ~= 0, "A tooltip loaded incorrectly.")
  constructor.lastLine = tooltipData[#tooltipData].i
  
  for i = #tooltipData, 1, -1 do
    local line = tooltipData[i]
    
    -- move
    if i > 1 then
      if extraMoves[i] or line.pad or tooltipData[i-1].i ~= line.i - 1 then
        moves[line.i] = tooltipData[i-1].i
        merge[line.i] = true
        pads[line.i]  = line.pad
      end
    end
    
    -- recolor
    if line.recolorLeft or line.recolorRight then
      recolorLefts[line.i]  = line.recolorLeft
      recolorRights[line.i] = line.recolorRight
      merge[line.i] = true
    end
    
    -- reword
    if line.rewordLeft or line.rewordRight then
      rewordLefts[line.i]  = line.rewordLeft
      rewordRights[line.i] = line.rewordRight
      merge[line.i] = true
    end
    
    -- hide right
    if line.hideRight then
      hideRights[line.i] = line.hideRight
      merge[line.i] = true
    end
  end
  
  -- if the last line is being moved or padded, reanchor the line after it (should it exist)
  if tooltipData[#tooltipData].i ~= tooltipData.numLines or tooltipData.padLast then
    pads[tooltipData.numLines+1]  = tooltipData.padLast
    moves[tooltipData.numLines+1] = tooltipData[#tooltipData].i
    merge[tooltipData.numLines+1] = true
  end
  
  for i in pairs(merge) do
    local source       = i
    local dest         = moves[i]
    local pad          = pads[i]
    local hideLeft     = hideLefts[i]
    local hideRight    = hideRights[i]
    local recolorLeft  = recolorLefts[i]
    local recolorRight = recolorRights[i]
    local rewordLeft   = rewordLefts[i]
    local rewordRight  = rewordRights[i]
    if hideLeft then
      tinsert(constructor, {source, nil, hideLeft})
    elseif dest or recolorLeft or rewordLeft or hideRight or recolorRight or rewordRight then
      tinsert(constructor, {source, dest, nil, rewordLeft, rewordRight, pad, recolorLeft, recolorRight, hideRight})
    end
  end
  
  tblSort(constructor, function(a, b) return a[1] > b[1] end)
  
  if self:GetOption("debugOutput", "constructorCreated") then
    for i, line in ipairs(constructor) do
      local texts = {}
      for _, data in ipairs{
        {"instruction",  i},
        {"validation",   constructor.validation[line[1]]},
        {"source",       line[1]},
        {"dest",         line[2]},
        {"hideLeft",     line[3]},
        {"rewordLeft",   line[4]},
        {"rewordRight",  line[5]},
        {"pad",          line[6]},
        {"recolorLeft",  line[7]},
        {"recolorRight", line[8]},
        {"hideRight",    line[9]},
      } do
        if data[2] then
          if type(data[2]) == "string" then
            table.insert(texts, data[1] .. ": '" .. data[2] .. "'")
          else
            table.insert(texts, data[1] .. ": " .. tostring(data[2]))
          end
        end
      end
      self:Debug(tblConcat(texts, ", "))
    end
    for i, line in ipairs(constructor.addLines or {}) do
      local texts = {}
      for _, data in ipairs{
        {"addLine",        i},
        {"souble",         line[1]},
        {"textLeft",       line[2]},
        {"hexLeft",        line[3]},
        {"textRight/wrap", line[4]},
        {"hexRight",       line[5]},
      } do
        if data[2] then
          if type(data[2]) == "string" then
            table.insert(texts, data[1] .. ": '" .. data[2] .. "'")
          else
            table.insert(texts, data[1] .. ": " .. tostring(data[2]))
          end
        end
      end
      self:Debug(tblConcat(texts, ", "))
    end
  end
  
  return constructor
end


local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local tinsert   = table.insert
local tblRemove = table.remove
local tblSort   = table.sort
local tblConcat = table.concat



local function OutputConstructorCreation(constructor)
  if Addon:GetGlobalOption("debugOutput", "constructorCreated") then
    for i, line in ipairs(constructor) do
      Addon:DebugData{
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
        {"fakeout",      line[10]},
      }
    end
    for i, line in ipairs(constructor.addLines or {}) do
      Addon:DebugData{
        {"addLine",        i},
        {"dest",           line[1]},
        {"double",         line[2]},
        {"textLeft",       line[3]},
        {"hexLeft",        line[4]},
        {"textRight/wrap", line[5]},
        {"hexRight",       line[6]},
      }
    end
  end
end

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
  local fakeouts      = {}
  local extraMoves    = {}
  
  if tooltipData.extraLines then
    local slot = 1
    local lastDest
    
    constructor.addLines = {}
    for i = #tooltipData, 1, -1 do
      local line = tooltipData[i]
      if line.fake then
        local before
        for j = i, 1, -1 do
          before = tooltipData[j].i
          if before then
            break
          end
        end
        before = before or 0
        
        local after
        for j = i, #tooltipData do
          after = tooltipData[j].i
          if after then
            break
          end
        end
        
        if before == lastDest then
          slot = slot - 1
        end
        tinsert(constructor.addLines, slot, {before, line.pad, unpack(line, 1, 4)})
        extraMoves[after or (i+1)] = true
        tblRemove(tooltipData, i)
        slot     = slot + 1
        lastDest = before
      end
    end
  end
  
  if self:GetGlobalOption("constructor", "doValidation") then
    constructor.validation = {}
    for _, line in ipairs(tooltipData) do
      constructor.validation[line.i] = line.realTextLeft
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
  
  -- if the last line is being moved or padded, reanchor the line after it (should it exist and is not an extraLine)
  if tooltipData[#tooltipData].i ~= tooltipData.numLines or tooltipData.padLast then
    pads[tooltipData.numLines+1]     = tooltipData.padLast
    moves[tooltipData.numLines+1]    = tooltipData[#tooltipData].i
    fakeouts[tooltipData.numLines+1] = true
    merge[tooltipData.numLines+1]    = true
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
    local fakeout      = fakeouts[i]
    if hideLeft then
      tinsert(constructor, {source, nil, hideLeft})
    elseif dest or recolorLeft or rewordLeft or hideRight or recolorRight or rewordRight then
      tinsert(constructor, {source, dest, nil, rewordLeft, rewordRight, pad, recolorLeft, recolorRight, hideRight, fakeout})
    end
  end
  
  tblSort(constructor, function(a, b) return a[1] > b[1] end)
  
  OutputConstructorCreation(constructor)
  
  return constructor
end

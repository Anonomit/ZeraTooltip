
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local tinsert   = table.insert
local tblRemove = table.remove
local tblSort   = table.sort


function Addon:CreateConstructor(tooltipData)
  local merge         = {}
  local moves         = {}
  local pads          = {}
  local recolorLefts  = {}
  local recolorRights = {}
  local rewordLefts   = {}
  local rewordRights  = {}
  local hideLefts     = {}
  local hideRights    = {}
  
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
  local constructor = {
    numLines = tooltipData.numLines,
    lastLine = tooltipData[#tooltipData].i
  }
  
  for i = #tooltipData, 1, -1 do
    local line = tooltipData[i]
    
    -- move
    if i > 1 then
      if line.pad or tooltipData[i-1].i ~= line.i - 1 then
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
  
  return constructor
end


local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local tblConcat = table.concat


local function OutputLineRecognition(line)
  Addon:DebugData{
    {"fake",        line.fake},
    {"textLeft",    line[2]},
    
    {"line",        line.i},
    {"textLeft",    line.textLeftText},
    {"textRight",   line.textRightText},
    {"type",        line.type},
    {"stat",        line.stat},
    {"prefix",      line.prefix},
    {"bindType",    line.bindType},
    {"colorLeft",   line.colorLeft},
    {"colorRight",  line.colorRight},
    {"pad",         line.pad},
    {"used",        line.used},
    {"rewordLeft",  line.rewordLeft},
    {"rewordRight", line.rewordRight},
    {"hideRight",   line.hideRight},
    {"hide",        line.hide},
  }
end


function Addon:ModifyTooltipData(tooltip, tooltipData)
  if #tooltipData == 0 then return tooltipData end
  self:RecognizeLineTypes(tooltipData)
  local allResist = tooltipData.resists == 5 and not self:GetOption("hide", "All Resistance")
  
  for i, line in ipairs(tooltipData) do
    self:RecognizeStat(line, tooltipData, allResist)
    
    if self:GetOption("debugOutput", "initialTooltipData") then
      OutputLineRecognition(line)
    end
    
    if not self:HideLine(line, allResist) then
      self:RecolorLine(tooltip, line, tooltipData)
      self:RewordLine(tooltip, line, tooltipData)
    end
  end
  
  self:AddHeroicTag(tooltipData)
  self:AddItemLevel(tooltipData)
  self:AddStackSize(tooltipData)
  
  self:ReorderLines(tooltipData)
  
  self:CalculatePadding(tooltipData)
  
  if self:GetOption("debugOutput", "finalTooltipData") then
    for i, line in ipairs(tooltipData) do
      OutputLineRecognition(line)
    end
  end
end

do
  local function AddLine(tooltipData, i, ...)
    tooltipData.extraLines = true
    tinsert(tooltipData, i, {fake = true, ...})
    Addon:BumpLocationsRange(tooltipData, i)
  end
  
  function Addon:AddExtraLine(tooltipData, n, textLeft, hex, wordWrap)
    AddLine(tooltipData, n+1, false, textLeft, hex, wordWrap)
  end
  function Addon:AddExtraDoubleLine(tooltipData, n, textLeft, hexLeft, textRight, hexRight)
    AddLine(tooltipData, n+1, true, textLeft, hexLeft, textRight, hexRight)
  end
end

function Addon:BumpLocationsExact(tooltipData, amount, ...)
  if not amount then
    amount = 1
  end
  for _, k in ipairs{...} do
    local loc = tooltipData.locs[k]
    if loc then
      tooltipData.locs[k] = loc + amount
    end
  end
end

function Addon:BumpLocationsRange(tooltipData, min, max, amount)
  if not amount then
    amount = 1
  end
  for k, loc in pairs(tooltipData.locs) do
    if not min or min <= loc then
      if not max or max >= loc then
        tooltipData.locs[k] = loc + amount
      end
    end
  end
end

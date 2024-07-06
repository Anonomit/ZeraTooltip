
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local tblConcat = table.concat


local function OutputLineRecognition(line)
  Addon:DebugData{
    {"fake",        line.fake},
    {"textLeft",    line[2]},
    
    {"line",         line.i},
    {"textLeft",     line.textLeftText},
    {"textRight",    line.textRightText},
    {"type",         line.type},
    {"socketType",   line.socketType},
    {"stat",         line.stat},
    {"prefix",       line.prefix},
    {"bindType",     line.bindType},
    {"colorLeft",    line.colorLeft},
    {"colorRight",   line.colorRight},
    {"texture",      line.texture and line.texture[1]},
    {"pad",          line.pad},
    {"used",         line.used},
    {"rewordLeft",   line.rewordLeft},
    {"rewordRight",  line.rewordRight},
    {"recolorLeft",  line.recolorLeft},
    {"recolorRight", line.recolorRight},
    {"hideRight",    line.hideRight},
    {"hide",         line.hide},
  }
end


function Addon:ModifyTooltipData(tooltip, tooltipData)
  if #tooltipData == 0 then return tooltipData end
  self:RecognizeLineTypes(tooltipData)
  local allResist = tooltipData.resists == 5 and not self:GetOption("hide", "All Resistance")
  
  for i, line in ipairs(tooltipData) do
    self:RecognizeStat(line, tooltipData, allResist)
    
    if self:GetGlobalOption("debugOutput", "initialTooltipData") then
      OutputLineRecognition(line)
    end
    
    if not self:HideLine(line, allResist) then
      self:RecolorLine(tooltip, line, tooltipData)
      self:RewordLine(tooltip, line, tooltipData)
    end
  end
  
  self:AddHeroicTag(tooltipData)
  self:AddItemLevel(tooltipData)
  self:AddReputation(tooltipData)
  self:AddStackSize(tooltipData)
  
  self:ReorderLines(tooltipData)
  
  self:CalculatePadding(tooltipData)
  
  self:MarkTooltip(tooltipData)
  
  if self:GetGlobalOption("debugOutput", "finalTooltipData") then
    for i, line in ipairs(tooltipData) do
      OutputLineRecognition(line)
    end
  end
end

do
  local function AddLine(tooltipData, i, ...)
    tooltipData.extraLines = true
    tinsert(tooltipData, i+1, {fake = true, ...})
    Addon:BumpLocationsRange(tooltipData, i)
  end
  
  function Addon:AddExtraLine(tooltipData, n, textLeft, hex, wordWrap)
    AddLine(tooltipData, n, false, textLeft, hex, wordWrap)
  end
  function Addon:AddExtraDoubleLine(tooltipData, n, textLeft, hexLeft, textRight, hexRight)
    AddLine(tooltipData, n, true, textLeft, hexLeft, textRight, hexRight)
  end
end

function Addon:BumpLocationsExact(tooltipData, amount, ...)
  amount = amount or 1
  for _, k in ipairs{...} do
    for _, locType in ipairs{"locs", "embedLocs"} do
      local loc = tooltipData[locType][k]
      if loc then
        tooltipData[locType][k] = loc + amount
      end
    end
  end
end

function Addon:BumpLocationsRange(tooltipData, min, max, amount)
  amount = amount or 1
  for _, locType in ipairs{"locs", "embedLocs"} do
    local new = {}
    for k, loc in pairs(tooltipData[locType]) do
      new[k] = loc
      if not min or min <= loc then
        if not max or max >= loc then
          new[k] = loc + amount
        end
      end
    end
    tooltipData[locType] = new
  end
end

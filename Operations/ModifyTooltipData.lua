
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strLower = string.lower
local strMatch = string.match

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
  local allResist = tooltipData.resists == 5 and not self:GetOption("hide", "All Resistance") and self:GetOption("allow", "reword") and self:GetOption("doReword", "All Resistance")
  
  
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
  
  if self.isSoD or self.isTBC then
    -- split healing/damage into two lines
    if self:GetOption("allow", "reword") and self:GetOption("doReword", "Healing") and not self:GetOption("hide", "Spell Damage") then
      for i, line in ipairs(tooltipData) do
        if line.stat == "Healing" and (line.type == "SecondaryStat" or line.oldType == "SecondaryStat" or line.type == "BaseStat" or line.oldType == "BaseStat") then
          
          local value = strMatch(line.textLeftText, self.L["[%d,%.]+"] .. "%D+(%d+)") or strMatch(line.textLeftText, "(%d+)%D+" .. self.L["[%d,%.]+"])
          local value1, value2 = strMatch(line.textLeftText, format("(%s)%%D+(%s)", self.L["[%d,%.]+"], self.L["[%d,%.]+"]))
          value1 = tonumber(value1)
          value2 = tonumber(value2)
          local value
          if value1 and value2 then
            value = value1 <= value2 and value1 or value2
          end
          if value then
            
            local stat = "Spell Damage"
            local text = self.statsInfo[stat]:ConvertToNormalForm(format(self.L["Increases damage done by magical spells and effects by up to %s."], value or "0"))
            
            local extraLine = self:AddExtraLine(tooltipData, i)
            
            extraLine.stat                 = stat
            extraLine.normalForm           = text
            extraLine.textLeftText         = text
            extraLine.textLeftTextStripped = strLower(self:StripText(text))
            extraLine.realTextLeftText     = text
            extraLine.validationText       = text
            
            extraLine.type      = line.oldType or line.type
            extraLine.colorLeft = self.colors.GREEN
            extraLine.realColor = self.colors.GREEN
            
            if not self:HideLine(extraLine) then
              self:RecolorLine(tooltip, extraLine, tooltipData)
              self:RewordLine(tooltip, extraLine, tooltipData)
            end
            
            extraLine[2] = extraLine.rewordLeft  or extraLine[2]
            extraLine[3] = extraLine.recolorLeft or extraLine[3]
          end
          break
        end
      end
    end
  end
  
  
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
    local line = {fake = true, ...}
    tinsert(tooltipData, i+1, line)
    Addon:BumpLocationsRange(tooltipData, i)
    return line
  end
  
  function Addon:AddExtraLine(tooltipData, n, textLeft, hex, wordWrap)
    return AddLine(tooltipData, n, false, textLeft, hex, wordWrap)
  end
  function Addon:AddExtraDoubleLine(tooltipData, n, textLeft, hexLeft, textRight, hexRight)
    return AddLine(tooltipData, n, true, textLeft, hexLeft, textRight, hexRight)
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

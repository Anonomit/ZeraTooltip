
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match


local hiddenResists = Addon:MakeLookupTable{"Fire Resistance", "Nature Resistance", "Frost Resistance", "Shadow Resistance"}

local function HideLeft(line)
  line.oldType = line.type
  line.type    = "Padding"
  
  local pre  = Addon:GetDebugView"tooltipLineNumbers" and format("[%d] ", line.i) or ""
  local text = Addon:GetDebugView"paddingConversionSuccesses" and ("[Padding Success] " .. line.textLeftText) or " "
  line.rewordLeft = pre .. text
  
  return true
end

function Addon:HideLine(line, allResist)
  self:Switch(line.type, {
    Binding = function()
      if self:GetOption("hide", line.bindType) then
        return HideLeft(line)
      end
    end,
    Damage = function()
      if self:GetOption("hide", "Speed") then
        line.hideRight = true
      end
    end,
    DamagePerSecond = function()
      if self:GetOption("hide", "Speedbar") then
        line.hideRight = true
      end
    end,
    Block = function()
      -- Block is removed and does nothing in Cata, but the line still appears sometimes
      if self:GetOption("hide", line.type) or self.expansionLevel >= self.expansions.cata then
        return HideLeft(line)
      end
    end,
    RequiredRaces = function()
      if line.colorLeft ~= self.colors.WHITE then return end
      if self:GetOption("hide", "RequiredRaces_allowedLines") then
        return HideLeft(line)
      elseif self:GetOption("hide", "uselessRaces") and self:IsUselessRaceLine(line.textLeftText) then
        return HideLeft(line)
      end
    end,
    RequiredClasses = function()
      if line.colorLeft == self.colors.WHITE and self:GetOption("hide", "myClass") and line.textLeftText == self.myClassString then
        return HideLeft(line)
      end
    end,
    RequiredLevel = function()
      local level = tonumber(strMatch(line.textLeftText, self:ReversePattern(ITEM_MIN_LEVEL)))
      if level <= self.MY_LEVEL and self:GetOption("hide", "requiredLevelMet") or UnitLevel"player" == self.MAX_LEVEL and level == self.MAX_LEVEL and self:GetOption("hide", "requiredLevelMax") then
        return HideLeft(line)
      end
    end,
    ItemLevel = function()
      return HideLeft(line)
    end,
    MadeBy = function()
      if self:ShouldHideMadeBy(line.textLeftText) then
        return HideLeft(line)
      end
    end,
    GiftFrom = function()
      if self:ShouldHideGiftFrom(line.textLeftText) then
        return HideLeft(line)
      end
    end,
    WrittenBy = function()
      if self:ShouldHideWrittenBy(line.textLeftText) then
        return HideLeft(line)
      end
    end,
  }, function()
    if allResist and line.stat and hiddenResists[line.stat] then
      return HideLeft(line)
    elseif line.prefix and not line.stat then
      local stat = self.prefixStats[line.prefix]
      if stat and self:GetOption("hide", stat) then
        return HideLeft(line)
      end
    end
  end)
  if line.type and self:GetOption("hide", line.type) or (line.type == "BaseStat" or line.type == "SecondaryStat") and line.stat and self:GetOption("hide", line.stat) then
    return HideLeft(line)
  end
  
  return false
end

local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match


local function HideLeft(line)
  line.type       = "Padding"
  line.rewordLeft = " "
  return true
end

function Addon:HideLine(line)
  if line.type == "Binding" then
    if self:GetOption("hide", line.bindType) then
      return HideLeft(line)
    end
  elseif line.type == "Damage" then
    if self:GetOption("hide", "Speed") then
      line.hideRight = true
    end
  elseif line.type == "DamagePerSecond" then
    if self:GetOption("hide", "Speedbar") then
      line.hideRight = true
    end
  elseif line.type == "RequiredRaces" then
    if line.colorLeft == self.COLORS.WHITE and self:GetOption("hide", "uselessRaces") and self.uselessRaceStrings[line.textLeftText] then
      return HideLeft(line)
    end
  elseif line.type == "RequiredClasses" then
    if line.colorLeft == self.COLORS.WHITE and self:GetOption("hide", "myClass") and line.textLeftText == self.myClassString then
      return HideLeft(line)
    end
  elseif line.type == "RequiredLevel" then
    local level = tonumber(strMatch(line.textLeftText, self:ReversePattern(ITEM_MIN_LEVEL)))
    if level <= self.MY_LEVEL and self:GetOption("hide", "requiredLevelMet") or level == self.MAX_LEVEL and self:GetOption("hide", "requiredLevelMax") then
      return HideLeft(line)
    end
  elseif line.prefix and not line.stat then
    local stat = self.prefixStats[line.prefix]
    if stat and self:GetOption("hide", stat) then
      return HideLeft(line)
    end
  end
  if line.type and self:GetOption("hide", line.type) or line.stat and self:GetOption("hide", line.stat) then
    return HideLeft(line)
  end
  
  return false
end
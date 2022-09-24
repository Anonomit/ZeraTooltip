
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match


local function HideLeft(line)
  line.type       = "Padding"
  line.rewordLeft = " "
  return true
end

function Addon:HideLine(line)
  if line.type == "Damage" then
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
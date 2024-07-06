
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)



local strMatch = string.match
local strGsub  = string.gsub


local TOTAL_RACE_COUNT = #Addon.raceNames.all

local factionAlliancePattern = format("%s: %s", Addon.L["Faction"], Addon.L["Alliance"])
local factionHordePattern    = format("%s: %s", Addon.L["Faction"], Addon.L["Horde"])

local racesPattern = Addon:ReversePattern(Addon.L["Races: %s"])


local function CountRaces(text)
  return #({strsplit(",", text)})
end


local function GetFactionText(text)
  local races = strMatch(text, racesPattern)
  local races = {strsplit(",", races)}
  
  local isAlliance, isHorde
  for _, race in ipairs(races) do
    if Addon.raceNames.Alliance[race] then
      isAlliance = true
      if isHorde then break end
    elseif Addon.raceNames.Horde[race] then
      isHorde = true
      if isAlliance then break end
    end
  end
  if not (isHorde and isAlliance) then
    if isAlliance then
      return #races == #Addon.raceNames.Alliance and factionAlliancePattern or nil
    elseif isHorde then
      return #races == #Addon.raceNames.Horde and factionHordePattern or nil
    end
  end
  
  return nil
end


local stat = "RequiredRaces"
function Addon:ModifyRequiredRaces(text)
  if not self:GetOption("allow", "reword") or not self:GetOption("doReword", stat) then return text end
  
  text = GetFactionText(text) or text
  
  return text
end


function Addon:IsUselessRaceLine(text)
  return CountRaces(text) == TOTAL_RACE_COUNT
end

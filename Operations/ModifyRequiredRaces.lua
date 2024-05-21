
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local FACTION_ALLIANCE = format("%s: %s", FACTION--[[ or "Faction:"]], FACTION_ALLIANCE)
local FACTION_HORDE    = format("%s: %s", FACTION--[[ or "Faction:"]], FACTION_HORDE)


local stat = "RequiredRaces"
function Addon:ModifyRequiredRaces(text)
  if not self:GetOption("allow", "reword") or not self:GetOption("doReword", stat) then return text end
  
  if text == self.raceStrings.alliance then
    text = FACTION_ALLIANCE
  elseif text == self.raceStrings.horde then
    text = FACTION_HORDE
  end
  
  return text
end
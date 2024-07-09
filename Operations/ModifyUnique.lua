
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strMatch = string.match
local strGsub  = string.gsub


local patterns = {
  Unique                      = Addon:CoverSpecialCharacters(strMatch(Addon.L["Unique"],                   "^[^%(%%)]+")),
  UniqueLimit                 = Addon:CoverSpecialCharacters(strMatch(Addon.L["Unique (%d)"],              "^[^%(%%)]+")),
  UniqueCategoryLimit         = Addon:CoverSpecialCharacters(strMatch(Addon.L["Unique: %s (%d)"],          "^[^%(%%)]+")),
  UniqueEquipped              = Addon:CoverSpecialCharacters(strMatch(Addon.L["Unique-Equipped"],          "^[^%(%%)]+")),
  UniqueEquippedCategoryLimit = Addon:CoverSpecialCharacters(strMatch(Addon.L["Unique-Equipped: %s (%d)"], "^[^%(%%)]+")),
}


function Addon:RewordUnique(text, stat)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local pattern = patterns[stat]
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= pattern then
      text = strGsub(text, pattern, alias)
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end


function Addon:ShouldHideUnique(stat, uniqueLimit, redundantUniqueLimits)
  if self:GetOption("hide", stat) then
    return true
  elseif self:GetOption("hide", "Unique_uselessLines") then
    local limit = redundantUniqueLimits[stat]
    return limit and (limit:Get() == 0 or uniqueLimit <= limit:Get()) or false
  end
  return false
end


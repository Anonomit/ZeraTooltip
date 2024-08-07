
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strGsub  = string.gsub


local coveredPrefixes = Addon:Map(Addon.prefixStats, function(v, k) return Addon:CoverSpecialCharacters(k) end, function(v) return v end)
local emptyPrefixes   = Addon:Map(coveredPrefixes, function(v) return v .. " *" end)

local stat = "Equip"
function Addon:ModifyPrefix(text, prefix)
  if not self:GetOption("allow", "reword") then return text end
  local stat = self.prefixStats[prefix]
  if not stat then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias then -- empty alias is allowed
      if self:GetOption("trimSpace", stat) then
        text = strGsub(text, emptyPrefixes[stat], alias)
      elseif alias ~= coveredPrefixes[stat] then
        text = strGsub(text, coveredPrefixes[stat], alias)
      end
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end
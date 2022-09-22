
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub


local coveredPrefixes = Addon:Map(Addon.prefixStats, function(v, k) return Addon:CoverSpecialCharacters(k) end, function(v) return v end)
local emptyPrefixes   = Addon:Map(coveredPrefixes, function(v) return v .. " *" end)

local stat = "Equip"
local defaultText = ITEM_SPELL_TRIGGER_ONEQUIP
local coveredDefaultText = Addon:CoverSpecialCharacters(ITEM_SPELL_TRIGGER_ONEQUIP)
function Addon:ModifyPrefix(text, prefix)
  if not Addon:GetOption("allow", "reword") then return text end
  local stat = self.prefixStats[prefix]
  if not stat then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias then -- empty alias is allowed
      if self:GetOption("trimSpace", stat) then
        text = strGsub(text, emptyPrefixes[stat], alias)
      elseif alias ~= prefix then
        text = strGsub(text, coveredPrefixes[stat], alias)
      end
    end
  end
  
  if self:GetOption("doIcon", stat) then
    if self:GetOption("iconSpace", stat) then
      text = self:GetOption("icon", stat) .. " " .. text
    else
      text = self:GetOption("icon", stat) .. text
    end
  end
  
  return text
end
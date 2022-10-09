
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local strMatch = string.match
local strGsub  = string.gsub


local defaultPrefix = strMatch(ENCHANTED_TOOLTIP_LINE, "^[^:]+")
local coveredDefaultPrefix = Addon:CoverSpecialCharacters(defaultPrefix)

local function ModifyEnchant(text, stat)
  local self = Addon
  
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then -- whether to add a prefix
    local prefix = ENCHANTED_TOOLTIP_LINE
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= defaultPrefix then
      prefix = strGsub(prefix, coveredDefaultPrefix, alias)
    end
    text = format(prefix, text)
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end


function Addon:ModifyEnchantment(text)
  return ModifyEnchant(text, "Enchant")
end

function Addon:ModifyWeaponEnchantment(text)
  return ModifyEnchant(text, "WeaponEnchant")
end
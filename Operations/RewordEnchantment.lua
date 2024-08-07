
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)



local strMatch = string.match
local strGsub  = string.gsub


local enchantedPattern = Addon.L["Enchanted: %s"]
local defaultPrefix = strMatch(enchantedPattern, "^[^:]+")
local coveredDefaultPrefix = Addon:CoverSpecialCharacters(defaultPrefix)

local function ModifyEnchant(text, stat)
  local self = Addon
  
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then -- whether to add a prefix
    local prefix = enchantedPattern
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= coveredDefaultPrefix then
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

function Addon:ModifyOnUseEnchantment(text)
  return ModifyEnchant(text, "EnchantOnUse")
end

function Addon:ModifyWeaponEnchantment(text)
  return ModifyEnchant(text, "WeaponEnchant")
end

local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local strMatch = string.match
local strGsub  = string.gsub


local stat = "Enchant"
local defaultPrefix = strMatch(ENCHANTED_TOOLTIP_LINE, "^[^:]+")
local coveredDefaultPrefix = Addon:CoverSpecialCharacters(defaultPrefix)
function Addon:ModifyEnchantment(text)
  if not Addon:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then -- whether to add a prefix
    local prefix = ENCHANTED_TOOLTIP_LINE
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= defaultPrefix then
      prefix = strGsub(prefix, coveredDefaultPrefix, alias)
    end
    text = format(prefix, text)
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
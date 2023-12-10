
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local strMatch = string.match
local strGsub  = string.gsub



local defaultPrefix = EQUIPPED_RUNES or "Equipped Runes"
local coveredDefaultPrefix = Addon:CoverSpecialCharacters(defaultPrefix)
local prefixPattern = strGsub(ENCHANTED_TOOLTIP_LINE, "^[^:]+", coveredDefaultPrefix)

local stat = "Rune"
function Addon:ModifyRune(text)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then -- whether to add a prefix
    local prefix = prefixPattern
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= coveredDefaultPrefix then
      prefix = strGsub(prefix, coveredDefaultPrefix, alias)
    end
    text = format(prefix, text)
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end
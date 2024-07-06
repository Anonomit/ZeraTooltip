
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strGsub = string.gsub


local defaultText = Addon.L["Reforged"]
local coveredDefaultText = Addon:CoverSpecialCharacters(defaultText)

local stat = "Reforged"
function Addon:RewordReforged(text)
  if self:GetOption("allow", "reword") and self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= coveredDefaultText then
      text = strGsub(text, coveredDefaultText, alias)
    end
  end
  return text
end
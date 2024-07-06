
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strGsub = string.gsub


local stat = "Title"
function Addon:RewordTitle(text, icon)
  if not self:GetOption("allow", "reword") then return text end
  
  text = self:InsertIcon(text, stat, icon)
  
  return text
end
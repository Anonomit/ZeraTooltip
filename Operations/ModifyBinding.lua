
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


function Addon:RewordBinding(text, bindType)
  if not Addon:GetOption("allow", "reword") then return text end
  
  local stat = bindType
  
  text = self:InsertIcon(text, stat)
  
  return text
end
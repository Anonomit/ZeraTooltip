
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


function Addon:RewordBinding(text, bindType)
  if not Addon:GetOption("allow", "reword") then return text end
  
  local stat = bindType
  
  if self:GetOption("doIcon", stat) then
    if self:GetOption("iconSpace", stat) then
      text = self:GetOption("icon", stat) .. " " .. text
    else
      text = self:GetOption("icon", stat) .. text
    end
  end
  
  return text
end
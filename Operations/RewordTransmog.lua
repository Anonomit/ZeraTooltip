
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strGsub  = string.gsub


local defaultText = Addon.L["Transmogrified to:"]
local coveredText = Addon:ReversePattern(Addon.L["Transmogrified to:"])

local stat = "TransmogHeader"
function Addon:RewordTransmogHeader(text)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= coveredText then -- empty alias is allowed
      text = strGsub("1", "1", alias)
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end


local stat = "Transmog"
function Addon:RewordTransmog(text)
  if not self:GetOption("allow", "reword") then return text end
  
  text = self:InsertIcon(text, stat)
  
  return text
end


local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match



local stat = "SoulboundTradeable"
function Addon:RewordTradeable(text)
  local self = Addon
  
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local time = strMatch(text, self:ReversePattern(BIND_TRADE_TIME_REMAINING))
    if time then
      text = format("%s: %s", self.L["Trade"], time)
    end
  end
  
  return text
end
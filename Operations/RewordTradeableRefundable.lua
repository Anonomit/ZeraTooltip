
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strMatch = string.match


local stat = "Refundable"
function Addon:RewordRefundable(text)
  local self = Addon
  
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local time = strMatch(text, self:ReversePattern(REFUND_TIME_REMAINING))
    if time then
      text = format("%s: %s", L["Refund"], time)
    end
  end
  
  return text
end

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
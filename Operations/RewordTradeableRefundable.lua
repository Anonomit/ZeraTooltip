
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strMatch = string.match

local refundPattern = Addon:ReversePattern(Addon.L["You may sell this item to a vendor within %s for a full refund."])
local tradePattern  = Addon:ReversePattern(Addon.L["You may trade this item with players that were also eligible to loot this item for the next %s."])


local stat = "Refundable"
function Addon:RewordRefundable(text)
  local self = Addon
  
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local time = strMatch(text, refundPattern)
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
    local time = strMatch(text, tradePattern)
    if time then
      text = format("%s: %s", self.L["Trade"], time)
    end
  end
  
  return text
end
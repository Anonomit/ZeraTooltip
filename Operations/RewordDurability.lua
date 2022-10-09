
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch = string.match
local strGsub  = string.gsub
local strRep   = string.rep



local durabilityText = strMatch(DURABILITY_TEMPLATE, "(.-) *%%")
local coveredText    = Addon:CoverSpecialCharacters(durabilityText)
local emptyText      = durabilityText .. " *"

local stat = "Durability"
local function RewordDurabilityNumbers(text)
  local self = Addon
  
  if not self:GetOption("durability", "showPercent") then return text end -- no changes to make
  
  local curMax, cur, max = strMatch(text, "((%d+) ?%/ ?(%d+))")
  if cur and max then
    cur, max = tonumber(cur), tonumber(max)
    local percent = self:Round((cur/max)*100, 1)
    
    return strGsub(text, "%d+ ?%/ ?%d+", self:GetOption("durability", "showCur") and format("%s (%s%%%%)", curMax, percent) or format("%s%%%%", percent))
  end
  return text
end


function Addon:ModifyDurability(text)
  if not self:GetOption("allow", "reword") then return text end
  
  text = RewordDurabilityNumbers(text)
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias then -- empty alias is allowed
      if self:GetOption("trimSpace", stat) then
        text = strGsub(text, emptyText, alias)
      elseif alias ~= prefix then
        text = strGsub(text, coveredText, alias)
      end
    end
  end
  
  text = self:InsertIcon(text, stat)
  
  return text
end
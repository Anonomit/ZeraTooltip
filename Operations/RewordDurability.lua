
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
  
  local showMax     = self:GetOption("allow", "reword") and self:GetOption("durability", "showMax")
  local showPercent = self:GetOption("allow", "reword") and self:GetOption("durability", "showPercent")
  if showMax and not showPercent then return text end -- no changes to make
  local showCur = self:GetOption("allow", "reword") and self:GetOption("durability", "showCur")
  
  local curMax, cur, max = strMatch(text, "((%d+) ?%/ ?(%d+))")
  if cur then
    cur, max = tonumber(cur), tonumber(max)
    local percent = showPercent and self:Round((cur/max)*100, 1) or nil
    
    local pattern
    if showMax then
      pattern = format("%s / %s", cur, max)
    elseif showCur then
      pattern = tostring(cur)
    end
    if percent then
      if pattern then
        pattern = format("%s (%s%%%%)", pattern, percent)
      else
        pattern = format("%s%%%%", percent)
      end
    end
    
    return strGsub(text, "%d+ ?%/ ?%d+", pattern)
  end
  return text
end


function Addon:ModifyDurability(text)
  if not Addon:GetOption("allow", "reword") then return text end
  
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
  
  if self:GetOption("doIcon", stat) then
    if self:GetOption("iconSpace", stat) then
      text = self:GetOption("icon", stat) .. " " .. text
    else
      text = self:GetOption("icon", stat) .. text
    end
  end
  
  return text
end
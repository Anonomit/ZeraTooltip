
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub
local strMatch = string.match
local tinsert  = table.insert




local stat = "ItemLevel"

local iLvlText    = strMatch(GARRISON_FOLLOWER_ITEM_LEVEL, "(.-) *%%")
local coveredText = Addon:CoverSpecialCharacters(iLvlText)
local emptyText   = iLvlText .. " *"



function Addon:RewordItemLevel(text)
  if not self:GetOption("allow", "reword") then return text end
  
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


function Addon:AddItemLevel(tooltipData)
  if self:GetOption("hide", stat) then return end
  local equipLoc = select(4, GetItemInfoInstant(tooltipData.id))
  if equipLoc ~= "" then
    local itemLevel = select(4, GetItemInfo(tooltipData.id))
    local color = self:GetDefaultOption("color", stat)
    if self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) then
      color = self:GetOption("color", stat)
    end
    self:AddExtraLine(tooltipData, 1, self:RewordItemLevel(format(GARRISON_FOLLOWER_ITEM_LEVEL, itemLevel)), color)
  end
end


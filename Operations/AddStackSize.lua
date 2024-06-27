
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub  = string.gsub


local invTypeWhitelist = Addon:MakeLookupTable{""}


local stat = "StackSize"

local stackSizeText = Addon.L["Stack Size"]
local coveredText   = Addon:CoverSpecialCharacters(stackSizeText)

function Addon:RewordStackSize(text)
  if not self:GetOption("allow", "reword") then return text end
  
  if self:GetOption("doReword", stat) then
    local alias = self:GetOption("reword", stat)
    if alias and alias ~= "" and alias ~= coveredText then
      text = strGsub(text, coveredText, alias)
    end
  end
  
  return text
end


function Addon:AddStackSize(tooltipData)
  if self:GetOption("hide", stat) then return end
  
  local stackSize = select(8, GetItemInfo(tooltipData.id))
  if not stackSize then return end
  
  if self:GetOption("hide", "StackSize_single") and stackSize == 1 then return end
  
  if self:GetOption("hide", "StackSize_equipment") and stackSize == 1 then
    local equipLoc = select(4, GetItemInfoInstant(tooltipData.id))
    if not invTypeWhitelist[equipLoc] then
      return
    end
  end
  
  local color = self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and self:GetOption("color", stat) or self:GetDefaultOption("color", stat)
  
  self:AddExtraLine(tooltipData, self:GetOption("doReorder", stat) and tooltipData.locs.quality or #tooltipData, self:RewordStackSize(format(coveredText .. ": %d", stackSize)), color)
end


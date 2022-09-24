
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



function Addon:ModifyTooltipData(tooltip, tooltipData)
  if #tooltipData == 0 then return tooltipData end
  self:RecognizeLineTypes(tooltipData)
  
  for i, line in ipairs(tooltipData) do
    self:RecognizeStat(line)
    
    if not self:HideLine(line) then
      self:RecolorLine(tooltip, line, tooltipData)
      self:RewordLine(tooltip, line, tooltipData)
    end
    
    if self:GetOption("debug", "output", "lineRecognitions") then
      self:Debug(i, line.textLeftText, "type:", line.type, "stat:", line.stat, "prefix:", line.prefix)
    end
  end
  
  self:SortStats(tooltipData)
  
  self:CalculatePadding(tooltipData)
end

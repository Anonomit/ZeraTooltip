
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local tblConcat = table.concat


local function OutputLineRecognition(line)
  local self = Addon
  
  local texts = {}
  for _, data in ipairs{
    {"line",       line.i},
    {"textLeft",   line.textLeftText},
    {"textRight",  line.textRightText},
    {"type",       line.type},
    {"stat",       line.stat},
    {"prefix",     line.prefix},
    {"bindType",   line.bindType},
    {"colorLeft",  line.colorLeft},
    {"colorRight", line.colorRight},
  } do
    if data[2] then
      if type(data[2]) == "string" then
        table.insert(texts, data[1] .. ": '" .. data[2] .. "'")
      else
        table.insert(texts, data[1] .. ": " .. data[2])
      end
    end
  end
  self:Debug(tblConcat(texts, ", "))
end


function Addon:ModifyTooltipData(tooltip, tooltipData)
  if #tooltipData == 0 then return tooltipData end
  self:RecognizeLineTypes(tooltipData)
  
  for i, line in ipairs(tooltipData) do
    self:RecognizeStat(line)
    
    if self:GetOption("debugOutput", "lineRecognitions") then
      OutputLineRecognition(line)
    end
    
    if not self:HideLine(line) then
      self:RecolorLine(tooltip, line, tooltipData)
      self:RewordLine(tooltip, line, tooltipData)
    end
  end
  
  self:ReorderLines(tooltipData)
  
  self:CalculatePadding(tooltipData)
  
  self:AddHeroicTag(tooltipData)
  self:AddItemLevel(tooltipData)
end


function Addon:AddExtraLine(tooltipData, n, textLeft, hex, wordWrap)
  if not tooltipData.extraLines then
    tooltipData.extraLines = {}
  end
  tinsert(tooltipData.extraLines, {false, n, textLeft, hex, wordWrap})
end
function Addon:AddExtraDoubleLine(tooltipData, n, textLeft, hexLeft, textRight, hexRight)
  if not tooltipData.extraLines then
    tooltipData.extraLines = {}
  end
  tinsert(tooltipData.extraLines, {true, n, textLeft, hexLeft, textRight, hexRight})
end

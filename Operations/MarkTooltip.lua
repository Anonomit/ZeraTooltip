
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local strFind = string.find




local mark        = "|r|r|r"
local markPattern = mark .. "$"


local function AddMark(text)
  return text .. mark
end
local function IsMarked(text)
  return strFind(text, markPattern)
end


function Addon:MarkTooltip(tooltipData)
  local line = tooltipData[1]
  self:Assert(line and line.textLeftText)
  line.rewordLeft = AddMark(line.rewordLeft or line.textLeftText)
end



function Addon:IsTooltipMarked(tooltip)
  self:Assert(tooltip and tooltip.GetName)
  local line = _G[tooltip:GetName() .. "TextLeft1"]
  self:Assert(line and line.GetText)
  return IsMarked(line:GetText())
end


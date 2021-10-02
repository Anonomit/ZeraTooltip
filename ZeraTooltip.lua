

local ADDON_NAME, Shared = ...

ZeraTooltip = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME)
local L     = LibStub("AceLocale-3.0"):GetLocale("ZeraTooltip")



local DEBUG = false


-- Curseforge automatic packaging will comment this out
-- https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging
--@debug@
DEBUG = true
--@end-debug@



function Shared.Round(num, decimalPlaces)
  local mult = 10^(decimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end



function ZeraTooltip:TrimText(text)
  return text:gsub(L["TrimEquip"], "")
end

function ZeraTooltip:SimplifyText(text)
  for i, label in ipairs(L.LABEL) do
    local input, output = L.INPUT[i], L.OUTPUT[i]
    local matches = {text:match(input)}
    if #matches > 0 then
      local pattern = type(output) == "function" and output(unpack(matches)) or output:format(unpack(matches))
      return self:TrimText(text:gsub(input, pattern)) .. (DEBUG and ("  [%s]"):format(label) or "")
    end
  end
end



function ZeraTooltip:CreateHooks()
  
  local function OnTooltipSetHyperlink(tooltip)
    local name, link = tooltip:GetItem()
    if not link then return end
    
    local leftText = tooltip:GetName().."TextLeft"
    for i = 2, tooltip:NumLines() do
      local fontString = _G[leftText..i]
      local text = fontString:GetText()
      if text then
        if strfind(text, "%d") then
          lineColor = select(3, strfind(text, "|c%x%x%x%x%x%x%x%x")) or "|r"
          text = self:SimplifyText(text)
          if text then
            fontString:SetText(lineColor .. text)
          end
        end
      end
    end
  end
  GameTooltip             : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ItemRefTooltip          : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ItemRefShoppingTooltip1 : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ItemRefShoppingTooltip2 : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ShoppingTooltip1        : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ShoppingTooltip2        : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
end



function ZeraTooltip:OnInitialize()
  
end

function ZeraTooltip:OnEnable()
  self:CreateHooks()
end

function ZeraTooltip:OnDisable()
  
end

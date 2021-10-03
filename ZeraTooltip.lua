

local ADDON_NAME, Shared = ...

ZeraTooltip = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME)
local L     = LibStub("AceLocale-3.0"):GetLocale("ZeraTooltip")


local DEBUG             = false
local SHOW_LABELS       = false
local SHIFT_SUPPRESSION = false


-- Curseforge automatic packaging will comment this out
-- https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging
--@debug@
DEBUG             = true
SHOW_LABELS       = false
SHIFT_SUPPRESSION = true
--@end-debug@



function Shared.Round(num, decimalPlaces)
  local mult = 10^(decimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


function ZeraTooltip:IsSameColor(color1, color2)
  for k, v in pairs(color1) do
    if color2[k] ~= v then
      return false
    end
  end
  return true
end



function ZeraTooltip:TrimLine(text)
  return text:gsub(L["TrimEquip"], "")
end

function ZeraTooltip:SimplifyLine(text)
  for i, label in ipairs(L.LABEL) do
    local input, output = L.INPUT[i], L.OUTPUT[i]
    local matches = {text:match(input)}
    if #matches > 0 then
      local pattern = type(output) == "function" and output(unpack(matches)) or output:format(unpack(matches))
      return self:TrimLine(text:gsub(input, pattern)) .. (SHOW_LABELS and ("  [%s]"):format(label) or "")
    end
  end
end


function ZeraTooltip:SimplifyLines(tooltip)
  if SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  local leftText = tooltip:GetName().."TextLeft"
  for i = 2, tooltip:NumLines() do
    local fontString = _G[leftText..i]
    local text = fontString:GetText()
    if text then
      if text:find"%d" then
        text = self:SimplifyLine(text)
        if text then
          fontString:SetText(text)
        end
      end
    end
  end
end


function ZeraTooltip:ReorderLines(tooltip)
  if SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  local leftText = tooltip:GetName() .. "TextLeft"
  
  local groups = { }
  for i = 2, tooltip:NumLines() do
    local fontString = _G[leftText .. i]
    local text = fontString:GetText()
    if text then
      local r, g, b, a = fontString:GetTextColor()
      local color = {r=r, g=g, b=b, a=a}
      
      for j, pattern in ipairs(L.ORDER) do
        if text:match(pattern) then
          if #groups == 0 or not ZeraTooltip:IsSameColor(groups[#groups].color, color) or groups[#groups].line + #groups[#groups] ~= i then
            table.insert(groups, {color = color, line = i})
          end
          table.insert(groups[#groups], {order = j, text = text})
          break
        end
      end
    end
  end
  
  for _, group in ipairs(groups) do
    if #group > 1 then
      table.sort(group, function(a, b) if a.order == b.order then return a.text < b.text end return a.order < b.order end)
      for i, line in ipairs(group) do
        local fontString = _G[leftText .. (group.line + i - 1)]
        fontString:SetText(line.text)
      end
    end
  end
end



local function OnTooltipSetHyperlink(tooltip)
  local name, link = tooltip:GetItem()
  if not link then return end
  
  ZeraTooltip:SimplifyLines(tooltip)
  ZeraTooltip:ReorderLines(tooltip)
end



function ZeraTooltip:CreateHooks()
  
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

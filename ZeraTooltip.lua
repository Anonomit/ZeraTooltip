

local ADDON_NAME, Shared = ...

ZeraTooltip = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME)
local L     = LibStub("AceLocale-3.0"):GetLocale("ZeraTooltip")

local AceConfig       = LibStub"AceConfig-3.0"
local AceConfigDialog = LibStub"AceConfigDialog-3.0"


ZeraTooltip.ENABLED           = true

ZeraTooltip.DEBUG             = false
ZeraTooltip.SHOW_LABELS       = false
ZeraTooltip.SHIFT_SUPPRESSION = false

ZeraTooltip.GRAY = {0.5, 0.5, 0.5, 1}


-- Curseforge automatic packaging will comment this out
-- https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging
--@debug@
ZeraTooltip.ENABLED           = true

ZeraTooltip.DEBUG             = true
ZeraTooltip.SHOW_LABELS       = false
ZeraTooltip.SHIFT_SUPPRESSION = false
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

function ZeraTooltip:IsSameColorFuzzy(color1, color2, fuzziness)
  fuzziness = fuzziness or 0.05
  for k, v in pairs(color1) do
    if math.abs(color2[k] - v) > fuzziness then
      return false
    end
  end
  return true
end



function ZeraTooltip:TrimLine(text)
  return text:gsub(L["Equip"], "")
end

function ZeraTooltip:SimplifyLine(text)
  for i, data in ipairs(L) do
    for j, map in ipairs(data.MAP or {}) do
      local input, output = map.INPUT, map.OUTPUT
      local matches = {text:match(input)}
      if #matches > 0 then
        local pattern = type(output) == "function" and output(unpack(matches)) or output:format(unpack(matches))
        return self:TrimLine(text:gsub(input, pattern)) .. (ZeraTooltip.SHOW_LABELS and ("  [%s]"):format(data.LABEL) or "")
      end
    end
  end
end


function ZeraTooltip:SimplifyLines(tooltip)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
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


function ZeraTooltip:ReorderLines(tooltip, simplified)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  local leftText = tooltip:GetName() .. "TextLeft"
  
  local groups = { }
  for i = 2, tooltip:NumLines() do
    local fontString = _G[leftText .. i]
    local text = fontString:GetText()
    if text then
      local r, g, b, a = fontString:GetTextColor()
      local color = {r=r, g=g, b=b, a=a}
      
      for j, data in ipairs(L) do
        local captures = {}
        for i, capture in ipairs(data.CAPTURES or {}) do
          table.insert(captures, "^" .. capture)
        end
        if not simplified then
          for i, map in ipairs(data.MAP or {}) do
            table.insert(captures, map.INPUT)
          end
        end
        for k, pattern in ipairs(captures) do
          if text:match(pattern) then
            if #groups == 0 or not self:IsSameColor(groups[#groups].color, color) or groups[#groups].line + #groups[#groups] ~= i then
              table.insert(groups, {color = color, line = i})
            end
            table.insert(groups[#groups], {order = j, text = text})
            break
          end
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


function ZeraTooltip:RecolorLines(tooltip, simplified)
  if not ZeraTooltip.ENABLED or ZeraTooltip.SHIFT_SUPPRESSION and IsShiftKeyDown() then return end
  local leftText = tooltip:GetName() .. "TextLeft"
  
  for i = 2, tooltip:NumLines() do
    local fontString = _G[leftText .. i]
    local text = fontString:GetText()
    if text then
      local r, g, b, a = fontString:GetTextColor()
      local color = {r, g, b}
      
      for j, data in ipairs(L) do
        local captures = {}
        for i, capture in ipairs(data.CAPTURES or {}) do
          table.insert(captures, capture)
        end
        if not simplified then
          for i, map in ipairs(data.MAP or {}) do
            table.insert(captures, map.INPUT)
          end
        end
        for k, pattern in ipairs(captures) do
          if text:match(pattern) and (not text:find(L["ConjunctiveWord"]) or pattern:find(L["ConjunctiveWord"])) then
            if data.COLOR then
              if not self:IsSameColorFuzzy(color, ZeraTooltip.GRAY) and not text:match(L["SocketBonus"]) then
                fontString:SetTextColor(data.COLOR[1]/255, data.COLOR[2]/255, data.COLOR[3]/255, 1)
              end
            end
            break
          end
        end
      end
    end
  end
end



local function OnTooltipSetHyperlink(tooltip)
  local name, link = tooltip:GetItem()
  if not link then return end
  
  if ZeraTooltipData.OPTIONS.SIMPLIFY then
    ZeraTooltip:SimplifyLines(tooltip)
  end
  if ZeraTooltipData.OPTIONS.REORDER then
    ZeraTooltip:ReorderLines(tooltip, ZeraTooltipData.OPTIONS.SIMPLIFY)
  end
  if ZeraTooltipData.OPTIONS.RECOLOR then
    ZeraTooltip:RecolorLines(tooltip, ZeraTooltipData.OPTIONS.SIMPLIFY)
  end
end



function ZeraTooltip:CreateHooks()
  
  GameTooltip             : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ItemRefTooltip          : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ItemRefShoppingTooltip1 : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ItemRefShoppingTooltip2 : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ShoppingTooltip1        : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
  ShoppingTooltip2        : HookScript("OnTooltipSetItem", OnTooltipSetHyperlink)
end






function ZeraTooltip:CreateOptions()
  local addonOptions = {
    type = "group",
    args = {
      simplify = {
        name = "Simplify stats",
        desc = "",
        type = "toggle",
        set = function(info, val)        ZeraTooltipData.OPTIONS.SIMPLIFY = val end,
        get = function(info)      return ZeraTooltipData.OPTIONS.SIMPLIFY       end,
      },
      reorder = {
        name = "Reorder stats",
        desc = "",
        type = "toggle",
        set = function(info, val)        ZeraTooltipData.OPTIONS.REORDER = val end,
        get = function(info)      return ZeraTooltipData.OPTIONS.REORDER       end,
      },
      recolor = {
        name = "Recolor stats",
        desc = "",
        type = "toggle",
        set = function(info, val)        ZeraTooltipData.OPTIONS.RECOLOR = val end,
        get = function(info)      return ZeraTooltipData.OPTIONS.RECOLOR       end,
      },
    }
  }
  
  AceConfig:RegisterOptionsTable("ZeraTooltip", addonOptions)
  AceConfigDialog:AddToBlizOptions("ZeraTooltip")
end








function ZeraTooltip:OnInitialize()
  if not ZeraTooltipData then
    ZeraTooltipData = {}
    if not ZeraTooltipData.OPTIONS then
      ZeraTooltipData.OPTIONS = {}
      
      ZeraTooltipData.OPTIONS.SIMPLIFY = true
      ZeraTooltipData.OPTIONS.REORDER  = true
      ZeraTooltipData.OPTIONS.RECOLOR  = true
    end
  end
end

function ZeraTooltip:OnEnable()
  self:CreateOptions()
  self:CreateHooks()
end

function ZeraTooltip:OnDisable()
  
end

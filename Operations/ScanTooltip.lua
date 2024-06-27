
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local strLower = string.lower
local strMatch = string.match
local strFind  = string.find
local strGSub  = string.gsub

local mathMin  = math.min



local weaponInvTypes = Addon:MakeLookupTable{
  "INVTYPE_WEAPON",
  "INVTYPE_2HWEAPON",
  "INVTYPE_WEAPONMAINHAND",
  "INVTYPE_WEAPONOFFHAND",
}
local engravableInvTypes = Addon:MakeLookupTable{
  "INVTYPE_CHEST",
  "INVTYPE_ROBE",
  "INVTYPE_LEGS",
  "INVTYPE_HAND",
  "INVTYPE_WRIST",
  "INVTYPE_CLOAK",
  "INVTYPE_FEET",
  "INVTYPE_HEAD",
  "INVTYPE_SHOULDER",
  "INVTYPE_WAIST",
}


function Addon:PrepareTooltip(tooltip, link, methodName, ...)
  local args = {n = select("#", ...), ...}
  return pcall(function()
    tooltip.currentItem = nil
    tooltip:Hide()
    local tooltipName = tooltip.tooltip:GetName()
    local opt = "tooltip_" .. tooltipName
    if self:GetGlobalOption("debugView", opt) then
      tooltip:SetOwner(WorldFrame, "ANCHOR_TOP")
    else
      tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    end
    if methodName == "SetCompareItem" and strFind(opt, "1$") then
      local tooltipName = strGSub(tooltip:GetName(), "1$", "2")
      local tooltip = _G[tooltipName]
      local opt = strGSub(opt, "%d$", "2")
      if tooltip then
        if self:GetGlobalOption("debugView", opt) then
          tooltip:SetOwner(WorldFrame, "ANCHOR_TOPLEFT")
        end
        self:DebugfIfOutput(opt, "Refreshing scanner tooltip: %s", tooltip.tooltip:GetName())
      end
    end
    if methodName then
      tooltip[methodName](tooltip, unpack(args, 1, args.n))
      self:DebugfIfOutput(opt, "Refreshing scanner tooltip: %s", tooltipName)
    end
  end)
end


function Addon:ReadTooltip(tooltip, name, link, maxLines)
  local tooltipName = tooltip:GetName()
  local numLines    = maxLines and mathMin(tooltip:NumLines(), maxLines) or tooltip:NumLines()
  
  
  local textLeftName   = tooltipName .. "TextLeft"
  local textRightName  = tooltipName .. "TextRight"
  local textureName    = tooltipName .. "Texture"
  local moneyFrameName = tooltipName .. "MoneyFrame"
  
  local textureMap = {}
  local moneyMap   = {}
  
  -- Get textures
  for i = 1, 10 do
    local texture = _G[textureName .. i]
    if texture and texture:IsShown() then
      local _, parent = texture:GetPoint()
      if parent then
        textureMap[parent] = {texture:GetTexture(), i}
      end
    end
  end
  -- Get money
  if tooltip.hasMoney then
    for i = 1, tooltip.shownMoneyFrames or 0 do
      local moneyFrame = _G[moneyFrameName .. i]
      if moneyFrame and moneyFrame:IsShown() then
        local _, parent = moneyFrame:GetPoint()
        if parent then
          moneyMap[parent] = {i, moneyFrame}
        end
      end
    end
  end
  
  local tooltipData = {}
  for i = 1, numLines do
    local textLeft  = _G[textLeftName  .. i]
    local textRight = _G[textRightName .. i]
    
    local textLeftText  = textLeft:GetText() or " "
    local textRightText = textRight and textRight:IsShown() and textRight:GetText() or nil
    
    local hex, text = strMatch(textLeftText, "^|c%x%x(%x%x%x%x%x%x)(.*)|r$")
    textLeftText = text or textLeftText
    
    local realTextLeft = _G[tooltip.tooltip:GetName().."TextLeft"..i]
    if not realTextLeft then break end
    
    tooltipData[i] = {
      i                     = i,
      textLeftText          = textLeftText,
      textLeftTextStripped  = strLower(self:StripText(textLeftText)),
      textRightText         = textRightText,
      colorLeft             = hex or self:GetTextColorAsHex(textLeft),
      colorRight            = textRightText and self:GetTextColorAsHex(textRight) or nil,
      texture               = textureMap[textLeft],
      moneyFrame            = moneyMap[textLeft],
      realTextLeft          = realTextLeft:GetText() or " ",
      realColor             = self:GetTextColorAsHex(realTextLeft),
    }
  end
  tooltipData.numLines     = #tooltipData
  tooltipData.realNumLines = tooltip.tooltip:NumLines()
  
  -- tooltipData.name = name
  -- tooltipData.link = link
  tooltipData.id = tonumber(strMatch(link, "item:(%d+):"))
  if strFind(link, "item:%d+:%d+") then
    tooltipData.hasEnchant = true
  end
  local _, _, _, itemEquipLoc, icon = GetItemInfoInstant(tooltipData.id)
  tooltipData.isWeapon     = weaponInvTypes[itemEquipLoc]
  tooltipData.isGem = select(6, GetItemInfoInstant(tooltipData.id)) == Enum.ItemClass.Gem
  tooltipData.isEngravable = Addon.isSoD and engravableInvTypes[itemEquipLoc] or nil
  tooltipData.icon         = icon
  
  tooltipData.resists = 0
  tooltipData.lastUse = "SecondaryStat"
  
  tooltipData.locs = {}
  
  return tooltipData
end


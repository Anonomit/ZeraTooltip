
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

local strMatch = string.match
local strFind  = string.find
local mathMin  = math.min



local weaponInvTypes = {
  INVTYPE_WEAPON         = true,
  INVTYPE_2HWEAPON       = true,
  INVTYPE_WEAPONMAINHAND = true,
  INVTYPE_WEAPONOFFHAND  = true,
}


function Addon:PrepareTooltip(tooltip, methodName, ...)
  local args = {n = select("#", ...), ...}
  return pcall(function()
    tooltip:Hide()
    local tooltipName = tooltip.tooltip:GetName()
    local opt = "tooltip_" .. tooltipName
    if self:GetOption("debugView", opt) then
      tooltip:SetOwner(UIParent, "ANCHOR_TOP")
    else
      tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    end
    if methodName then
      tooltip[methodName](tooltip, unpack(args, 1, args.n))
      self:DebugfIf({"debugOutput", opt}, "Refreshing scanner tooltip: %s", tooltipName)
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
        textureMap[parent] = {i, texture}
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
      textLeftTextStripped  = self:StripText(textLeftText),
      textRightText         = textRightText,
      colorLeft             = hex or self:GetTextColorAsHex(textLeft),
      colorRight            = textRightText and self:GetTextColorAsHex(textRight) or nil,
      texture               = textureMap[textLeft],
      moneyFrame            = moneyMap[textLeft],
      realTextLeft          = realTextLeft:GetText() or " ",
      realColor             = self:GetTextColorAsHex(realTextLeft),
    }
  end
  tooltipData.numLines = #tooltipData
  
  -- tooltipData.name = name
  -- tooltipData.link = link
  tooltipData.id = tonumber(strMatch(link, "item:(%d+):"))
  if strFind(link, "item:%d+:%d+") then
    tooltipData.hasEnchant = true
  end
  local _, _, _, itemEquipLoc, icon = GetItemInfoInstant(tooltipData.id)
  tooltipData.isWeapon = weaponInvTypes[itemEquipLoc]
  tooltipData.icon     = icon
  
  tooltipData.resists = 0
  tooltipData.lastUse = "SecondaryStat"
  
  tooltipData.locs = {}
  
  return tooltipData
end


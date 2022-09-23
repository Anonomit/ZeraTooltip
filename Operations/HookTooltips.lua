
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strGsub = string.gsub
local tinsert = table.insert


local tooltipScanners = {}

local function ScannerOnTooltipSetItem(scannerTooltip)
  if scannerTooltip.lengths then
    tinsert(scannerTooltip.lengths, scannerTooltip:NumLines())
  end
end

local function CreateScanner(tooltip)
  local tooltipName = tooltip:GetName()
  local scannerTooltip = tooltipScanners[tooltipName]
  if not scannerTooltip then
    -- can't have tooltipName as an unbroken string anywhere in the name due to overly aggressive tooltip hooking from previous versions of TipHooker-1.0
    scannerTooltip = CreateFrame("GameTooltip", strGsub(tooltipName, "Tooltip", "ZeraTooltip"), UIParent, "GameTooltipTemplate")
    scannerTooltip:HookScript("OnTooltipSetItem", ScannerOnTooltipSetItem)
    scannerTooltip.tooltip = tooltip
    
    tooltipScanners[tooltipName] = scannerTooltip
  end
  return scannerTooltip
end

local function ResetScanner(scannerTooltip, link, methodName, ...)
  if not link then
    local tooltip = scannerTooltip.tooltip
    if not tooltip.GetItem then return end
    local name
    name, link = tooltip:GetItem()
    if not name or not link then return end
  end
  
  scannerTooltip.lastTime = GetTime()
  scannerTooltip.lastLink = link
  scannerTooltip.lastCall = {link, methodName, ...} -- TODO: if same frame, same item, last call different, then the destructor would be needed to undo OnTooltipSetItem. pray that this never happens
  scannerTooltip.lastCall.n = select("#", ...) + 2
  
  local _, _, _, _, _, itemType = GetItemInfoInstant(link)
  scannerTooltip.isRecipe = itemType == Enum.ItemClass.Recipe
  scannerTooltip.updates  = 0
  scannerTooltip.lengths  = {}
end

local compareMethods = setmetatable({SetCompareItem = true, SetHyperlinkCompareItem = true}, {__index = function() return false end})
local recursion      = false -- used for shopping tooltips
local alreadyPrepped = false -- used for shopping tooltips
local function OnTooltipItemMethod(tooltip, methodName, ...)
  local self = Addon
  if not self:IsEnabled() then return end
  
  if not tooltip.GetItem then return end
  local name, link = tooltip:GetItem()
  if not name or not link then return end
  local isComparison = compareMethods[methodName]
  
  local args = {...}
  args.n = select("#", ...)
  if not recursion and isComparison then
    args[1] = CreateScanner(args[1])
    ResetScanner(args[1], nil, methodName, ...)
    alreadyPrepped = false
  end
  
  do
    local scannerTooltip = CreateScanner(tooltip)
    if not recursion then
      if scannerTooltip.lastTime == GetTime() and scannerTooltip.lastLink == link then return end
      ResetScanner(scannerTooltip, link, methodName, ...)
    end
    
    if tooltip:IsShown() then
      local constructor = self:GetConstructor(tooltip, link, methodName, ...)
      if not constructor then
        if isComparison and not recursion then
          if not self:PrepareTooltip(args[1]) then return end
        end
        if not recursion or not alreadyPrepped then
          if not self:PrepareTooltip(scannerTooltip, methodName, unpack(args, 1, args.n)) then return end
          alreadyPrepped = true
        end
        local tooltipData = self:ReadTooltip(scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil) -- TODO: could theoretically do better than this if I search the main tooltip for matching lines; however, it would be unreliable
        if #tooltipData > 0 then
          self:ModifyTooltipData(tooltip, tooltipData)
          constructor = self:CreateConstructor(tooltipData)
          self:SetConstructor(constructor, tooltip, link, methodName, ...)
        end
      end
      
      if constructor then
        local destructor = self:ConstructTooltip(tooltip, constructor)
        -- self:DestructTooltip(tooltip, destructor)
      end
    end
  end
  
  if not recursion and isComparison then
    recursion = true
    local args = {...}
    args.n = select("#", ...)
    OnTooltipItemMethod(args[1], methodName, ...)
    recursion = false
  end
end

local function OnTooltipSetItem(tooltip)
  local self = Addon
  if not self:IsEnabled() then return end
  local scannerTooltip = CreateScanner(tooltip)
  if not tooltip.GetItem then return end
  local name, link = tooltip:GetItem()
  if not name or not link then return end
  if scannerTooltip.lastTime ~= GetTime() or scannerTooltip.lastLink ~= link then return end -- TODO: also use a frame counter
  
  scannerTooltip.updates = scannerTooltip.updates + 1
  if scannerTooltip.isRecipe and scannerTooltip.updates % 2 == 1 then return end
  
  local constructor = self:GetConstructor(tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
  if not constructor then
    local tooltipData = self:ReadTooltip(scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil)
    if #tooltipData > 0 then
      self:ModifyTooltipData(scannerTooltip.tooltip, tooltipData)
      constructor = self:CreateConstructor(tooltipData)
      self:SetConstructor(constructor, tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
    end
  end
  if constructor then
    local destructor = self:ConstructTooltip(scannerTooltip.tooltip, constructor)
    -- self:DestructTooltip(scannerTooltip.tooltip, destructor)
  end
end

function Addon:HookTooltips()
  -- hook tooltips with OnTooltipSetItem
  self.TipHooker2:Hook(OnTooltipSetItem, "item")
  
  -- hook tooltips with a more powerful method
  self.TipHooker:Hook(function(tooltip, methodName, _, _, ...) OnTooltipItemMethod(tooltip, methodName, ...) end, "item")
  self.TipHooker:Hook(function(tooltip, methodName, slot) OnTooltipItemMethod(tooltip, methodName, slot) end, "action")
end


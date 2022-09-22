
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

local function OnTooltipItemMethod(tooltip, methodName, name, link, ...)
  local self = Addon
  if not self:IsEnabled() then return end
  local args = {..., n = select("#", ...)}
  for i = 1, #args do
    local arg = args[i]
    if type(arg) == "table" and arg.GetName then
      args[i] = arg:GetName()
    end
  end
  
  local args = {...}
  args.n = select("#", ...)
  -- self:Debug(tooltip:GetName(), methodName, unpack(args, 1, args.n))
  local calls = {}
  tinsert(calls, {tooltip = tooltip, methodName = methodName, args = args})
  
  if methodName == "SetCompareItem" or methodName == "SetHyperlinkCompareItem" then
    tinsert(calls, {tooltip = args[1], methodName = nil, args = args})
    args[1] = CreateScanner(args[1])
  end
  
  for i, call in ipairs(calls) do
    local scannerTooltip = CreateScanner(call.tooltip)
    call.scannerTooltip = scannerTooltip
    
    if not call.tooltip.GetItem then call.ignore = true end
    local name, link
    if not call.ignore then
      name, link = call.tooltip:GetItem()
      if not link then call.ignore = true end
    end
    if scannerTooltip.lastTime == GetTime() and scannerTooltip.lastLink == link then call.ignore = true end
    
    if not call.ignore then
      scannerTooltip.lastTime = GetTime()
      scannerTooltip.lastLink = link
      scannerTooltip.lastCall = {link, methodName, ...} -- TODO: if same frame, same item, last call different, then the destructor would be needed to undo OnTooltipSetItem. pray that this never happens
      scannerTooltip.lastCall.n = select("#", ...) + 2
      
      local _, _, _, _, _, itemType = GetItemInfoInstant(link)
      scannerTooltip.isRecipe = itemType == Enum.ItemClass.Recipe
      scannerTooltip.updates  = 0
      scannerTooltip.lengths  = {}
    end
  end
  
  for _, call in ipairs(calls) do
    if call.tooltip:IsShown() and not call.ignore then
      local scannerTooltip = call.scannerTooltip
      
      local constructor = self:GetConstructor(tooltip, link, methodName, ...)
      if not constructor then
        if call.methodName then
          if not self:PrepareTooltip(scannerTooltip, call.methodName, unpack(call.args, 1, call.args.n)) then return end
        end
        local tooltipData = self:ReadTooltip(scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil) -- TODO: could theoretically do better than this if I search the main tooltip for matching lines; however, it would be unreliable
        if #tooltipData > 0 then
          self:ModifyTooltipData(call.tooltip, tooltipData)
          constructor = self:CreateConstructor(tooltipData)
          self:SetConstructor(constructor, tooltip, link, methodName, ...)
        end
      end
      
      if constructor then
        local destructor = self:ConstructTooltip(call.tooltip, constructor)
        -- self:DestructTooltip(call.tooltip, destructor)
      end
    end
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
  self.TipHooker:Hook(OnTooltipItemMethod, "item")
  self.TipHooker:Hook(function(tooltip, methodName, slot)
    if not self:IsEnabled() then return end
    if not tooltip.GetItem then return end
    local name, link = tooltip:GetItem()
    if not name or not link then return end
    OnTooltipItemMethod(tooltip, methodName, name, link, slot)
  end, "action")
end


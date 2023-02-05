
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


local strMatch  = string.match
local strGsub   = string.gsub

local tinsert   = table.insert
local tblConcat = table.concat



function Addon:IsHookEnabled()
  local invertMode = self:GetOption"invertMode"
  if invertMode == "none" then
    return self:GetOption"enabled"
  elseif invertMode == "any" then
    if     IsShiftKeyDown()   and self:GetOption("modKeys", "shift")
        or IsControlKeyDown() and self:GetOption("modKeys", "ctrl")
        or IsAltKeyDown()     and self:GetOption("modKeys", "alt")
    then
      return not self:GetOption"enabled"
    else
      return self:GetOption"enabled"
    end
  elseif invertMode == "all" then
    if      (IsShiftKeyDown()   or not self:GetOption("modKeys", "shift"))
        and (IsControlKeyDown() or not self:GetOption("modKeys", "ctrl"))
        and (IsAltKeyDown()     or not self:GetOption("modKeys", "alt"))
    then
      return not self:GetOption"enabled"
    else
      return self:GetOption"enabled"
    end
  end
end




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
  scannerTooltip.lastCall = {link, methodName, ...}
  scannerTooltip.lastCall.n = select("#", ...) + 2
  
  local _, _, _, _, _, itemType = GetItemInfoInstant(link)
  scannerTooltip.isRecipe = itemType == Enum.ItemClass.Recipe
  scannerTooltip.updates  = 0
  scannerTooltip.lengths  = {}
end

local function ConvertArgs(...)
  local args = {n = select("#", ...), ...}
  for i = 1, args.n do
    if type(args[i]) == "table" and args[i].GetName then
      args[i] = args[i]:GetName()
    else
      args[i] = tostring(args[i])
    end
  end
  return args
end

local compareMethods = setmetatable({SetCompareItem = true, SetHyperlinkCompareItem = true}, {__index = function() return false end})
local recursion      = false -- used for shopping tooltips
local alreadyPrepped = false -- used for shopping tooltips
local function OnTooltipItemMethod(tooltip, methodName, ...)
  local self = Addon
  if not self:IsHookEnabled() then return end
  
  if not tooltip.GetItem then
    if Addon:GetOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(...)
      Addon:Debugf("Bad Hook (no field 'GetItem'): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
    end
    return
  end
  local name, link = tooltip:GetItem()
  if not name or not link then
    if Addon:GetOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(...)
      Addon:Debugf("Bad Hook (GetItem() returned nil): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
    end
    return
  end
  local isComparison = compareMethods[methodName]
  
  if Addon:GetOption("debugOutput", "tooltipMethodHook") then
    local args = ConvertArgs(...)
    Addon:Debugf("Hook: %s:%s(%s) - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), link)
  end
  
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
      if not constructor or not self:ValidateConstructor(tooltip, constructor) then
        if constructor then -- failed validation
          constructor = self:WipeConstructor(tooltip, link, methodName, ...)
        end
        if isComparison and not recursion then
          if not self:PrepareTooltip(args[1]) then return end
        end
        if not recursion or not alreadyPrepped then
          if not self:PrepareTooltip(scannerTooltip, methodName, unpack(args, 1, args.n)) then return end
          alreadyPrepped = true
        end
        local tooltipData = self:ReadTooltip(scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil)
        if #tooltipData > 0 then
          self:ModifyTooltipData(tooltip, tooltipData)
          constructor = self:CreateConstructor(tooltipData)
          self:SetConstructor(constructor, tooltip, link, methodName, ...)
        end
      end
      
      if constructor then
        local destructor = self:ConstructTooltip(tooltip, constructor)
        if self:GetOption("constructor", "alwaysDestruct") then
          self:DestructTooltip(tooltip, destructor)
        end
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

 -- works on uncached itemlinks
local function DoLinksMatch(link1, link2)
  if link1 == link2 then return true end
  if not link1 or not link2 then return false end
  return strMatch(link1, "|Hitem:([:%-%w]+)|h") == strMatch(link2, "|Hitem:([:%-%w]+)|h")
end

local function OnTooltipSetItem(tooltip)
  local self = Addon
  if not self:IsHookEnabled() then return end
  local scannerTooltip = CreateScanner(tooltip)
  if not tooltip.GetItem then return end
  local name, link = tooltip:GetItem()
  if not name or not link then return end
  if scannerTooltip.lastTime ~= GetTime() or not DoLinksMatch(scannerTooltip.lastLink, link) then return end
  
  scannerTooltip.updates = scannerTooltip.updates + 1
  if scannerTooltip.isRecipe and scannerTooltip.updates % 2 == 1 then return end
  
  if self:GetOption("debugOutput", "tooltipOnSetItemHook") then
    local methodName = scannerTooltip.lastCall[2]
    local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
    Addon:Debugf("OnTooltipSetItem: %s:%s(%s) - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), link)
  end
  
  local constructor = self:GetConstructor(tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
  if not constructor or not self:ValidateConstructor(tooltip, constructor) then
    if constructor then -- failed validation
      constructor = self:WipeConstructor(tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
    end
    local tooltipData = self:ReadTooltip(scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil)
    if #tooltipData > 0 then
      self:ModifyTooltipData(scannerTooltip.tooltip, tooltipData)
      constructor = self:CreateConstructor(tooltipData)
      self:SetConstructor(constructor, tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
    end
  end
  if constructor then
    local destructor = self:ConstructTooltip(scannerTooltip.tooltip, constructor)
    if self:GetOption("constructor", "alwaysDestruct") then
      self:DestructTooltip(scannerTooltip.tooltip, destructor)
    end
  end
end

function Addon:HookTooltips()
  -- hook tooltips with OnTooltipSetItem
  self.TipHooker2:Hook(OnTooltipSetItem, "item")
  
  -- hook tooltips with a more powerful method
  self.TipHooker:Hook(OnTooltipItemMethod, "item")
  self.TipHooker:Hook(function(tooltip, methodName, slot) OnTooltipItemMethod(tooltip, methodName, slot) end, "action")
end


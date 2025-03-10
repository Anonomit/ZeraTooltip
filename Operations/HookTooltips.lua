
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strMatch  = string.match
local strGsub   = string.gsub

local tinsert   = table.insert
local tblConcat = table.concat



local equipmentChanged = false
Addon:RegisterEventCallback("PLAYER_EQUIPMENT_CHANGED", function() equipmentChanged = true end)




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

local function ScannerOnTooltipSetItem(scannerTooltip)
  Addon:WipeConstructorCache()
  if scannerTooltip.lengths then
    tinsert(scannerTooltip.lengths, scannerTooltip:NumLines())
  end
  if Addon:GetGlobalOption("debugOutput", "tooltip_" .. scannerTooltip.tooltip:GetName()) then
    local name, link = scannerTooltip:GetItem()
    local methodName = scannerTooltip.lastCall[2]
    local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
    local methodName = scannerTooltip.lastCall[2]
    Addon:Debugf("OnTooltipSetItem: %s:%s(%s) - %s", scannerTooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), tostring(link))
  end
end

local tooltipScanners = {}
local function GetScanner(tooltip)
  local tooltipName = tooltip:GetName()
  local scannerTooltip = tooltipScanners[tooltipName]
  if not scannerTooltip then
    -- can't have tooltipName as an unbroken string anywhere in the name due to overly aggressive tooltip hooking from previous versions of TipHooker-1.0
    scannerTooltip = CreateFrame("GameTooltip", strGsub(tooltipName, "Tooltip", "ZeraTooltip"), nil, "GameTooltipTemplate")
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
  scannerTooltip.lastCall = {link, methodName, ...}
  scannerTooltip.lastCall.n = select("#", ...) + 2
  
  local _, _, _, _, _, itemType = GetItemInfoInstant(link)
  scannerTooltip.isRecipe = itemType == Enum.ItemClass.Recipe
  scannerTooltip.updates  = 0
  scannerTooltip.lengths  = {}
end

local function GenerateConstructor(tooltip, scannerTooltip, name, link, maxLines)
  local tooltipData, constructor
  
  if Addon:xpcall(function() tooltipData = Addon:ReadTooltip(scannerTooltip, name, link, maxLines) end) then
    if #tooltipData > 0 then
      if Addon:xpcall(function() Addon:ModifyTooltipData(tooltip, tooltipData) end) then
        Addon:xpcall(function() constructor = Addon:CreateConstructor(tooltipData) end)
      end
    end
  end
  
  return constructor
end

local compareMethods = Addon:MakeLookupTable{"SetCompareItem", "SetHyperlinkCompareItem"}
local recursion      = false -- used for shopping tooltips
local shoppingPrepped = false -- used for shopping tooltips
local function OnTooltipItemMethod(tooltip, methodName, ...)
  local self = Addon
  if not self:IsHookEnabled() then return end
  
  if not tooltip.GetItem then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(...)
      Addon:Debugf("Bad Hook (no field 'GetItem'): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
    end
    return
  end
  local name, link = tooltip:GetItem()
  if not name or not link then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(...)
      Addon:Debugf("Bad Hook (GetItem() returned nil): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
    end
    return
  end
  
  local isComparison = compareMethods[methodName]
  
  if self:IsTooltipMarked(tooltip) then
    if isComparison and equipmentChanged then
      equipmentChanged = false
      if Addon:GetGlobalOption("debugOutput", "tooltipMethodHook") then
        local args = ConvertArgs(...)
        Addon:Debugf("Hook (early prep): %s:%s(%s) - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), link)
      end
      
      if isComparison and not recursion then
        ResetScanner(GetScanner((...)), nil, methodName, ...)
      else
        ResetScanner(GetScanner(tooltip), nil, methodName, ...)
      end
      self:PrepareTooltip(GetScanner(tooltip), link, methodName, ...)
      
    elseif Addon:GetGlobalOption("debugOutput", "tooltipHookMarked") then
      local args = ConvertArgs(...)
      Addon:Debugf("Hook already marked: %s:%s(%s) - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), link)
    end
    return
  end
  
  if Addon:GetGlobalOption("debugOutput", "tooltipMethodHook") then
    local args = ConvertArgs(...)
    Addon:Debugf("Hook: %s:%s(%s) - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), link)
  end
  
  local args = {...}
  args.n = select("#", ...)
  if not recursion and isComparison then
    args[1] = GetScanner(args[1])
    ResetScanner(args[1], nil, methodName, ...)
    shoppingPrepped = false
  end
  
  do
    local scannerTooltip = GetScanner(tooltip)
    if not recursion then
      ResetScanner(scannerTooltip, link, methodName, ...)
    end
    
    if tooltip:IsShown() then
      local alreadyPrepped = false
      local constructor = self:GetConstructor(tooltip, link, methodName, ...)
      if not constructor or not self:ValidateConstructor(tooltip, constructor) then
        local passedValidation = not constructor
        if constructor then -- validation failed
          self:DebugfIfOutput("constructorValidationFail", "Constructor validation failed at point #1")
          self:WipeConstructor(tooltip, link, methodName, ...)
          constructor = nil
        end
        if isComparison and recursion then
          scannerTooltip.currentItem = link
        end
        if not recursion or not shoppingPrepped or not passedValidation then
          if not self:PrepareTooltip(scannerTooltip, link, methodName, unpack(args, 1, args.n)) then
            if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
              local args = ConvertArgs(...)
              Addon:Debugf("Bad Hook (Preparing failed): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
            end
            return
          end
          alreadyPrepped = true
          scannerTooltip.currentItem = link
          shoppingPrepped = true
        end
        
        constructor = GenerateConstructor(tooltip, scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil)
      end
      if not constructor or not self:ValidateConstructor(tooltip, constructor) then
        if constructor then -- validation failed
          self:DebugfIfOutput("constructorValidationFail", "Constructor validation failed at point #2")
          self:WipeConstructor(tooltip, link, methodName, ...)
          constructor = nil
        end
        if not self:PrepareTooltip(scannerTooltip, link, methodName, unpack(args, 1, args.n)) then
          if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
            local args = ConvertArgs(...)
            Addon:Debugf("Bad Hook (Preparing failed): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
          end
        end
        scannerTooltip.currentItem = link
        shoppingPrepped = true
        constructor = GenerateConstructor(tooltip, scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil)
      end
      if constructor and name ~= "" then
        self:SetConstructor(constructor, tooltip, link, methodName, ...)
      end
      
      if constructor then
        local destructor = self:ConstructTooltip(tooltip, constructor)
        if self:GetGlobalOption("constructor", "alwaysDestruct") then
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
  self:RefreshDebugOptions()
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
  
  local scannerTooltip = GetScanner(tooltip)
  if not scannerTooltip.lastCall then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
      Addon:Debugf("Bad OnSetItem Hook (no field 'GetItem'): %s", tooltip:GetName())
    end
    return
  end
  if not tooltip.GetItem then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
      Addon:Debugf("Bad OnSetItem Hook (no field 'GetItem'): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
    end
    return
  end
  local name, link = tooltip:GetItem()
  if not name or not link then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
      local methodName = scannerTooltip.lastCall[2]
      Addon:Debugf("Bad OnSetItem Hook (GetItem() returned nil): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
    end
    return
  end
  if not scannerTooltip.currentItem or not DoLinksMatch(scannerTooltip.currentItem, link) then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
      local methodName = scannerTooltip.lastCall[2]
      Addon:Debugf("Bad OnSetItem Hook (link doesn't match): %s:%s(%s) - %s - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), tostring(scannerTooltip.currentItem), tostring(link))
    end
    return
  end
  if self:IsTooltipMarked(tooltip) then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookMarked") then
      local methodName = scannerTooltip.lastCall[2]
      local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
      local methodName = scannerTooltip.lastCall[2]
      Addon:Debugf("OnTooltipSetItem already marked: %s:%s(%s) - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), link)
    end
    return
  end
  
  scannerTooltip.updates = scannerTooltip.updates + 1
  if scannerTooltip.isRecipe and scannerTooltip.updates % 2 == 1 then
    if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
      local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
      local methodName = scannerTooltip.lastCall[2]
      Addon:Debugf("Bad OnSetItem Hook (recipe isn't ready): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
    end
    return
  end
  
  if self:GetGlobalOption("debugOutput", "tooltipOnSetItemHook") then
    local methodName = scannerTooltip.lastCall[2]
    local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
    local methodName = scannerTooltip.lastCall[2]
    Addon:Debugf("OnTooltipSetItem: %s:%s(%s) - %s", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "), link)
  end
  
  local constructor = self:GetConstructor(tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
  if not constructor or not self:ValidateConstructor(tooltip, constructor) then
    if constructor then -- validation failed
      self:DebugfIfOutput("constructorValidationFail", "Constructor validation failed at point #3")
      self:WipeConstructor(tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
      constructor = nil
      if tooltip == ShoppingTooltip2 then
        self:WipeConstructor(ShoppingTooltip1, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
      end
      
      local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
      if not self:PrepareTooltip(scannerTooltip, link, methodName, unpack(args, 1, args.n)) then
        if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
          Addon:Debugf("Bad Hook (Preparing failed): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
        end
      end
    end
    
    constructor = GenerateConstructor(tooltip, scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil)
  end
  local args = ConvertArgs(unpack(scannerTooltip.lastCall, 3, scannerTooltip.lastCall.n))
  if not constructor or not self:ValidateConstructor(tooltip, constructor) then
    if constructor then -- validation failed
      self:DebugfIfOutput("constructorValidationFail", "Constructor validation failed at point #4")
      self:WipeConstructor(tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
      constructor = nil
    end
    if not self:PrepareTooltip(scannerTooltip, link, methodName, unpack(args, 1, args.n)) then
      if Addon:GetGlobalOption("debugOutput", "tooltipHookFail") then
        Addon:Debugf("Bad Hook (Preparing failed): %s:%s(%s)", tooltip:GetName(), methodName, tblConcat({unpack(args, 1, args.n)}, ", "))
      end
    end
    constructor = GenerateConstructor(tooltip, scannerTooltip, name, link, scannerTooltip.isRecipe and scannerTooltip.lengths[1] or nil)
  end
  
  if constructor and name ~= "" then
    self:SetConstructor(constructor, tooltip, unpack(scannerTooltip.lastCall, 1, scannerTooltip.lastCall.n))
  end
  
  if constructor then
    local destructor = self:ConstructTooltip(scannerTooltip.tooltip, constructor)
    if self:GetGlobalOption("constructor", "alwaysDestruct") then
      self:DestructTooltip(scannerTooltip.tooltip, destructor)
    end
  end
  self:RefreshDebugOptions()
end

Addon:RegisterAddonEventCallback("ENABLE", function(self)
  -- hook tooltips with OnTooltipSetItem
  self.TipHooker2:Hook(OnTooltipSetItem, "item")
  
  -- hook tooltips with a more powerful method
  self.TipHooker:Hook(OnTooltipItemMethod, "item")
  self.TipHooker:Hook(function(tooltip, methodName, slot) OnTooltipItemMethod(tooltip, methodName, slot) end, "action")
end)


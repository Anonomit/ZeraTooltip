
--[[
TODO...

regressions:
  no longer supporting tbc (impossible to test on this client)
  can't color elemental weapon damage differently than weapon damage


option to force word wrap on/off for each stat?
  not sure what the use of this would be besides maybe fixing unforseen incompatibility issues

setting to show item level
  showItemLevel cvar missing?
setting to show Heroic tag
  supposed to be visible already in wrath?
    would need to make a database of heroic items
example for above settings: https://www.wowhead.com/wotlk/item=51933/shawl-of-nerubian-silk

recognize ITEM_READABLE
enchantment should be found only if the link has an enchantment


measure performance and memory usage with and without caches. maybe only cache particularly expensive operations? like localeExtras


--]]

local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
ZeraTooltip = Addon
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strLower  = string.lower
local strGmatch = string.gmatch
local tblConcat = table.concat
local tblRemove = table.remove

local function DeepCopy(orig, seen)
  local new
  if type(orig) == "table" then
    if seen[orig] then
      new = seen[orig]
    else
      new = {}
      seen[orig] = copy
      for k, v in next, orig, nil do
        new[DeepCopy(k, seen)] = DeepCopy(v, seen)
      end
      setmetatable(new, DeepCopy(getmetatable(orig), seen))
    end
  else
    new = orig
  end
  return new
end
function Addon:Copy(val)
  return DeepCopy(val, {})
end

function Addon:GetDB()
  return self.db
end
function Addon:GetDefaultDB()
  return self.dbDefault
end
function Addon:GetProfile()
  return Addon.GetDB(self).profile
end
function Addon:GetDefaultProfile()
  return Addon.GetDefaultDB(self).profile
end
local function GetOption(self, db, ...)
  local val = db
  for _, key in ipairs{...} do
    assert(type(val) == "table", format("Bad database access: %s", tblConcat({...}, " > ")))
    val = val[key]
  end
  return val
end
function Addon:GetOption(...)
  return GetOption(self, Addon.GetProfile(self), ...)
end
function Addon:GetDefaultOption(...)
  return GetOption(self, Addon.GetDefaultProfile(self), ...)
end
local function SetOption(self, db, val, ...)
  local keys = {...}
  local lastKey = tblRemove(keys, #keys)
  local tbl = db
  for _, key in ipairs(keys) do
    tbl = tbl[key]
  end
  tbl[lastKey] = val
  Addon.OnSet(self, db, val, ...)
end
function Addon:SetOption(val, ...)
  return SetOption(self, Addon.GetProfile(self), val, ...)
end
function Addon:ResetOption(...)
  return Addon.SetOption(self, Addon.Copy(self, Addon.GetDefaultOption(self, ...)), ...)
end

function Addon:OnSet(...)
  for _, func in next, Addon.onSetHandlers, nil do
    func(...)
  end
end


function Addon:IsEnabled()
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


local strMatch = string.match
local strFind  = string.find
local strGsub  = string.gsub
local strSub   = string.sub





function Addon:OnChatCommand(input)
  self:OpenConfig(ADDON_NAME)
end

-- Fix InterfaceOptionsFrame_OpenToCategory not actually opening the category (and not even scrolling to it)
-- Originally from BlizzBugsSuck (https://www.wowinterface.com/downloads/info17002-BlizzBugsSuck.html) and edited to not be global
do
  local function GetPanelName(panel)
    local tp = type(panel)
    local cat = INTERFACEOPTIONS_ADDONCATEGORIES
    if tp == "string" then
      for i = 1, #cat do
        local p = cat[i]
        if p.name == panel then
          if p.parent then
            return GetPanelName(p.parent)
          else
            return panel
          end
        end
      end
    elseif tp == "table" then
      for i = 1, #cat do
        local p = cat[i]
        if p == panel then
          if p.parent then
            return GetPanelName(p.parent)
          else
            return panel.name
          end
        end
      end
    end
  end
  
  local function InterfaceOptionsFrame_OpenToCategory_Fix(panel)
    if skip or InCombatLockdown() then return end
    local panelName = GetPanelName(panel)
    if not panelName then return end -- if its not part of our list return early
    local noncollapsedHeaders = {}
    local shownPanels = 0
    local myPanel
    local t = {}
    local cat = INTERFACEOPTIONS_ADDONCATEGORIES
    for i = 1, #cat do
      local panel = cat[i]
      if not panel.parent or noncollapsedHeaders[panel.parent] then
        if panel.name == panelName then
          panel.collapsed = true
          t.element = panel
          InterfaceOptionsListButton_ToggleSubCategories(t)
          noncollapsedHeaders[panel.name] = true
          myPanel = shownPanels + 1
        end
        if not panel.collapsed then
          noncollapsedHeaders[panel.name] = true
        end
        shownPanels = shownPanels + 1
      end
    end
    local min, max = InterfaceOptionsFrameAddOnsListScrollBar:GetMinMaxValues()
    if shownPanels > 15 and min < max then
      local val = (max/(shownPanels-15))*(myPanel-2)
      InterfaceOptionsFrameAddOnsListScrollBar:SetValue(val)
    end
    skip = true
    InterfaceOptionsFrame_OpenToCategory(panel)
    skip = false
  end

  hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", function(...) if Addon:GetOption"fixOptionsMenu" then InterfaceOptionsFrame_OpenToCategory_Fix(...) end end)
  
  function Addon:OpenConfig(category)
    InterfaceOptionsFrame_OpenToCategory_Fix(category)
  end
end

function Addon:ResetProfile(category)
  self:GetDB():ResetProfile()
  self.AceConfigRegistry:NotifyChange(category)
end
function Addon:CreateOptionsCategory(categoryName, options)
  local category = ADDON_NAME .. (categoryName and ("." .. categoryName) or "")
  self.AceConfig:RegisterOptionsTable(category, options)
  local Panel = self.AceConfigDialog:AddToBlizOptions(category, categoryName, categoryName and ADDON_NAME or nil)
  Panel.default = function() self:ResetProfile(category) end
  return Panel
end

function Addon:CreateOptions()
  self:InitOptionTableHelpers()
  
  self:MakeOptionsTable()
  
  self:MakeStatsOptionsTable()
  self:MakePaddingOptionsTable()
  self:MakeExtraStatsOptionsTable()
  
  local profileOptions = self.AceDBOptions:GetOptionsTable(self:GetDB())
  self:CreateOptionsCategory(profileOptions.name, profileOptions)
  
  self:MakeResetOptionsTable()
  
  if self:IsDebugEnabled() then
    self:MakeDebugOptionsTable()
  end
end

function Addon:InitDB()
  local configVersion = self.SemVer(self:GetOption"version" or tostring(self.Version))
  
  
  if not self:GetOption"version" then
    -- first run
    self:OverrideAllLocaleDefaults()
  end
  
  
  -- clear settings from earlier than 2.0.0 (wrath launch)
  if configVersion < self.SemVer"2.0.0" then
    return self:GetDB():ResetProfile()
  end
  
  
  -- validate
  -- add missing stats to list of stats
  local append
  local stats = {}
  for stat in strGmatch(self:GetOption("order", self.expansionLevel), "[^,]+") do
    stats[stat] = true
  end
  for stat in strGmatch(self:GetDefaultOption("order", self.expansionLevel), "[^,]+") do
    if not stats[stat] then
      append = (append or "") .. "," .. stat
    end
  end
  if append then
    self:SetOption(self:GetOption("order", self.expansionLevel) .. append, "order", self.expansionLevel)
  end
  
  -- load stat order
  self:RegenerateStatOrder()
  
  self:SetOption(tostring(self.Version), "version")
end


function Addon:OnInitialize()
  self.db        = self.AceDB:New(("%sDB"):format(ADDON_NAME), self:MakeDefaultOptions(), true)
  self.dbDefault = self.AceDB:New({}                         , self:MakeDefaultOptions(), true)
  
  self:RegisterChatCommand("zt", "OnChatCommand", true)
  
  self.tooltipCache = {}
end

function Addon:OnEnable()
  self.Version = self.SemVer(GetAddOnMetadata(ADDON_NAME, "Version"))
  self:InitDB()
  self:GetDB().RegisterCallback(self, "OnProfileChanged", "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileCopied" , "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileReset"  , "InitDB")
  
  self:CreateOptions()
  self:HookTooltips() -- TODO: delay hooking to make sure I'm last?
  
  -- fix some blizzard addons not respecting tooltip.updateTooltip
  self.addonLoadHooks = {}
  self:RegisterEvent("ADDON_LOADED", function(e, addon)
    if self.addonLoadHooks[addon] then
      self.addonLoadHooks[addon]()
    end
  end)
  self:ThrottleAuctionUpdates()
  self:ThrottleInspectUpdates()
  self:ThrottleMailUpdates()
  self:ThrottleTradeSkillUpdates()
end

function Addon:OnDisable()
  
end



local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)




local strGmatch = string.gmatch

local tinsert   = table.insert
local tblRemove = table.remove
local tblConcat = table.concat


function Addon:RegisterChatArg(arg, func)
  self.chatArgs[arg] = func
end

function Addon:OnChatCommand(input)
  local args = {self:GetArgs(input, 1)}
  
  local func = args[1] and self.chatArgs[args[1]] or nil
  if func then
    func(self, unpack(args))
  else
    self:OpenConfig()
  end
end


function Addon:InitDB()
  local configVersion = self.SemVer(self:GetOption"version" or tostring(self.version))
  
  
  if not self:GetOption"version" then -- first run
    self:OverrideAllLocaleDefaults()
  else -- upgrade data schema
    
    -- clear settings from earlier than 2.0.0 (wrath launch)
    if configVersion < self.SemVer"2.0.0" then
      return self:GetDB():ResetProfile()
    end
    
    -- convert icons to newer format
    if configVersion < self.SemVer"2.2.0" then
      for stat, icon in pairs(self:GetOption("icon")) do
        self:SetOption(self:UnmakeIcon(icon), "icon", stat)
      end
    end
    
    -- make cache option global
    if configVersion <= self.SemVer"2.8.1" then
      self:xpcallSilent(function()
        self:SetGlobalOption(self:GetOption("cache", "enabled"), "cache", "enabled")
      end)
      self:SetOption(nil, "cache")
    end
  end
  
  
  -- validate
  do
    -- add missing stats to list of stats. delete nonexistant stats from order
    local rewrite = false
    
    local defaultList  = self.statDefaultList
    local defaultOrder = self.statDefaultOrder
    local currentOrder = {}
    local foundStats   = {}
    local missing      = {}
    for stat in strGmatch(self:GetOption("order", self.expansionLevel), "[^,]+") do
      local defaultLocation = defaultOrder[stat]
      if defaultLocation then
        tinsert(currentOrder, stat)
        foundStats[stat] = true
      else
        rewrite = true
      end
    end
    for i, stat in ipairs(defaultList) do
      if not foundStats[stat] then
        tinsert(missing, 1, i)
      end
    end
    while #missing > 0 do
      rewrite = true
      local prevMissing = #missing
      for j = #missing, 1, -1 do
        local k          = missing[j]
        local stat       = defaultList[k]
        local beforeStat = defaultList[k-1]
        local afterStat  = defaultList[k+1]
        local offset     = self.statPrefOrder[k]
        
        local firstStat, secondStat
        if offset == 1 then
          firstStat, secondStat = afterStat, beforeStat
        else
          firstStat, secondStat = beforeStat, afterStat
        end
        offset = (offset + 1) % 2
        
        local otherStat = firstStat
        if not otherStat or not foundStats[otherStat] then
          otherStat = secondStat
          offset = (offset + 1) % 2
        end
        
        local success = false
        for i = #currentOrder, 1, -1 do
          if currentOrder[i] == otherStat then
            tinsert(currentOrder, i + offset, stat)
            tblRemove(missing, j)
            foundStats[stat] = true
            break
          end
        end
        
        if j == 1 and #missing == prevMissing then
          tinsert(currentOrder, stat)
          tblRemove(missing, j)
          foundStats[stat] = true
        end
      end
    end
    
    if rewrite then
      self:SetOption(tblConcat(currentOrder, ","), "order", self.expansionLevel)
    end
  end
  
  -- load stat order
  self:RegenerateStatOrder()
  
  self:SetOption(tostring(self.version), "version")
end


function Addon:OnInitialize()
  self.db        = self.AceDB:New(("%sDB"):format(ADDON_NAME), self:MakeDefaultOptions(), true)
  self.dbDefault = self.AceDB:New({}                         , self:MakeDefaultOptions(), true)
  
  self.chatArgs     = {}
  self.tooltipCache = {}
end

function Addon:OnEnable()
  self.version = self.SemVer(GetAddOnMetadata(ADDON_NAME, "Version"))
  self:InitDB()
  self:GetDB().RegisterCallback(self, "OnProfileChanged", "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileCopied" , "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileReset"  , "InitDB")
  
  for i, chatCommand in ipairs{"zt", "zera", ADDON_NAME:lower()} do
    if i == 1 then
      self:MakeAddonOptions(chatCommand)
      self:MakeBlizzardOptions(chatCommand)
    end
    self:RegisterChatCommand(chatCommand, "OnChatCommand", true)
  end
  
  do
    local function PrintVersion() self:Printf("Version: %s", tostring(self.version)) end
    for _, arg in ipairs{"version", "vers", "ver", "v"} do self:RegisterChatArg(arg, PrintVersion) end
  end
  
  self:HookTooltips()
  
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
  
  local criticalCVars = self:MakeLookupTable{"colorblindMode"}
  self:RegisterEvent("CVAR_UPDATE", function(e, cvar, val)
    if criticalCVars[cvar] then
      self:DebugfIfOutput("cvarSet", "Setting %s: %s", cvar, tostring(val))
      for funcName, func in next, Addon.onCVarSetHandlers, nil do
        if type(func) == "function" then
          func(self, cvar, val)
        else
          self[funcName](self, cvar, val)
        end
      end
    end
  end)
end

function Addon:OnDisable()
  
end


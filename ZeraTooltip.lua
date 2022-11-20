
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)




local strGmatch = string.gmatch



function Addon:OnChatCommand(input)
  local arg = self:GetArgs(input, 1)
  
  local func = arg and self.chatArgs[arg] or nil
  if func then
    func(self)
  else
    self:OpenConfig(ADDON_NAME)
  end
end



function Addon:CreateOptions()
  self:MakeAddonOptions(self.chatCommands[1])
  
  self:MakeStatsOptions(self.L["Stats"], self.chatCommands[1], "stats", "stat", "st")
  self:MakePaddingOptions(L["Spacing"], self.chatCommands[1], "spacing", "space", "spaces", "spa", "sp", "padding", "pad", "pa")
  self:MakeExtraOptions(self.L["Miscellaneous"], self.chatCommands[1], "misc", "miscellaneous", "other", "m")
  
  -- Profile Options
  do
    local args = {"profiles", "profile", "prof", "pro", "pr", "p"}
    local profileOptions = self.AceDBOptions:GetOptionsTable(self:GetDB())
    local categoryName = profileOptions.name
    profileOptions.name = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), profileOptions.name, self.chatCommands[1], args[1])
    local panel = self:CreateOptionsCategory(categoryName, profileOptions)
    local function OpenOptions() return self:OpenConfig(panel) end
    for _, arg in ipairs(args) do
      self.chatArgs[arg] = OpenOptions
    end
  end
  
  -- Reset Options
  self:MakeResetOptions(self.L["Reset"], self.chatCommands[1], "reset", "res", "re", "r")
  
  -- Debug Options
  if self:IsDebugEnabled() then
    self:MakeDebugOptions(self.L["Debug"], self.chatCommands[1], "debug", "db", "d")
  end
end

function Addon:InitDB()
  local configVersion = self.SemVer(self:GetOption"version" or tostring(self.Version))
  
  
  if not self:GetOption"version" then -- first run
    self:OverrideAllLocaleDefaults()
  else -- upgrade data chema
    
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
  end
  
  
  -- validate
  do
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
  end
  
  -- load stat order
  self:RegenerateStatOrder()
  
  self:SetOption(tostring(self.Version), "version")
end


function Addon:OnInitialize()
  self.db        = self.AceDB:New(("%sDB"):format(ADDON_NAME), self:MakeDefaultOptions(), true)
  self.dbDefault = self.AceDB:New({}                         , self:MakeDefaultOptions(), true)
  
  self.chatCommands = {"zt", "zera", ADDON_NAME:lower()}
  for _, chatCommand in ipairs(self.chatCommands) do
    self:RegisterChatCommand(chatCommand, "OnChatCommand", true)
  end
  
  self.tooltipCache = {}
end

function Addon:OnEnable()
  self.Version = self.SemVer(GetAddOnMetadata(ADDON_NAME, "Version"))
  self:InitDB()
  self:GetDB().RegisterCallback(self, "OnProfileChanged", "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileCopied" , "InitDB")
  self:GetDB().RegisterCallback(self, "OnProfileReset"  , "InitDB")
  
  self.chatArgs = {}
  do
    local function PrintVersion() self:Printf("Version: %s", tostring(self.Version)) end
    for _, arg in ipairs{"version", "vers", "ver", "v"} do self.chatArgs[arg] = PrintVersion end
  end
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


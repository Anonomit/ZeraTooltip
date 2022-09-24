
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)


local strGmatch = string.gmatch
local strGsub   = string.gsub
local strByte   = string.byte
local tinsert   = table.insert
local tblRemove = table.remove
local tblConcat = table.concat
local mathMin   = math.min
local mathMax   = math.max



-- these are optional table which may be defined in /LocaleExtra
-- they are run when relevant settings are reset or initialized
local localeDefaultOverrideMethods = {
  SetDefaultRewordByLocale    = {"reword"   , "defaultRewordLocaleOverrides"},
  SetDefaultModByLocale       = {"mod"      , "defaultModLocaleOverrides"},
  SetDefaultPrecisionByLocale = {"precision", "defaultPrecisionLocaleOverrides"},
}
for method, data in pairs(localeDefaultOverrideMethods) do
  local field, overrides = unpack(data, 1, 2)
  Addon[method] = function(self, stat)
    if stat then
      if Addon[overrides][stat] then
        Addon.SetOption(self, Addon[overrides][stat], field, stat)
      end
    else
      for stat, val in pairs(Addon[overrides]) do
        Addon.SetOption(self, val, field, stat)
      end
    end
  end
end

function Addon:OverrideAllLocaleDefaults()
  for method in pairs(localeDefaultOverrideMethods) do
    Addon[method](self)
  end
end


--   ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
--  ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
--  ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
--  ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
--  ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--   ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 


local icons = {
  "|TInterface\\Buttons\\UI-AttributeButton-Encourage-Up:0|t",
  "|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:0|t",
  "|TInterface\\Buttons\\UI-GroupLoot-DE-Up:0|t",
  "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:0|t",
  
  "|TInterface\\Buttons\\UI-PlusButton-Up:0|t",
  "|TInterface\\Buttons\\UI-PlusButton-Disabled:0|t",
  "|TInterface\\Buttons\\UI-CheckBox-Check:0|t",
  "|TInterface\\Buttons\\UI-CheckBox-Check-Disabled:0|t",
  -- "|TInterface\\Buttons\\UI-SliderBar-Button-Vertical:0|t",
  
  -- "|TInterface\\COMMON\\FavoritesIcon:0|t",
  -- "|TInterface\\COMMON\\friendship-archivistscodex:0|t",
  -- "|TInterface\\COMMON\\friendship-FistHuman:0|t",
  -- "|TInterface\\COMMON\\friendship-FistOrc:0|t",
  "|TInterface\\COMMON\\friendship-heart:0|t",
  "|TInterface\\COMMON\\friendship-manaorb:0|t",
  -- "|TInterface\\COMMON\\help-i:0|t",
  -- "|TInterface\\COMMON\\Indicator-Gray:0|t",
  -- "|TInterface\\COMMON\\Indicator-Green:0|t",
  -- "|TInterface\\COMMON\\Indicator-Yellow:0|t",
  -- "|TInterface\\COMMON\\Indicator-Red:0|t",
  "|TInterface\\COMMON\\RingBorder:0|t",
  
  "|TInterface\\CURSOR\\Attack:0|t",
  -- "|TInterface\\CURSOR\\Missions:0|t",
  "|TInterface\\CURSOR\\Cast:0|t",
  "|TInterface\\CURSOR\\Point:0|t",
  "|TInterface\\CURSOR\\Crosshairs:0|t",
  
  "|TInterface\\FriendsFrame\\InformationIcon:0|t",
  -- "|TInterface\\FriendsFrame\\StatusIcon-Away:0|t",
  -- "|TInterface\\FriendsFrame\\StatusIcon-DnD:0|t",
  "|TInterface\\FriendsFrame\\StatusIcon-Offline:0|t",
  "|TInterface\\FriendsFrame\\StatusIcon-Online:0|t",
  
  "|TInterface\\HELPFRAME\\HotIssueIcon:0|t",
  -- "|TInterface\\HELPFRAME\\HelpIcon-HotIssues:0|t",
  -- "|TInterface\\HELPFRAME\\HelpIcon-Suggestion:0|t",
  -- "|TInterface\\HELPFRAME\\ReportLagIcon-Spells:0|t",
  
  "|TInterface\\MINIMAP\\Dungeon:0|t",
  "|TInterface\\MINIMAP\\Raid:0|t",
  "|TInterface\\MINIMAP\\TempleofKotmogu_ball_cyan:0|t",
  "|TInterface\\MINIMAP\\TempleofKotmogu_ball_green:0|t",
  "|TInterface\\MINIMAP\\TempleofKotmogu_ball_orange:0|t",
  "|TInterface\\MINIMAP\\TempleofKotmogu_ball_purple:0|t",
  "|TInterface\\MINIMAP\\Vehicle-AllianceMagePortal:0|t",
  "|TInterface\\MINIMAP\\Vehicle-HordeMagePortal:0|t",
  
  "|TInterface\\MONEYFRAME\\Arrow-Left-Down:0|t",
  -- "|TInterface\\MONEYFRAME\\Arrow-Left-Up:0|t",
  "|TInterface\\MONEYFRAME\\Arrow-Right-Down:0|t",
  -- "|TInterface\\MONEYFRAME\\Arrow-Right-Up:0|t",
  
  "|TInterface\\Transmogrify\\transmog-tooltip-arrow:0|t",
  
  "|TInterface\\Tooltips\\ReforgeGreenArrow:0|t",
  
  "|TInterface\\OPTIONSFRAME\\VoiceChat-Play:0|t",
  "|TInterface\\OPTIONSFRAME\\VoiceChat-Record:0|t",
  
  "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:0|t",
  
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1:0|t",
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_2:0|t",
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_3:0|t",
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_4:0|t",
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_5:0|t",
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_6:0|t",
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_7:0|t",
  "|TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:0|t",
}
local iconsDropdown = Addon:Map(icons, nil, function(v) return v end)


function Addon:MakeDefaultOptions()
  local fakeAddon = {
    db = {
      profile = {
        
        enabled = true,
        invertMode = "none",
        modKeys = {
          ["*"] = true,
        },
        
        allow = { -- only applies to stats
          reorder = true,
          reword  = true,
          recolor = true,
        },
        
        order = {
          [self.expansions.wrath]   = tblConcat(self.statList[self.expansions.wrath]  , ","),
          [self.expansions.tbc]     = tblConcat(self.statList[self.expansions.tbc]    , ","),
          [self.expansions.classic] = tblConcat(self.statList[self.expansions.classic], ","),
        },
        hide = {
          ["*"]        = false,
          uselessRaces = true,
        },
        doReword = {
          ["*"]         = true,
          Enchant       = false,
          WeaponEnchant = false,
          Equip         = false,
          ChanceOnHit   = false,
          Use           = false,
        },
        reword = {
          ["*"] = "",
        },
        mod = {
          ["*"] = 1,
        },
        precision = {
          ["*"] = 0,
          Speed = 1,
        },
        doRecolor = {
          ["*"]   = true,
          Enchant = false,
        },
        color = (function() local colors = {["*"] = "00ff00"} for stat, StatInfo in pairs(self.statsInfo) do colors[stat] = StatInfo.color end return colors end)(),
        
        damage = {
          ["*"]              = true,
          showVariance       = false,
          ["variancePrefix"] = "+-",
        },
        dps = {
          ["*"] = true,
        },
        speedBar = {
          min         = 1.2,
          max         = 4,
          size        = 15,
          fillChar    = "I",
          blankChar   = " ",
          speedPrefix = false,
        },
        trimSpace = {
          ["*"] = true,
        },
        doIcon = {
          ["*"]         = false,
          Enchant       = true,
          WeaponEnchant = true,
        },
        icon = {
          Enchant       = "|TInterface\\Buttons\\UI-GroupLoot-DE-Up:0|t",
          WeaponEnchant = "|TInterface\\CURSOR\\Attack:0|t",
          Equip         = "|TInterface\\Tooltips\\ReforgeGreenArrow:0|t",
          ChanceOnHit   = "|TInterface\\Buttons\\UI-GroupLoot-Dice-Up:0|t",
          Use           = "|TInterface\\CURSOR\\Cast:0|t",
        },
        iconSpace = {
          ["*"] = true,
        },
        
        pad = {
          before = {
            ["*"]    = true,
            BaseStat = false,
          },
          after = {
            ["*"] = true,
          },
        },
        padLastLine  = true,
        combineStats = true,
        
        
        -- Debug options
        debug = {
          enabled = false,
          
          output = {
            suppressAll = false,
            
            tooltipHook      = true,
            lineRecognitions = true,
          },
          
        },
        
        constructorCache = {
          wipeDelay    = 10,  -- time in seconds without constructor being requested before it's cleared
          minSeenCount = 4,   -- minimum number of times constructor must be requested before it can be cached
          minSeenTime  = 0.5, -- minimum time in seconds since constructor was first requested before it can be cached
        },
        
        cache = {
          ["*"] = true,
          -- constructor = false,
          -- text        = false,
          -- stat        = false,
        },
        
        throttle = {
          ["*"] = true,
          -- AuctionFrame    = false,
          -- InspectFrame    = false,
          -- MailFrame       = false,
          -- TradeSkillFrame = false,
        },
        
        -- TODO: config options for blizzard fixes?
        fixOptionsMenu = false,
      },
    },
  }
  Addon.OverrideAllLocaleDefaults(fakeAddon)
  return fakeAddon.db
end


--  ███████╗███╗   ██╗██████╗      ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
--  ██╔════╝████╗  ██║██╔══██╗    ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
--  █████╗  ██╔██╗ ██║██║  ██║    ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
--  ██╔══╝  ██║╚██╗██║██║  ██║    ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
--  ███████╗██║ ╚████║██████╔╝    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚══════╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 







function Addon:InitOptionTableHelpers()
  self.GUI = {}
  local GUI = self.GUI
  
  local defaultInc   = 1000
  local defaultOrder = 1000
  local order        = defaultOrder
  
  function GUI:GetOrder()
    return order
  end
  function GUI:SetOrder(newOrder)
    order = newOrder
    return self
  end
  function GUI:ResetOrder()
    order = defaultOrder
    return self
  end
  function GUI:Order(inc)
    self:SetOrder(self:GetOrder() + (inc or defaultInc))
    return self:GetOrder()
  end
  
  function GUI:CreateEntry(opts, keys, name, desc, widgetType, disabled, order)
    if type(keys) ~= "table" then keys = {keys} end
    local key = widgetType .. "_" .. (tblConcat(keys, ".") or "")
    opts.args[key] = {name = name, desc = desc, type = widgetType, order = order or self:Order(), disabled = disabled}
    opts.args[key].set = function(info, val)        Addon:SetOption(val, unpack(keys)) end
    opts.args[key].get = function(info)      return Addon:GetOption(unpack(keys))      end
    return opts.args[key]
  end
  
  function GUI:CreateHeader(opts, name)
    local option = self:CreateEntry(opts, self:Order(), name, nil, "header", nil, self:Order(0))
  end
  
  function GUI:CreateDescription(opts, desc, fontSize)
    local option = self:CreateEntry(opts, self:Order(), desc, nil, "description", nil, self:Order(0))
    option.fontSize = fontSize or "large"
    return option
  end
  function GUI:CreateDivider(opts, count, fontSize)
    for i = 1, count or 1 do
      self:CreateDescription(opts, " ", fontSize or "small")
    end
  end
  function GUI:CreateNewline(opts)
    return self:CreateDivider(opts, 1)
  end
  
  function GUI:CreateToggle(opts, keys, name, desc, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "toggle", disabled)
    return option
  end
  
  function GUI:CreateSelect(opts, keys, name, desc, values, sorting, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "select", disabled)
    option.values  = values
    option.sorting = sorting
    option.style   = "dropdown"
    return option
  end
  
  function GUI:CreateMultiSelect(opts, keys, name, desc, values, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "multiselect", disabled)
    option.values  = values
    return option
  end
  
  function GUI:CreateRange(opts, keys, name, desc, min, max, step, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "range", disabled)
    option.min   = min
    option.max   = max
    option.step  = step
    return option
  end
  
  function GUI:CreateInput(opts, keys, name, desc, multiline, disabled)
    local option     = self:CreateEntry(opts, keys, name, desc, "input", disabled)
    option.multiline = multiline
    return option
  end
  
  function GUI:CreateColor(opts, keys, name, desc, disabled)
    local option = self:CreateEntry(opts, keys, name, desc, "color", disabled)
    option.set   = function(info, r, g, b)        Addon:SetOption(Addon:ConvertColorFromBlizzard(r, g, b), unpack(keys)) end
    option.get   = function(info)          return Addon:ConvertColorToBlizzard(Addon:GetOption(unpack(keys)))            end
    return option
  end
  
  function GUI:CreateExecute(opts, key, name, desc, func, disabled)
    local option = self:CreateEntry(opts, key, name, desc, "execute", disabled)
    option.func  = func
    return option
  end
  
  function GUI:CreateGroup(opts, key, name, groupType, disabled)
    key = "group_" .. key
    opts.args[key] = {name = name, type = "group", childGroups = groupType, args = {}, order = self:Order(), disabled = disabled}
    return opts.args[key]
  end
  
  function GUI:CreateGroupBox(opts, name)
    local key = "group_" .. self:Order(-1)
    opts.args[key] = {name = name, type = "group", args = {}, order = self:Order(), inline = true}
    return opts.args[key]
  end
  
  function GUI:CreateGroupTop(name, groupType, disabled)
    return {name = name, type = "group", childGroups = groupType, args = {}, order = self:Order(), disabled = disabled}
  end
end



function Addon:ChangeOrder(from, to)
  tinsert(self.statList[self.expansionLevel], to, tblRemove(self.statList[self.expansionLevel], from))
  self:SetOption(tblConcat(self.statList[self.expansionLevel], ","), "order", self.expansionLevel)
  self:RegenerateStatOrder()
end
function Addon:ResetOrder()
  self:ResetOption("order", self.expansionLevel)
  self:RegenerateStatOrder()
end
function Addon:ResetReword(stat)
  self:ResetOption("reword", stat)
  self:SetDefaultRewordByLocale(stat)
end
function Addon:ResetMod(stat)
  self:ResetOption("mod", stat)
  self:SetDefaultModByLocale(stat)
end
function Addon:ResetPrecision(stat)
  self:ResetOption("precision", stat)
  self:SetDefaultPrecisionByLocale(stat)
end

local function CreateCombineStatsOption(opts)
  Addon.GUI:CreateToggle(opts, {"combineStats"}, L["Group Secondary Stats with Base Stats"], nil, not Addon:GetOption("allow", "reorder")).width = 2
end


-- ZeraTooltip options
function Addon:MakeOptionsTable()
  local title = ADDON_NAME .. " v" .. tostring(self:GetOption"version")
  self:CreateOptionsCategory(nil, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title, "tab")
  
  do
    local enabled    = self:GetOption"enabled"
    local invertMode = self:GetOption"invertMode"
    
    local opts = GUI:CreateGroup(opts, 1, self.L["Enable"], "tab")
    
    GUI:CreateToggle(opts, {"enabled"}, self.L["Enabled"])
    GUI:CreateDivider(opts, 2)
    
    local text = enabled and self.L["Disable"] or self.L["Enable"]
    GUI:CreateSelect(opts, {"invertMode"}, text, desc, {none = self.L["never"], any = self.L["any"], all = self.L["all"]}, {"none", "any", "all"}).width = 0.7
    GUI:CreateNewline(opts)
    
    local disabled = invertMode == "none"
    GUI:CreateToggle(opts, {"modKeys", "shift"}, self.L["SHIFT key"], nil, disabled).width = 0.8
    GUI:CreateToggle(opts, {"modKeys", "ctrl"} , self.L["CTRL key"] , nil, disabled).width = 0.8
    GUI:CreateToggle(opts, {"modKeys", "alt"}  , self.L["ALT key"]  , nil, disabled).width = 0.8
  end
  
  do
    local opts = GUI:CreateGroup(opts, 2, self.L["Features"], "tab")
    
    GUI:CreateToggle(opts, {"allow", "reorder"}, L["Reorder"])
    GUI:CreateNewline(opts)
    GUI:CreateToggle(opts, {"allow", "reword"} , self.L["Rename"])
    GUI:CreateNewline(opts)
    GUI:CreateToggle(opts, {"allow", "recolor"}, L["Recolor"])
  end
  
  return opts
  end)
end


-- Stat options
local function GetDefaultStatText(number, stat)
  local StatInfo = Addon.statsInfo[stat]
  return Addon:MakeColorCode(StatInfo.tooltipColor, StatInfo:GetDefaultForm(number))
end

local function GetFormattedStatText(number, stat)
  local StatInfo = Addon.statsInfo[stat]
  local hidden = Addon:GetOption("hide", stat)
  local text = StatInfo:GetDefaultForm(number)
  if Addon:GetOption("allow", "reword") and Addon:GetOption("doReword", stat) then
    text = StatInfo:ConvertToNormalForm(text)
    text = strGsub(StatInfo:Reword(text, text), "%+(%-)", "%1")
  end
  local color = StatInfo.tooltipColor
  if hidden then
    color = Addon.COLORS.GRAY
  elseif Addon:GetOption("allow", "recolor") and Addon:GetOption("doRecolor", stat) then
    color = Addon:GetOption("color", stat)
  end
  return (hidden and "|T132320:0|t " or "") .. Addon:MakeColorCode(color, text)
end
local function GetFormattedText(stat, originalColor, defaultText, formattedText)
  local changed
  if formattedText ~= defaultText then
    changed = true
  end
  
  local color = Addon:GetOption("color", stat)
  if Addon:GetOption("hide", stat) then
    formattedText = "|T132320:0|t " .. Addon:MakeColorCode(Addon.COLORS.GRAY, formattedText)
    changed = true
  elseif Addon:GetOption("allow", "recolor") and Addon:GetOption("doRecolor", stat) and color ~= originalColor then
    formattedText = Addon:MakeColorCode(color, formattedText)
    changed = true
  else
    formattedText = Addon:MakeColorCode(originalColor, formattedText)
  end
  return Addon:MakeColorCode(originalColor, defaultText), formattedText, changed
end
local function CreateTitle(opts, defaultText, formattedText, changed, newline)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Example Text:"])
  
  GUI:CreateDescription(opts, self.L["Default"], "small")
  GUI:CreateDescription(opts, defaultText)
  GUI:CreateDivider(opts)
  if changed then
    GUI:CreateDescription(opts, self.L["Current"], "small")
    GUI:CreateDescription(opts, formattedText)
  else
    GUI:CreateDescription(opts, " ", "small")
    GUI:CreateDescription(opts, " ")
  end
  if newline then
    GUI:CreateNewline(opts)
  end
  
  return opts
end
local function CreateReset(opts, option, func)
  local self = Addon
  local GUI  = self.GUI
  
  GUI:CreateExecute(opts, option, self.L["Reset"], nil, func or function() self:ResetOption(unpack(option)) end).width = 0.6
end
local function CreateColor(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, L["Recolor"])
  
  local disabled = not Addon:GetOption("allow", "recolor")
  GUI:CreateToggle(opts, {"doRecolor", stat}, self.L["Enable"], nil, disabled).width = 0.5
  GUI:CreateColor(opts, {"color", stat}, self.L["Color"], nil, disabled or not Addon:GetOption("doRecolor", stat)).width = 0.5
  CreateReset(opts, {"color", stat})
  
  return opts
end
local function CreateReword(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
  
  local disabled = not Addon:GetOption("allow", "reword")
  GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
  local disabled = disabled or not self:GetOption("doReword", stat)
  local option = GUI:CreateInput(opts, {"reword", stat}, self.L["Custom"], nil, nil, disabled)
  option.width = 0.9
  option.set = function(info, val)        self:SetOption(self:CoverSpecialCharacters(val), "reword", stat) end
  option.get = function(info)      return Addon:UncoverSpecialCharacters(self:GetOption("reword", stat))   end
  CreateReset(opts, {"reword", stat}, function() self:ResetReword(stat) end)
  
  return opts
end
local function CreateHide(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Hide"])
  
  GUI:CreateToggle(opts, {"hide", stat}, self.L["Hide"]).width = 0.6
  CreateReset(opts, {"hide", stat})
  
  return opts
end
local function CreateIcon(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Icon"])
  
  local disabled = not self:GetOption("allow", "reword")
  GUI:CreateToggle(opts, {"doIcon", stat}, self.L["Icon"], nil, disabled).width = 0.6
  GUI:CreateSelect(opts, {"icon", stat}, self.L["Choose an Icon:"], nil, iconsDropdown, icons, disabled).width = 0.7
  CreateReset(opts, {"icon", stat}, function() self:ResetOption("icon", stat) end)
  GUI:CreateDivider(opts)
  
  local disabled = disabled or not self:GetOption("doIcon", stat)
  GUI:CreateToggle(opts, {"iconSpace", stat}, L["Icon Space"], nil, disabled).width = 0.7
  CreateReset(opts, {"iconSpace", stat}, function() self:ResetOption("iconSpace", stat) end)
  
  return opts
end
local sampleNumber = 10
local function CreateStatOption(opts, i, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local defaultText = GetDefaultStatText(sampleNumber, stat)
  local formattedText = GetFormattedStatText(sampleNumber, stat)
  
  local opts = GUI:CreateGroup(opts, stat, formattedText, "tab")
  
  do
    local opts = CreateTitle(opts, defaultText, formattedText, defaultText ~= formattedText, 1)
    
    -- Test
    local option = GUI:CreateRange(opts, {"sampleNumber"}, L["Test"], nil, -1000000, 1000000, 1)
    option.softMin = 0
    option.softMax = 100
    option.set = function(info, val)        sampleNumber = val end
    option.get = function(info)      return sampleNumber       end
  end
  
  do -- Reorder
    local opts = GUI:CreateGroupBox(opts, "Reorder", L["Reorder"])
    
    local disabled = not Addon:GetOption("allow", "reorder")
    local option = GUI:CreateExecute(opts, {"order", stat, "up"}, self.L["Move Up"], nil, function() self:ChangeOrder(i, i-1) end, disabled or i == 1)
    local option = GUI:CreateExecute(opts, {"order", stat, "wayUp"}, self.L["Move to Top"], nil, function() self:ChangeOrder(i, 1) end, disabled or i == 1)
    GUI:CreateNewline(opts)
    local option = GUI:CreateExecute(opts, {"order", stat, "down"}, self.L["Move Down"], nil, function() self:ChangeOrder(i, i+1) end, disabled or i == #self.statList[self.expansionLevel])
    local option = GUI:CreateExecute(opts, {"order", stat, "wayDown"}, self.L["Move to Bottom"], nil, function() self:ChangeOrder(i, #self.statList[self.expansionLevel]) end, disabled or i == #self.statList[self.expansionLevel])
  end
  
  CreateColor(opts, stat)
  
  CreateReword(opts, stat)
  
  do -- Multiply
    local opts = GUI:CreateGroupBox(opts, L["Multiply"])
    
    local option = GUI:CreateRange(opts, {"mod", stat}, L["Multiplier"], nil, 0, 1000, nil, disabled)
    option.width     = 1.5
    option.softMax   = 12
    option.bigStep   = 0.1
    option.isPercent = true
    CreateReset(opts, {"mod", stat}, function() self:ResetMod(stat) end)
    GUI:CreateRange(opts, {"precision", stat}, L["Precision"], nil, 0, 5, 1, disabled).width = 1.5
    CreateReset(opts, {"precision", stat}, function() self:ResetPrecision(stat) end)
  end
  
  CreateHide(opts, stat)
end
function Addon:MakeStatsOptionsTable()
  local title = self.L["Stats"]
  self:CreateOptionsCategory(title, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title)
  
  CreateCombineStatsOption(opts)
  
  if Addon:GetOption("allow", "reorder") then
    for i, stat in ipairs(self.statList[self.expansionLevel]) do
      CreateStatOption(opts, i, stat)
    end
  else
    for stat in strGmatch(self:GetDefaultOption("order", self.expansionLevel), "[^,]+") do
      CreateStatOption(opts, nil, stat)
    end
  end
  
  return opts
  end)
end


local sampleDamage   = 20
local sampleVariance = 0.5
local sampleSpeed    = 2.6
-- Misc options
function Addon:MakeExtraStatsOptionsTable()
  local title = self.L["Other Options"]
  self:CreateOptionsCategory(title, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title)
  
  -- Trainable
  do
    local stat = "Trainable"
    
    local defaultText = self.L["Weapon"]
    local _, name = GetFormattedText(stat, self.COLORS.RED, L["Trainable Equipment"], L["Trainable Equipment"])
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.RED, defaultText, defaultText)
    
    local opts = GUI:CreateGroup(opts, stat, name)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
  end
  
  GUI:CreateGroup(opts, "afterTrainable" , " ").disabled = true
  
  -- Weapon Damage
  do
    local stat = "Damage"
    
    local defaultText = format(DAMAGE_TEMPLATE, sampleDamage * (1-sampleVariance), sampleDamage * (1+sampleVariance))
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, defaultText, self:ModifyWeaponDamage(defaultText, sampleDamage, 1))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    do
      local opts = CreateTitle(opts, defaultText, formattedText, changed, 1)
      
      -- Test
      local option = GUI:CreateRange(opts, {"sampleDamage"}, L["Test"], nil, 0, 1000000, 0.5)
      option.softMax = 1000
      option.bigStep = 10
      option.set = function(info, val)        sampleDamage = val end
      option.get = function(info)      return sampleDamage       end
      local option = GUI:CreateRange(opts, {"sampleVariance"}, L["Test"], nil, 0, 1, 0.1)
      option.isPercent = true
      option.set = function(info, val)        sampleVariance = val end
      option.get = function(info)      return sampleVariance       end
    end
    
    CreateColor(opts, stat)
    
    do -- Reword
      local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"damage", "showMinMax"}  , L["Show Minimum and Maximum"], nil, disabled or not self:GetOption("damage", "showAverage")).width = 1.5
      CreateReset(opts, {"damage", "showMinMax"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"damage", "showAverage"} , L["Show Average"], nil, disabled or not self:GetOption("damage", "showMinMax")).width = 1.5
      CreateReset(opts, {"damage", "showAverage"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"damage", "showVariance"}, L["Show Variance"], nil, disabled).width = 1.5
      CreateReset(opts, {"damage", "showVariance"})
      GUI:CreateNewline(opts)
      GUI:CreateInput(opts, {"damage", "variancePrefix"} , L["Variance Prefix"], nil, nil, disabled).width = 0.5
      CreateReset(opts, {"damage", "variancePrefix"})
    end
    
    CreateHide(opts, stat)
  end
  
  local speedString = strGsub(format("%.2f", sampleSpeed), "%.", DECIMAL_SEPERATOR)
  local speedStringFull = SPEED .. " " .. speedString
  -- Weapon Speed
  do
    local stat = "Speed"
    
    local defaultSpeedString = speedString
    local defaultText = speedStringFull
    local formattedTextOriginal = self:ModifyWeaponSpeed(defaultText, sampleSpeed, defaultSpeedString)
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, defaultText, formattedTextOriginal)
    local disabled
    if self:GetOption("hide", "Damage") then
      formattedText = "|T132320:0|t " .. formattedTextOriginal
      changed = true
      disabled = true
    end
    
    local opts = GUI:CreateGroup(opts, stat, "  " .. (formattedText), nil, disabled)
    
    if not disabled then
      do
        local opts = CreateTitle(opts, defaultText, formattedText, changed, 1)
        
        -- Test
        local option = GUI:CreateRange(opts, {"sampleSpeed"}, L["Test"], nil, self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1)
        option.set = function(info, val)        sampleSpeed = val end
        option.get = function(info)      return sampleSpeed       end
      end
      
      CreateColor(opts, stat)
      
      CreateReword(opts, stat)
      
      do -- Precision
        local opts = GUI:CreateGroupBox(opts, L["Precision"])
        
        GUI:CreateRange(opts, {"precision", stat}, L["Precision"], nil, 0, 5, 1, disabled)
        CreateReset(opts, {"precision", stat}, function() self:ResetOption("precision", stat) end)
      end
      
      CreateHide(opts, stat)
    end
  end
  
  GUI:CreateGroup(opts, "afterSpeed" , " ", nil, true)
  
  -- Weapon DPS
  local sampleDPS = strGsub(format("%.1f", sampleDamage / sampleSpeed), "%.", DECIMAL_SEPERATOR)
  do
    local stat = "DamagePerSecond"
    
    local defaultText = format(DPS_TEMPLATE, sampleDPS)
    local formattedText = Addon:ModifyWeaponDamagePerSecond(defaultText)
    -- if self:GetOption("dps", "removeBrackets") then
    --   formattedText = self:ChainGsub(formattedText, {"^%(", "%)$", ""})
    -- end
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, defaultText, formattedText)
    
    if self:GetOption("dps", "removeBrackets") then
      -- defaultText   = self:ChainGsub(defaultText  , {"^%(", "%)$", ""})
      formattedText = self:ChainGsub(formattedText, {"^%(", "%)$", ""})
      if defaultText ~= formattedText then
        changed = true
      end
    end
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    do -- Remove Brackers
      local opts = GUI:CreateGroupBox(opts, L["Remove Brackets"])
      
      GUI:CreateToggle(opts, {"dps", "removeBrackets"}, L["Remove Brackets"], nil, disabled)
      CreateReset(opts, {"dps", "removeBrackets"})
    end
    
    CreateHide(opts, stat)
  end
  
  -- Weapon Speedbar
  do
    local stat = "Speedbar"
    
    local defaultSpeed = sampleSpeed
    local defaultText = self:ModifyWeaponSpeedbar(defaultSpeed, speedString, speedStringFull) or ""
    local formattedTextOriginal = defaultText == "" and L["Speed Bar"] or defaultText
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, formattedTextOriginal, formattedTextOriginal)
    local name, disabled
    if self:GetOption("hide", "DamagePerSecond") then
      name     = "|T132320:0|t " .. self:MakeColorCode(self.COLORS.GRAY, defaultText == "" and L["Speed Bar"] or formattedText)
      disabled = true
    end
    
    local opts = GUI:CreateGroup(opts, stat, "  " .. (name or formattedText), nil, disabled)
    
    if not disabled then
      
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Example Text:"])
        
        GUI:CreateDescription(opts, tostring(defaultSpeed), "small")
        GUI:CreateDescription(opts, formattedText)
        GUI:CreateDivider(opts)
        
        -- Test
        local option = GUI:CreateRange(opts, {"sampleSpeed"}, L["Test"], nil, self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1)
        option.set = function(info, val)        sampleSpeed = val end
        option.get = function(info)      return sampleSpeed       end
      end
      
      CreateColor(opts, stat)
      
      do -- Reword
        local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
        
        local disabled = not self:GetOption("allow", "reword")
        GUI:CreateToggle(opts, {"speedBar", "speedPrefix"}, L["Show Speed"], nil, disabled)
        CreateReset(opts, {"speedBar", "speedPrefix"})
        GUI:CreateNewline(opts)
        local option = GUI:CreateInput(opts, {"speedBar", "fillChar"} , L["Fill Character"], nil, nil, disabled)
        CreateReset(opts, {"speedBar", "fillChar"})
        GUI:CreateNewline(opts)
        local option = GUI:CreateInput(opts, {"speedBar", "blankChar"}, L["Blank Character"], nil, nil, disabled)
        CreateReset(opts, {"speedBar", "blankChar"})
      end
      
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Settings"])
        
        local option = GUI:CreateRange(opts, {"speedBar", "min"}, self.L["Minimum"], nil, self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
        option.set = function(info, val) self:SetOption(val, "speedBar", "min") self:SetOption(mathMax(val, self:GetOption("speedBar", "max")), "speedBar", "max") end
        local option = GUI:CreateRange(opts, {"speedBar", "max"}, self.L["Maximum"], nil, self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
        option.set = function(info, val) self:SetOption(val, "speedBar", "max") self:SetOption(mathMin(val, self:GetOption("speedBar", "min")), "speedBar", "min") end
        GUI:CreateNewline(opts)
        GUI:CreateRange(opts, {"speedBar", "size"}, self.L["Frame Width"], nil, 0, 30, 1, disabled)
        CreateReset(opts, {"speedBar", "size"}, func)
      end
      
      CreateHide(opts, stat)
    end
  end
  
  GUI:CreateGroup(opts, "afterSpeedbar" , " ", nil, true)
  
  -- Enchant
  do
    local stat = "Enchant"
    
    local defaultText = self.L["Enchant"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:ModifyEnchantment(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Weapon Enchant
  do
    local stat = "WeaponEnchant"
    
    local defaultText = self.L["Weapon Enchantment"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:ModifyWeaponEnchantment(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  GUI:CreateGroup(opts, "afterEnchant" , " ", nil, true)
  
  -- Races
  do
    local stat = "RequiredRaces"
    
    local defaultText = format(ITEM_RACES_ALLOWED, Addon.MY_RACE_NAME)
    local formattedText = defaultText
    local changed
    if self:GetOption("hide", stat) then
      formattedText = "|T132320:0|t " .. self:MakeColorCode(self.COLORS.GRAY, formattedText)
      changed = true
    else
      formattedText = self:MakeColorCode(self.COLORS.WHITE, formattedText)
    end
    
    local sampleText = self.uselessRaceStrings[1]
    if self:GetOption("hide", stat) or self:GetOption("hide", "uselessRaces") then
      sampleText = "|T132320:0|t " .. self:MakeColorCode(self.COLORS.GRAY, sampleText)
    else
      self:MakeColorCode(self.COLORS.WHITE, sampleText)
    end
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    do
      local opts = CreateTitle(opts, defaultText, formattedText, changed)
      GUI:CreateDivider(opts)
      
      GUI:CreateDescription(opts, L["Test"], "small")
      GUI:CreateDescription(opts, sampleText)
    end
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "uselessRaces"}, L["Hide Pointless Lines"])
      CreateReset(opts, {"hide", "uselessRaces"})
    end
  end
  
  -- Classes
  do
    local stat = "RequiredClasses"
    
    local opts = GUI:CreateGroup(opts, stat, nil)
    local name
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Example Text:"])
      
      GUI:CreateDescription(opts, self.L["Default"], "small")
      for i, sample in ipairs(self.sampleRequiredClassesStrings) do
        local defaultText = sample
        GUI:CreateDescription(opts, defaultText)
      end
      GUI:CreateDescription(opts, self.myClassString)
      
      GUI:CreateDivider(opts)
      
      for i, sample in ipairs(self.sampleRequiredClassesStrings) do
        local defaultText = sample
        local formattedText = defaultText
        local changed
        if self:GetOption("hide", stat) then
          formattedText = "|T132320:0|t " .. self:MakeColorCode(self.COLORS.GRAY, strGsub(formattedText, "|c%x%x%x%x%x%x%x%x", ""))
          changed = true
        elseif self:GetOption("doRecolor", stat) then
          formattedText = self:ChainGsub(formattedText, unpack(self.classColorReplacements))
          changed = true
        end
        
        if i == 1 then
          GUI:CreateDescription(opts, (changed or self:GetOption("hide", "myClass")) and self.L["Current"] or " ", "small")
        end
        GUI:CreateDescription(opts, changed and formattedText or " ")
        if i == self.sampleRequiredClassesStrings.mine then
          name = formattedText
        end
      end
      
      local formattedText = self.myClassString
      local changed
      if self:GetOption("hide", stat) or self:GetOption("hide", "myClass") then
        formattedText = "|T132320:0|t " .. self:MakeColorCode(self.COLORS.GRAY, formattedText)
        changed = true
      elseif self:GetOption("doRecolor", stat) then
        formattedText = self:ChainGsub(formattedText, unpack(self.classColorReplacements))
        changed = true
      end
      GUI:CreateDescription(opts, changed and formattedText or " ")
    end
    opts.name = name
    
    do
      local opts = GUI:CreateGroupBox(opts, L["Recolor"])
      
      local disabled = not Addon:GetOption("allow", "recolor")
      GUI:CreateToggle(opts, {"doRecolor", stat}, self.L["Enable"], nil, disabled).width = 0.5
      CreateReset(opts, {"color", stat})
    end
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "myClass"}, self.L["Me"]).width = 0.6
      CreateReset(opts, {"hide", "myClass"})
    end
  end
  
  -- Level
  do
    local stat = "RequiredLevel"
    
    local opts = GUI:CreateGroup(opts, stat, nil)
    local name
    local sample1 = self.MY_LEVEL - (self.MY_LEVEL == self.MAX_LEVEL and 1 or 0)
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Example Text:"])
      
      local sampleLevels = {sample1, self.MAX_LEVEL, self.MAX_LEVEL + 1}
      
      GUI:CreateDescription(opts, self.L["Default"], "small")
      for i, level in ipairs(sampleLevels) do
        local defaultText = format("|cffff%s%s", level > self.MY_LEVEL and "0000" or "ffff", format(ITEM_MIN_LEVEL, level))
        GUI:CreateDescription(opts, defaultText)
      end
      GUI:CreateDivider(opts)
      
      local anyChanged
      local anyChangedOpt = GUI:CreateDescription(opts, " ", "small")
      
      for i, level in ipairs(sampleLevels) do
        local defaultText = format("|cffff%s%s", level > self.MY_LEVEL and "0000" or "ffff", format(ITEM_MIN_LEVEL, level))
        local formattedText = defaultText
        local changed = self:GetOption("hide", stat) or self:GetOption("hide", "requiredLevelMet") and level <= self.MY_LEVEL or self:GetOption("hide", "requiredLevelMax") and level == self.MAX_LEVEL
        if changed then
          formattedText = "|T132320:0|t " .. self:MakeColorCode(self.COLORS.GRAY, strGsub(formattedText, "|c%x%x%x%x%x%x%x%x", ""))
        end
        
        if changed then anyChanged = true end
        GUI:CreateDescription(opts, changed and formattedText or " ")
        if level > self.MY_LEVEL then
          name = formattedText
        end
      end
      
      if anyChanged then
        anyChangedOpt.name = self.L["Current"]
      end
    end
    opts.name = name
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "requiredLevelMet"}, format(self:ChainGsub(self.L["|cff000000%s (low level)|r"], {"|c%x%x%x%x%x%x%x%x", "|r", ""}), format(self.L["Level %d"], sample1)))
      CreateReset(opts, {"hide", "requiredLevelMet"})
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "requiredLevelMax"}, self.L["Max Level"])
      CreateReset(opts, {"hide", "requiredLevelMax"})
    end
  end
  
  GUI:CreateGroup(opts, "afterRaces" , " ", nil, true)
  
  -- Prefixes
  for _, data in ipairs{
    {"Equip",       ITEM_SPELL_TRIGGER_ONEQUIP},
    -- {"ChanceOnHit", ITEM_SPELL_TRIGGER_ONPROC},
    {"Use",         ITEM_SPELL_TRIGGER_ONUSE},
  } do
    local stat   = data[1]
    local prefix = data[2]
    
    local defaultText = format("%s %s", prefix, format(ITEM_RESIST_ALL, strByte"+", sampleNumber))
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:ModifyPrefix(defaultText, prefix))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateReword(opts, stat)
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
    end
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  GUI:CreateGroup(opts, "afterPrefixes" , " ", nil, true)
  
  -- Socket Hint
  do
    local stat = "SocketHint"
    
    local defaultText = ITEM_SOCKETABLE
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:RewordSocketHint(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Misc locale rewording
  if #self.localeExtraReplacements > 0 then
    GUI:CreateGroup(opts, "afterSocketHint" , " ", nil, true)
    
    do
      local stat = "Miscellaneous"
      local name = Addon:MakeColorCode(self.COLORS.WHITE, self.L["Miscellaneous"])
      
      local opts = GUI:CreateGroup(opts, stat, name)
      
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Miscellaneous"])
        
        -- Reword
        local disabled = not self:GetOption("allow", "reword")
        GUI:CreateToggle(opts, {"doReword", stat}, self.L["Rename"], nil, disabled).width = 0.6
        CreateReset(opts, {"doReword", stat})
      end
    end
  end
  
  return opts
  end)
end


-- Padding options
local function CreateGroupGap(opts, name, disabled)
  if disabled then return end
  local self = Addon
  local GUI  = self.GUI
  
  GUI:CreateGroup(opts, name, " ", nil, true)
end
local function CreatePaddingOption(opts, name, beforeStat, afterStat, sample, disabled)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroup(opts, name, name, nil, disabled)
  
  if beforeStat then
    GUI:CreateToggle(opts, beforeStat, L["Space Above"], nil, disabled)
  else -- only happens at the end
    return GUI:CreateToggle(opts, afterStat, L["Space Below"], nil, disabled)
  end
  
  GUI:CreateNewline(opts)
  if sample then
    GUI:CreateDescription(opts, sample)
  else
    GUI:CreateDescription(opts, " ")
  end
  
  if afterStat then
    GUI:CreateNewline(opts)
    GUI:CreateToggle(opts, afterStat, L["Space Below"], nil, disabled)
  end
end
local function CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, disabled, paddedAfterPrevious)
  local self = Addon
  
  if beforeStat and self:GetOption(unpack(beforeStat)) and not paddedAfterPrevious then CreateGroupGap(opts, "before" .. name) end
  CreatePaddingOption(opts, name, beforeStat, afterStat, sample)
  paddedAfterPrevious = self:GetOption(unpack(afterStat))
  if paddedAfterPrevious then CreateGroupGap(opts, "after" .. name) end
  return paddedAfterPrevious
end
function Addon:MakePaddingOptionsTable()
  local title = L["Spacing"]
  self:CreateOptionsCategory(title, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title)
  
  CreateCombineStatsOption(opts)
  Addon.GUI:CreateToggle(opts, {"pad", "before", "BonusEffect"}, L["Space Above Bonus Effects"]).width = 2
  
  local paddedAfterPrevious = false
  local combineStats = self:GetOption("allow", "reorder") and self:GetOption"combineStats"
  
  -- Base Stats
  local name, beforeStat, afterStat, sample = self.L["Base Stats"], {"pad", "before", "BaseStat"}, {"pad", "after", "BaseStat"}, format(ITEM_MOD_STAMINA, strByte"+", 10)
  if beforeStat and self:GetOption(unpack(beforeStat)) and not paddedAfterPrevious then CreateGroupGap(opts, "before" .. name) end
  CreatePaddingOption(opts, name, beforeStat, afterStat, sample)
  if combineStats then
    -- Secondary Stats
    local name, beforeStat, afterStat, sample = L["Secondary Stats"], {"pad", "before", "SecondaryStat"}, {"pad", "after", "SecondaryStat"}, ITEM_SPELL_TRIGGER_ONEQUIP .. " " .. format(ITEM_MOD_MANA_REGENERATION, "10")
    CreatePaddingOption(opts, name, beforeStat, afterStat, sample, true)
  end
  paddedAfterPrevious = self:GetOption(unpack(afterStat))
  if paddedAfterPrevious then CreateGroupGap(opts, "after" .. name) end
  
  -- Enchant
  local name, beforeStat, afterStat, sample = self.L["Enchant"], {"pad", "before", "Enchant"}, {"pad", "after", "Enchant"}, format(ENCHANTED_TOOLTIP_LINE, self.L["Enchant"])
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, true, paddedAfterPrevious)
  
  -- Weapon Enchant
  local name, beforeStat, afterStat, sample = self.L["Weapon Enchantment"], {"pad", "before", "WeaponEnchant"}, {"pad", "after", "WeaponEnchant"}, format(ENCHANTED_TOOLTIP_LINE, self.L["Weapon Enchantment"])
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, true, paddedAfterPrevious)
  
  -- Sockets
  local name, beforeStat, afterStat, sample = L["Sockets"], {"pad", "before", "Socket"}, {"pad", "after", "SocketBonus"}
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, true, paddedAfterPrevious)
  
  if not combineStats then
    -- Secondary Stats
    local name, beforeStat, afterStat, sample = L["Secondary Stats"], {"pad", "before", "SecondaryStat"}, {"pad", "after", "SecondaryStat"}, ITEM_SPELL_TRIGGER_ONEQUIP .. " " .. format(ITEM_MOD_MANA_REGENERATION, "10")
    paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, true, paddedAfterPrevious)
  end
  
  -- Set List
  local name, beforeStat, afterStat, sample = L["Set List"], {"pad", "before", "SetName"}, {"pad", "after", "SetPiece"}
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, true, paddedAfterPrevious)
  
  -- Set Bonus
  local name, beforeStat, afterStat, sample = L["Set List"], {"pad", "before", "SetBonus"}, {"pad", "after", "SetBonus"}, format(ITEM_SET_BONUS, format(ITEM_MOD_MANA_REGENERATION, "10"))
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, true, paddedAfterPrevious)
  
  -- End
  local name, beforeStat, afterStat, sample = self.L["End"], nil, {"padLastLine"}
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, true, paddedAfterPrevious)
  
  
  GUI:CreateGroup(opts, "-", "------------------", nil, true)
  
  return opts
  end)
end


-- Reset Options
function Addon:MakeResetOptionsTable()
  local title = self.L["Reset"]
  self:CreateOptionsCategory(title, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title)
  
  GUI:CreateDivider(opts, 2)
  
  for _, v in ipairs{
    {self.L["All"]    , function() self:ResetProfile()     end},
    {L["Order"]       , function() self:ResetOrder()       end},
    {self.L["Color"]  , function() self:ResetOption"color" end},
    {self.L["Rename"] , function() self:ResetReword()      end},
    {L["Mod"]         , function() self:ResetMod()         end},
    {L["Precision"]   , function() self:ResetPrecision()   end},
    {self.L["Hide"]   , function() self:ResetOption"hide"  end},
    {L["Spacing"]     , function() self:ResetOption"pad"   end},
  } do
    local cat, func = unpack(v, 1, 2)
    GUI:CreateDescription(opts, cat)
    CreateReset(opts, {cat}, func)
    GUI:CreateNewline(opts)
  end
  
  return opts
  end)
end


-- Debug Options
function Addon:MakeDebugOptionsTable()
  local title = self.L["Debug"]
  self:CreateOptionsCategory(title, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title, "tab")
  
  -- Debug Messages
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), self.L["Enable"])
    
    GUI:CreateToggle(opts, {"debug", "enabled"}, self.L["Debug"])
    GUI:CreateExecute(opts, "reload", self.L["Reload UI"], nil, ReloadUI)
    GUI:CreateNewline(opts)
    
    
    do
      local opts = GUI:CreateGroupBox(opts, "Messages")
      
      GUI:CreateToggle(opts, {"debug", "output", "suppressAll"}, self.debugPrefix .. " " .. self.L["Hide messages like this one."]).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debug", "output", "tooltipHook"}, "Tooltip Hook Messages")
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debug", "output", "lineRecognitions"}, "Line Recognitions")
    end
    
    --[[
    output = {
      suppressAll = false,
      
      tooltipHook      = true,
      lineRecognitions = true,
    },--]]
  end
  
  -- Caches
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Cache")
    
    GUI:CreateToggle(opts, {"cache", "constructor"}, "Cache Constructors")
    GUI:CreateNewline(opts)
    
    GUI:CreateToggle(opts, {"cache", "text"}, "Cache Text Rewords")
    GUI:CreateNewline(opts)
    
    GUI:CreateToggle(opts, {"cache", "stat"}, "Cache Stat Recognition")
    GUI:CreateNewline(opts)
    
    local option = GUI:CreateRange(opts, {"constructorCache", "wipeDelay"}, "Wipe Delay", "Time in seconds without constructor being requested before it's cleared.", 0, 1000000, 0.001)
    option.softMax = 60
    option.bigStep = 1
    GUI:CreateNewline(opts)
    
    local option = GUI:CreateRange(opts, {"constructorCache", "minSeenCount"}, "Minimum Seen Count", "Minimum number of times constructor must be requested before it can be cached.", 0, 1000000, 1)
    option.softMax = 50
    GUI:CreateNewline(opts)
    
    local option = GUI:CreateRange(opts, {"constructorCache", "minSeenTime"}, "Minimum Seen Time", "Minimum time in seconds since constructor was first requested before it can be cached.", 0, 1000000, 0.001)
    option.softMax = 10
    option.bigStep = 0.25
  end
  
  -- Throttles
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Throttles")
    
    GUI:CreateToggle(opts, {"throttle", "AuctionFrame"}, "Throttle AuctionFrame", "Throttle tooltips updates from this frame so they use the regular tooltip update interval.")
    GUI:CreateNewline(opts)
    
    GUI:CreateToggle(opts, {"throttle", "InspectFrame"}, "Throttle InspectFrame", "Throttle tooltips updates from this frame so they use the regular tooltip update interval.")
    GUI:CreateNewline(opts)
    
    GUI:CreateToggle(opts, {"throttle", "MailFrame"}, "Throttle MailFrame", "Throttle tooltips updates from this frame so they use the regular tooltip update interval.")
    GUI:CreateNewline(opts)
    
    GUI:CreateToggle(opts, {"throttle", "TradeSkillFrame"}, "Throttle TradeSkillFrame", "Throttle tooltips updates from this frame so they use the regular tooltip update interval.")
  end
  
  -- Fixes
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Fixes")
    
    GUI:CreateToggle(opts, {"fixOptionsMenu"}, "Fix Options Menu", "Fix a bug with Interface Options so that it can be opened to a category that isn't visible without scrolling.")
  end
  
  return opts
  end)
end


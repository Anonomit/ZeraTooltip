
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)



local strGmatch = string.gmatch
local strGsub   = string.gsub
local strByte   = string.byte

local tinsert   = table.insert

local mathMin   = math.min
local mathMax   = math.max










--  ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
--  ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
--  ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
--  ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
--  ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
--  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝


local function CreateReset(opts, option, func, disabled)
  Addon.GUI:CreateExecute(opts, {"reset", unpack(option)}, Addon.L["Reset"], nil, func or function() Addon:ResetOption(unpack(option)) end, disabled).width = 0.6
end
local function CreateCombineStatsOption(opts)
  Addon.GUI:CreateToggle(opts, {"combineStats"}, L["Group Secondary Stats with Base Stats"], L["Move secondary effects (such as Attack Power and Spell Power), up to where the base stats (such as Stamina) are located."], not Addon:GetOption("allow", "reorder")).width = 2
end

local function GetDefaultStatText(number, stat)
  local StatInfo = Addon.statsInfo[stat]
  return Addon:MakeColorCode(StatInfo.tooltipColor, StatInfo:GetDefaultForm(number))
end
local function GetStatNormalName(stat)
  local StatInfo = Addon.statsInfo[stat]
  return Addon:MakeColorCode(StatInfo.tooltipColor, StatInfo:GetNormalName())
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
  return (hidden and Addon.stealthIcon or "") .. Addon:MakeColorCode(color, text)
end
local function GetFormattedText(stat, originalColor, defaultText, formattedText)
  local changed
  if formattedText ~= defaultText then
    changed = true
  end
  
  local color = Addon:GetOption("color", stat)
  if Addon:GetOption("hide", stat) then
    formattedText = Addon.stealthIcon .. Addon:MakeColorCode(Addon.COLORS.GRAY, Addon:StripColorCode(formattedText))
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
local function CreateSamples(opts, samples)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Example Text:"])
  
  local changed = false
  
  GUI:CreateDescription(opts, self.L["Default"], "small")
  for _, texts in ipairs(samples) do
    GUI:CreateDescription(opts, texts[1])
    if texts[1] ~= texts[2] then
      changed = true
    end
  end
  GUI:CreateDivider(opts)
  if changed then
    GUI:CreateDescription(opts, self.L["Current"], "small")
  else
    GUI:CreateDescription(opts, " ", "small")
  end
  for _, texts in ipairs(samples) do
    if texts[1] ~= texts[2] then
      GUI:CreateDescription(opts, texts[2])
    else
      GUI:CreateDescription(opts, " ")
    end
  end
  
  return opts
end
local function CreateColor(opts, stat, disabled)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, L["Recolor"])
  
  local disabled = disabled or not Addon:GetOption("allow", "recolor")
  GUI:CreateToggle(opts, {"doRecolor", stat}, self.L["Enable"], nil, disabled).width = 0.5
  GUI:CreateColor(opts, {"color", stat}, self.L["Color"], nil, disabled or not Addon:GetOption("doRecolor", stat)).width = 0.5
  CreateReset(opts, {"color", stat})
  
  return opts
end
local function CreateReword(opts, stat, disabled)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
  
  local disabled = disabled or not Addon:GetOption("allow", "reword")
  GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
  local disabled = disabled or not self:GetOption("doReword", stat)
  local option = GUI:CreateInput(opts, {"reword", stat}, self.L["Custom"], nil, nil, disabled)
  option.width = 0.9
  option.set = function(info, val)        self:SetOption(self:CoverSpecialCharacters(val), "reword", stat) end
  option.get = function(info)      return Addon:UncoverSpecialCharacters(self:GetOption("reword", stat))   end
  CreateReset(opts, {"reword", stat}, function() self:ResetReword(stat) end)
  
  return opts
end
local function CreateHide(opts, stat, disabled)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Hide"])
  
  GUI:CreateToggle(opts, {"hide", stat}, self.L["Hide"], nil, disabled).width = 0.6
  CreateReset(opts, {"hide", stat})
  
  return opts
end
local function CreateShow(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Show"])
  
  GUI:CreateReverseToggle(opts, {"hide", stat}, self.L["Show"], nil, disabled).width = 0.6
  CreateReset(opts, {"hide", stat})
  
  return opts
end
local icons         = Addon:Map(Addon.iconPaths, function(v) return Addon:MakeIcon(v) end)
local iconsDropdown = Addon:Map(icons, nil, function(v) return v end)
local function CreateIcon(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Icon"])
  
  local disabled = not self:GetOption("allow", "reword")
  GUI:CreateToggle(opts, {"doIcon", stat}, self.L["Icon"], nil, disabled).width = 0.6
  local option = GUI:CreateSelect(opts, {"icon", stat}, self.L["Choose an Icon:"], nil, iconsDropdown, icons, disabled or not self:GetOption("doIcon", stat))
  option.width = 0.7
  option.set   = function(info, v) self:SetOption(self:UnmakeIcon(v), "icon", stat)   end
  option.get   = function(info)    return self:MakeIcon(self:GetOption("icon", stat)) end
  CreateReset(opts, {"icon", stat}, function() self:ResetOption("icon", stat) end)
  GUI:CreateNewline(opts)
  
  local disabled = disabled or not self:GetOption("doIcon", stat)
  GUI:CreateToggle(opts, {"iconSizeManual", stat}, self.L["Manual"], nil, disabled).width = 0.6
  local option = GUI:CreateRange(opts, {"iconSize", stat}, L["Icon Size"], nil, 0, 96, 1, disabled or not self:GetOption("iconSizeManual", stat))
  option.width = 0.7
  option.softMin = 8
  option.softMax = 32
  CreateReset(opts, {"iconSize", stat}, function() self:ResetOption("iconSize", stat) end)
  GUI:CreateNewline(opts)
  
  GUI:CreateToggle(opts, {"iconSpace", stat}, L["Icon Space"], nil, disabled).width = 0.7
  CreateReset(opts, {"iconSpace", stat}, function() self:ResetOption("iconSpace", stat) end)
  
  return opts
end
local function CreateReorder(opts, stat, desc)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, L["Reorder"])
  
  local disabled = not Addon:GetOption("allow", "reorder")
  
  GUI:CreateToggle(opts, {"doReorder", stat}, self.L["Enable"], desc, disabled).width = 0.6
  CreateReset(opts, {"doReorder", stat}, function() self:ResetOption("doReorder", stat) end)
  
  return opts
end







--   █████╗ ██████╗ ██████╗  ██████╗ ███╗   ██╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔══██╗██╔══██╗██╔═══██╗████╗  ██║    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ███████║██║  ██║██║  ██║██║   ██║██╔██╗ ██║    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══██║██║  ██║██║  ██║██║   ██║██║╚██╗██║    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║  ██║██████╔╝██████╔╝╚██████╔╝██║ ╚████║    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝  ╚═╝╚═════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

function Addon:MakeAddonOptions(chatCmd)
  local title = format("%s v%s  (/%s)", ADDON_NAME, tostring(self:GetOption"version"), chatCmd)
  local panel = self:CreateOptionsCategory(nil, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title, "tab")
  
  do
    local opts = GUI:CreateGroup(opts, 1, self.L["Enable"], nil, "tab")
    
    do
      local opts = GUI:CreateGroupBox(opts, ADDON_NAME)
      
      GUI:CreateToggle(opts, {"enabled"}, self.L["Enabled"], L["Whether to modify tooltips."])
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Modifiers:"])
      
      GUI:CreateSelect(opts, {"invertMode"}, self:GetOption"enabled" and self.L["Disable"] or self.L["Enable"], L["Reverse behavior when modifier keys are held."], {none = self.L["never"], any = self.L["any"], all = self.L["all"]}, {"none", "any", "all"}).width = 0.7
      GUI:CreateNewline(opts)
      
      local disabled = self:GetOption"invertMode" == "none"
      GUI:CreateToggle(opts, {"modKeys", "shift"}, self.L["SHIFT key"], nil, disabled).width = 0.8
      GUI:CreateToggle(opts, {"modKeys", "ctrl"} , self.L["CTRL key"] , nil, disabled).width = 0.8
      GUI:CreateToggle(opts, {"modKeys", "alt"}  , self.L["ALT key"]  , nil, disabled).width = 0.8
    end
  end
  
  do
    local opts = GUI:CreateGroup(opts, 2, self.L["Features"], nil, "tab")
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Features"])
      
      GUI:CreateToggle(opts, {"allow", "reorder"}, L["Reorder"], L["Allow or prohibit all reordering."])
      CreateReset(opts, {"allow", "reorder"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"allow", "reword"} , self.L["Rename"], L["Allow or prohibit all rewording."])
      CreateReset(opts, {"allow", "reword"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"allow", "recolor"}, L["Recolor"], L["Allow or prohibit all recoloring."])
      CreateReset(opts, {"allow", "recolor"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"cache", "enabled"}, L["Cache"], L["Speeds up processing, but may introduce tooltip issues."])
      CreateReset(opts, {"cache", "enabled"})
    end
  end
  
  return opts
  end)
  function self:OpenAddonOptions() return self:OpenConfig(panel) end
end




--  ███████╗████████╗ █████╗ ████████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ███████╗   ██║   ███████║   ██║       ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ╚════██║   ██║   ██╔══██║   ██║       ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ███████║   ██║   ██║  ██║   ██║       ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝        ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local sampleNumber = 10
local function CreateStatOption(opts, i, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local defaultText = GetDefaultStatText(sampleNumber, stat)
  local formattedText = GetFormattedStatText(sampleNumber, stat)
  
  local opts = GUI:CreateGroup(opts, stat, formattedText, GetStatNormalName(stat), "tab")
  
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


function Addon:MakeStatsOptions(categoryName, chatCmd, arg1, ...)
  local title = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), categoryName, chatCmd, arg1)
  local panel = self:CreateOptionsCategory(categoryName, function()
  
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
  local function OpenOptions() return self:OpenConfig(panel) end
  for _, arg in ipairs{arg1, ...} do
    self.chatArgs[arg] = OpenOptions
  end
end






--  ██████╗  █████╗ ██████╗ ██████╗ ██╗███╗   ██╗ ██████╗      ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝     ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██████╔╝███████║██║  ██║██║  ██║██║██╔██╗ ██║██║  ███╗    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔═══╝ ██╔══██║██║  ██║██║  ██║██║██║╚██╗██║██║   ██║    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║     ██║  ██║██████╔╝██████╔╝██║██║ ╚████║╚██████╔╝    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝     ╚═╝  ╚═╝╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝      ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function CreateGroupGap(opts, name, disabled)
  if disabled then return end
  local self = Addon
  local GUI  = self.GUI
  
  GUI:CreateGroup(opts, name, " ", nil, nil, true)
end
local function CreatePaddingOption(opts, name, beforeStat, afterStat, samples, disabled)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroup(opts, name, name, nil, nil, disabled)
  
  if beforeStat then
    GUI:CreateToggle(opts, beforeStat, L["Space Above"], L["Place an empty line above this line."], disabled)
  else -- only happens at the end
    return GUI:CreateToggle(opts, afterStat, L["Space Below"], L["Place an empty line at the end of the tooltip, when possible."], disabled)
  end
  
  GUI:CreateNewline(opts)
  for _, sample in ipairs(type(samples) == "table" and samples or {samples}) do
    GUI:CreateDescription(opts, sample)
  end
  
  if afterStat then
    GUI:CreateNewline(opts)
    GUI:CreateToggle(opts, afterStat, L["Space Below"], L["Place an empty line below this line."], disabled)
  end
end
local function CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, samples, paddedAfterPrevious)
  local self = Addon
  
  if beforeStat and self:GetOption(unpack(beforeStat)) and not paddedAfterPrevious then CreateGroupGap(opts, "before" .. name) end
  CreatePaddingOption(opts, name, beforeStat, afterStat, samples)
  paddedAfterPrevious = self:GetOption(unpack(afterStat))
  if paddedAfterPrevious then CreateGroupGap(opts, "after" .. name) end
  return paddedAfterPrevious
end


function Addon:MakePaddingOptions(categoryName, chatCmd, arg1, ...)
  local title = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), categoryName, chatCmd, arg1)
  local panel = self:CreateOptionsCategory(categoryName, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title)
  
  CreateCombineStatsOption(opts)
  Addon.GUI:CreateToggle(opts, {"pad", "before", "BonusEffect"}, L["Add Space Above Bonus Effects"], L["Bonus effects are secondary effects that aren't just adding a stat (example: Hearthstone)."]).width = 2
  
  local paddedAfterPrevious = false
  local combineStats = self:GetOption("allow", "reorder") and self:GetOption"combineStats"
  
  GUI:CreateGroup(opts, GUI:Order(), "------------------", nil, nil, true)
  
  -- Base Stats
  local name, beforeStat, afterStat, sample = self.L["Base Stats"], {"pad", "before", "BaseStat"}, {"pad", "after", "BaseStat"}, format(ITEM_MOD_STAMINA, strByte"+", 10)
  if beforeStat and self:GetOption(unpack(beforeStat)) and not paddedAfterPrevious then CreateGroupGap(opts, "before" .. name) end
  CreatePaddingOption(opts, name, beforeStat, afterStat, sample)
  if combineStats then
    -- Secondary Stats
    local name, beforeStat, afterStat, sample = L["Secondary Stats"], {"pad", "before", "SecondaryStat"}, {"pad", "after", "SecondaryStat"}, self:MakeColorCode(self.COLORS.GREEN, self.L["Equip:"] .. " " .. format(ITEM_MOD_MANA_REGENERATION, "10"))
    CreatePaddingOption(opts, name, beforeStat, afterStat, sample, true)
  end
  paddedAfterPrevious = self:GetOption(unpack(afterStat))
  if paddedAfterPrevious then CreateGroupGap(opts, "after" .. name) end
  
  -- Enchant
  local name, beforeStat, afterStat, sample = self.L["Enchant"], {"pad", "before", "Enchant"}, {"pad", "after", "Enchant"}, self:MakeColorCode(self.COLORS.GREEN, format(ENCHANTED_TOOLTIP_LINE, self.L["Enchant"]))
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  -- Weapon Enchant
  local name, beforeStat, afterStat, sample = self.L["Weapon Enchantment"], {"pad", "before", "WeaponEnchant"}, {"pad", "after", "WeaponEnchant"}, self:MakeColorCode(self.COLORS.GREEN, format(ENCHANTED_TOOLTIP_LINE, self.L["Weapon Enchantment"]))
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  -- Sockets
  local name, beforeStat, afterStat, sample = L["Sockets"], {"pad", "before", "Socket"}, {"pad", "after", "SocketBonus"}, {self.socketIcon .. " " .. self:MakeColorCode(self.COLORS.GRAY, self.L["Meta Socket"]), self:MakeColorCode(self.COLORS.GRAY, format(ITEM_SOCKET_BONUS, format(ITEM_MOD_MANA_REGENERATION, "10")))}
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  if not combineStats then
    -- Secondary Stats
    local name, beforeStat, afterStat, sample = L["Secondary Stats"], {"pad", "before", "SecondaryStat"}, {"pad", "after", "SecondaryStat"}, self:MakeColorCode(self.COLORS.GREEN, self.L["Equip:"] .. " " .. format(ITEM_MOD_MANA_REGENERATION, "10"))
    paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  end
  
  -- Set Bonus
  local name, beforeStat, afterStat, sample = L["Set List"], {"pad", "before", "SetBonus"}, {"pad", "after", "SetBonus"}, self:MakeColorCode(self.COLORS.GREEN, format(ITEM_SET_BONUS, self.L["Effects"]))
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  -- End
  local name, beforeStat, afterStat, sample = self.L["End"], nil, {"padLastLine"}
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  
  GUI:CreateGroup(opts, GUI:Order(), "------------------", nil, nil, true)
  
  return opts
  end)
  local function OpenOptions() return self:OpenConfig(panel) end
  for _, arg in ipairs{arg1, ...} do
    self.chatArgs[arg] = OpenOptions
  end
end





--  ███╗   ███╗██╗███████╗ ██████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ████╗ ████║██║██╔════╝██╔════╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██╔████╔██║██║███████╗██║         ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║╚██╔╝██║██║╚════██║██║         ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║ ╚═╝ ██║██║███████║╚██████╗    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝     ╚═╝╚═╝╚══════╝ ╚═════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local hearthstoneIcon = select(5, GetItemInfoInstant(Addon.SAMPLE_TITLE_ID))
local sampleDamage   = 20
local sampleVariance = 0.5
local sampleSpeed    = 2.6


function Addon:MakeExtraOptions(categoryName, chatCmd, arg1, ...)
  local title = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), categoryName, chatCmd, arg1)
  local panel = self:CreateOptionsCategory(categoryName, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title)
  
  local disabled -- just in case some other addon clobbers _G.disabled
  
  -- Title
  do
    local stat = "Title"
    
    local defaultText = self.SAMPLE_TITLE_NAME or L["Hearthstone"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, defaultText, self:RewordTitle(defaultText, hearthstoneIcon))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Icon"])
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doIcon", stat}, self.L["Icon"], nil, disabled).width = 0.6
      CreateReset(opts, {"doIcon", stat}, function() self:ResetOption("doIcon", stat) end)
      GUI:CreateNewline(opts)
      
      local disabled = disabled or not self:GetOption("doIcon", stat)
      GUI:CreateToggle(opts, {"iconSizeManual", stat}, self.L["Manual"], nil, disabled).width = 0.6
      local option = GUI:CreateRange(opts, {"iconSize", stat}, L["Icon Size"], nil, 0, 96, 1, disabled or not self:GetOption("iconSizeManual", stat))
      option.width = 0.7
      option.softMin = 8
      option.softMax = 32
      CreateReset(opts, {"iconSize", stat}, function() self:ResetOption("iconSize", stat) end)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"iconSpace", stat}, L["Icon Space"], nil, disabled).width = 0.7
      CreateReset(opts, {"iconSpace", stat}, function() self:ResetOption("iconSpace", stat) end)
    end
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Heroic
  if self.expansionLevel >= self.expansions.wrath then
    local stat = "Heroic"
    
    local samples = {}
    local defaultText = ITEM_HEROIC
    local _, formattedText = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:RewordHeroic(defaultText))
    defaultText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, defaultText)
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Item Level
  local function MakeItemLevelOptions()
    local stat = "ItemLevel"
    
    local samples = {}
    local defaultText = format(self:GetOption("itemLevel", "useShortName") and GARRISON_FOLLOWER_ITEM_LEVEL or ITEM_LEVEL, random(1, 100))
    local _, formattedText = GetFormattedText(stat, self.COLORS.DEFAULT, defaultText, self:RewordItemLevel(defaultText))
    defaultText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, defaultText)
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateReorder(opts, stat, L["Show this line where it was originally positioned in Wrath of The Lich King."])
    
    CreateColor(opts, stat)
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
      
      GUI:CreateToggle(opts, {"itemLevel", "useShortName"}, self.L["Short Name"], format(L["Show %s instead of %s."], self:MakeColorCode(self.COLORS.DEFAULT, self.itemLevelTexts[true].iLvlText), self:MakeColorCode(self.COLORS.DEFAULT, self.itemLevelTexts[false].iLvlText)), disabled)
      CreateReset(opts, {"itemLevel", "useShortName"})
      GUI:CreateNewline(opts)
      
      local disabled = disabled or not Addon:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
      local disabled = disabled or not self:GetOption("doReword", stat)
      local option = GUI:CreateInput(opts, {"reword", stat}, self.L["Custom"], nil, nil, disabled)
      option.width = 0.9
      option.set = function(info, val)        self:SetOption(self:CoverSpecialCharacters(val), "reword", stat) end
      option.get = function(info)      return Addon:UncoverSpecialCharacters(self:GetOption("reword", stat))   end
      CreateReset(opts, {"reword", stat}, function() self:ResetReword(stat) end)
      
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
    end
    
    CreateIcon(opts, stat)
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Show"])
      
      GUI:CreateReverseToggle(opts, {"hide", stat}, self.L["Show Item Level"], nil, disabled)
      CreateReset(opts, {"hide", stat})
      GUI:CreateNewline(opts)
      
      local disabled = self:GetOption("hide", stat)
      GUI:CreateReverseToggle(opts, {"hide", "nonEquipment"}, L["Show Non Equipment"], L["Show item level on items that cannot be equipped by anyone."], disabled)
      CreateReset(opts, {"hide", "nonEquipment"})
    end
  end
  if not self:GetOption("doReorder", "ItemLevel") then MakeItemLevelOptions() end
  
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Races
  local function MakeRequiredRacesOption()
    local stat = "RequiredRaces"
    
    local defaultText = format(ITEM_RACES_ALLOWED, self.MY_RACE_NAME)
    local formattedText = defaultText
    local changed
    if self:GetOption("hide", stat) then
      formattedText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, formattedText)
      changed = true
    else
      formattedText = self:MakeColorCode(self.COLORS.WHITE, formattedText)
    end
    
    local sampleText = self.uselessRaceStrings[1]
    if self:GetOption("hide", stat) or self:GetOption("hide", "uselessRaces") then
      sampleText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, sampleText)
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
    
    CreateReorder(opts, stat, L["Whether to show this line much higher up on the tooltip rather than its usual location."])
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "uselessRaces"}, L["Hide Pointless Lines"], L["Hide lines which list every race."])
      CreateReset(opts, {"hide", "uselessRaces"})
    end
  end
  -- Classes
  local function MakeRequiredClassesOption()
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
        local formattedText = self:ModifyRequiredClasses(defaultText)
        local changed
        if self:GetOption("hide", stat) then
          formattedText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, self:StripColorCode(formattedText))
        end
        changed = formattedText ~= defaultText
        
        if i == 1 then
          GUI:CreateDescription(opts, (changed or self:GetOption("hide", "myClass")) and self.L["Current"] or " ", "small")
        end
        GUI:CreateDescription(opts, changed and formattedText or " ")
        if i == self.sampleRequiredClassesStrings.mine then
          name = formattedText
        end
      end
      
      local defaultText = self.myClassString
      local formattedText = self:ModifyRequiredClasses(defaultText)
      local changed
      if self:GetOption("hide", stat) or self:GetOption("hide", "myClass") then
        formattedText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, self:StripColorCode(formattedText))
      end
      changed = formattedText ~= defaultText
      GUI:CreateDescription(opts, changed and formattedText or " ")
    end
    opts.name = name
    
    CreateReorder(opts, stat, L["Whether to show this line much higher up on the tooltip rather than its usual location."])
    
    do
      local opts = GUI:CreateGroupBox(opts, L["Recolor"])
      
      local disabled = not self:GetOption("allow", "recolor")
      GUI:CreateToggle(opts, {"doRecolor", stat}, self.L["Show Class Color"], nil, disabled).width = 1
      CreateReset(opts, {"doRecolor", stat}, disabled)
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
      
      local disabled = disabled or not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled or not self:GetOption("doIcon", stat)).width = 0.6
      CreateReset(opts, {"reword", stat}, function() self:ResetOption("doReword", stat) end, disabled or not self:GetOption("doIcon", stat))
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"trimPunctuation", stat}, self.L["Minimize"], nil, disabled).width = 0.6
      CreateReset(opts, {"trimPunctuation", stat}, function() self:ResetOption("trimPunctuation", stat) end, disabled)
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Icon"])
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doIcon", stat}, self.L["Icon"], nil, disabled or self:GetOption("doReword", stat)).width = 0.6
      CreateReset(opts, {"doIcon", stat}, function() self:ResetOption("doIcon", stat) end, disabled or self:GetOption("doReword", stat))
      GUI:CreateNewline(opts)
      
      local disabled = disabled or not self:GetOption("doIcon", stat)
      GUI:CreateToggle(opts, {"iconSizeManual", stat}, self.L["Manual"], nil, disabled).width = 0.6
      local option = GUI:CreateRange(opts, {"iconSize", stat}, L["Icon Size"], nil, 0, 96, 1, disabled or not self:GetOption("iconSizeManual", stat))
      option.width = 0.7
      option.softMin = 8
      option.softMax = 32
      CreateReset(opts, {"iconSize", stat}, function() self:ResetOption("iconSize", stat) end)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"iconSpace", stat}, L["Icon Space"], nil, disabled).width = 0.7
      CreateReset(opts, {"iconSpace", stat}, function() self:ResetOption("iconSpace", stat) end)
    end
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "myClass"}, self.L["Me"], L["Hide lines that contain only my class."]).width = 0.6
      CreateReset(opts, {"hide", "myClass"})
    end
  end
  -- Level
  local function MakeRequiredLevelOption()
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
        local changed = self:GetOption("hide", stat) or self:GetOption("hide", "requiredLevelMet") and level <= self.MY_LEVEL or self:GetOption("hide", "requiredLevelMax") and UnitLevel"player" == self.MAX_LEVEL and level == self.MAX_LEVEL
        if changed then
          formattedText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, strGsub(formattedText, "|c%x%x%x%x%x%x%x%x", ""))
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
    
    CreateReorder(opts, stat, L["Whether to show this line much higher up on the tooltip rather than its usual location."])
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "requiredLevelMet"}, format(self:ChainGsub(self.L["|cff000000%s (low level)|r"], {"|c%x%x%x%x%x%x%x%x", "|r", ""}), format(self.L["Level %d"], sample1)), L["Hide white level requirements."])
      CreateReset(opts, {"hide", "requiredLevelMet"})
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "requiredLevelMax"}, self.L["Max Level"], L["Hide maximum level requirements when you are the maximum level."])
      CreateReset(opts, {"hide", "requiredLevelMax"})
    end
  end
  
  if self:GetOption("doReorder", "RequiredRaces")   then MakeRequiredRacesOption() end
  if self:GetOption("doReorder", "RequiredClasses") then MakeRequiredClassesOption() end
  if self:GetOption("doReorder", "RequiredLevel")   then MakeRequiredLevelOption() end
  if self:GetOption("doReorder", "RequiredRaces") or self:GetOption("doReorder", "RequiredClasses") or self:GetOption("doReorder", "RequiredLevel") then
    GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  end
  
  -- Binding
  for _, data in ipairs{
    {"AlreadyBound",   ITEM_SOULBOUND},
    {"CharacterBound", ITEM_BIND_ON_PICKUP},
    {"AccountBound",   ITEM_BIND_TO_ACCOUNT, ITEM_BIND_TO_BNETACCOUNT},
    {"Tradeable",      ITEM_BIND_ON_EQUIP,   ITEM_BIND_ON_USE},
  } do
    local stat = data[1]
    
    local samples = {}
    for i = 2, #data do
      local defaultText = data[i]
      local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, defaultText, self:RewordBinding(defaultText, stat))
      tinsert(samples, {defaultText, formattedText})
    end
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Refundable
  local function MakeRefundableOption()
    local stat = "Refundable"
    
    do
      local defaultText = format(REFUND_TIME_REMAINING, format(INT_SPELL_DURATION_HOURS, 2))
      local formattedText = Addon:RewordRefundable(defaultText)
      local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.SKY_BLUE, defaultText, formattedText)
      
      local opts = GUI:CreateGroup(opts, stat, formattedText)
      
      CreateTitle(opts, defaultText, formattedText, changed)
      
      CreateReorder(opts, stat)
      
      CreateColor(opts, stat)
      
      -- Reword
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
        
        local disabled = not Addon:GetOption("allow", "reword")
        GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
        CreateReset(opts, {"doReword", stat}, function() self:ResetOption("doReword", stat) end)
      end
      
      CreateHide(opts, stat)
    end
    
    if self:GetOption("doReorder", "Refundable") ~= self:GetOption("doReorder", "SoulboundTradeable") then
      GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
    end
  end
  -- Soulbound Tradeable
  local function MakeTradeableOption()
    local stat = "SoulboundTradeable"
    
    do
      local defaultText = format(BIND_TRADE_TIME_REMAINING, format(INT_SPELL_DURATION_HOURS, 2))
      local formattedText = Addon:RewordTradeable(defaultText)
      local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.SKY_BLUE, defaultText, formattedText)
      
      local opts = GUI:CreateGroup(opts, stat, formattedText)
      
      CreateTitle(opts, defaultText, formattedText, changed)
      
      CreateReorder(opts, stat)
      
      CreateColor(opts, stat)
      
      -- Reword
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
        
        local disabled = not Addon:GetOption("allow", "reword")
        GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
        CreateReset(opts, {"doReword", stat}, function() self:ResetOption("doReword", stat) end)
      end
      
      CreateHide(opts, stat)
    end
    GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  end
  if self:GetOption("doReorder", "Refundable")         then MakeRefundableOption() end
  if self:GetOption("doReorder", "SoulboundTradeable") then MakeTradeableOption() end
  
  -- Trainable
  do
    local stat = "Trainable"
    
    local defaultText = self.L["Weapon"]
    local _, name = GetFormattedText(stat, self.COLORS.RED, L["Trainable Equipment"], L["Trainable Equipment"])
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.RED, defaultText, defaultText)
    
    local opts = GUI:CreateGroup(opts, stat, name, L["Equipment that a trainer can teach you to wear."])
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Weapon Damage
  do
    local stat = "Damage"
    
    local defaultText = format(DAMAGE_TEMPLATE, sampleDamage * (1-sampleVariance), sampleDamage * (1+sampleVariance))
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, defaultText, self:ModifyWeaponDamage(defaultText, sampleDamage, 1))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, self.L["Weapon Damage"])
    
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
      GUI:CreateToggle(opts, {"damage", "variancePercent"}, L["Show Percent"], nil, disabled or not self:GetOption("damage", "showVariance")).width = 1.5
      CreateReset(opts, {"damage", "variancePercent"})
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
      formattedText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, formattedTextOriginal)
      changed = true
      disabled = true
    end
    
    local opts = GUI:CreateGroup(opts, stat, "  " .. (formattedText), self.L["Speed"], nil, disabled)
    
    do
      local opts = CreateTitle(opts, defaultText, formattedText, changed, 1)
      
      -- Test
      local option = GUI:CreateRange(opts, {"sampleSpeed"}, L["Test"], nil, self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
      option.set = function(info, val)        sampleSpeed = val end
      option.get = function(info)      return sampleSpeed       end
    end
    
    CreateColor(opts, stat, disabled)
    
    CreateReword(opts, stat, disabled)
    
    do -- Precision
      local opts = GUI:CreateGroupBox(opts, L["Precision"])
      
      GUI:CreateRange(opts, {"precision", stat}, L["Precision"], nil, 0, 5, 1, disabled)
      CreateReset(opts, {"precision", stat}, function() self:ResetOption("precision", stat) end)
    end
    
    CreateHide(opts, stat, disabled)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Weapon DPS
  local sampleDPS = strGsub(format("%.1f", sampleDamage / sampleSpeed), "%.", DECIMAL_SEPERATOR)
  do
    local stat = "DamagePerSecond"
    
    local defaultText = format(DPS_TEMPLATE, sampleDPS)
    local formattedText = self:ModifyWeaponDamagePerSecond(defaultText)
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
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, self.L["Damage Per Second"])
    
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
      name     = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, defaultText == "" and L["Speed Bar"] or formattedText)
      disabled = true
    end
    
    local opts = GUI:CreateGroup(opts, stat, "  " .. (name or formattedText), L["Speed Bar"], nil, disabled)
    
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
        
        do
          local defaultSpeedString = speedString
          local defaultText = speedStringFull
          local formattedText = self:ModifyWeaponSpeed(defaultText, sampleSpeed, defaultSpeedString)
          
          local color = self:GetOption("color", "Speed")
          if self:GetOption("allow", "recolor") and self:GetOption("doRecolor", "Speed") and color ~= self.COLORS.WHITE then
            formattedText = self:MakeColorCode(color, formattedText)
          else
            formattedText = self:MakeColorCode(self.COLORS.WHITE, formattedText)
          end
          GUI:CreateExecute(opts, {"goto", "Speed"}, formattedText, nil, function() GUI:SwapLinks("Speedbar", "Speed") end)
          GUI:CreateNewline(opts)
        end
        
        GUI:CreateToggle(opts, {"speedBar", "speedPrefix"}, L["Show Speed"], nil, disabled)
        CreateReset(opts, {"speedBar", "speedPrefix"})
      end
      
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Settings"])
        
        local option = GUI:CreateRange(opts, {"speedBar", "min"}, self.L["Minimum"], L["Fastest speed on the speed bar."], self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
        option.set = function(info, val) self:SetOption(val, "speedBar", "min") self:SetOption(mathMax(val, self:GetOption("speedBar", "max")), "speedBar", "max") end
        local option = GUI:CreateRange(opts, {"speedBar", "max"}, self.L["Maximum"], L["Slowest speed on the speed bar."], self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
        option.set = function(info, val) self:SetOption(val, "speedBar", "max") self:SetOption(mathMin(val, self:GetOption("speedBar", "min")), "speedBar", "min") end
        GUI:CreateNewline(opts)
        local option = GUI:CreateRange(opts, {"speedBar", "size"}, self.L["Frame Width"], L["Width of the speed bar."], 1, 1000, 1, disabled)
        option.softMin = 10
        option.softMax = 50
        CreateReset(opts, {"speedBar", "size"}, func)
      end
      
      CreateHide(opts, stat)
    end
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Enchant
  do
    local stat = "Enchant"
    
    local defaultText = self.L["Enchant"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:ModifyEnchantment(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, L["This applies to most enchantments."])
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- EnchantOnUse
  local function MakeEnchantOnUseOptions()
    local stat = "EnchantOnUse"
    
    local originalColor = self.COLORS.GREEN
    local defaultText = self.L["Use:"] .. " " .. self.L["Enchant"]
    local prefixModifiedText = self:ModifyPrefix(defaultText, ITEM_SPELL_TRIGGER_ONUSE)
    local _, prefixFormattedText = GetFormattedText("Use", originalColor, defaultText, prefixModifiedText)
    local formattedText = self:ModifyOnUseEnchantment(prefixModifiedText)
    
    local color = self:GetOption("color", "Use")
    if self:GetOption("hide", stat) or self:GetOption("hide", "Use") then
      formattedText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, formattedText)
    elseif self:GetOption("allow", "recolor") and self:GetOption("doRecolor", "Use") and color ~= originalColor then
      formattedText = self:MakeColorCode(color, formattedText)
    else
      formattedText = self:MakeColorCode(originalColor, formattedText)
    end
    local defaultText = self:MakeColorCode(originalColor, defaultText)
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, L["This applies to enchantments that add an On Use effect to the item."])
    
    CreateSamples(opts, {{defaultText, formattedText}})
    
    GUI:CreateNewline(opts)
    GUI:CreateExecute(opts, {"goto", "Use"}, prefixFormattedText, nil, function() GUI:SwapLinks("EnchantOnUse", "Use") end)
    GUI:CreateNewline(opts)
    
    CreateReorder(opts, stat, L["Whether to position this line with other On Use effects rather than the normal enchantment location."])
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  if not self:GetOption("doReorder", "EnchantOnUse") then MakeEnchantOnUseOptions() end
  
  -- Weapon Enchant
  do
    local stat = "WeaponEnchant"
    
    local defaultText = self.L["Weapon Enchantment"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:ModifyWeaponEnchantment(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, L["This applies to temporary weapon enchantments."])
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Socket Hint
  local function MakeSocketHintOptions()
    do
      local stat = "SocketHint"
      
      local defaultText = ITEM_SOCKETABLE
      local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:RewordSocketHint(defaultText))
      
      local opts = GUI:CreateGroup(opts, stat, formattedText)
      
      CreateTitle(opts, defaultText, formattedText, changed)
      
      CreateReorder(opts, stat, L["Move this line to the socket bonus."])
      
      CreateColor(opts, stat)
      
      CreateReword(opts, stat)
      
      CreateHide(opts, stat)
    end
    GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  end
  if self:GetOption("doReorder", "SocketHint") then MakeSocketHintOptions() end
  
  -- Durability
  do
    local stat = "Durability"
    
    local defaultDurability, defaultDurabilityFull = 5, 50
    local defaultText = format(DURABILITY_TEMPLATE, defaultDurability, defaultDurabilityFull)
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.WHITE, defaultText, self:ModifyDurability(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, nil, nil, disabled)
      
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateReword(opts, stat)
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
      GUI:CreateNewline(opts)
      
      local disabled = false
      GUI:CreateToggle(opts, {"durability", "showCur"}  , L["Show Current"], nil, disabled or not self:GetOption("durability", "showPercent"))
      CreateReset(opts, {"durability", "showCur"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"durability", "showPercent"}, L["Show Percent"], nil, disabled or not self:GetOption("durability", "showCur"))
      CreateReset(opts, {"durability", "showPercent"})
    end
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  
  if not self:GetOption("doReorder", "RequiredRaces")   then MakeRequiredRacesOption() end
  if not self:GetOption("doReorder", "RequiredClasses") then MakeRequiredClassesOption() end
  if not self:GetOption("doReorder", "RequiredLevel")   then MakeRequiredLevelOption() end
  if not self:GetOption("doReorder", "RequiredRaces") or not self:GetOption("doReorder", "RequiredClasses") or not self:GetOption("doReorder", "RequiredLevel") then
    GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  end
  
  if self:GetOption("doReorder", "ItemLevel") then MakeItemLevelOptions() GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  -- Prefixes
  for _, data in ipairs{
    {"Equip",       ITEM_SPELL_TRIGGER_ONEQUIP},
    {"ChanceOnHit", ITEM_SPELL_TRIGGER_ONPROC},
    {"Use",         ITEM_SPELL_TRIGGER_ONUSE},
  } do
    local stat   = data[1]
    local prefix = data[2]
    
    local defaultText = format("%s %s", prefix, self.L["Effects"])
    local defaultText, formattedText, changed = GetFormattedText(stat, self.COLORS.GREEN, defaultText, self:ModifyPrefix(defaultText, prefix))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, prefix)
    
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
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  if self:GetOption("doReorder", "EnchantOnUse") then MakeEnchantOnUseOptions() GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  -- Made By
  do
    local stat = "MadeBy"
    
    local samples = {}
    local secondName = UnitExists"target" and UnitName"target" or nil
    secondName = secondName and secondName ~= self.MY_NAME and secondName or self.SAMPLE_NAMES[random(#self.SAMPLE_NAMES)]
    for _, name in ipairs{self.MY_NAME, secondName} do
      for _, pattern in ipairs{self.ITEM_CREATED_BY, self.ITEM_WRAPPED_BY, ITEM_WRITTEN_BY} do
        local defaultText = format(pattern, name)
        
        local formattedText = defaultText
        local originalColor = self.COLORS.GREEN
        local color = self:GetOption("color", stat)
        if self:ShouldHideMadeBy(defaultText, pattern) then
          formattedText = self.stealthIcon .. self:MakeColorCode(self.COLORS.GRAY, formattedText)
        elseif self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and color ~= originalColor then
          formattedText = self:MakeColorCode(color, formattedText)
        else
          formattedText = self:MakeColorCode(originalColor, formattedText)
        end
        defaultText = self:MakeColorCode(originalColor, defaultText)
        
        tinsert(samples, {defaultText, formattedText})
      end
    end
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      local disabled = self:GetOption("hide", stat)
      GUI:CreateToggle(opts, {"hide", "MadeByMe"}, self.L["Me"], L["Made by myself."], disabled).width = 0.6
      CreateReset(opts, {"hide", "MadeByMe"})
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "MadeByOther"}, self.L["Other"], L["Made by others."], disabled).width = 0.6
      CreateReset(opts, {"hide", "MadeByOther"})
    end
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  if not self:GetOption("doReorder", "SocketHint") then MakeSocketHintOptions() end
  
  if not self:GetOption("doReorder", "Refundable")         then MakeRefundableOption() end
  if not self:GetOption("doReorder", "SoulboundTradeable") then MakeTradeableOption() end
  
  -- Misc locale rewording
  if #self:GetExtraReplacements() > 0 then
    local stat = "Miscellaneous"
    local name = self:MakeColorCode(self.COLORS.WHITE, self.L["Miscellaneous"])
    
    local opts = GUI:CreateGroup(opts, stat, name, L["Reword some various small things, such as mana potions and speed enchantments. This option is different for each locale."])
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Miscellaneous"])
      
      -- Reword
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doReword", stat}, self.L["Rename"], L["Reword some various small things, such as mana potions and speed enchantments. This option is different for each locale."], disabled).width = 0.6
      CreateReset(opts, {"doReword", stat})
    end
  end
  
  return opts
  end)
  local function OpenOptions() return self:OpenConfig(panel) end
  for _, arg in ipairs{arg1, ...} do
    self.chatArgs[arg] = OpenOptions
  end
end





--  ██████╗ ███████╗███████╗███████╗████████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔════╝██╔════╝██╔════╝╚══██╔══╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██████╔╝█████╗  ███████╗█████╗     ██║       ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══██╗██╔══╝  ╚════██║██╔══╝     ██║       ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║  ██║███████╗███████║███████╗   ██║       ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝        ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

function Addon:MakeResetOptions(categoryName, chatCmd, arg1, ...)
  local title = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), categoryName, chatCmd, arg1)
  local panel = self:CreateOptionsCategory(categoryName, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title)
  
  GUI:CreateDivider(opts)
  
  for _, v in ipairs{
    {self.L["All"]    , function() self:ResetProfile()     end},
    {L["Order"]       , function() self:ResetOrder()       end},
    {self.L["Color"]  , function() self:ResetOption"color" self:ResetOption"doRecolor" end},
    {self.L["Rename"] , function() self:ResetReword()      self:ResetOption"doReword" end},
    {self.L["Icon"]   , function() self:ResetOption"icon"  self:ResetOption"doIcon" self:ResetOption"iconSizeManual" self:ResetOption"iconSize" self:ResetOption"iconSpace" end},
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
  local function OpenOptions() return self:OpenConfig(panel) end
  for _, arg in ipairs{arg1, ...} do
    self.chatArgs[arg] = OpenOptions
  end
end





--  ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗      ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝     ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝      ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

function Addon:MakeDebugOptions(categoryName, chatCmd, arg1, ...)
  local title = format("%s v%s > %s  (/%s %s)", ADDON_NAME, tostring(self:GetOption"version"), categoryName, chatCmd, arg1)
  local panel = self:CreateOptionsCategory(categoryName, function()
  
  local GUI = self.GUI:ResetOrder()
  local opts = GUI:CreateGroupTop(title, "tab")
  
  -- Enable
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), self.L["Enable"])
    
    do
      local opts = GUI:CreateGroupBox(opts, "Debug")
      GUI:CreateToggle(opts, {"debug"}, self.L["Enable"])
      GUI:CreateNewline(opts)
      GUI:CreateExecute(opts, "reload", self.L["Reload UI"], nil, ReloadUI)
    end
  end
  
  -- Debug View
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "View")
    
    local disabled = not self:GetOption"debug"
    
    do
      local opts = GUI:CreateGroupBox(opts, "Suppress All")
      
      GUI:CreateToggle(opts, {"debugView", "suppressAll"}, self.L["Hide"], nil, disabled).width = 2
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Tooltips")
      
      local disabled = disabled or self:GetOption("debugView", "suppressAll")
      
      GUI:CreateToggle(opts, {"debugView", "tooltipLineNumbers"}, "Tooltip Line Numbers", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugView", "paddingConversionSuccesses"}, "Padding Conversion Successes", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugView", "paddingConversionFailures"}, "Padding Conversion Failures", nil, disabled).width = 2
    end
  end
  
  -- Debug Output
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Output")
    
    local disabled = not self:GetOption"debug"
    
    do
      local opts = GUI:CreateGroupBox(opts, "Suppress All")
      
      GUI:CreateToggle(opts, {"debugOutput", "suppressAll"}, self.debugPrefix .. " " .. self.L["Hide messages like this one."], nil, disabled).width = 2
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Message Types")
      
      local disabled = disabled or self:GetOption("debugOutput", "suppressAll")
      
      GUI:CreateToggle(opts, {"debugOutput", "luaError"}, "Lua Error", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "tooltipMethodHook"}, "Tooltip Method Hook", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "tooltipOnSetItemHook"}, "Tooltip tooltipOnSetItem Hook", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "tooltipHookFail"}, "Tooltip Hook Failure", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "initialTooltipData"}, "Initial Tooltip Data", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "finalTooltipData"}, "Final Tooltip Data", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "constructorCreated"}, "Constructor Created", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "constructorCached"}, "Constructor Cached", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "constructorWiped"}, "Constructor Wiped", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "constructorValidationFail"}, "Constructor Validation Failure", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "constructorLineMove"}, "Constructor Moving Line", nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "InterfaceOptionsFrameFix"}, "Interface Options Patch", nil, disabled).width = 2
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Tooltips")
      
      GUI:CreateToggle(opts, {"debugOutput", "GameTooltip"}, "GameTooltip", nil, disabled)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "ItemRefTooltip"}, "ItemRefTooltip", nil, disabled)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "ShoppingTooltip1"}, "ShoppingTooltip1", nil, disabled)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugOutput", "ShoppingTooltip2"}, "ShoppingTooltip2", nil, disabled)
      GUI:CreateNewline(opts)
      GUI:CreateExecute(opts, "reload", self.L["Reload UI"], nil, ReloadUI)
    end
  end
  
  -- Caches
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Cache")
    
    local group
    
    do
      local opts = GUI:CreateGroupBox(opts, "Cache")
      group = opts
      
      GUI:CreateToggle(opts, {"cache", "enabled"}, self.L["Enable"])
      CreateReset(opts, {"cache", "enabled"})
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"constructor", "alwaysDestruct"}, "Always Destruct", "Undo tooltip modifications after they're complete.")
      CreateReset(opts, {"constructor", "alwaysDestruct"})
    end
    
    for _, data in ipairs{
      {"Text Rewords"     , {"cache", "text"}       , "WipeTextCache"       , "GetTextCacheSize"},
      {"Stat Recognitions", {"cache", "stat"}       , "WipeStatCache"       , "GetStatCacheSize"},
      {"Constructors"     , {"cache", "constructor"}, "WipeConstructorCache", "GetConstructorCacheSize"},
    } do
      local opts = GUI:CreateGroupBox(opts, data[1] .. ": " .. self[data[4]](self))
      group = opts
      
      local disabled = not self:GetOption("cache", "enabled")
      GUI:CreateToggle(opts, data[2], self.L["Enable"], nil, disabled)
      CreateReset(opts, data[2])
      GUI:CreateExecute(opts, {"wipe", unpack(data[2])}, self.L["Clear Cache"], nil, function() self[data[3]](self) end, disabled).width = 0.6
    end
    
    do
      local opts = group
      GUI:CreateDivider(opts)
      
      local disabled = not self:GetOption("cache", "enabled") or not self:GetOption("cache", "constructor")
      
      GUI:CreateToggle(opts, {"constructor", "doValidation"}, "Do Validation", "Perform constructor validation checks.", disabled)
      CreateReset(opts, {"constructor", "doValidation"})
      GUI:CreateNewline(opts)
      
      local option = GUI:CreateRange(opts, {"cache", "constructorWipeDelay"}, "Wipe Delay", "Time in seconds without constructor being requested before it's cleared.", 0, 1000000, 0.001, disabled)
      option.softMax = 60
      option.bigStep = 1
      CreateReset(opts, {"cache", "constructorWipeDelay"})
      GUI:CreateNewline(opts)
      
      local option = GUI:CreateRange(opts, {"cache", "constructorMinSeenCount"}, "Minimum Seen Count", "Minimum number of times constructor must be requested before it can be cached.", 0, 1000000, 1, disabled)
      option.softMax = 50
      CreateReset(opts, {"cache", "constructorMinSeenCount"})
      GUI:CreateNewline(opts)
      
      local option = GUI:CreateRange(opts, {"cache", "constructorMinSeenTime"}, "Minimum Seen Time", "Minimum time in seconds since constructor was first requested before it can be cached.", 0, 1000000, 0.001, disabled)
      option.softMax = 10
      option.bigStep = 0.25
      CreateReset(opts, {"cache", "constructorMinSeenTime"})
    end
  end
  
  -- Throttles
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Throttles")
    
    for _, frameName in ipairs{
      "AuctionFrame",
      "InspectFrame",
      "MailFrame",
      "TradeSkillFrame",
    } do
      local opts = GUI:CreateGroupBox(opts, frameName)
      
      GUI:CreateToggle(opts, {"throttle", frameName}, "Throttle " .. frameName, "Throttle tooltips updates from this frame so they use the regular tooltip update interval.")
    end
  end
  
  -- Fixes
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Fixes")
    
    do
      local opts = GUI:CreateGroupBox(opts, "Options Menu")
      
      GUI:CreateToggle(opts, {"fix", "InterfaceOptionsFrameForMe"}, "Fix Category Opening For Me", "Fix a bug with Interface Options so that it can be opened to this addon when scrolling would be required.").width = 2
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"fix", "InterfaceOptionsFrameForAll"}, "Fix Category Opening For All", "Fix a bug with Interface Options so that it can be opened to a category that isn't visible without scrolling.").width = 2
    end
  end
  
  return opts
  end)
  local function OpenOptions() return self:OpenConfig(panel) end
  for _, arg in ipairs{arg1, ...} do
    self.chatArgs[arg] = OpenOptions
  end
end



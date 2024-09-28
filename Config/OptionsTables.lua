
local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)



local strGmatch = string.gmatch
local strGsub   = string.gsub
local strByte   = string.byte

local tinsert   = table.insert
local tblConcat = table.concat

local mathMin   = math.min
local mathMax   = math.max










--  ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
--  ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
--  ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
--  ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
--  ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
--  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝


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

local OpenColorblindOptions
Addon:xpcall(function()
  if SettingsPanel then
    for _, category in ipairs(SettingsPanel:GetCategoryList().allCategories) do
      if category.categorySet == 1 and category:GetName() == self.L["Colorblind Mode"] then
        local id = category:GetID()
        OpenColorblindOptions = function() Settings.OpenToCategory(category:GetID()) self.AceConfigDialog:Close(ADDON_NAME) end
        break
      end
    end
  elseif InterfaceOptionsColorblindPanel then
    OpenColorblindOptions = function()
      InterfaceOptionsFrame_OpenToCategory(InterfaceOptionsColorblindPanel)
    end
  end
end)

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
    color = Addon.colors.GRAY
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
    formattedText = Addon.stealthIcon .. Addon:MakeColorCode(Addon.colors.GRAY, Addon:StripColorCode(formattedText))
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
  GUI:CreateReset(opts, {"color", stat}, function() self:ResetColor(stat) end)
  
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
  option.get = function(info)      return Addon:UncoverSpecialCharacters(self:GetOption("reword", stat))   end
  option.set = function(info, val)        self:SetOption(self:CoverSpecialCharacters(val), "reword", stat) end
  GUI:CreateReset(opts, {"reword", stat}, function() self:ResetReword(stat) end)
  
  return opts
end
local function CreateThousandsSeparator(opts, stat, disabled)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Formatting"])
  
  local disabled = disabled or not self:GetOption("allow", "reword")
  GUI:CreateDropdown(opts, {"separateThousands", stat}, self.L["Formatting"], self.L["Formatting"], {[true] = self:ToFormattedNumber(10000), [false] = self:ToFormattedNumber(10000, nil, nil, "")}, {true, false}, disabled).width = 0.5
  GUI:CreateReset(opts, {"separateThousands", stat}, function() self:ResetOption("separateThousands", stat) end)
  
  return opts
end
local function CreateHide(opts, stat, disabled)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Hide"])
  
  GUI:CreateToggle(opts, {"hide", stat}, self.L["Hide"], nil, disabled).width = 0.6
  GUI:CreateReset(opts, {"hide", stat})
  
  return opts
end
local function CreateShow(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Show"])
  
  GUI:CreateReverseToggle(opts, {"hide", stat}, self.L["Show"], nil, disabled).width = 0.6
  GUI:CreateReset(opts, {"hide", stat})
  
  return opts
end
local icons         = Addon:Map(Addon.iconPaths, function(v) return Addon:MakeIcon(v, 16) end)
local iconsDropdown = Addon:Map(icons, nil, function(v) return v end)
local function CreateIcon(opts, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, self.L["Icon"])
  
  local disabled = not self:GetOption("allow", "reword")
  GUI:CreateToggle(opts, {"doIcon", stat}, self.L["Icon"], nil, disabled).width = 0.6
  local option = GUI:CreateDropdown(opts, {"icon", stat}, self.L["Choose an Icon:"], nil, iconsDropdown, icons, disabled or not self:GetOption("doIcon", stat))
  option.width = 0.7
  option.get   = function(info)    return self:MakeIcon(self:GetOption("icon", stat), 16) end
  option.set   = function(info, v) self:SetOption(self:UnmakeIcon(v), "icon", stat)   end
  GUI:CreateReset(opts, {"icon", stat}, function() self:ResetIcon(stat) end)
  GUI:CreateNewline(opts)
  
  local disabled = disabled or not self:GetOption("doIcon", stat)
  GUI:CreateToggle(opts, {"iconSizeManual", stat}, self.L["Manual"], nil, disabled).width = 0.6
  local option = GUI:CreateRange(opts, {"iconSize", stat}, L["Icon Size"], nil, 0, 96, 1, disabled or not self:GetOption("iconSizeManual", stat))
  option.width = 0.7
  option.softMin = 8
  option.softMax = 32
  GUI:CreateReset(opts, {"iconSize", stat}, function() self:ResetIconSize(stat) end)
  GUI:CreateNewline(opts)
  
  GUI:CreateToggle(opts, {"iconSpace", stat}, L["Icon Space"], nil, disabled).width = 0.7
  GUI:CreateReset(opts, {"iconSpace", stat}, function() self:ResetOption("iconSpace", stat) end)
  
  return opts
end
local function CreateReorder(opts, stat, desc)
  local self = Addon
  local GUI  = self.GUI
  
  local opts = GUI:CreateGroupBox(opts, L["Reorder"])
  
  local disabled = not Addon:GetOption("allow", "reorder")
  
  GUI:CreateToggle(opts, {"doReorder", stat}, self.L["Enable"], desc, disabled).width = 0.6
  GUI:CreateReset(opts, {"doReorder", stat}, function() self:ResetOption("doReorder", stat) end)
  
  return opts
end









--   ██████╗ ███████╗███╗   ██╗███████╗██████╗  █████╗ ██╗          ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔══██╗██╔══██╗██║         ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║  ███╗█████╗  ██╔██╗ ██║█████╗  ██████╔╝███████║██║         ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ██╔══██╗██╔══██║██║         ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ╚██████╔╝███████╗██║ ╚████║███████╗██║  ██║██║  ██║███████╗    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--   ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeGeneralOptions(opts)
  local self = Addon
  local GUI = self.GUI
  local opts = GUI:CreateGroup(opts, ADDON_NAME, ADDON_NAME, nil, "tab")
  
  do
    local opts = GUI:CreateGroup(opts, 1, self.L["Enable"], nil, "tab")
    
    do
      local opts = GUI:CreateGroupBox(opts, ADDON_NAME)
      
      GUI:CreateToggle(opts, {"enabled"}, self.L["Enabled"], L["Whether to modify tooltips."])
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Modifiers:"])
      
      GUI:CreateDropdown(opts, {"invertMode"}, self:GetOption"enabled" and self.L["Disable"] or self.L["Enable"], L["Reverse behavior when modifier keys are held."], {none = self.L["never"], any = self.L["any"], all = self.L["all"]}, {"none", "any", "all"}).width = 0.7
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
      GUI:CreateReset(opts, {"allow", "reorder"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"allow", "reword"} , self.L["Rename"], L["Allow or prohibit all rewording."])
      GUI:CreateReset(opts, {"allow", "reword"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"allow", "recolor"}, L["Recolor"], L["Allow or prohibit all recoloring."])
      GUI:CreateReset(opts, {"allow", "recolor"})
      GUI:CreateNewline(opts)
      
      GUI:SetDBType"Global"
      GUI:CreateToggle(opts, {"cache", "enabled"}, L["Cache"], L["Greatly speeds up processing, but may occasionally cause tooltip formatting issues."] .. "|n|n" .. Addon:MakeColorCode(Addon.colors.RED, format(L["If a tooltip appears to be formatted incorrectly, hide it for %d seconds to clear the cache."], Addon:GetGlobalOption("cache", "constructorWipeDelay"))))
      GUI:CreateReset(opts, {"cache", "enabled"})
      GUI:ResetDBType()
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Formatting"])
      
      local samples = {}
      for _, data in ipairs{
        {1000,        0},
        {1000000.01,  2},
        {1000.0001,   4},
        {-10.0000001, 7},
      } do
        local number, numDecimalPlaces = unpack(data)
        local sample1 = self:ToFormattedNumber(number, numDecimalPlaces, self.L["."], self.L[","], false, false)
        local sample2 = self:ToFormattedNumber(number, numDecimalPlaces)
        tinsert(samples, {sample1, sample2})
      end
      
      CreateSamples(opts, samples)
      
      do
        GUI:CreateToggle(opts, {"overwriteSeparator", "."}, self.L["Rename"], L["Use custom decimal separator."])
        local option = GUI:CreateInput(opts, {"separator", "."}, self.L["."], nil, nil, not self:GetOption("overwriteSeparator", "."))
        option.set = function(info, v)
          v = strGsub(v, "[0-9]", "")
          if v == "" then
            v = self.L["."]
          end
          self:SetOption(v, "separator", ".")
        end
        
        GUI:CreateReset(opts, {"separator", "."})
        GUI:CreateNewline(opts)
      end
      do
        GUI:CreateToggle(opts, {"overwriteSeparator", ","}, self.L["Rename"], L["Use custom thousands separator."])
        local option = GUI:CreateInput(opts, {"separator", ","}, self.L[","], nil, nil, not self:GetOption("overwriteSeparator", ","))
        option.set = function(info, v)
          v = strGsub(v, "[0-9]", "")
          self:SetOption(v, "separator", ",")
        end
        
        GUI:CreateReset(opts, {"separator", ","})
        GUI:CreateNewline(opts)
      end
      
      GUI:CreateToggle(opts, {"separator", "fourDigitException"}, L["Four Digit Exception"], L["Don't group digits if there are four or fewer on that side of the decimal marker."] .. "|n|n" .. L["Recommended by NIST (National Institute of Standards and Technology)."])
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"separator", "separateDecimals"}, L["Group decimal digits"], L["Group digits to the right of the decimal marker."] .. "|n|n" .. L["Recommended by NIST (National Institute of Standards and Technology)."])
      GUI:CreateNewline(opts)
    end
  end
  
  return opts
end



--  ███████╗████████╗ █████╗ ████████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ███████╗   ██║   ███████║   ██║       ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ╚════██║   ██║   ██╔══██║   ██║       ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ███████║   ██║   ██║  ██║   ██║       ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝        ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local percentStats = Addon:MakeLookupTable{"Dodge Rating", "Parry Rating", "Block Rating", "Hit Rating", "Critical Strike Rating", "Physical Hit Rating", "Physical Critical Strike Rating", "Spell Hit Rating", "Spell Critical Strike Rating"}
local sampleNumber = Addon:Switch(Addon.expansionLevel, {
  [Addon.expansions.cata] = 1000,
  [Addon.expansions.wrath] = 100,
  [Addon.expansions.tbc] = 10,
  [Addon.expansions.era] = 10,
}, 10)
local function CreateStatOption(opts, i, stat)
  local self = Addon
  local GUI  = self.GUI
  
  local percent = Addon.isEra and percentStats[stat] and "%" or ""
  
  local defaultText = GetDefaultStatText(sampleNumber .. percent, stat)
  local formattedText = GetFormattedStatText(sampleNumber .. percent, stat)
  
  local opts = GUI:CreateGroup(opts, stat, formattedText, GetStatNormalName(stat), "tab")
  
  do
    local opts = CreateTitle(opts, defaultText, formattedText, defaultText ~= formattedText, 1)
    
    -- Test
    local option = GUI:CreateRange(opts, {"sampleNumber"}, L["Test"], nil, -1000000, 1000000, 1)
    option.softMin = 0
    option.softMax = 1000
    option.get = function(info)      return sampleNumber       end
    option.set = function(info, val)        sampleNumber = val end
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
  
  CreateThousandsSeparator(opts, stat)
  
  do -- Multiply
    local opts = GUI:CreateGroupBox(opts, L["Multiply"])
    
    local option = GUI:CreateRange(opts, {"mod", stat}, L["Multiplier"], nil, 0, 1000, nil, disabled)
    option.width     = 1.5
    option.softMax   = 12
    option.bigStep   = 0.1
    option.isPercent = true
    GUI:CreateReset(opts, {"mod", stat}, function() self:ResetMod(stat) end)
    GUI:CreateNewline(opts)
    
    GUI:CreateRange(opts, {"precision", stat}, L["Precision"], L["Number of decimal places."], 0, 5, 1, disabled).width = 1.5
    GUI:CreateReset(opts, {"precision", stat}, function() self:ResetPrecision(stat) end)
  end
  
  CreateHide(opts, stat)
end


local function MakeStatsOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  local opts = GUI:CreateGroup(opts, categoryName, categoryName, nil, "tree")
  
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
    return GUI:CreateToggle(opts, afterStat, L["Space Below"], L["Place an empty line at the end of the tooltip, before other addons add lines."], disabled)
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


local function MakePaddingOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  local opts = GUI:CreateGroup(opts, categoryName, categoryName, nil, "tree")
  
  CreateCombineStatsOption(opts)
  Addon.GUI:CreateToggle(opts, {"pad", "before", "BonusEffect"}, L["Add Space Above Bonus Effects"], L["Bonus effects are secondary effects that aren't just adding a stat (example: Hearthstone)."]).width = 2
  
  local paddedAfterPrevious = false
  local combineStats = self:GetOption("allow", "reorder") and self:GetOption"combineStats"
  
  GUI:CreateGroup(opts, GUI:Order(), "------------------", nil, nil, true)
  
  -- Base Stats
  local name, beforeStat, afterStat, sample = self.L["Base Stats"], {"pad", "before", "BaseStat"}, {"pad", "after", "BaseStat"}, format(self.L["%c%d Stamina"], strByte"+", 10)
  if beforeStat and self:GetOption(unpack(beforeStat)) and not paddedAfterPrevious then CreateGroupGap(opts, "before" .. name) end
  CreatePaddingOption(opts, name, beforeStat, afterStat, sample)
  if combineStats then
    -- Secondary Stats
    local name, beforeStat, afterStat, sample = L["Secondary Stats"], {"pad", "before", "SecondaryStat"}, {"pad", "after", "SecondaryStat"}, self:MakeColorCode(self.colors.GREEN, self.L["Equip:"] .. " " .. format(self.L["Increases spell power by %s."], "10"))
    CreatePaddingOption(opts, name, beforeStat, afterStat, sample, true)
  end
  paddedAfterPrevious = self:GetOption(unpack(afterStat))
  if paddedAfterPrevious then CreateGroupGap(opts, "after" .. name) end
  
  -- Enchant
  local name, beforeStat, afterStat, sample = self.L["Enchant"], {"pad", "before", "Enchant"}, {"pad", "after", "Enchant"}, self:MakeColorCode(self.colors.GREEN, format(self.L["Enchanted: %s"], self.L["Enchant"]))
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  -- Weapon Enchant
  local name, beforeStat, afterStat, sample = self.L["Weapon Enchantment"], {"pad", "before", "WeaponEnchant"}, {"pad", "after", "WeaponEnchant"}, self:MakeColorCode(self.colors.GREEN, format(self.L["Enchanted: %s"], self.L["Weapon Enchantment"]))
  CreatePaddingOption(opts, name, beforeStat, afterStat, sample)
  paddedAfterPrevious = false
  -- paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  -- Rune
  if Addon.isSoD then
    local name, beforeStat, afterStat, sample = self.L["Equipped Runes"], {"pad", "before", "WeaponEnchant"}, {"pad", "after", "WeaponEnchant"}, self:MakeColorCode(self.colors.GREEN, self.L["Equipped Runes"])
    CreatePaddingOption(opts, name, beforeStat, afterStat, sample, true)
  end
  
  if self:GetOption("pad", "after", "WeaponEnchant") then
    CreateGroupGap(opts, "after" .. self.L["Weapon Enchantment"])
    paddedAfterPrevious = true
  end
  
  -- Sockets
  local name, beforeStat, afterStat, sample = L["Sockets"], {"pad", "before", "Socket"}, {"pad", "after", "SocketBonus"}, {self.socketIcon .. " " .. self:MakeColorCode(self.colors.GRAY, self.L["Meta Socket"]), self:MakeColorCode(self.colors.GRAY, format(self.L["Socket Bonus: %s"], format(self.L["Increases spell power by %s."], "10")))}
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  if not combineStats then
    -- Secondary Stats
    local name, beforeStat, afterStat, sample = L["Secondary Stats"], {"pad", "before", "SecondaryStat"}, {"pad", "after", "SecondaryStat"}, self:MakeColorCode(self.colors.GREEN, self.L["Equip:"] .. " " .. format(self.L["Increases spell power by %s."], "10"))
    paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  end
  
  -- Set Bonus
  local name, beforeStat, afterStat, sample = L["Set List"], {"pad", "before", "SetBonus"}, {"pad", "after", "SetBonus"}, self:MakeColorCode(self.colors.GREEN, format(self.L["Set: %s"], self.L["Effects"]))
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  -- End
  local name, beforeStat, afterStat, sample = self.L["End"], nil, {"padLastLine"}
  paddedAfterPrevious = CreateStandardPaddingMenu(opts, name, beforeStat, afterStat, sample, paddedAfterPrevious)
  
  
  GUI:CreateGroup(opts, GUI:Order(), "------------------", nil, nil, true)
  
  return opts
end





--  ███╗   ███╗██╗███████╗ ██████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ████╗ ████║██║██╔════╝██╔════╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██╔████╔██║██║███████╗██║         ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║╚██╔╝██║██║╚════██║██║         ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║ ╚═╝ ██║██║███████║╚██████╗    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝     ╚═╝╚═╝╚══════╝ ╚═════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local hearthstoneIcon = select(5, GetItemInfoInstant(Addon.sampleTitleID))
local sampleDamage   = 20
local sampleVariance = 0.5
local sampleSpeed    = 2.6


local function MakeExtraOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  local opts = GUI:CreateGroup(opts, categoryName, categoryName, nil, "tree")
  
  local disabled -- just in case some other addon clobbers _G.disabled
  
  -- Title
  do
    local stat = "Title"
    
    local defaultText = self.sampleTitleName or L["Hearthstone"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, defaultText, self:RewordTitle(defaultText, hearthstoneIcon))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Icon"])
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doIcon", stat}, self.L["Icon"], nil, disabled).width = 0.6
      GUI:CreateReset(opts, {"doIcon", stat}, function() self:ResetOption("doIcon", stat) end)
      GUI:CreateNewline(opts)
      
      local disabled = disabled or not self:GetOption("doIcon", stat)
      GUI:CreateToggle(opts, {"iconSizeManual", stat}, self.L["Manual"], nil, disabled).width = 0.6
      local option = GUI:CreateRange(opts, {"iconSize", stat}, L["Icon Size"], nil, 0, 96, 1, disabled or not self:GetOption("iconSizeManual", stat))
      option.width = 0.7
      option.softMin = 8
      option.softMax = 32
      GUI:CreateReset(opts, {"iconSize", stat}, function() self:ResetIconSize(stat) end)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"iconSpace", stat}, L["Icon Space"], nil, disabled).width = 0.7
      GUI:CreateReset(opts, {"iconSpace", stat}, function() self:ResetOption("iconSpace", stat) end)
    end
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Quality
  if GetCVarBool"colorblindMode" or self.expansionLevel < self.expansions.wrath then
    local stat = "Quality"
    
    local samples = {}
    local hiddenText
    for _, sample in ipairs(self.itemQualityDescriptions) do
      local defaultText = sample
      hiddenText = hiddenText or (self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, defaultText))
      local defaultText, formattedText = GetFormattedText(stat, self.colors.WHITE, defaultText, defaultText)
      tinsert(samples, {defaultText, formattedText})
    end
    
    local opts = GUI:CreateGroup(opts, "Quality", GetCVarBool"colorblindMode" and (samples[1] or {})[2] or hiddenText or "", nil, nil, disabled)
    
    do
      local option = GUI:CreateToggle(opts, {"colorblindMode"}, self.L["Enable UI Colorblind Mode"], self.L["Adds additional information to tooltips and several other interfaces."])
      option.get = function() return C_CVar.GetCVarBool"colorblindMode" end
      option.set = function() C_CVar.SetCVar("colorblindMode", C_CVar.GetCVarBool"colorblindMode" and 0 or 1) end
      option.width = 1.5
    end
    GUI:CreateReset(opts, {"colorblindMode"}, function() C_CVar.SetCVar("colorblindMode", C_CVar.GetCVarDefault"colorblindMode") end)
    GUI:CreateNewline(opts)
    if OpenColorblindOptions then
      GUI:CreateExecute(opts, "openColorblindSettings", self.L["Colorblind Mode"], nil, function() OpenColorblindOptions() self.AceConfigDialog:Close(ADDON_NAME) end)
      GUI:CreateNewline(opts)
    end
    
    if GetCVarBool"colorblindMode" then
      CreateSamples(opts, samples)
      
      CreateColor(opts, stat)
      
      CreateHide(opts, stat)
    end
  else -- Heroic
    local stat = "Heroic"
    
    local samples = {}
    local defaultText = self.L["Heroic"]
    local defaultText, formattedText = GetFormattedText(stat, self.colors.GREEN, defaultText, self:RewordHeroic(defaultText))
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, "Quality", samples[1][2], nil, nil, disabled)
    
    do
      local option = GUI:CreateToggle(opts, {"colorblindMode"}, self.L["Enable UI Colorblind Mode"], self.L["Adds additional information to tooltips and several other interfaces."])
      option.get = function() return C_CVar.GetCVarBool"colorblindMode" end
      option.set = function() C_CVar.SetCVar("colorblindMode", C_CVar.GetCVarBool"colorblindMode" and 0 or 1) end
      option.width = 1.5
    end
    GUI:CreateReset(opts, {"colorblindMode"}, function() C_CVar.SetCVar("colorblindMode", C_CVar.GetCVar"colorblindMode") end)
    GUI:CreateNewline(opts)
    if OpenColorblindOptions then
      GUI:CreateExecute(opts, "openColorblindSettings", self.L["Colorblind Mode"], nil, OpenColorblindOptions)
      GUI:CreateNewline(opts)
    end
    
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Item Level
  local function MakeItemLevelOptions()
    local stat = "ItemLevel"
    
    local sampleItemLevel = random(1, self.MAX_ITEMLEVEL)
    
    local samples = {}
    local defaultText   = format(self.L["Item Level %d"], sampleItemLevel)
    local itemLevelText = format(self:GetOption("itemLevel", "useShortName") and self.L["iLvl %d"] or self.L["Item Level %d"], sampleItemLevel)
    local defaultText, _             = GetFormattedText(stat, self.colors.WHITE, defaultText,   defaultText)
    local _,           formattedText = GetFormattedText(stat, self.colors.WHITE, itemLevelText, self:RewordItemLevel(itemLevelText))
    if self.expansionLevel < self.expansions.cata then
      defaultText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, self:StripColorCode(defaultText))
    end
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
    
    CreateSamples(opts, samples)
    
    CreateReorder(opts, stat, L["Show this line where it was originally positioned in Wrath of The Lich King."])
    
    CreateColor(opts, stat)
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
      
      GUI:CreateToggle(opts, {"itemLevel", "useShortName"}, self.L["Short Name"], format(L["Show %s instead of %s."], self:MakeColorCode(self.colors.DEFAULT, self.itemLevelTexts[true].iLvlText), self:MakeColorCode(self.colors.DEFAULT, self.itemLevelTexts[false].iLvlText)), disabled)
      GUI:CreateReset(opts, {"itemLevel", "useShortName"})
      GUI:CreateNewline(opts)
      
      local disabled = disabled or not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
      local disabled = disabled or not self:GetOption("doReword", stat)
      local option = GUI:CreateInput(opts, {"reword", stat}, self.L["Custom"], nil, nil, disabled)
      option.width = 0.9
      option.get = function(info)      return self:UncoverSpecialCharacters(self:GetOption("reword", stat))    end
      option.set = function(info, val)        self:SetOption(self:CoverSpecialCharacters(val), "reword", stat) end
      GUI:CreateReset(opts, {"reword", stat}, function() self:ResetReword(stat) end)
      
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      GUI:CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
    end
    
    CreateIcon(opts, stat)
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Show"])
      
      GUI:CreateReverseToggle(opts, {"hide", stat}, self.L["Show Item Level"], nil, disabled)
      GUI:CreateReset(opts, {"hide", stat})
      GUI:CreateNewline(opts)
      
      local disabled = self:GetOption("hide", stat)
      GUI:CreateReverseToggle(opts, {"hide", "nonEquipment"}, L["Show Non Equipment"], L["Show item level on items that cannot be equipped by anyone."], disabled)
      GUI:CreateReset(opts, {"hide", "nonEquipment"})
      if Addon.isSoD then
        local disabled = disabled or not self:GetOption("hide", "nonEquipment")
        GUI:CreateNewline(opts)
        GUI:CreateToggle(opts, {"itemLevel", "showWaylaidSupplies"}, L["Show Waylaid Supplies"], L["Show item level on Waylaid Supplies and Supply Shipments."], disabled)
        GUI:CreateReset(opts, {"itemLevel", "showWaylaidSupplies"})
      end
    end
  end
  if not self:GetOption("doReorder", "ItemLevel") then MakeItemLevelOptions() end
  
  -- Stack Size
  local function MakeStackSizeOptions()
    local stat = "StackSize"
    
    local samples = {}
    local defaultText = format(self.L["Stack Size"] .. ": %d", self:Random{5, 20, 80, 200, 1000})
    
    local _, formattedText = GetFormattedText(stat, self.colors.DEFAULT, defaultText, self:RewordStackSize(defaultText))
    defaultText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, defaultText)
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
    
    CreateSamples(opts, samples)
    
    CreateReorder(opts, stat, L["Whether to show this line much higher up on the tooltip rather than its usual location."])
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      local disabled = self:GetOption("hide", stat)
      GUI:CreateToggle(opts, {"hide", "StackSize_single"}, L["Hide Single Stacks"], L["Hide stack size on unstackable items."], disabled)
      GUI:CreateReset(opts, {"hide", "StackSize_single"})
      GUI:CreateNewline(opts)
      
      local disabled = disabled or self:GetOption("hide", "StackSize_single")
      GUI:CreateToggle(opts, {"hide", "StackSize_equipment"}, L["Hide Equipment"], L["Hide stack size on unstackable items that can be equipped on a character."], disabled)
      GUI:CreateReset(opts, {"hide", "StackSize_equipment"})
    end
  end
  if self:GetOption("doReorder", "StackSize") then MakeStackSizeOptions() end
  
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- TransmogHeader
  if self.expansionLevel >= self.expansions.cata then
    local stat = "TransmogHeader"
    
    local samples = {}
    local defaultText = self.L["Transmogrified to:"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.TRANSMOG, defaultText, self:RewordTransmogHeader(defaultText))
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Transmog
  if self.expansionLevel >= self.expansions.cata then
    local stat = "Transmog"
    
    local samples = {}
    local defaultText = self.sampleTransmogName or L["Teebu's Blazing Longsword"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.TRANSMOG, defaultText, self:RewordTransmog(defaultText))
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  if self.expansionLevel >= self.expansions.cata then GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  -- Races
  local function MakeRequiredRacesOption()
    local stat = "RequiredRaces"
    
    local samples = {}
    for i, sample in ipairs{format(self.L["Races: %s"], self.MY_RACE_LOCALNAME), format(self.L["Races: %s"], tblConcat(self.raceNames.Alliance, ", ")), format(self.L["Races: %s"], tblConcat(self.raceNames.Horde, ", "))} do
      local otherFaction = i == 2 and self.MY_FACTION == "Horde" or i == 3 and self.MY_FACTION == "Alliance"
      local defaultColor = otherFaction and self.colors.RED or self.colors.WHITE
      
      local defaultText = sample
      local defaultText, formattedText = GetFormattedText(stat, defaultColor, defaultText, self:ModifyRequiredRaces(defaultText))
      if self:GetOption("hide", stat) then
        samples[#samples+1] = {defaultText, formattedText}
      elseif not otherFaction and self:GetOption("hide", "RequiredRaces_allowedLines") then
        samples[#samples+1] = {defaultText, self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, self:StripColorCode(formattedText))}
      else
        samples[#samples+1] = {defaultText, self:MakeColorCode(defaultColor, self:StripColorCode(formattedText))}
      end
    end
    
    local sampleText = format(self.L["Races: %s"], tblConcat(self.raceNames.all, ", "))
    if self:GetOption("hide", stat) or self:GetOption("hide", "uselessRaces") or not otherFaction and self:GetOption("hide", "RequiredRaces_allowedLines") then
      samples[#samples+1] = {sampleText, self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, sampleText)}
    else
      samples[#samples+1] = {sampleText, self:MakeColorCode(self.colors.WHITE, sampleText)}
    end
    
    local opts = GUI:CreateGroup(opts, stat, self:GetOption("hide", stat) and samples[1][2] or samples[1][1])
    
    CreateSamples(opts, samples)
    
    CreateReorder(opts, stat, L["Whether to show this line much higher up on the tooltip rather than its usual location."])
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
      GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, not Addon:GetOption("allow", "reword")).width = 0.6
      GUI:CreateReset(opts, {"reword", stat}, function() self:ResetReword(stat) end)
    end
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "RequiredRaces_allowedLines"}, self.L["Me"], L["Hide lines that contain my race."]).width = 0.6
      GUI:CreateReset(opts, {"hide", "RequiredRaces_allowedLines"})
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "uselessRaces"}, L["Hide Pointless Lines"], L["Hide lines which list every race."])
      GUI:CreateReset(opts, {"hide", "uselessRaces"})
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
          formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, self:StripColorCode(formattedText))
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
        formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, self:StripColorCode(formattedText))
      end
      changed = formattedText ~= defaultText
      GUI:CreateDescription(opts, changed and formattedText or " ")
    end
    opts.name = name
    
    CreateReorder(opts, stat, L["Whether to show this line much higher up on the tooltip rather than its usual location."])
    
    do
      local opts = GUI:CreateGroupBox(opts, L["Recolor"])
      
      local disabled = not self:GetOption("allow", "recolor")
      local option = GUI:CreateToggle(opts, {"doRecolor", stat}, self.L["Show Class Color"], nil, disabled)
      option.width = self.isEra and 1.5 or 1
      GUI:CreateReset(opts, {"doRecolor", stat})
      
      if self.isEra then
        local disabled = not self:GetOption("allow", "recolor") or not self:GetOption("doRecolor", stat)
        GUI:CreateToggle(opts, {"doRecolor", "RequiredClasses_shaman"}, self:MakeColorCode("F58CBA", C_CreatureInfo.GetClassInfo(7).className) .. " -> " .. self:MakeColorCode("2459FF", C_CreatureInfo.GetClassInfo(7).className), nil, disabled).width = 1.5
        GUI:CreateReset(opts, {"doRecolor", "RequiredClasses_shaman"})
      end
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
      
      local disabled = disabled or not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled or not self:GetOption("doIcon", stat)).width = 0.6
      GUI:CreateReset(opts, {"reword", stat}, function() self:ResetOption("doReword", stat) end, disabled or not self:GetOption("doIcon", stat))
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"trimPunctuation", stat}, self.L["Minimize"], nil, disabled).width = 0.6
      GUI:CreateReset(opts, {"trimPunctuation", stat}, function() self:ResetOption("trimPunctuation", stat) end, disabled)
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Icon"])
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doIcon", stat}, self.L["Icon"], nil, disabled or self:GetOption("doReword", stat)).width = 0.6
      GUI:CreateReset(opts, {"doIcon", stat}, function() self:ResetOption("doIcon", stat) end, disabled or self:GetOption("doReword", stat))
      GUI:CreateNewline(opts)
      
      local disabled = disabled or not self:GetOption("doIcon", stat)
      GUI:CreateToggle(opts, {"iconSizeManual", stat}, self.L["Manual"], nil, disabled).width = 0.6
      local option = GUI:CreateRange(opts, {"iconSize", stat}, L["Icon Size"], nil, 0, 96, 1, disabled or not self:GetOption("iconSizeManual", stat))
      option.width = 0.7
      option.softMin = 8
      option.softMax = 32
      GUI:CreateReset(opts, {"iconSize", stat}, function() self:ResetIconSize(stat) end)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"iconSpace", stat}, L["Icon Space"], nil, disabled).width = 0.7
      GUI:CreateReset(opts, {"iconSpace", stat}, function() self:ResetOption("iconSpace", stat) end)
    end
    
    do
      local opts = CreateHide(opts, stat)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "myClass"}, self.L["Me"], L["Hide lines that contain only my class."]).width = 0.6
      GUI:CreateReset(opts, {"hide", "myClass"})
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
      
      local sampleLevels = {
        {self.L["Requires Level %d"], sample1},
        {self.L["Requires Level %d"], self.MAX_LEVEL},
        {self.L["Requires Level %d"], self.MAX_LEVEL + 1},
        self:ShortCircuit(self.expansionLevel >= self.expansions.cata, {self.L["Requires level %d to %d (%d)"], 1, self.MAX_LEVEL, self.MY_LEVEL}, nil),
      }
      
      GUI:CreateDescription(opts, self.L["Default"], "small")
      for i, levels in ipairs(sampleLevels) do
        local pattern, min, max, current = unpack(levels)
        local defaultText = format("|cffff%s%s", min > self.MY_LEVEL and "0000" or "ffff", format(pattern, min, max, current))
        GUI:CreateDescription(opts, defaultText)
      end
      GUI:CreateDivider(opts)
      
      local anyChanged
      local anyChangedOpt = GUI:CreateDescription(opts, " ", "small")
      
      for i, levels in ipairs(sampleLevels) do
        local pattern, min, max, current = unpack(levels)
        local defaultText = format("|cffff%s%s", min > self.MY_LEVEL and "0000" or "ffff", format(pattern, min, max, current))
        local formattedText = defaultText
        local changed = self:GetOption("hide", stat) or self:GetOption("hide", "requiredLevelMet") and min <= self.MY_LEVEL or self:GetOption("hide", "requiredLevelMax") and self.MY_LEVEL == self.MAX_LEVEL and min == self.MAX_LEVEL and max == self.MAX_LEVEL or max and self:GetOption("hide", "RequiredLevel_range")
        if changed then
          formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, strGsub(formattedText, "|c%x%x%x%x%x%x%x%x", ""))
        end
        
        if changed then anyChanged = true end
        GUI:CreateDescription(opts, changed and formattedText or " ")
        if min > self.MY_LEVEL then
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
      GUI:CreateReset(opts, {"hide", "requiredLevelMet"})
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"hide", "requiredLevelMax"}, self.L["Max Level"], L["Hide maximum level requirements when you are the maximum level."])
      GUI:CreateReset(opts, {"hide", "requiredLevelMax"})
      
      if self.expansionLevel >= self.expansions.wrath then
        GUI:CreateNewline(opts)
        GUI:CreateToggle(opts, {"hide", "RequiredLevel_range"}, self.L["Heirloom"], L["Hide level range requirements."])
        GUI:CreateReset(opts, {"hide", "RequiredLevel_range"})
      end
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
    {"AlreadyBound",   self.L["Soulbound"]},
    {"CharacterBound", self.L["Binds when picked up"]},
    {"AccountBound",   self.L["Binds to account"],      self.L["Binds to Blizzard account"]},
    {"Tradeable",      self.L["Binds when equipped"],   self.L["Binds when used"]},
  } do
    local stat = data[1]
    
    local samples = {}
    for i = 2, #data do
      local defaultText = data[i]
      local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, defaultText, self:RewordBinding(defaultText, stat))
      tinsert(samples, {defaultText, formattedText})
    end
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Unique
  do
    local stat = "Unique"
    
    for _, data in ipairs{
      {"Unique",                      Addon.L["Unique"],                   nil,                nil},
      {"UniqueLimit",                 Addon.L["Unique (%d)"],              1,                  nil},
      {"UniqueCategoryLimit",         Addon.L["Unique: %s (%d)"],          self.L["Category"], 1},
      {"UniqueEquipped",              Addon.L["Unique-Equipped"],          nil,                nil},
      {"UniqueEquippedCategoryLimit", Addon.L["Unique-Equipped: %s (%d)"], self.L["Category"], 1},
    } do
      local stat = data[1]
      
      local samples = {}
      
      local defaultText = format(unpack(data, 2, 4))
      local defaultText, formattedText = GetFormattedText(stat, self.colors.WHITE, defaultText, self:RewordUnique(defaultText, stat))
      tinsert(samples, {defaultText, formattedText})
      
      local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
      CreateSamples(opts, samples)
      
      CreateColor(opts, stat)
      
      CreateReword(opts, stat)
      
      CreateIcon(opts, stat)
      
      do
        local opts = CreateHide(opts, stat)
        GUI:CreateNewline(opts)
        
        GUI:CreateToggle(opts, {"hide", "Unique_uselessLines"}, L["Hide Pointless Lines"], L["Hide redundant lines when multiple Unique lines exist."])
        GUI:CreateReset(opts, {"hide", "Unique_uselessLines"})
      end
    end
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Refundable
  local function MakeRefundableOption()
    local stat = "Refundable"
    
    do
      local defaultText = format(self.L["You may sell this item to a vendor within %s for a full refund."], format(self.L["%d |4hour:hrs;"], 2))
      local formattedText = self:RewordRefundable(defaultText)
      local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.SKY_BLUE, defaultText, formattedText)
      
      local opts = GUI:CreateGroup(opts, stat, formattedText)
      
      CreateTitle(opts, defaultText, formattedText, changed)
      
      CreateReorder(opts, stat)
      
      CreateColor(opts, stat)
      
      -- Reword
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
        
        local disabled = not self:GetOption("allow", "reword")
        GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
        GUI:CreateReset(opts, {"doReword", stat}, function() self:ResetOption("doReword", stat) end)
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
      local defaultText = format(self.L["You may trade this item with players that were also eligible to loot this item for the next %s."], format(self.L["%d |4hour:hrs;"], 2))
      local formattedText = self:RewordTradeable(defaultText)
      local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.SKY_BLUE, defaultText, formattedText)
      
      local opts = GUI:CreateGroup(opts, stat, formattedText)
      
      CreateTitle(opts, defaultText, formattedText, changed)
      
      CreateReorder(opts, stat)
      
      CreateColor(opts, stat)
      
      -- Reword
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
        
        local disabled = not self:GetOption("allow", "reword")
        GUI:CreateToggle(opts, {"doReword", stat}, self.L["Enable"], nil, disabled).width = 0.6
        GUI:CreateReset(opts, {"doReword", stat}, function() self:ResetOption("doReword", stat) end)
      end
      
      CreateHide(opts, stat)
    end
    GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  end
  if self:GetOption("doReorder", "Refundable")         then MakeRefundableOption() end
  if self:GetOption("doReorder", "SoulboundTradeable") then MakeTradeableOption() end
  
  -- Trainable
  if self.expansionLevel < self.expansions.cata then
    do
      local stat = "Trainable"
      
      local defaultText = self.L["Weapon"]
      local _, name = GetFormattedText(stat, self.colors.RED, L["Trainable Equipment"], L["Trainable Equipment"])
      local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.RED, defaultText, defaultText)
      
      local opts = GUI:CreateGroup(opts, stat, name, L["Equipment that a trainer can teach you to wear."])
      
      CreateTitle(opts, defaultText, formattedText, changed)
      
      CreateColor(opts, stat)
    end
    GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  end
  
  -- Reforged
  if Addon.expansionLevel >= Addon.expansions.cata then
    do
      local stat = "Reforged"
      
      local defaultText = self.L["Reforged"]
      local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.GREEN, defaultText, self:RewordReforged(defaultText))
      
      local opts = GUI:CreateGroup(opts, stat, formattedText)
      
      CreateTitle(opts, defaultText, formattedText, changed)
      
      CreateColor(opts, stat)
      
      CreateReword(opts, stat)
      
      CreateIcon(opts, stat)
      
      CreateHide(opts, stat)
    end
  end
  if self.expansionLevel >= self.expansions.cata then GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  -- Weapon Damage
  do
    local stat = "Damage"
    
    local samples = {}
    do
      local min, max = self:Round(sampleDamage * (1-sampleVariance)), self:Round(sampleDamage * (1+sampleVariance))
      local default1 = format(self.L["%s - %s Damage"], self:ToFormattedNumber(min, nil, self.L["."], self.L[","], false, false), self:ToFormattedNumber(max, nil, self.L["."], self.L[","], false, false))
      local default2 = format(self.L["+ %s - %s Damage"], self:ToFormattedNumber(min, nil, self.L["."], self.L[","], false, false), self:ToFormattedNumber(max, nil, self.L["."], self.L[","], false, false))
      
      for _, v in ipairs{
        {default1, self:ModifyWeaponDamage(default1, sampleDamage*2, 1, {min, max}), self:GetOption("hide", stat)},
        {default2, self:ModifyWeaponDamageBonus(default2, {min, max}),               self:GetOption("hide", stat) or self:GetOption("hide", "DamageBonus")},
      } do
        local defaultText   = v[1]
        local formattedText = v[2]
        local hidden        = v[3]
        
        local originalColor = self.colors.WHITE
        local color = self:GetOption("color", stat)
        if hidden then
          formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, self:StripColorCode(formattedText))
        elseif self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and color ~= originalColor then
          formattedText = self:MakeColorCode(color, formattedText)
        else
          formattedText = self:MakeColorCode(originalColor, formattedText)
        end
        defaultText = self:MakeColorCode(originalColor, defaultText)
        
        tinsert(samples, {defaultText, formattedText})
      end
    end
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], self.L["Weapon Damage"])
    
    do
      local opts = CreateSamples(opts, samples)
      GUI:CreateNewline(opts)
      
      -- Test
      local option = GUI:CreateRange(opts, {"sampleDamage"}, L["Test"], nil, 0, 1000000, 0.01)
      option.softMax = 10000
      option.bigStep = 10
      option.get = function(info)      return sampleDamage       end
      option.set = function(info, val)        sampleDamage = val end
      local option = GUI:CreateRange(opts, {"sampleVariance"}, L["Test"], nil, 0, 1, 0.05)
      option.isPercent = true
      option.get = function(info)      return sampleVariance       end
      option.set = function(info, val)        sampleVariance = val end
    end
    
    CreateColor(opts, stat)
    
    do -- Reword
      local opts = GUI:CreateGroupBox(opts, self.L["Rename"])
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"damage", "showMinMax"}  , L["Show Minimum and Maximum"], nil, disabled or not self:GetOption("damage", "showAverage")).width = 1.5
      GUI:CreateReset(opts, {"damage", "showMinMax"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"damage", "showAverage"} , L["Show Average"], nil, disabled or not self:GetOption("damage", "showMinMax")).width = 1.5
      GUI:CreateReset(opts, {"damage", "showAverage"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"damage", "showVariance"}, L["Show Variance"], nil, disabled).width = 1.5
      GUI:CreateReset(opts, {"damage", "showVariance"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"damage", "variancePercent"}, L["Show Percent"], nil, disabled or not self:GetOption("damage", "showVariance")).width = 1.5
      GUI:CreateReset(opts, {"damage", "variancePercent"})
      GUI:CreateNewline(opts)
      GUI:CreateInput(opts, {"damage", "variancePrefix"} , L["Variance Prefix"], nil, nil, disabled).width = 0.5
      GUI:CreateReset(opts, {"damage", "variancePrefix"})
    end
    
    do
      local opts = CreateThousandsSeparator(opts, stat)
      GUI:CreateNewline(opts)
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateRange(opts, {"precision", stat}, L["Precision"], L["Number of decimal places."], 0, 5, 1, disabled)
      GUI:CreateReset(opts, {"precision", stat}, function() self:ResetOption("precision", stat) end)
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Hide"])
      
      GUI:CreateToggle(opts, {"hide", stat}, self.L["Hide"], nil, disabled)
      GUI:CreateReset(opts, {"hide", stat})
      GUI:CreateNewline(opts)
      
      local disabled = self:GetOption("hide", stat)
      GUI:CreateToggle(opts, {"hide", "DamageBonus"}, self.L["Bonus Damage"], L["Merge Bonus Damage into Weapon Damage"], disabled)
      GUI:CreateReset(opts, {"hide", "DamageBonus"})
    end
  end
  
  local speedString = strGsub(format("%.2f", sampleSpeed), "%.", DECIMAL_SEPERATOR) -- always use default DECIMAL_SEPERATOR
  local speedStringFull = self.L["Speed"] .. " " .. speedString
  -- Weapon Speed
  do
    local stat = "Speed"
    
    local defaultSpeedString = speedString
    local defaultText = speedStringFull
    local formattedTextOriginal = self:ModifyWeaponSpeed(defaultText, sampleSpeed, defaultSpeedString)
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, defaultText, formattedTextOriginal)
    local disabled
    if self:GetOption("hide", "Damage") then
      formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, formattedTextOriginal)
      changed = true
      disabled = true
    end
    
    local opts = GUI:CreateGroup(opts, stat, "  " .. (formattedText), self.L["Speed"], nil, disabled)
    
    do
      local opts = CreateTitle(opts, defaultText, formattedText, changed, 1)
      
      -- Test
      local option = GUI:CreateRange(opts, {"sampleSpeed"}, L["Test"], nil, self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
      option.get = function(info)      return sampleSpeed       end
      option.set = function(info, val)        sampleSpeed = val end
    end
    
    CreateColor(opts, stat, disabled)
    
    CreateReword(opts, stat, disabled)
    
    do -- Precision
      local opts = GUI:CreateGroupBox(opts, L["Precision"])
      
      GUI:CreateRange(opts, {"precision", stat}, L["Precision"], L["Number of decimal places."], 0, 5, 1, disabled)
      GUI:CreateReset(opts, {"precision", stat}, function() self:ResetOption("precision", stat) end)
    end
    
    CreateHide(opts, stat, disabled)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Weapon DPS
  local sampleDPS = format("%.1f", sampleDamage / sampleSpeed) -- always uses period as decimal
  do
    local stat = "DamagePerSecond"
    
    local defaultText = format(self.L["(%s damage per second)"], sampleDPS)
    local formattedText = self:ModifyWeaponDamagePerSecond(defaultText)
    -- if self:GetOption("dps", "removeBrackets") then
    --   formattedText = self:ChainGsub(formattedText, {"^%(", "%)$", ""})
    -- end
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, defaultText, formattedText)
    
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
    
    do
      local opts = CreateThousandsSeparator(opts, stat)
      GUI:CreateNewline(opts)
      
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateRange(opts, {"precision", stat}, L["Precision"], L["Number of decimal places."], 0, 5, 1, disabled)
      GUI:CreateReset(opts, {"precision", stat}, function() self:ResetOption("precision", stat) end)
      
      GUI:CreateToggle(opts, {"dps", "removeBrackets"}, L["Remove Brackets"], nil, disabled)
      GUI:CreateReset(opts, {"dps", "removeBrackets"})
    end
    
    CreateHide(opts, stat)
  end
  
  -- Weapon Speedbar
  do
    local stat = "Speedbar"
    
    local defaultSpeed = sampleSpeed
    local defaultText = self:ModifyWeaponSpeedbar(defaultSpeed, speedString, speedStringFull) or ""
    local formattedTextOriginal = defaultText == "" and L["Speed Bar"] or defaultText
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, formattedTextOriginal, formattedTextOriginal)
    local name, disabled
    if self:GetOption("hide", "DamagePerSecond") then
      name     = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, defaultText == "" and L["Speed Bar"] or formattedText)
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
        option.get = function(info)      return sampleSpeed       end
        option.set = function(info, val)        sampleSpeed = val end
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
          if self:GetOption("allow", "recolor") and self:GetOption("doRecolor", "Speed") and color ~= self.colors.WHITE then
            formattedText = self:MakeColorCode(color, formattedText)
          else
            formattedText = self:MakeColorCode(self.colors.WHITE, formattedText)
          end
          GUI:CreateExecute(opts, {"goto", "Speed"}, formattedText, nil, function() self:OpenConfig("Miscellaneous", "Speed") end)
          GUI:CreateNewline(opts)
        end
        
        GUI:CreateToggle(opts, {"speedBar", "speedPrefix"}, L["Show Speed"], nil, disabled)
        GUI:CreateReset(opts, {"speedBar", "speedPrefix"})
      end
      
      do
        local opts = GUI:CreateGroupBox(opts, self.L["Settings"])
        
        local option = GUI:CreateRange(opts, {"speedBar", "min"}, self.L["Minimum"], L["Fastest speed on the speed bar."], self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
        option.set = function(info, val) self:SetOptionConfig(val, "speedBar", "min") self:SetOptionConfig(mathMax(val, self:GetOption("speedBar", "max")), "speedBar", "max") end
        local option = GUI:CreateRange(opts, {"speedBar", "max"}, self.L["Maximum"], L["Slowest speed on the speed bar."], self:GetDefaultOption("speedBar", "min"), self:GetDefaultOption("speedBar", "max"), 0.1, disabled)
        option.set = function(info, val) self:SetOptionConfig(val, "speedBar", "max") self:SetOptionConfig(mathMin(val, self:GetOption("speedBar", "min")), "speedBar", "min") end
        GUI:CreateNewline(opts)
        local option = GUI:CreateRange(opts, {"speedBar", "size"}, self.L["Frame Width"], L["Width of the speed bar."], 1, 1000, 1, disabled)
        option.softMin = 10
        option.softMax = 50
        GUI:CreateReset(opts, {"speedBar", "size"})
      end
      
      CreateHide(opts, stat)
    end
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Armor
  do
    local stat = "Armor"
    
    local sample = 1000
    
    local samples = {}
    local defaultText = format(self.L["%s Armor"], self:ToFormattedNumber(sample, nil, self.L["."], self.L[","], false, false))
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, defaultText, self:RewordArmor(defaultText))
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateReword(opts, stat)
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("allow", "reword") or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      GUI:CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
      GUI:CreateNewline(opts)
    end
    
    CreateThousandsSeparator(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Bonus Armor
  do
    local stat = "BonusArmor"
    
    local sample = 2000
    
    local samples = {}
    local defaultText = format(self.L["%s Armor"], self:ToFormattedNumber(sample, nil, self.L["."], self.L[","], false, false))
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.GREEN, defaultText, self:RewordBonusArmor(defaultText))
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
      
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateReword(opts, stat)
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("allow", "reword") or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      GUI:CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
      GUI:CreateNewline(opts)
    end
    
    CreateThousandsSeparator(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Block
  if self.expansionLevel < self.expansions.cata then
    local stat = "Block"
    
    local sample = 1000
    local defaultText = format(self.L["%d Block"], sample)
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, defaultText, self:RewordBlock(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, nil, nil, disabled)
      
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateReword(opts, stat)
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      GUI:CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
      GUI:CreateNewline(opts)
    end
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Enchant
  do
    local stat = "Enchant"
    
    local defaultText = self.L["Enchant"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.GREEN, defaultText, self:ModifyEnchantment(defaultText))
    
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
    
    local originalColor = self.colors.GREEN
    local defaultText = self.L["Use:"] .. " " .. self.L["Enchant"]
    local prefixModifiedText = self:ModifyPrefix(defaultText, self.L["Use:"])
    local _, prefixFormattedText = GetFormattedText("Use", originalColor, defaultText, prefixModifiedText)
    local formattedText = self:ModifyOnUseEnchantment(prefixModifiedText)
    
    local color = self:GetOption("color", "Use")
    if self:GetOption("hide", stat) or self:GetOption("hide", "Use") then
      formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, formattedText)
    elseif self:GetOption("allow", "recolor") and self:GetOption("doRecolor", "Use") and color ~= originalColor then
      formattedText = self:MakeColorCode(color, formattedText)
    else
      formattedText = self:MakeColorCode(originalColor, formattedText)
    end
    local defaultText = self:MakeColorCode(originalColor, defaultText)
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, L["This applies to enchantments that add an On Use effect to the item."])
    
    CreateSamples(opts, {{defaultText, formattedText}})
    
    GUI:CreateNewline(opts)
    GUI:CreateExecute(opts, {"goto", "Use"}, prefixFormattedText, nil, function() self:OpenConfig("Miscellaneous", "Use") end)
    GUI:CreateNewline(opts)
    
    CreateReorder(opts, stat, L["Whether to position this line with other On Use effects rather than the normal enchantment location."])
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  if Addon.expansionLevel >= Addon.expansions.wrath and not self:GetOption("doReorder", "EnchantOnUse") then MakeEnchantOnUseOptions() end
  
  -- Weapon Enchant
  do
    local stat = "WeaponEnchant"
    
    local defaultText = self.L["Weapon Enchantment"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.GREEN, defaultText, self:ModifyWeaponEnchantment(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, L["This applies to temporary weapon enchantments."])
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  
  -- Rune
  if Addon.isSoD then
    local stat = "Rune"
    
    local defaultText = self.L["All Runes"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.GREEN, defaultText, self:ModifyRune(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, L["This applies to runes."])
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Socket
  if self.expansionLevel >= self.expansions.tbc then
    local stat = "Socket"
    
    local sockets = Addon:Squish{
      {"Socket_red",       self.L["Red Socket"]},
      {"Socket_blue",      self.L["Blue Socket"]},
      {"Socket_yellow",    self.L["Yellow Socket"]},
      {"Socket_purple",    self.L["Matches a Red or Blue Socket."]},
      {"Socket_green",     self.L["Matches a Blue or Yellow Socket."]},
      {"Socket_orange",    self.L["Matches a Red or Yellow Socket."]},
      {"Socket_prismatic", self.L["Prismatic Socket"]},
      {"Socket_meta",      self.L["Meta Socket"]},
      Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.cata, {"Socket_cogwheel", self.L["Cogwheel Socket"]}, nil),
      Addon:ShortCircuit(Addon.expansionLevel >= Addon.expansions.mop, {"Socket_hydraulic", self.L["Hydraulic Socket"]}, nil),
    }
    
    local samples = {}
    for _, socket in ipairs(sockets) do
      local socketType, defaultText = unpack(socket, 1, 2)
      local defaultText, formattedText = GetFormattedText(socketType, self.colors.WHITE, defaultText, defaultText)
      tinsert(samples, {defaultText, formattedText})
    end
    
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2])
      
    -- CreateTitle(opts, defaultText, formattedText, changed)
    CreateSamples(opts, samples)
    
    for _, socket in ipairs(sockets) do
      local stat = socket[1]
      local opts = GUI:CreateGroupBox(opts, socket[2])
      
      local disabled = disabled or not Addon:GetOption("allow", "recolor")
      GUI:CreateToggle(opts, {"doRecolor", stat}, L["Recolor"], nil, disabled).width = 0.5
      GUI:CreateColor(opts, {"color", stat}, self.L["Color"], nil, disabled or not Addon:GetOption("doRecolor", stat)).width = 0.5
      GUI:CreateReset(opts, {"color", stat}, function() self:ResetColor(stat) end)
    end
  end
  
  -- Socket Hint
  local function MakeSocketHintOptions()
    local stat = "SocketHint"
    
    local defaultText = self.L["<Shift Right Click to Socket>"]
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.GREEN, defaultText, self:RewordSocketHint(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateReorder(opts, stat, L["Move this line to the socket bonus."])
    
    CreateColor(opts, stat)
    
    CreateReword(opts, stat)
    
    CreateHide(opts, stat)
  end
  if self.expansionLevel >= self.expansions.tbc and self:GetOption("doReorder", "SocketHint") then MakeSocketHintOptions() end
  if self.expansionLevel >= self.expansions.tbc then GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  -- Durability
  do
    local stat = "Durability"
    
    local defaultDurability, defaultDurabilityFull = 5, 50
    local defaultText = format(self.L["Durability %d / %d"], defaultDurability, defaultDurabilityFull)
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.WHITE, defaultText, self:ModifyDurability(defaultText))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, nil, nil, disabled)
      
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateReword(opts, stat)
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      GUI:CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
      GUI:CreateNewline(opts)
      
      local disabled = false
      GUI:CreateToggle(opts, {"durability", "showCur"}  , L["Show Current"], nil, disabled or not self:GetOption("durability", "showPercent"))
      GUI:CreateReset(opts, {"durability", "showCur"})
      GUI:CreateNewline(opts)
      GUI:CreateToggle(opts, {"durability", "showPercent"}, L["Show Percent"], nil, disabled or not self:GetOption("durability", "showCur"))
      GUI:CreateReset(opts, {"durability", "showPercent"})
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
    {"Equip",       self.L["Equip:"]},
    {"ChanceOnHit", self.L["Chance on hit:"]},
    {"Use",         self.L["Use:"]},
  } do
    local stat   = data[1]
    local prefix = data[2]
    
    local defaultText = format("%s %s", prefix, self.L["Effects"])
    local defaultText, formattedText, changed = GetFormattedText(stat, self.colors.GREEN, defaultText, self:ModifyPrefix(defaultText, prefix))
    
    local opts = GUI:CreateGroup(opts, stat, formattedText, prefix)
    
    CreateTitle(opts, defaultText, formattedText, changed)
    
    CreateColor(opts, stat)
    
    do
      local opts = CreateReword(opts, stat)
      GUI:CreateNewline(opts)
      
      -- Trim Space
      local disabled = disabled or not self:GetOption("doReword", stat)
      GUI:CreateToggle(opts, {"trimSpace", stat}, L["Remove Space"], nil, disabled)
      GUI:CreateReset(opts, {"trimSpace", stat}, function() self:ResetOption("trimSpace", stat) end)
    end
    
    CreateIcon(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  if Addon.expansionLevel >= Addon.expansions.wrath and self:GetOption("doReorder", "EnchantOnUse") then MakeEnchantOnUseOptions() GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  
  -- Charges
  do
    local stat = "Charges"
    
    local sampleCharges = 10
    local someCharges   = format(self.L["%d |4Charge:Charges;"], sampleCharges)
    local noCharges     = self.L["No charges"]
    
    local samples = {}
    do
      local defaultText = someCharges
      local defaultText, formattedText = GetFormattedText(stat, self.colors.WHITE, defaultText, defaultText)
      tinsert(samples, {defaultText, formattedText})
    end
    do
      local defaultText = noCharges
      local formattedText = defaultText
      local originalColor = self.colors.WHITE
      local color = self:GetOption("color", "NoCharges")
      
      if self:GetOption("hide", stat) then
        formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, self:StripColorCode(formattedText))
      elseif self:GetOption("allow", "recolor") and self:GetOption("doRecolor", "NoCharges") and color ~= originalColor then
        formattedText = self:MakeColorCode(color, formattedText)
      else
        formattedText = self:MakeColorCode(originalColor, formattedText)
      end
      tinsert(samples, {self:MakeColorCode(originalColor, defaultText), formattedText})
    end
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
    
    CreateSamples(opts, samples)
    
    do
      local opts = GUI:CreateGroupBox(opts, L["Recolor"])
      
      local disabled = disabled or not self:GetOption("allow", "recolor")
      GUI:CreateToggle(opts, {"doRecolor", "Charges"}, someCharges, nil, disabled).width = 1
      GUI:CreateColor(opts, {"color", "Charges"}, self.L["Color"], nil, disabled or not self:GetOption("doRecolor", "Charges")).width = 0.5
      GUI:CreateReset(opts, {"color", "Charges"}, function() self:ResetColor"Charges" end)
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"doRecolor", "NoCharges"}, noCharges, nil, disabled).width = 1
      GUI:CreateColor(opts, {"color", "NoCharges"}, self.L["Color"], nil, disabled or not self:GetOption("doRecolor", "NoCharges")).width = 0.5
      GUI:CreateReset(opts, {"color", "NoCharges"}, function() self:ResetColor"NoCharges" end)
    end
    
    CreateHide(opts, stat)
  end
  
  -- Cooldown
  do
    local stat = "Cooldown"
    
    local sampleCooldown = 10
    local defaultText = format(self.L["Cooldown remaining: %d min"], sampleCooldown)
    
    local samples = {}
    local defaultText, formattedText = GetFormattedText(stat, self.colors.WHITE, defaultText, defaultText)
    tinsert(samples, {defaultText, formattedText})
    
    local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
    
    CreateSamples(opts, samples)
    
    CreateColor(opts, stat)
    
    CreateHide(opts, stat)
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  -- Reputation
  if Addon.isSoD then
    do
      local stat = "Reputation"
      
      local samples = {}
      for _, itemID in ipairs{211822, 2453} do
        local defaultText = Addon:RewordReputation(itemID)
        
        local formattedText = defaultText
        local originalColor = self.colors.REP
        local color = self:GetOption("color", stat)
        if self:ShouldHideReputation(itemID) then
          formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, formattedText)
        elseif self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and color ~= originalColor then
          formattedText = self:MakeColorCode(color, formattedText)
        else
          formattedText = self:MakeColorCode(originalColor, formattedText)
        end
        defaultText = self:MakeColorCode(originalColor, defaultText)
        
        tinsert(samples, {defaultText, formattedText})
      end
      
      local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
        
      CreateSamples(opts, samples)
      
      CreateColor(opts, stat)
      
      CreateIcon(opts, stat)
      
      do
        local opts = CreateHide(opts, stat)
        GUI:CreateNewline(opts)
        
        local disabled = self:GetOption("hide", stat)
        GUI:CreateToggle(opts, {"hide", "Reputation_waylaidSuppliesItems"}, self.L["Items"], nil, disabled).width = 0.6
        GUI:CreateReset(opts, {"hide", "Reputation_waylaidSuppliesItems"})
      end
    end
    
    GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  end
  
  -- MadeBy / GiftFrom / WrittenBy
  do
    for _, data in ipairs{
      {"MadeBy",    self.L["<Made by %s>"],   "ShouldHideMadeBy",    "MadeByMe",    L["Made by myself."],    "MadeByOther",    L["Made by others."]},
      {"GiftFrom",  self.L["<Gift from %s>"], "ShouldHideGiftFrom",  "GiftFromMe",  L["Gift from myself."],  "GiftFromOther",  L["Gift from others."]},
      {"WrittenBy", self.L["Written by %s"],  "ShouldHideWrittenBy", "WrittenByMe", L["Written by myself."], "WrittenByOther", L["Written by others."]},
    } do
      
      local stat, pattern, ShouldHide, hideMe, hideMeDesc, hideOther, hideOtherDesc = unpack(data)
      
      local samples = {}
      local secondName = UnitExists"target" and UnitNameUnmodified"target" or nil
      secondName = secondName and secondName ~= self.MY_NAME and secondName or self:Random(self.SAMPLE_NAMES)
      for _, name in ipairs{self.MY_NAME, secondName} do
        local defaultText = format(pattern, name)
        
        local formattedText = defaultText
        local originalColor = self.colors.GREEN
        local color = self:GetOption("color", stat)
        if self[ShouldHide](self, defaultText, pattern) then
          formattedText = self.stealthIcon .. self:MakeColorCode(self.colors.GRAY, formattedText)
        elseif self:GetOption("allow", "recolor") and self:GetOption("doRecolor", stat) and color ~= originalColor then
          formattedText = self:MakeColorCode(color, formattedText)
        else
          formattedText = self:MakeColorCode(originalColor, formattedText)
        end
        defaultText = self:MakeColorCode(originalColor, defaultText)
        
        tinsert(samples, {defaultText, formattedText})
      end
      
      local opts = GUI:CreateGroup(opts, stat, samples[1][2], nil, nil, disabled)
        
      CreateSamples(opts, samples)
      
      CreateColor(opts, stat)
      
      do
        local opts = CreateHide(opts, stat)
        GUI:CreateNewline(opts)
        
        local disabled = self:GetOption("hide", stat)
        GUI:CreateToggle(opts, {"hide", hideMe}, self.L["Me"], hideMeDesc, disabled).width = 0.6
        GUI:CreateReset(opts, {"hide", hideMe})
        GUI:CreateNewline(opts)
        
        GUI:CreateToggle(opts, {"hide", hideOther}, self.L["Other"], hideOtherDesc, disabled).width = 0.6
        GUI:CreateReset(opts, {"hide", hideOther})
      end
    end
  end
  GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true)
  
  if self.expansionLevel >= self.expansions.tbc and not self:GetOption("doReorder", "SocketHint") then MakeSocketHintOptions() GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  if not self:GetOption("doReorder", "Refundable")         then MakeRefundableOption() end
  if not self:GetOption("doReorder", "SoulboundTradeable") then MakeTradeableOption() end
  
  if not self:GetOption("doReorder", "StackSize") then MakeStackSizeOptions() GUI:CreateGroup(opts, GUI:Order(), " ", nil, nil, true) end
  
  -- Misc locale rewording
  if #self:GetExtraReplacements() > 0 then
    local stat = "Miscellaneous"
    local name = self:MakeColorCode(self.colors.WHITE, self.L["Miscellaneous"])
    
    local opts = GUI:CreateGroup(opts, stat, name, L["Reword some various small things, such as mana potions and speed enchantments. This option is different for each locale."])
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Miscellaneous"])
      
      -- Reword
      local disabled = not self:GetOption("allow", "reword")
      GUI:CreateToggle(opts, {"doReword", stat}, self.L["Rename"], L["Reword some various small things, such as mana potions and speed enchantments. This option is different for each locale."], disabled).width = 0.6
      GUI:CreateReset(opts, {"doReword", stat})
    end
  end
  
  return opts
end





--  ██████╗ ███████╗███████╗███████╗████████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔════╝██╔════╝██╔════╝╚══██╔══╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██████╔╝█████╗  ███████╗█████╗     ██║       ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══██╗██╔══╝  ╚════██║██╔══╝     ██║       ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║  ██║███████╗███████║███████╗   ██║       ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝   ╚═╝        ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeResetOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  local opts = GUI:CreateGroup(opts, categoryName, categoryName)
  
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
    GUI:CreateReset(opts, {cat}, func)
    GUI:CreateNewline(opts)
  end
  
  return opts
end





--  ██████╗ ███████╗██████╗ ██╗   ██╗ ██████╗      ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔════╝██╔══██╗██║   ██║██╔════╝     ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██║  ██║█████╗  ██████╔╝██║   ██║██║  ███╗    ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██║  ██║██╔══╝  ██╔══██╗██║   ██║██║   ██║    ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██████╔╝███████╗██████╔╝╚██████╔╝╚██████╔╝    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═════╝ ╚══════╝╚═════╝  ╚═════╝  ╚═════╝      ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeDebugOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  
  if not self:IsDebugEnabled() then return end
  
  GUI:SetDBType"Global"
  local opts = GUI:CreateGroup(opts, categoryName, categoryName, nil, "tab")
  
  GUI:CreateExecute(opts, "reload", self.L["Reload UI"], nil, ReloadUI)
  
  -- Enable
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), self.L["Enable"])
    
    do
      local opts = GUI:CreateGroupBox(opts, self.L["Debug"])
      GUI:CreateToggle(opts, {"debug"}, self.L["Enable"])
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"debugShowLuaErrors"}, self.L["Display Lua Errors"], nil, disabled).width = 2
      GUI:CreateNewline(opts)
      
      local disabled = not self:GetGlobalOption"debugShowLuaErrors"
      GUI:CreateToggle(opts, {"debugShowLuaWarnings"}, self.L["Lua Warning"], nil, disabled).width = 2
    end
  end
  
  -- Debug View
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "View")
    
    local disabled = not self:GetGlobalOption"debug"
    
    do
      local opts = GUI:CreateGroupBox(opts, "Suppress All")
      
      GUI:CreateToggle(opts, {"debugView", "suppressAll"}, self.L["Hide"], nil, disabled).width = 2
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Tooltips")
      
      local disabled = disabled or self:GetGlobalOption("debugView", "suppressAll")
      
      for i, data in ipairs{
        {"tooltipLineNumbers",         "Tooltip Line Numbers"},
        {"paddingConversionSuccesses", "Padding Conversion Successes"},
        {"paddingConversionFailures",  "Padding Conversion Failures"},
      } do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        GUI:CreateToggle(opts, {"debugView", data[1]}, data[2], nil, disabled).width = 2
      end
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Scanner Tooltips")
      
      for i, data in ipairs{
        {"tooltip_GameTooltip",      "GameTooltip"},
        {"tooltip_ItemRefTooltip",   "ItemRefTooltip"},
        {"tooltip_ShoppingTooltip1", "ShoppingTooltip1"},
        {"tooltip_ShoppingTooltip2", "ShoppingTooltip2"},
      } do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        GUI:CreateToggle(opts, {"debugView", data[1]}, data[2]).width = 2
      end
    end
  end
  
  -- Debug Output
  do
    local opts = GUI:CreateGroup(opts, GUI:Order(), "Output")
    
    local disabled = not self:GetGlobalOption"debug"
    
    do
      local opts = GUI:CreateGroupBox(opts, "Suppress All")
      
      GUI:CreateToggle(opts, {"debugOutput", "suppressAll"}, self.debugPrefix .. " " .. self.L["Hide messages like this one."], nil, disabled).width = 2
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Message Types")
      
      local disabled = disabled or self:GetGlobalOption("debugOutput", "suppressAll")
      
      for i, data in ipairs{
        {"tooltipMethodHook",         "Tooltip Method Hook"},
        {"tooltipOnSetItemHook",      "Tooltip tooltipOnSetItem Hook"},
        {"tooltipHookFail",           "Tooltip Hook Failure"},
        {"tooltipHookMarked",         "Tooltip Hook Marked"},
        {"initialTooltipData",        "Initial Tooltip Data"},
        {"finalTooltipData",          "Final Tooltip Data"},
        {"constructorCreated",        "Constructor Created"},
        {"constructorCached",         "Constructor Cached"},
        {"constructorWiped",          "Constructor Wiped"},
        {"constructorValidationFail", "Constructor Validation Failure"},
        {"constructorLineMove",       "Constructor Moving Line"},
        {"paddingDecisions",          "Padding Decisions"},
        {"optionSet",                 "Option Set"},
        {"cvarSet",                   "CVar Set"},
        {"InterfaceOptionsFrameFix",  "Interface Options Patch"},
        {"throttlingStarted",         "Throttling Started"},
      } do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        GUI:CreateToggle(opts, {"debugOutput", data[1]}, data[2], nil, disabled).width = 2
      end
    end
    
    do
      local opts = GUI:CreateGroupBox(opts, "Scanner Tooltips")
      
      local disabled = disabled or self:GetGlobalOption("debugOutput", "suppressAll")
      
      for i, data in ipairs{
        {"tooltip_GameTooltip",      "GameTooltip"},
        {"tooltip_ItemRefTooltip",   "ItemRefTooltip"},
        {"tooltip_ShoppingTooltip1", "ShoppingTooltip1"},
        {"tooltip_ShoppingTooltip2", "ShoppingTooltip2"},
      } do
        if i ~= 1 then
          GUI:CreateNewline(opts)
        end
        GUI:CreateToggle(opts, {"debugOutput", data[1]}, data[2], nil, disabled).width = 2
      end
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
      GUI:CreateReset(opts, {"cache", "enabled"})
      GUI:CreateNewline(opts)
      
      GUI:CreateToggle(opts, {"constructor", "alwaysDestruct"}, "Always Destruct", "Undo tooltip modifications after they're complete.")
      GUI:CreateReset(opts, {"constructor", "alwaysDestruct"})
    end
    
    for _, data in ipairs{
      {"Text Rewords"     , {"cache", "text"}       , "WipeTextCache"       , "GetTextCacheSize"},
      {"Stat Recognitions", {"cache", "stat"}       , "WipeStatCache"       , "GetStatCacheSize"},
      {"Constructors"     , {"cache", "constructor"}, "WipeConstructorCache", "GetConstructorCacheSize"},
    } do
      local opts = GUI:CreateGroupBox(opts, data[1] .. ": " .. self[data[4]](self))
      group = opts
      
      local disabled = not self:GetGlobalOption("cache", "enabled")
      GUI:CreateToggle(opts, data[2], self.L["Enable"], nil, disabled)
      GUI:CreateReset(opts, data[2])
      GUI:CreateExecute(opts, {"wipe", unpack(data[2])}, self.L["Clear Cache"], nil, function() self[data[3]](self) end, disabled).width = 0.6
    end
    
    do
      local opts = group
      GUI:CreateDivider(opts)
      
      local disabled = not self:GetGlobalOption("cache", "enabled") or not self:GetGlobalOption("cache", "constructor")
      
      GUI:CreateToggle(opts, {"constructor", "doValidation"}, "Do Validation", "Perform constructor validation checks.", disabled)
      GUI:CreateReset(opts, {"constructor", "doValidation"})
      GUI:CreateNewline(opts)
      
      local option = GUI:CreateRange(opts, {"cache", "constructorWipeDelay"}, "Wipe Delay", "Time in seconds without constructor being requested before it's cleared.", 0, 1000000, 0.001, disabled)
      option.softMax = 60
      option.bigStep = 1
      GUI:CreateReset(opts, {"cache", "constructorWipeDelay"})
      GUI:CreateNewline(opts)
      
      local option = GUI:CreateRange(opts, {"cache", "constructorMinSeenCount"}, "Minimum Seen Count", "Minimum number of times constructor must be requested before it can be cached.", 0, 1000000, 1, disabled)
      option.softMax = 50
      GUI:CreateReset(opts, {"cache", "constructorMinSeenCount"})
      GUI:CreateNewline(opts)
      
      local option = GUI:CreateRange(opts, {"cache", "constructorMinSeenTime"}, "Minimum Seen Time", "Minimum time in seconds since constructor was first requested before it can be cached.", 0, 1000000, 0.001, disabled)
      option.softMax = 10
      option.bigStep = 0.25
      GUI:CreateReset(opts, {"cache", "constructorMinSeenTime"})
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
  
  GUI:ResetDBType()
  
  return opts
end


--  ██████╗ ██████╗  ██████╗ ███████╗██╗██╗     ███████╗     ██████╗ ██████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔══██╗██╔══██╗██╔═══██╗██╔════╝██║██║     ██╔════╝    ██╔═══██╗██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  ██████╔╝██████╔╝██║   ██║█████╗  ██║██║     █████╗      ██║   ██║██████╔╝   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔═══╝ ██╔══██╗██║   ██║██╔══╝  ██║██║     ██╔══╝      ██║   ██║██╔═══╝    ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║     ██║  ██║╚██████╔╝██║     ██║███████╗███████╗    ╚██████╔╝██║        ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝╚══════╝     ╚═════╝ ╚═╝        ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local function MakeProfileOptions(opts, categoryName)
  local self = Addon
  local GUI = self.GUI
  
  local profileOptions = self.AceDBOptions:GetOptionsTable(self:GetDB())
  profileOptions.order = GUI:Order()
  opts.args[categoryName] = profileOptions
  
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
  
  local sections = {}
  for _, data in ipairs{
    {MakeGeneralOptions, nil},
    {MakeStatsOptions,   self.L["Stats"],         "stats"},
    {MakePaddingOptions, L["Spacing"],            "spacing", "spaces", "padding"},
    {MakeExtraOptions,   self.L["Miscellaneous"], "miscellaneous", "other"},
    {MakeProfileOptions, "Profiles",              "profiles"},
    {MakeResetOptions,   self.L["Reset"],         "reset"},
    {MakeDebugOptions,   self.L["Debug"],         "debug"},
  } do
    
    local func = data[1]
    local name = data[2]
    local args = {unpack(data, 3)}
    
    tinsert(sections, function(opts) return func(opts, name) end)
    
    local function OpenOptions() return self:OpenConfig(name) end
    if name == self.L["Debug"] then
      local OpenOptions_Old = OpenOptions
      OpenOptions = function(...)
        if not self:GetGlobalOption"debug" then
          self:SetGlobalOption(true, "debug")
          self:Debug("Debug mode enabled")
        end
        return OpenOptions_Old(...)
      end
    end
    
    for _, arg in ipairs(args) do
      self:RegisterChatArgAliases(arg, OpenOptions)
    end
  end
  
  self.AceConfig:RegisterOptionsTable(ADDON_NAME, function()
    local GUI = self.GUI:ResetOrder()
    local opts = GUI:CreateOpts(title, "tab")
    
    for _, func in ipairs(sections) do
      func(opts)
    end
    
    return opts
  end)
  
  -- default is (700, 500)
  self.AceConfigDialog:SetDefaultSize(ADDON_NAME, 700, 800)
end


function Addon:MakeBlizzardOptions(chatCmd)
  local title = format("%s v%s  (/%s)", ADDON_NAME, tostring(self:GetOption"version"), chatCmd)
  local panel = self:CreateBlizzardOptionsCategory(function()
    local GUI = self.GUI:ResetOrder()
    local opts = GUI:CreateOpts(title, "tab")
    
    GUI:CreateExecute(opts, "key", ADDON_NAME .. " " .. self.L["Options"], nil, function()
      self:OpenConfig(ADDON_NAME)
      self:CloseBlizzardConfig()
    end)
    
    return opts
  end)
end




local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_NAME)

Addon.TipHooker  = LibStub"LibTipHooker-1.1-ZeraTooltip"
Addon.TipHooker2 = LibStub"LibTipHooker-1.0-ZeraTooltip"





local strLower  = string.lower
local strFind   = string.find
local strGsub   = string.gsub
local strGmatch = string.gmatch
local strMatch  = string.match

local tinsert   = table.insert
local tblConcat = table.concat
local tblRemove = table.remove

local tostring = tostring



--  ██╗  ██╗███████╗██╗     ██████╗ ███████╗██████╗ ███████╗
--  ██║  ██║██╔════╝██║     ██╔══██╗██╔════╝██╔══██╗██╔════╝
--  ███████║█████╗  ██║     ██████╔╝█████╗  ██████╔╝███████╗
--  ██╔══██║██╔══╝  ██║     ██╔═══╝ ██╔══╝  ██╔══██╗╚════██║
--  ██║  ██║███████╗███████╗██║     ███████╗██║  ██║███████║
--  ╚═╝  ╚═╝╚══════╝╚══════╝╚═╝     ╚══════╝╚═╝  ╚═╝╚══════╝

do
  Addon.statList = {}
  for i = 1, Addon.expansionLevel do
    Addon.statList[i] = {}
  end
  Addon.statsInfo        = setmetatable({}, {__index = function() return {} end})
  Addon.statOrder        = {}
  Addon.statDefaultList  = {}
  Addon.statDefaultOrder = {}
  Addon.statPrefOrder    = {}
  
  
  function Addon:RegenerateStatOrder()
    wipe(self.statList[self.expansionLevel])
    wipe(self.statOrder)
    for stat in strGmatch(self:GetOption("order", self.expansionLevel), "[^,]+") do
      tinsert(self.statList[self.expansionLevel], stat)
      self.statOrder[stat] = #self.statList[self.expansionLevel]
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
  function Addon:ResetColor(stat)
    if stat then
      self:ResetOption("doRecolor", stat)
      self:ResetOption("color", stat)
    else
      self:ResetOptionQuiet"doRecolor"
      self:ResetOptionQuiet"color"
    end
  end
  function Addon:ResetReword(stat)
    if stat then
      self:ResetOption("doReword", stat)
      self:ResetOption("reword", stat)
    else
      self:ResetOptionQuiet("doReword")
      self:ResetOptionQuiet("reword")
    end
    -- self:SetDefaultRewordByLocale(stat)
  end
  function Addon:ResetMod(stat)
    if stat then
      self:ResetOption("mod", stat)
    else
      self:ResetOptionQuiet"mod"
    end
    -- self:SetDefaultModByLocale(stat)
  end
  function Addon:ResetPrecision(stat)
    if stat then
      self:ResetOption("precision", stat)
    else
      self:ResetOptionQuiet"precision"
    end
    -- self:SetDefaultPrecisionByLocale(stat)
  end
  function Addon:ResetIcon(stat)
    if stat then
      self:ResetOption("doIcon", stat)
      self:ResetOption("icon", stat)
    else
      self:ResetOptionQuiet"doIcon"
      self:ResetOptionQuiet"icon"
    end
  end
  function Addon:ResetIconSize(stat)
    if stat then
      self:ResetOption("iconSizeManual", stat)
      self:ResetOption("iconSize", stat)
    else
      self:ResetOptionQuiet"iconSizeManual"
      self:ResetOptionQuiet"iconSize"
    end
  end
end



--  ██╗      ██████╗  ██████╗ █████╗ ██╗     ███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗██║     ██╔════╝
--  ██║     ██║   ██║██║     ███████║██║     █████╗  
--  ██║     ██║   ██║██║     ██╔══██║██║     ██╔══╝  
--  ███████╗╚██████╔╝╚██████╗██║  ██║███████╗███████╗
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝

do
  local self = Addon
  
  Addon.itemQualityDescriptions = Addon:MakeLookupTable((function()
    local t = {}
    local function iter(globalstring)
      local i = 0
      return function()
        i = i + 1
        return _G[format(globalstring, i)]
      end
    end
    for key in iter"ITEM_QUALITY%d_DESC" do
      tinsert(t, key)
    end
    if Addon.expansionLevel >= Addon.expansions.wrath then
      for key in iter"ITEM_HEROIC_QUALITY%d_DESC" do
        tinsert(t, key)
      end
    end
    return t
  end)(), nil, true)
  
  Addon.prefixStats = {
    [Addon.L["Equip:"]]         = "Equip",
    [Addon.L["Chance on hit:"]] = "ChanceOnHit",
    [Addon.L["Use:"]]           = "Use",
  }
end



--  ███████╗████████╗ █████╗ ████████╗███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
--  ███████╗   ██║   ███████║   ██║   ███████╗
--  ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
--  ███████║   ██║   ██║  ██║   ██║   ███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝

do
  local self = Addon
  
  local spellDamageStats = {}
  for _, stat in ipairs{"Arcane Damage", "Fire Damage", "Nature Damage", "Frost Damage", "Shadow Damage", "Holy Damage"} do
    local rules = Addon:GetExtraStatCapture(stat)
    if rules then
      spellDamageStats[stat] = Addon:ChainGsub(rules[1].INPUT, {"%(%[%%d[^%]]*%]%+%)", "%(%%d%+%)", "%%s"}, {"^%^", "%$$", ""}, {"%%([^s])", "%1"})
    end
  end
  
  
  local elementResistances = {
    self.L["Arcane Resistance"],
    self.L["Fire Resistance"],
    self.L["Nature Resistance"],
    self.L["Frost Resistance"],
    self.L["Shadow Resistance"],
    self.L["Holy Resistance"],
  }
  local elementNames = {
    self.L["Arcane"],
    self.L["Fire"],
    self.L["Nature"],
    self.L["Frost"],
    self.L["Shadow"],
    self.L["Holy"],
  }
  local elementColors = {
    self.colors.ARCANE,
    self.colors.FIRE,
    self.colors.NATURE,
    self.colors.FROST,
    self.colors.SHADOW,
    self.colors.HOLY,
  }
  
  local statsData = {}
  
  tinsert(statsData, {0, {nil, nil, nil, true}, "Bonus Armor", self.L["Bonus Armor"], self.L["%c%s Bonus Armor"], self.colors.GREEN, self.colors.GREEN})
  
  
  tinsert(statsData, {1, {true, true, true, true}, "Stamina",   self.L["Stamina"],   self.L["%c%d Stamina"],   self.colors.WHITE, self.colors.PALE_LIGHT_GREEN})
  tinsert(statsData, {1, {true, true, true, true}, "Strength",  self.L["Strength"],  self.L["%c%d Strength"],  self.colors.WHITE, self.colors.TUMBLEWEED})
  tinsert(statsData, {0, {true, true, true, true}, "Agility",   self.L["Agility"],   self.L["%c%d Agility"],   self.colors.WHITE, self.colors.PUMPKIN_ORANGE})
  tinsert(statsData, {1, {true, true, true, true}, "Intellect", self.L["Intellect"], self.L["%c%d Intellect"], self.colors.WHITE, self.colors.JORDY_BLUE})
  tinsert(statsData, {0, {true, true, true, true}, "Spirit",    self.L["Spirit"],    self.L["%c%d Spirit"],    self.colors.WHITE, self.colors.LIGHT_AQUA})
  
  
  tinsert(statsData, {1, {true, true, true, true}, "All Resistance", self:ChainGsub(self.L["%c%d to All Resistances"], {"%%%d%$", "%%"}, {"%%.", "^ *", " *$", ""}), self:ChainGsub(self.L["%c%d to All Resistances"], {"%%%d+%$", "%%"}), self.colors.WHITE, self.colors.YELLOW})
  
  for i, stat in ipairs{"Arcane Resistance", "Fire Resistance", "Nature Resistance", "Frost Resistance", "Shadow Resistance"} do
    tinsert(statsData, {(i == 1 and 1 or 0), {true, true, true, true}, stat, elementResistances[i], format(self:ChainGsub(Addon.L["%c%d %s Resistance"], {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), elementNames[i]), self.colors.WHITE, elementColors[i]})
  end
  
  
  tinsert(statsData, {1, {true, true, true, nil},  "Defense Rating",    self.L["Defense Rating"],    self.L["Increases defense rating by %s."],                 self.colors.GREEN, self.colors.YELLOW})
  tinsert(statsData, {1, {true, true, true, true}, "Dodge Rating",      self.L["Dodge Rating"],      self.L["Increases your dodge rating by %s."],              self.colors.GREEN, self.colors.YELLOW})
  tinsert(statsData, {0, {true, true, true, true}, "Parry Rating",      self.L["Parry Rating"],      self.L["Increases your parry rating by %s."],              self.colors.GREEN, self.colors.YELLOW})
  tinsert(statsData, {1, {true, true, true, true}, "Block Rating",      self.L["Block Rating"],      self.L["Increases your shield block rating by %s."],       self.colors.GREEN, self.colors.YELLOW})
  tinsert(statsData, {0, {true, true, true, nil},  "Block Value",       self.L["Block Value"],       self.L["Increases the block value of your shield by %s."], self.colors.GREEN, self.colors.YELLOW})
  tinsert(statsData, {0, {nil , true, true, true}, "Resilience Rating", self.L["Resilience Rating"], self.L["Improves your resilience rating by %s."],          self.colors.GREEN, self.colors.YELLOW})
  
  
  tinsert(statsData, {1, {self.isSoD, true, true, true}, "Expertise Rating",         self.L["Expertise Rating"],         self.L["Increases your expertise rating by %s."],  self.colors.GREEN, self.colors.TUMBLEWEED})
  tinsert(statsData, {1, {true,       true, true, true}, "Attack Power",             self.L["Attack Power"],             self.L["Increases attack power by %s."],           self.colors.GREEN, self.colors.TUMBLEWEED})
  tinsert(statsData, {0, {true,       true, true, nil},  "Ranged Attack Power",      self.L["Ranged Attack Power"],      self.L["Increases ranged attack power by %s."],    self.colors.GREEN, self.colors.TUMBLEWEED})
  tinsert(statsData, {0, {true,       true, true, nil},  "Attack Power In Forms",    self.L["Attack Power In Forms"],    self.L["Increases attack power by %s in Cat, Bear, Dire Bear, and Moonkin forms only."], self.colors.GREEN, self.colors.TUMBLEWEED})
  tinsert(statsData, {0, {true,       true, true, nil},  "Armor Penetration Rating", self.L["Armor Penetration Rating"], self.L["Increases your armor penetration by %s."], self.colors.GREEN, self.colors.TUMBLEWEED})
  
  
  tinsert(statsData, {1, {true, true, true, true}, "Spell Power", self.L["Spell Power"], self.L["Increases spell power by %s."], self.colors.GREEN, self.colors.LILAC_GEODE})
  
  tinsert(statsData, {0, {true, true, nil , true}, "Healing", self.L["Bonus Healing"], self.L["Increases healing done by magical spells and effects by up to %s."], self.colors.GREEN, self.colors.LIGHT_CYAN})
  
  tinsert(statsData, {1, {true, true, nil, nil}, "Spell Damage" , self.L["Bonus Damage"], self.L["Increases damage done by magical spells and effects by up to %s."], self.colors.GREEN, self.colors.KISSES})
  for i, stat in ipairs{"Arcane Damage", "Fire Damage", "Nature Damage", "Frost Damage", "Shadow Damage", "Holy Damage"} do
    if spellDamageStats[stat] then
      tinsert(statsData, {(i == 1 and 1 or 0), {true, true, true, true} , stat, format(self.L["%s Damage"], elementNames[i]), spellDamageStats[stat], self.colors.GREEN, elementColors[i]})
    end
  end
  
  tinsert(statsData, {0, {true, true, true, true}, "Spell Penetration", self.L["Spell Penetration"], self.L["Increases spell penetration by %s."],                                self.colors.GREEN, self.colors.VENUS_SLIPPER_ORCHID})
  
  
  tinsert(statsData, {1, {self.isSoD, nil , true, true}, "Hit Rating",                      self.L["Hit Rating"],                      self.L["Improves hit rating by %s."],                    self.colors.GREEN, self.colors.PINK_SHERBET})
  tinsert(statsData, {0, {self.isSoD, nil , true, true}, "Critical Strike Rating",          self.L["Critical Strike Rating"],          self.L["Improves critical strike rating by %s."],        self.colors.GREEN, self.colors.PARIS_GREEN})
  tinsert(statsData, {0, {nil ,       nil , true, true}, "Haste Rating",                    self.L["Haste Rating"],                    self.L["Improves haste rating by %s."],                  self.colors.GREEN, self.colors.LEMON_LIME})
  tinsert(statsData, {1, {true,       true, nil,  nil},  "Physical Hit Rating",             self.L["Hit Rating"],                      self.L["Improves hit rating by %s."],                    self.colors.GREEN, self.colors.PINK_SHERBET})
  tinsert(statsData, {0, {true,       true, nil,  nil},  "Physical Critical Strike Rating", self.L["Critical Strike Rating"],          self.L["Improves critical strike rating by %s."],        self.colors.GREEN, self.colors.PARIS_GREEN})
  tinsert(statsData, {0, {self.isSoD, true, nil,  nil},  "Physical Haste Rating",           self.L["Haste Rating"],                    self.L["Improves haste rating by %s."],                  self.colors.GREEN, self.colors.LEMON_LIME})
  tinsert(statsData, {1, {true,       true, nil,  nil},  "Spell Hit Rating",                self.L["Hit Rating (Spell)"],              self.L["Improves spell hit rating by %s."],              self.colors.GREEN, self.colors.PINK_SHERBET})
  tinsert(statsData, {0, {true,       true, nil,  nil},  "Spell Critical Strike Rating",    self.L["Critical Strike Rating (Spell)"] , self.L["Improves spell critical strike rating by %s."] , self.colors.GREEN, self.colors.PARIS_GREEN})
  tinsert(statsData, {0, {self.isSoD, true, nil,  nil},  "Spell Haste Rating",              self.L["Haste Rating (Spell)"],            self.L["Improves spell haste rating by %s."],            self.colors.GREEN, self.colors.LEMON_LIME})
  tinsert(statsData, {0, { nil,       nil,  nil,  true}, "Mastery Rating",                  self.L["Mastery"],                         self.L["%c%s Mastery"],                                  self.colors.GREEN, self.colors.GREEN_GAS})
    
    
  tinsert(statsData, {1, {true, true, true, true}, "Health Regeneration", self.L["Health Regeneration"], self.L["Restores %s health per 5 sec."], self.colors.GREEN, self.colors.PALE_LIGHT_GREEN})
  tinsert(statsData, {0, {true, true, true, nil},  "Mana Regeneration",   self.L["Mana Regeneration"],   self.L["Restores %s mana per 5 sec."],   self.colors.GREEN, self.colors.JORDY_BLUE})
  
  
  
  local isReversedLocale = not strFind(self.L["%c%d Stamina"], "^%%")
  local GetLocaleStatFormat = isReversedLocale and function(pre, suf, capture) return format("%s %s%s", suf, capture and "?" or "", pre) end or function(pre, suf, capture) return format("%s %s%s", pre, capture and "?" or "", suf) end
  -- instead of flipping them, mess with the normal form pattern instead. format("%s %s", isBaseStat and sign or "+", normalName) vs format("%2$s %1$s", isBaseStat and sign or "+", normalName)
  
  for i, data in ipairs(statsData) do
    tinsert(self.statPrefOrder, data[1])
    
    local expacs    = {}
    local isInExpac = data[2]
    expacs[self.expansions.era]   = isInExpac[1]
    expacs[self.expansions.tbc]   = isInExpac[2]
    expacs[self.expansions.wrath] = isInExpac[3]
    expacs[self.expansions.cata]  = isInExpac[4]
    
    local stat = data[3]
    
    
    for expac, list in pairs(self.statList) do
      if expacs[expac] then
        tinsert(list, stat)
      end
    end
    if expacs[self.expansionLevel] then
      tinsert(self.statDefaultList, stat)
      self.statDefaultOrder[stat] = #self.statDefaultList
      
      local normalName = data[4]
      
      local tooltipPattern  = self:GetDefaultStatPattern(stat) or data[5]
      local tooltipPattern2 = self:ChainGsub(tooltipPattern, {"%%%d%$", "%%"}, {"%%c", "%%d", "%%s"})
      
      local tooltipColor = data[6]
      local color        = data[7]
      
      self.statsInfo[stat] = {}
      local StatInfo = self.statsInfo[stat]
      
      StatInfo.tooltipColor = tooltipColor
      StatInfo.color = color
      
      local isBaseStat = strFind(tooltipPattern, "%%%d?%$?c")
      local isFakeBaseStat = strFind(tooltipPattern, "%%%d?%$?c%%s")
      local reorderLocaleMode = isBaseStat and "%s%s" or "+%s"
      
      
      local normalNameReplacePattern = self:CoverSpecialCharacters(normalName)
      
      local tooltipPatternLower         = strLower(tooltipPattern)
      local normalFormPattern           = GetLocaleStatFormat(isBaseStat and "%1$s%2$s" or "+%1$s", normalName)
      local normalFormCapture           = strGsub(self:ReversePattern(GetLocaleStatFormat(isBaseStat and "%c%s%%?" or "+%s%%?", normalName,  nil)), "%$", "[。%.]*%0")
      local normalFormCaptureLower      = strLower(normalFormCapture)
      local normalFormLooseCapture      = strGsub(self:ReversePattern(GetLocaleStatFormat(isBaseStat and "%c%s%%?" or "+%s%%?", normalName, true)), "%$", "[。%.]*%0")
      local normalFormLooseCaptureLower = strLower(normalFormLooseCapture)
      local normalFormPattern2          = GetLocaleStatFormat(isBaseStat and "%s%s" or "+%s", normalName)
      
      
      local function ApplyMod(text, normalForm)
        local match1, match2 = strMatch(normalForm, normalFormCapture)
        local origStrNumber = match1 .. (match2 or "")
        local strNumber, percent = strMatch(origStrNumber, "(%-?" .. self.L["[%d,%.]+"] .. ")(%%?)")
        local number = self:Round(self:ToNumber(strNumber) * self:GetOption("mod", stat), 1 / 10^self:GetOption("precision", stat))
        strNumber = self:ToFormattedNumber(number, nil, nil, not self:GetOption("separateThousands", stat) and "" or nil)
        if isBaseStat and number > 0 then
          strNumber = "+" .. strNumber
        end
        return strGsub(text, self:CoverSpecialCharacters(origStrNumber), self:CoverSpecialCharacters(strNumber .. percent))
      end
      
      local function ConvertToAliasForm(text)
        local alias = self:GetOption("reword", stat)
        if alias and alias ~= "" and alias ~= normalNameReplacePattern then
          text = strGsub(text, normalNameReplacePattern, alias)
        end
        return text
      end
      
      function StatInfo:Reword(text, normalForm)
        return Addon:pcall(function()
          if Addon:GetOption("allow", "reword") and Addon:GetOption("doReword", stat) then
            text = ConvertToAliasForm(ApplyMod(text, normalForm))
          end
          return text
        end,
        function(err)
          Addon:Errorf("Problem with stat %s: %s", stat, err)
        end)
      end
      
      local function HasNumber(match1, match2)
        local strNumber = match1
        if isBaseStat then
          strNumber = match2
        end
        return self:ToNumber(strGsub(strNumber, "%%", ""))
      end
      
      function StatInfo:ConvertToNormalForm(text)
        return Addon:pcall(function()
          text = strLower(text)
          local match1, match2 = strMatch(text, Addon:ReversePattern(tooltipPatternLower))
          if match1 then
            if HasNumber(match1, match2) then return format(normalFormPattern, match1, match2) end
          end
          local match1, match2 = strMatch(text, strLower(normalFormCaptureLower))
          if match1 then
            if HasNumber(match1, match2) then return format(normalFormPattern, match1, match2) end
          end
          local match1, match2 = strMatch(text, strLower(normalFormLooseCaptureLower))
          if match1 then
            if HasNumber(match1, match2) then return format(normalFormPattern, match1, match2) end
          end
          for _, rule in ipairs(Addon:GetExtraStatCapture(stat) or {}) do
            local matches = rule.OUTPUT and {rule.OUTPUT(strMatch(text, rule.INPUT))} or {strMatch(text, rule.INPUT)}
            if #matches > 0 then
              if HasNumber(matches[1], matches[2]) then return format(normalFormPattern, matches[1], matches[2]) end
            end
          end
        end,
        function(err)
          Addon:Errorf("Problem with stat %s: %s", stat, err)
        end)
      end
      
      function StatInfo:GetDefaultForm(number)
        return Addon:pcall(function()
          local percent = strFind(number, "%%$")
          number = Addon:ToNumber(number)
          local strNumber
          if isBaseStat and not isFakeBaseStat then
            strNumber = tostring(number)
          else
            strNumber = Addon:ToFormattedNumber(number, nil, Addon.L["."], Addon.L[","], false, false)
          end
          strNumber = strNumber .. (percent and "%" or "")
          return format(tooltipPattern2, isBaseStat and (number < 0 and "" or "+") or strNumber, isBaseStat and strNumber or nil)
        end,
        function(err)
          Addon:Errorf("Problem with stat %s: %s", stat, err)
        end)
      end
      
      function StatInfo:GetNormalName()
        return normalName
      end
    end
  end
  
  
  -- Default color settings
  
  self.statsInfo["Title"]                       = {color = self.colors.WHITE}
  
  self.statsInfo["Quality"]                     = {color = self.colors.WHITE}
  self.statsInfo["Heroic"]                      = {color = self.colors.GREEN}
  self.statsInfo["ItemLevel"]                   = {color = self.colors.DEFAULT}
  
  self.statsInfo["TransmogHeader"]              = {color = self.colors.TRANSMOG}
  self.statsInfo["Transmog"]                    = {color = self.colors.TRANSMOG}
  
  self.statsInfo["AlreadyBound"]                = {color = self.colors.WHITE}
  self.statsInfo["CharacterBound"]              = {color = self.colors.WHITE}
  self.statsInfo["AccountBound"]                = {color = self.colors.CANDID_BLUE}
  self.statsInfo["Tradeable"]                   = {color = self.colors.WHITE}
  
  self.statsInfo["Unique"]                      = {color = self.colors.WHITE}
  self.statsInfo["UniqueLimit"]                 = {color = self.colors.WHITE}
  self.statsInfo["UniqueCategoryLimit"]         = {color = self.colors.WHITE}
  self.statsInfo["UniqueEquipped"]              = {color = self.colors.WHITE}
  self.statsInfo["UniqueEquippedCategoryLimit"] = {color = self.colors.WHITE}
  
  self.statsInfo["Trainable"]                   = {color = self.colors.ORANGE}
  
  self.statsInfo["Reforged"]                    = {color = self.colors.GREEN}
  
  self.statsInfo["Damage"]                      = {color = self.colors.WHITE}
  self.statsInfo["DamageBonus"]                 = {color = self.colors.WHITE}
  self.statsInfo["Speed"]                       = {color = self.colors.WHITE}
  
  self.statsInfo["DamagePerSecond"]             = {color = self.colors.WHITE}
  self.statsInfo["Speedbar"]                    = {color = self.colors.WHITE}
  
  self.statsInfo["Armor"]                       = {color = self.colors.WHITE}
  self.statsInfo["BonusArmor"]                  = {color = self.colors.GREEN}
  self.statsInfo["Block"]                       = {color = self.colors.WHITE}
  
  self.statsInfo["Enchant"]                     = {color = self.colors.GREEN}
  self.statsInfo["WeaponEnchant"]               = {color = self.colors.GREEN}
  self.statsInfo["Rune"]                        = {color = self.colors.GREEN}
  
  self.statsInfo["Socket_red"]                  = {color = self.colors.RED}
  self.statsInfo["Socket_blue"]                 = {color = self.colors.BLUE}
  self.statsInfo["Socket_yellow"]               = {color = self.colors.YELLOW}
  self.statsInfo["Socket_purple"]               = {color = self.colors.PURPLE}
  self.statsInfo["Socket_green"]                = {color = self.colors.GREEN}
  self.statsInfo["Socket_orange"]               = {color = self.colors.ORANGE}
  self.statsInfo["Socket_prismatic"]            = {color = self.colors.WHITE}
  self.statsInfo["Socket_meta"]                 = {color = self.colors.WHITE}
  self.statsInfo["Socket_cogwheel"]             = {color = self.colors.WHITE}
  self.statsInfo["Socket_hydraulic"]            = {color = self.colors.WHITE}
  
  self.statsInfo["Charges"]                     = {color = self.colors.ORANGE}
  self.statsInfo["NoCharges"]                   = {color = self.colors.RED}
  self.statsInfo["Cooldown"]                    = {color = self.colors.RED}
  
  self.statsInfo["Durability"]                  = {color = self.colors.WHITE}
  
  self.statsInfo["Reputation"]                  = {color = self.colors.REP}
  
  self.statsInfo["MadeBy"]                      = {color = self.colors.GREEN}
  
  self.statsInfo["SocketHint"]                  = {color = self.colors.GREEN}
  
  self.statsInfo["Refundable"]                  = {color = self.colors.SKY_BLUE}
  self.statsInfo["SoulboundTradeable"]          = {color = self.colors.SKY_BLUE}
  
  self.statsInfo["StackSize"]                   = {color = self.colors.DEFAULT}
end


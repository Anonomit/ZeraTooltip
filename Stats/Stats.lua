
local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)
ZeraTooltip = Addon

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







--  ██╗      ██████╗  ██████╗ █████╗ ██╗     ███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗██║     ██╔════╝
--  ██║     ██║   ██║██║     ███████║██║     █████╗  
--  ██║     ██║   ██║██║     ██╔══██║██║     ██╔══╝  
--  ███████╗╚██████╔╝╚██████╗██║  ██║███████╗███████╗
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝

do
  Addon.ITEM_RESIST_ALL = ITEM_RESIST_ALL
  
  Addon.DAMAGE_SCHOOL7 = DAMAGE_SCHOOL7
  Addon.DAMAGE_SCHOOL3 = DAMAGE_SCHOOL3
  Addon.DAMAGE_SCHOOL4 = DAMAGE_SCHOOL4
  Addon.DAMAGE_SCHOOL5 = DAMAGE_SCHOOL5
  Addon.DAMAGE_SCHOOL6 = DAMAGE_SCHOOL6
  Addon.DAMAGE_SCHOOL2 = DAMAGE_SCHOOL2
  
  Addon.ITEM_MOD_STAMINA   = ITEM_MOD_STAMINA
  Addon.ITEM_MOD_STRENGTH  = ITEM_MOD_STRENGTH
  Addon.ITEM_MOD_AGILITY   = ITEM_MOD_AGILITY
  Addon.ITEM_MOD_INTELLECT = ITEM_MOD_INTELLECT
  Addon.ITEM_MOD_SPIRIT    = ITEM_MOD_SPIRIT
  
  do
    local head, single, plural, tail = strMatch(ITEM_SPELL_CHARGES, "(.*)|4([^:]+):([^;]+);(.*)")
    if single then
      Addon.ITEM_SPELL_CHARGES1 = head .. single .. tail
      Addon.ITEM_SPELL_CHARGES2 = head .. plural .. tail
    else
      Addon.ITEM_SPELL_CHARGES1 = ITEM_SPELL_CHARGES
    end
  end
  
  local locale = GetLocale()
  if locale == "esES" then
    Addon.ITEM_MOD_STAMINA   = ITEM_MOD_STAMINA  :lower()
    Addon.ITEM_MOD_STRENGTH  = ITEM_MOD_STRENGTH :lower()
    Addon.ITEM_MOD_AGILITY   = ITEM_MOD_AGILITY  :lower()
    Addon.ITEM_MOD_INTELLECT = ITEM_MOD_INTELLECT:lower()
    Addon.ITEM_MOD_SPIRIT    = ITEM_MOD_SPIRIT   :lower()
  elseif locale == "esMX" then
    Addon.ITEM_MOD_STAMINA   = Addon:ChainGsub(ITEM_MOD_STAMINA,   {SPELL_STAT3_NAME:lower(), SPELL_STAT3_NAME})
    Addon.ITEM_MOD_STRENGTH  = Addon:ChainGsub(ITEM_MOD_STRENGTH,  {SPELL_STAT1_NAME:lower(), SPELL_STAT1_NAME})
    Addon.ITEM_MOD_AGILITY   = Addon:ChainGsub(ITEM_MOD_AGILITY,   {SPELL_STAT2_NAME:lower(), SPELL_STAT2_NAME})
    Addon.ITEM_MOD_INTELLECT = Addon:ChainGsub(ITEM_MOD_INTELLECT, {SPELL_STAT4_NAME:lower(), SPELL_STAT4_NAME})
    Addon.ITEM_MOD_SPIRIT    = Addon:ChainGsub(ITEM_MOD_SPIRIT,    {SPELL_STAT5_NAME:lower(), SPELL_STAT5_NAME})
  elseif locale == "ruRU" then
    if Addon.isEra then
      Addon.DAMAGE_SCHOOL7 = SPELL_SCHOOL6_CAP
      Addon.DAMAGE_SCHOOL3 = SPELL_SCHOOL2_CAP
      Addon.DAMAGE_SCHOOL4 = SPELL_SCHOOL3_CAP
      Addon.DAMAGE_SCHOOL5 = SPELL_SCHOOL4_CAP
      Addon.DAMAGE_SCHOOL6 = SPELL_SCHOOL5_CAP
      Addon.DAMAGE_SCHOOL2 = SPELL_SCHOOL1_CAP
    else
      Addon.DAMAGE_SCHOOL7 = "тайной магии"
      Addon.DAMAGE_SCHOOL3 = "огню"
      Addon.DAMAGE_SCHOOL4 = "силам природы"
      Addon.DAMAGE_SCHOOL5 = "магии льда"
      Addon.DAMAGE_SCHOOL6 = "темной магии"
      Addon.DAMAGE_SCHOOL2 = "свету"
    end
  elseif locale == "zhTW" then
    if Addon.isEra then
      Addon.ITEM_MOD_STAMINA   = strGsub(ITEM_MOD_STAMINA  , " ", "", 1)
      Addon.ITEM_MOD_STRENGTH  = strGsub(ITEM_MOD_STRENGTH , " ", "", 1)
      Addon.ITEM_MOD_AGILITY   = strGsub(ITEM_MOD_AGILITY  , " ", "", 1)
      Addon.ITEM_MOD_INTELLECT = strGsub(ITEM_MOD_INTELLECT, " ", "", 1)
      Addon.ITEM_MOD_SPIRIT    = strGsub(ITEM_MOD_SPIRIT   , " ", "", 1)
    else
      Addon.ITEM_RESIST_ALL = strGsub(ITEM_RESIST_ALL, "(%%d)", "%1 ")
    end
  end
  
  Addon.SPELL_DAMAGE_STATS = {}
  for _, stat in ipairs{"Arcane Damage", "Fire Damage", "Nature Damage", "Frost Damage", "Shadow Damage", "Holy Damage"} do
    local rules = Addon:GetExtraStatCapture(stat)
    if rules then
      Addon.SPELL_DAMAGE_STATS[stat] = Addon:ChainGsub(rules[1].INPUT, {"%(%%d%+%)", "%%s"}, {"^%^", "%$$", ""}, {"%%([^s])", "%1"})
    end
  end
end




--  ███████╗████████╗ █████╗ ████████╗███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
--  ███████╗   ██║   ███████║   ██║   ███████╗
--  ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
--  ███████║   ██║   ██║  ██║   ██║   ███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝

do
  local self = Addon
  
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
  
  
  local elementResistances = {
    RESISTANCE6_NAME,
    RESISTANCE2_NAME,
    RESISTANCE3_NAME,
    RESISTANCE4_NAME,
    RESISTANCE5_NAME,
    RESISTANCE1_NAME,
  }
  local elementNames = {
    self.DAMAGE_SCHOOL7,
    self.DAMAGE_SCHOOL3,
    self.DAMAGE_SCHOOL4,
    self.DAMAGE_SCHOOL5,
    self.DAMAGE_SCHOOL6,
    self.DAMAGE_SCHOOL2,
  }
  local elementColors = {
    self.COLORS.ARCANE,
    self.COLORS.FIRE,
    self.COLORS.NATURE,
    self.COLORS.FROST,
    self.COLORS.SHADOW,
    self.COLORS.HOLY,
  }
  
  local ITEM_MOD_HASTE_SPELL_RATING_SHORT = ITEM_MOD_HASTE_SPELL_RATING_SHORT or strGsub(ITEM_MOD_CRIT_SPELL_RATING_SHORT, self:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING_SHORT), self:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING_SHORT))
  local ITEM_MOD_HASTE_SPELL_RATING       = ITEM_MOD_HASTE_SPELL_RATING       or strGsub(ITEM_MOD_CRIT_SPELL_RATING,       self:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING),       self:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING))
  
  local statsData = {}
  tinsert(statsData, {1, {true, true, true}, "Stamina",   SPELL_STAT3_NAME, self.ITEM_MOD_STAMINA,   self.COLORS.WHITE, self.COLORS.PALE_LIGHT_GREEN})
  tinsert(statsData, {1, {true, true, true}, "Strength",  SPELL_STAT1_NAME, self.ITEM_MOD_STRENGTH,  self.COLORS.WHITE, self.COLORS.TUMBLEWEED})
  tinsert(statsData, {0, {true, true, true}, "Agility",   SPELL_STAT2_NAME, self.ITEM_MOD_AGILITY,   self.COLORS.WHITE, self.COLORS.PUMPKIN_ORANGE})
  tinsert(statsData, {1, {true, true, true}, "Intellect", SPELL_STAT4_NAME, self.ITEM_MOD_INTELLECT, self.COLORS.WHITE, self.COLORS.JORDY_BLUE})
  tinsert(statsData, {0, {true, true, true}, "Spirit",    SPELL_STAT5_NAME, self.ITEM_MOD_SPIRIT,    self.COLORS.WHITE, self.COLORS.LIGHT_AQUA})
    
  tinsert(statsData, {1, {true, true, true}, "All Resistance", self:ChainGsub(Addon.ITEM_RESIST_ALL, {"%%%d%$", "%%"}, {"%%.", "^ *", " *$", ""}), self:ChainGsub(Addon.ITEM_RESIST_ALL, {"%%%d+%$", "%%"}), self.COLORS.WHITE, self.COLORS.YELLOW})
  
  for i, stat in ipairs{"Arcane Resistance", "Fire Resistance", "Nature Resistance", "Frost Resistance", "Shadow Resistance"} do
    tinsert(statsData, {(i == 1 and 1 or 0), {true, true, true}, stat, elementResistances[i], format(self:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), elementNames[i]), self.COLORS.WHITE, elementColors[i]})
  end
  -- {true, true, true, "Holy Resistance"  , RESISTANCE1_NAME, format(self:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), self.DAMAGE_SCHOOL2), self.COLORS.WHITE, self.COLORS.HOLY},
    
  tinsert(statsData, {1, {true, true, true}, "Defense Rating"   , ITEM_MOD_DEFENSE_SKILL_RATING_SHORT, ITEM_MOD_DEFENSE_SKILL_RATING, self.COLORS.GREEN, self.COLORS.YELLOW})
  tinsert(statsData, {1, {true, true, true}, "Dodge Rating"     , ITEM_MOD_DODGE_RATING_SHORT        , ITEM_MOD_DODGE_RATING        , self.COLORS.GREEN, self.COLORS.YELLOW})
  tinsert(statsData, {0, {true, true, true}, "Parry Rating"     , ITEM_MOD_PARRY_RATING_SHORT        , ITEM_MOD_PARRY_RATING        , self.COLORS.GREEN, self.COLORS.YELLOW})
  tinsert(statsData, {1, {true, true, true}, "Block Rating"     , ITEM_MOD_BLOCK_RATING_SHORT        , ITEM_MOD_BLOCK_RATING        , self.COLORS.GREEN, self.COLORS.YELLOW})
  tinsert(statsData, {0, {true, true, true}, "Block Value"      , ITEM_MOD_BLOCK_VALUE_SHORT         , ITEM_MOD_BLOCK_VALUE         , self.COLORS.GREEN, self.COLORS.YELLOW})
  tinsert(statsData, {0, {nil , true, true}, "Resilience Rating", ITEM_MOD_RESILIENCE_RATING_SHORT   , ITEM_MOD_RESILIENCE_RATING   , self.COLORS.GREEN, self.COLORS.YELLOW})
    
  tinsert(statsData, {1, {nil , true, true}, "Expertise Rating"        , ITEM_MOD_EXPERTISE_RATING_SHORT        , ITEM_MOD_EXPERTISE_RATING        , self.COLORS.GREEN, self.COLORS.TUMBLEWEED})
  tinsert(statsData, {1, {true, true, true}, "Attack Power"            , ITEM_MOD_ATTACK_POWER_SHORT            , ITEM_MOD_ATTACK_POWER            , self.COLORS.GREEN, self.COLORS.TUMBLEWEED})
  tinsert(statsData, {0, {true, true, true}, "Ranged Attack Power"     , ITEM_MOD_RANGED_ATTACK_POWER_SHORT     , ITEM_MOD_RANGED_ATTACK_POWER     , self.COLORS.GREEN, self.COLORS.TUMBLEWEED})
  tinsert(statsData, {0, {true, true, true}, "Attack Power In Forms"   , ITEM_MOD_FERAL_ATTACK_POWER_SHORT      , ITEM_MOD_FERAL_ATTACK_POWER      , self.COLORS.GREEN, self.COLORS.TUMBLEWEED})
  tinsert(statsData, {0, {true, true, true}, "Armor Penetration Rating", ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT, ITEM_MOD_ARMOR_PENETRATION_RATING, self.COLORS.GREEN, self.COLORS.TUMBLEWEED})
    
  tinsert(statsData, {1, {true, true, true}, "Spell Power", ITEM_MOD_SPELL_POWER_SHORT, ITEM_MOD_SPELL_POWER, self.COLORS.GREEN, self.COLORS.LILAC_GEODE})
    
  -- tinsert(statsData, {1, {true, true, true}, "Spell Damage" , ITEM_MOD_SPELL_DAMAGE_DONE_SHORT, ITEM_MOD_SPELL_DAMAGE_DONE, self.COLORS.GREEN, self.COLORS.PERIWINKLE})
  for i, stat in ipairs{"Arcane Damage", "Fire Damage", "Nature Damage", "Frost Damage", "Shadow Damage", "Holy Damage"} do
    if Addon.SPELL_DAMAGE_STATS[stat] then
      tinsert(statsData, {(i == 1 and 1 or 0), {true, true, true} , stat, format(SINGLE_DAMAGE_TEMPLATE, elementNames[i]), Addon.SPELL_DAMAGE_STATS[stat], self.COLORS.GREEN, elementColors[i]})
    end
  end
  
  tinsert(statsData, {0, {true, true, nil }, "Healing", ITEM_MOD_SPELL_HEALING_DONE_SHORT, ITEM_MOD_SPELL_HEALING_DONE, self.COLORS.GREEN, self.COLORS.LIGHT_CYAN})
    
  tinsert(statsData, {0, {true, true, true}, "Spell Penetration", ITEM_MOD_SPELL_PENETRATION_SHORT, ITEM_MOD_SPELL_PENETRATION, self.COLORS.GREEN, self.COLORS.VENUS_SLIPPER_ORCHID})
    
  tinsert(statsData, {1, {Addon.isSoD, nil , true}, "Hit Rating"                     , ITEM_MOD_HIT_RATING_SHORT        , ITEM_MOD_HIT_RATING        , self.COLORS.GREEN, self.COLORS.PINK_SHERBET})
  tinsert(statsData, {0, {Addon.isSoD, nil , true}, "Critical Strike Rating"         , ITEM_MOD_CRIT_RATING_SHORT       , ITEM_MOD_CRIT_RATING       , self.COLORS.GREEN, self.COLORS.PARIS_GREEN})
  tinsert(statsData, {0, {nil ,        nil , true}, "Haste Rating"                   , ITEM_MOD_HASTE_RATING_SHORT      , ITEM_MOD_HASTE_RATING      , self.COLORS.GREEN, self.COLORS.LEMON_LIME})
  tinsert(statsData, {1, {true,        true, nil }, "Physical Hit Rating"            , ITEM_MOD_HIT_RATING_SHORT        , ITEM_MOD_HIT_RATING        , self.COLORS.GREEN, self.COLORS.PINK_SHERBET})
  tinsert(statsData, {0, {true,        true, nil }, "Physical Critical Strike Rating", ITEM_MOD_CRIT_RATING_SHORT       , ITEM_MOD_CRIT_RATING       , self.COLORS.GREEN, self.COLORS.PARIS_GREEN})
  tinsert(statsData, {0, {nil ,        true, nil }, "Physical Haste Rating"          , ITEM_MOD_HASTE_RATING_SHORT      , ITEM_MOD_HASTE_RATING      , self.COLORS.GREEN, self.COLORS.LEMON_LIME})
  tinsert(statsData, {1, {true,        true, nil }, "Spell Hit Rating"               , ITEM_MOD_HIT_SPELL_RATING_SHORT  , ITEM_MOD_HIT_SPELL_RATING  , self.COLORS.GREEN, self.COLORS.PINK_SHERBET})
  tinsert(statsData, {0, {true,        true, nil }, "Spell Critical Strike Rating"   , ITEM_MOD_CRIT_SPELL_RATING_SHORT , ITEM_MOD_CRIT_SPELL_RATING , self.COLORS.GREEN, self.COLORS.PARIS_GREEN})
  tinsert(statsData, {0, {nil ,        true, nil }, "Spell Haste Rating"             , ITEM_MOD_HASTE_SPELL_RATING_SHORT, ITEM_MOD_HASTE_SPELL_RATING, self.COLORS.GREEN, self.COLORS.LEMON_LIME})
    
  tinsert(statsData, {1, {true, true, true}, "Health Regeneration", ITEM_MOD_HEALTH_REGENERATION_SHORT, ITEM_MOD_HEALTH_REGEN     , self.COLORS.GREEN, self.COLORS.PALE_LIGHT_GREEN})
  tinsert(statsData, {0, {true, true, true}, "Mana Regeneration"  , ITEM_MOD_MANA_REGENERATION_SHORT  , ITEM_MOD_MANA_REGENERATION, self.COLORS.GREEN, self.COLORS.JORDY_BLUE})
  
  
  
  local isReversedLocale = not ITEM_MOD_STAMINA:find"^%%"
  local GetLocaleStatFormat = isReversedLocale and function(pre, suf, capture) return format("%s %s%s", suf, capture and "?" or "", pre) end or function(pre, suf, capture) return format("%s %s%s", pre, capture and "?" or "", suf) end
  -- instead of flipping them, mess with the normal form pattern instead. format("%s %s", isBaseStat and sign or "+", normalName) vs format("%2$s %1$s", isBaseStat and sign or "+", normalName)
  
  for i, data in ipairs(statsData) do
    tinsert(self.statPrefOrder, data[1])
    
    local expacs    = {}
    local isInExpac = data[2]
    expacs[self.expansions.era]   = isInExpac[1]
    expacs[self.expansions.tbc]   = isInExpac[2]
    expacs[self.expansions.wrath] = isInExpac[3]
    
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
      
      local tooltipPattern  = data[5]
      local tooltipPattern2 = self:ChainGsub(tooltipPattern, {"%%%d%$", "%%"}, {"%%c", "%%d", "%%s"})
      
      local tooltipColor = data[6]
      local color        = data[7]
      
      self.statsInfo[stat] = {}
      local StatInfo = self.statsInfo[stat]
      
      StatInfo.tooltipColor = tooltipColor
      StatInfo.color = color
      
      local isBaseStat = strFind(tooltipPattern, "%%%d?%$?c")
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
        local strNumber, percent = strMatch(origStrNumber, "(%-?%d+)(%%?)")
        if DECIMAL_SEPERATOR ~= "." then
          strNumber = strGsub(strNumber, "%"..DECIMAL_SEPERATOR, ".")
        end
        local number = self:Round(tonumber(strNumber) * self:GetOption("mod", stat), 1 / 10^self:GetOption("precision", stat))
        strNumber = tostring(number)
        if DECIMAL_SEPERATOR ~= "." then
          strNumber = strGsub(strNumber, "%.", DECIMAL_SEPERATOR)
        end
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
        if Addon:GetOption("allow", "reword") and Addon:GetOption("doReword", stat) then
          text = ConvertToAliasForm(ApplyMod(text, normalForm))
        end
        return text
      end
      
      local function HasNumber(match1, match2)
        local strNumber = match1
        if isBaseStat then
          strNumber = match2
        end
        return tonumber((strGsub(strNumber, "%%", "")))
      end
      
      function StatInfo:ConvertToNormalForm(text)
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
        return nil
      end
      
      function StatInfo:GetDefaultForm(number)
        local strNumber = tostring(number)
        if type(number) == "string" then
          number = tonumber(strMatch(number, "%d+"))
        end
        if DECIMAL_SEPERATOR ~= "." then
          strNumber = strGsub(strNumber, "%.", DECIMAL_SEPERATOR)
        end
        return format(tooltipPattern2, isBaseStat and (number < 0 and "" or "+") or strNumber, isBaseStat and strNumber or nil)
      end
      
      function StatInfo:GetNormalName()
        return normalName
      end
    end
  end
  
  
  -- Default color settings
  
  self.statsInfo["Title"]              = {color = self.COLORS.WHITE}
  
  self.statsInfo["Quality"]            = {color = self.COLORS.WHITE}
  self.statsInfo["Heroic"]             = {color = self.COLORS.GREEN}
  self.statsInfo["ItemLevel"]          = {color = self.COLORS.DEFAULT}
  
  self.statsInfo["AlreadyBound"]       = {color = self.COLORS.WHITE}
  self.statsInfo["CharacterBound"]     = {color = self.COLORS.WHITE}
  self.statsInfo["AccountBound"]       = {color = self.COLORS.WHITE}
  self.statsInfo["Tradeable"]          = {color = self.COLORS.WHITE}
  
  self.statsInfo["Trainable"]          = {color = self.COLORS.ORANGE}
  
  self.statsInfo["Damage"]             = {color = self.COLORS.WHITE}
  self.statsInfo["DamageBonus"]        = {color = self.COLORS.WHITE}
  self.statsInfo["Speed"]              = {color = self.COLORS.WHITE}
  
  self.statsInfo["DamagePerSecond"]    = {color = self.COLORS.WHITE}
  self.statsInfo["Speedbar"]           = {color = self.COLORS.WHITE}
  
  self.statsInfo["Armor"]              = {color = self.COLORS.WHITE}
  self.statsInfo["BonusArmor"]         = {color = self.COLORS.GREEN}
  self.statsInfo["Block"]              = {color = self.COLORS.WHITE}
  
  self.statsInfo["Enchant"]            = {color = self.COLORS.GREEN}
  self.statsInfo["WeaponEnchant"]      = {color = self.COLORS.GREEN}
  self.statsInfo["Rune"]               = {color = self.COLORS.GREEN}
  
  self.statsInfo["Socket_red"]         = {color = self.COLORS.RED}
  self.statsInfo["Socket_blue"]        = {color = self.COLORS.BLUE}
  self.statsInfo["Socket_yellow"]      = {color = self.COLORS.YELLOW}
  self.statsInfo["Socket_purple"]      = {color = self.COLORS.PURPLE}
  self.statsInfo["Socket_green"]       = {color = self.COLORS.GREEN}
  self.statsInfo["Socket_orange"]      = {color = self.COLORS.ORANGE}
  self.statsInfo["Socket_prismatic"]   = {color = self.COLORS.WHITE}
  self.statsInfo["Socket_meta"]        = {color = self.COLORS.WHITE}
  
  self.statsInfo["Charges"]            = {color = self.COLORS.ORANGE}
  self.statsInfo["NoCharges"]          = {color = self.COLORS.RED}
  self.statsInfo["Cooldown"]           = {color = self.COLORS.RED}
  
  self.statsInfo["Durability"]         = {color = self.COLORS.WHITE}
  
  self.statsInfo["Reputation"]         = {color = self.COLORS.REP}
  
  self.statsInfo["MadeBy"]             = {color = self.COLORS.GREEN}
  
  self.statsInfo["SocketHint"]         = {color = self.COLORS.GREEN}
  
  self.statsInfo["Refundable"]         = {color = self.COLORS.SKY_BLUE}
  self.statsInfo["SoulboundTradeable"] = {color = self.COLORS.SKY_BLUE}
  
  self.statsInfo["StackSize"]          = {color = self.COLORS.DEFAULT}
end




local ADDON_NAME, Data = ...




local Addon = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
Addon.onSetHandlers = {}

-- Curseforge automatic packaging will comment this out
-- https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging
--@debug@
  Addon.debug = true
  
  -- GAME_LOCALE = "enUS" -- AceLocale override
  
  -- TOOLTIP_UPDATE_TIME = 10000
  
  -- DECIMAL_SEPERATOR = ","
--@end-debug@
function Addon:Debug(...)
  if self.debug then
    self:Print(...)
  end
end
function Addon:Debugf(...)
  if self.debug then
    self:Printf(...)
  end
end


Addon.AceConfig         = LibStub"AceConfig-3.0"
Addon.AceConfig         = LibStub"AceConfig-3.0"
Addon.AceConfigDialog   = LibStub"AceConfigDialog-3.0"
Addon.AceConfigRegistry = LibStub"AceConfigRegistry-3.0"
Addon.AceDB             = LibStub"AceDB-3.0"
Addon.AceDBOptions      = LibStub"AceDBOptions-3.0"

Addon.TipHooker  = LibStub"LibTipHooker-1.1-ZeraTooltip"
Addon.TipHooker2 = LibStub"LibTipHooker-1.0-ZeraTooltip"
Addon.SemVer     = LibStub"SemVer"



local buildMajor = tonumber(GetBuildInfo():match"^(%d+)%.")
if buildMajor >= 9 then
  Addon.expac = "retail"
elseif buildMajor >= 3 then
  Addon.expac = "wrath"
elseif buildMajor == 2 then
  Addon.expac = "tbc"
elseif buildMajor == 1 then
  Addon.expac = "classic"
end
Addon.isRetail  = Addon.expac == "retail"
Addon.isWrath   = Addon.expac == "wrath"
Addon.isTBC     = Addon.expac == "tbc"
Addon.isClassic = Addon.expac == "classic"




local strLower  = string.lower
local strFind   = string.find
local strMatch  = string.match
local strSub    = string.sub
local strGsub   = string.gsub
local strGmatch = string.gmatch
local strByte   = string.byte

local mathMin   = math.min
local mathMax   = math.max
local mathFloor = math.floor

local tinsert   = table.insert
local tblRemove = table.remove
local tblConcat = table.concat


local function strRemove(text, ...)
  for _, pattern in ipairs{...} do
    text = strGsub(text, pattern, "")
  end
  return text
end

function Addon:StripText(text)
  return strRemove(text, "|c%x%x%x%x%x%x%x%x", "|r", "^ +", " +$")
end

function Addon:ChainGsub(text, ...)
  for _, patterns in ipairs{...} do
    local newText = tblRemove(patterns)
    for _, oldText in ipairs(patterns) do
      text = strGsub(text, oldText, newText)
    end
  end
  return text
end

local reversedPatternsCache = {}
function Addon:ReversePattern(text)
  if not reversedPatternsCache[text] then
    reversedPatternsCache[text] = "^" .. self:ChainGsub(text, {"%%%d%$", "%%"}, {"[+-]", "%%%1"}, {"[%(%)%.]", "%%%0"}, {"%%c", "([+-])"}, {"%%d", "(%%d+)"}, {"%%s", "(.*)"}, {"|4[^:]-:[^:]-:[^:]-;", ".-"}, {"|4[^:]-:[^:]-;", ".-"}) .. "$"
  end
  return reversedPatternsCache[text]
end


function Addon:CoverSpecialCharacters(text)
  -- TODO: handle UI escape sequences here? or bypass and handle elsewhere?
  -- return self:ChainGsub(text, {"|3%-%d+%(%%s%)", "%%s"}, {"%p", "%%%0"})
  return self:ChainGsub(text, {"%p", "%%%0"})
end
function Addon:UncoverSpecialCharacters(text)
  return (strGsub(text, "%%(.)", "%1"))
end


















local L = setmetatable({}, {
  __index = function(self, key)
    rawset(self, key, key)
    if Addon.debug then
      geterrorhandler()(ADDON_NAME..": Missing entry for '"..tostring(key).."'")
    end
    return key
  end
})
Addon.L = L

L["Enable"]  = ENABLE
L["Disable"] = DISABLE
L["Enabled"] = VIDEO_OPTIONS_ENABLED
-- L["Disabled"] = ADDON_DISABLED

L["never"] = strLower(CALENDAR_REPEAT_NEVER)
L["any"]   = strLower(SPELL_TARGET_TYPE1_DESC)
L["all"]   = strLower(SPELL_TARGET_TYPE12_DESC)

L["SHIFT key"] = SHIFT_KEY
L["CTRL key"]  = CTRL_KEY
L["ALT key"]   = ALT_KEY

L["Features"] = FEATURES_LABEL

L["Stats"] = PET_BATTLE_STATS_LABEL

L["Default"] = DEFAULT
L["Current"] = REFORGE_CURRENT

L["Move Up"]        = TRACKER_SORT_MANUAL_UP
L["Move Down"]      = TRACKER_SORT_MANUAL_DOWN
L["Move to Top"]    = TRACKER_SORT_MANUAL_TOP
L["Move to Bottom"] = TRACKER_SORT_MANUAL_BOTTOM

L["Color"]  = COLOR
L["Reset"]  = RESET
L["Custom"] = CUSTOM
L["Rename"] = PET_RENAME
L["Hide"]   = HIDE

L["Base Stats"]         = PLAYERSTAT_BASE_STATS
L["Enchant"]            = ENSCRIBE
L["Weapon Enchantment"] = WEAPON_ENCHANTMENT
L["End"]                = KEY_END

L["Other Options"] = UNIT_FRAME_DROPDOWN_SUBSECTION_TITLE_OTHER
L["Weapon"] = WEAPON
-- L["Weapon Damage"] = DAMAGE_TOOLTIP
-- L["Damage Per Second"] = ITEM_MOD_DAMAGE_PER_SECOND_SHORT
L["Miscellaneous"] = MISCELLANEOUS
-- missing?
-- L["Test"]        = TEST_BUILD
L["Minimum"]     = MINIMUM
L["Maximum"]     = MAXIMUM
L["Frame Width"] = COMPACT_UNIT_FRAME_PROFILE_FRAMEWIDTH
L["Icon"] = EMBLEM_SYMBOL
L["Choose an Icon:"] = MACRO_POPUP_CHOOSE_ICON

L["All"] = ALL

L["ERROR"] = ERROR_CAPS



Addon.prefixStats = {
  [ITEM_SPELL_TRIGGER_ONEQUIP] = "Equip",
  [ITEM_SPELL_TRIGGER_ONUSE]   = "Use",
  [ITEM_SPELL_TRIGGER_ONPROC]  = "ChanceOnHit",
}





function Addon:Round(num, nearest)
  nearest = nearest or 1;
  local lower = mathFloor(num / nearest) * nearest;
  local upper = lower + nearest;
  return (upper - num < num - lower) and upper or lower;
end

function Addon:Clamp(min, num, max)
  assert(type(min) == "number", "Can't clamp. min is " .. type(min))
  assert(type(max) == "number", "Can't clamp. max is " .. type(max))
  assert(min <= max, format("Can't clamp. min (%d) > max (%d)", min, max))
  return mathMin(mathMax(num, min), max)
end


function Addon:GetHexFromColor(r, g, b)
  return format("%.2x%.2x%.2x", r, g, b)
end
function Addon:ConvertColorFromBlizzard(r, g, b)
  return self:GetHexFromColor(Addon:Round(r*255, 1), Addon:Round(g*255, 1), Addon:Round(b*255, 1))
end
function Addon:GetTextColorAsHex(frame)
  return self:ConvertColorFromBlizzard(frame:GetTextColor())
end

function Addon:ConvertColorToBlizzard(hex)
  return tonumber(strSub(hex, 1, 2), 16) / 255, tonumber(strSub(hex, 3, 4), 16) / 255, tonumber(strSub(hex, 5, 6), 16) / 255, 1
end
function Addon:SetTextColorFromHex(frame, hex)
  frame:SetTextColor(self:ConvertColorToBlizzard(hex))
end

function Addon:MakeColorCode(hex, text)
  return format("|cff%s%s%s", hex, text or "", text and "|r" or "")
end


function Addon:Map(t, ValMap, KeyMap)
  if type(KeyMap) == "table" then
    local keyTbl = KeyMap
    KeyMap = function(v, k, self) return keyTbl[k] end
  end
  if type(ValMap) == "table" then
    local valTbl = KeyMap
    ValMap = function(v, k, self) return valTbl[k] end
  end
  local new = {}
  for k, v in next, t, nil do
    local key, val = k, v
    if KeyMap then
      key = KeyMap(v, k, t)
    end
    if ValMap then
      val = ValMap(v, k, t)
    end
    if key then
      new[key] = val
    end
  end
  local meta = getmetatable(t)
  if meta then
    setmetatable(new, meta)
  end
  return new
end

function Addon:MakeLookupTable(t, val, keepOrigVals)
  local ValFunc
  if val ~= nil then
    if type(val) == "function" then
      ValFunc = val
    else
      ValFunc = function() return val end
    end
  end
  local new = {}
  for k, v in next, t, nil do
    if ValFunc then
      new[v] = ValFunc(v, k, t)
    else
      new[v] = k
    end
    if keepOrigVals and new[k] == nil then
      new[k] = v
    end
  end
  return new
end



Addon.statList = {
  classic = {},
  tbc     = {},
  wrath   = {},
}
Addon.statsInfo = setmetatable({}, {__index = function() return {} end})
Addon.statOrder = {}


Addon.defaultRewordLocaleOverrides    = {}
Addon.defaultModLocaleOverrides       = {}
Addon.defaultPrecisionLocaleOverrides = {}
Addon.localeExtras                    = {}

function Addon:AddDefaultRewordByLocale(stat, val)
  Addon.defaultRewordLocaleOverrides[stat] = val
end
function Addon:AddDefaultModByLocale(stat, val)
  Addon.defaultModLocaleOverrides[stat] = val
end
function Addon:AddDefaultPrecisionByLocale(stat, val)
  Addon.defaultPrecisionLocaleOverrides[stat] = val
end

function Addon:AddExtraStatCapture(stat, ...)
  if not Addon.localeExtras[stat] then
    Addon.localeExtras[stat] = {}
  end
  for i, rule in ipairs{...} do
    table.insert(Addon.localeExtras[stat], rule)
  end
end

local replacementKeys = {}
function Addon:AddExtraReplacement(label, ...)
  if not replacementKeys[label] then
    table.insert(Addon.localeExtras, {label = label})
    replacementKeys[label] = #Addon.localeExtras
  end
  for i, rule in ipairs{...} do
    table.insert(Addon.localeExtras[replacementKeys[label]], rule)
  end
end



do
  Addon.MY_RACE_NAME = UnitRace"player"
  
  -- Races: Human, Orc, Dwarf, Night Elf, Undead, Tauren, Gnome, Troll, Blood Elf, Draenei
  local raceIDs = {}
  raceIDs.classic = {1, 2, 3, 4, 5, 6, 7, 8}
  raceIDs.tbc     = {1, 2, 3, 4, 5, 6, 7, 8, 10, 11}
  raceIDs.wrath   = raceIDs.tbc
  
  Addon.raceNames = {}
  
  local allRaces     = {}
  local factionRaces = {Alliance = {}, Horde = {}}
  
  for _, raceID in ipairs(raceIDs[Addon.expac]) do
    local raceName = C_CreatureInfo.GetRaceInfo(raceID).raceName
    local factionTag = C_CreatureInfo.GetFactionInfo(raceID).groupTag
    Addon.raceNames[raceID] = raceName
    
    tinsert(allRaces, raceName)
    tinsert(factionRaces[factionTag], raceName)
  end
  Addon.uselessRaceStrings = {}
  local sample = format(ITEM_RACES_ALLOWED, tblConcat(allRaces, ", "))
  Addon.uselessRaceStrings[1] = sample -- used as an example in config
  Addon.uselessRaceStrings[sample] = true
  Addon.uselessRaceStrings[format(ITEM_RACES_ALLOWED, tblConcat(factionRaces.Alliance, ", "))] = true
  Addon.uselessRaceStrings[format(ITEM_RACES_ALLOWED, tblConcat(factionRaces.Horde, ", "))] = true
end



do
  Addon.MY_CLASS = select(2, UnitClassBase"player")
  
  -- WARRIOR, PALADIN, HUNTER, ROGUE, PRIEST, DEATHKNIGHT, SHAMAN, MAGE, WARLOCK, MONK, DRUID, DEMONHUNTER
  local ID = {}
  for i = 1, GetNumClasses() do
    local classInfo = C_CreatureInfo.GetClassInfo(i)
    if classInfo then
      ID[classInfo.classFile] = classInfo.classID
    end
  end
  
  local weapon      = Enum.ItemClass.Weapon
  local subWeapon   = Enum.ItemWeaponSubclass
  local armor       = Enum.ItemClass.Armor
  local subArmor    = Enum.ItemArmorSubclass
  local usableTypes = Addon:MakeLookupTable({weapon, armor}, function() return {} end)
  
  usableTypes[weapon][subWeapon.Unarmed]  = Addon:MakeLookupTable{ID.DRUID,       ID.HUNTER,  ID.ROGUE,   ID.SHAMAN,  ID.WARRIOR} -- Fist Weapons
  usableTypes[weapon][subWeapon.Axe1H]    = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.HUNTER,  ID.PALADIN, ID.ROGUE,   ID.SHAMAN,  ID.WARRIOR}
  usableTypes[weapon][subWeapon.Axe2H]    = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.HUNTER,  ID.PALADIN, ID.SHAMAN,  ID.WARRIOR}
  usableTypes[weapon][subWeapon.Bows]     = Addon:MakeLookupTable{ID.HUNTER,      ID.ROGUE,   ID.WARRIOR}
  usableTypes[weapon][subWeapon.Mace1H]   = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.DRUID,   ID.PALADIN, ID.PRIEST,  ID.ROGUE,   ID.SHAMAN,  ID.WARRIOR}
  usableTypes[weapon][subWeapon.Mace2H]   = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.DRUID,   ID.PALADIN, ID.SHAMAN,  ID.WARRIOR}
  usableTypes[weapon][subWeapon.Polearm]  = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.DRUID,   ID.HUNTER,  ID.PALADIN, ID.WARRIOR}
  usableTypes[weapon][subWeapon.Sword1H]  = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.HUNTER,  ID.MAGE,    ID.PALADIN, ID.ROGUE,   ID.WARLOCK, ID.WARRIOR}
  usableTypes[weapon][subWeapon.Sword2H]  = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.HUNTER,  ID.PALADIN, ID.WARRIOR}
  usableTypes[weapon][subWeapon.Staff]    = Addon:MakeLookupTable{ID.DRUID,       ID.HUNTER,  ID.MAGE,    ID.PRIEST,  ID.SHAMAN,  ID.WARLOCK, ID.WARRIOR}
  usableTypes[weapon][subWeapon.Dagger]   = Addon:MakeLookupTable{ID.DRUID,       ID.HUNTER,  ID.MAGE,    ID.PRIEST,  ID.ROGUE,   ID.SHAMAN,  ID.WARLOCK, ID.WARRIOR}
  usableTypes[weapon][subWeapon.Guns]     = Addon:MakeLookupTable{ID.HUNTER,      ID.ROGUE,   ID.WARRIOR}
  usableTypes[weapon][subWeapon.Crossbow] = Addon:MakeLookupTable{ID.HUNTER,      ID.ROGUE,   ID.WARRIOR}
  usableTypes[weapon][subWeapon.Thrown]   = Addon:MakeLookupTable{ID.HUNTER,      ID.ROGUE,   ID.WARRIOR}
  usableTypes[weapon][subWeapon.Wand]     = Addon:MakeLookupTable{ID.MAGE,        ID.PRIEST,  ID.WARLOCK}
  
  usableTypes[armor][subArmor.Leather]    = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.DRUID,   ID.HUNTER,  ID.PALADIN, ID.ROGUE,   ID.SHAMAN,  ID.WARRIOR}
  usableTypes[armor][subArmor.Mail]       = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.HUNTER,  ID.PALADIN, ID.SHAMAN,  ID.WARRIOR}
  usableTypes[armor][subArmor.Plate]      = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.PALADIN, ID.WARRIOR}
  usableTypes[armor][subArmor.Shield]     = Addon:MakeLookupTable{ID.PALADIN,     ID.SHAMAN,  ID.WARRIOR}
  usableTypes[armor][subArmor.Libram]     = Addon:MakeLookupTable{ID.PALADIN}
  usableTypes[armor][subArmor.Idol]       = Addon:MakeLookupTable{ID.DRUID}
  usableTypes[armor][subArmor.Totem]      = Addon:MakeLookupTable{ID.SHAMAN}
  usableTypes[armor][subArmor.Sigil]      = Addon:MakeLookupTable{ID.DEATHKNIGHT}
  -- usableTypes[weapon][subWeapon.Warglaive]   = Addon:MakeLookupTable{}
  -- usableTypes[weapon][subWeapon.Bearclaw]    = Addon:MakeLookupTable{}
  -- usableTypes[weapon][subWeapon.Catclaw]     = Addon:MakeLookupTable{}
  -- usableTypes[weapon][subWeapon.Generic]     = Addon:MakeLookupTable{}
  -- usableTypes[weapon][subWeapon.Obsolete3]   = Addon:MakeLookupTable{} -- Spears
  -- usableTypes[weapon][subWeapon.Fishingpole] = Addon:MakeLookupTable{}
  
  -- usableTypes[armor][subArmor.Generic]       = Addon:MakeLookupTable{}
  -- usableTypes[armor][subArmor.Cloth]         = Addon:MakeLookupTable{}
  -- usableTypes[armor][subArmor.Cosmetic]      = Addon:MakeLookupTable{}
  -- usableTypes[armor][subArmor.Relic]         = Addon:MakeLookupTable{}
  
  
  local dualWielders = Addon:MakeLookupTable{ID.DEATHKNIGHT, ID.HUNTER, ID.ROGUE, ID.SHAMAN, ID.WARRIOR}
  
  local MY_CLASS = Addon.MY_CLASS
  function Addon:IsItemUsable(itemID, classID)
    local invType, _, itemClassID, subClassID = select(4, GetItemInfoInstant(itemID))
    if usableTypes[itemClassID] and usableTypes[itemClassID][subClassID] then
      local class = classID or MY_CLASS
      return usableTypes[itemClassID][subClassID][class] and (invType ~= "INVTYPE_WEAPONOFFHAND" or dualWielders[class]) and true or false
    end
    return true
  end
end





function Addon:RegenerateStatOrder()
  wipe(self.statList[self.expac])
  wipe(self.statOrder)
  for stat in strGmatch(self:GetOption("order", self.expac), "[^,]+") do
    tinsert(self.statList[self.expac], stat)
    self.statOrder[stat] = #self.statList[self.expac]
  end
end



local function rgb(r, g, b)
  return Addon:GetHexFromColor(r, g, b)
end


-- https://colornamer.robertcooper.me/
Addon.COLORS = {
  WHITE  = rgb(255, 255, 255),
  GRAY   = rgb(127, 127, 127),
  RED    = rgb(255,  32,  32),
  ORANGE = rgb(255, 127,  32),
  GREEN  = rgb(  0, 255,   0),
  BLUE   = rgb(  0,   0, 255),

  ARCANE = rgb(255, 127, 255),
  FIRE   = rgb(255, 128,   0),
  NATURE = rgb( 76, 255,  76),
  FROST  = rgb(127, 255, 255),
  SHADOW = rgb(127, 127, 255),
  HOLY   = rgb(255, 229, 127),

  HONEYSUCKLE          = rgb(237, 252, 132),
  LIGHT_YELLOW_GREEN   = rgb(204, 253, 127),
  REEF                 = rgb(201, 255, 162),
  PALE_LIGHT_GREEN     = rgb(177, 252, 153),
  FOAM_GREEN           = rgb(144, 253, 169),
  PARIS_GREEN          = rgb( 80, 200, 120),
  LEMON_LIME           = rgb(191, 254,  40),

  YELLOW               = rgb(255, 255,   0),
  SANDY_YELLOW         = rgb(253, 238, 115),

  CITRON               = rgb(158, 169,  31),
  BRASS                = rgb(181, 166,  66),

  TUMBLEWEED           = rgb(222, 166, 129),
  ATOMIC_TANGERINE     = rgb(255, 153, 102),
  PUMPKIN_ORANGE       = rgb(248, 114,  23),

  SUNSET_ORANGE        = rgb(253,  94,  83),
  ROSSO_CORSA          = rgb(212,   0,   0),

  TICKLE_ME_PINK       = rgb(253, 135, 178),
  PINK_SHERBET         = rgb(247, 143, 167),
  BLUSH_PINK           = rgb(230, 169, 236),
  LIGHT_FUSCHIA_PINK   = rgb(249, 132, 239),
  VENUS_SLIPPER_ORCHID = rgb(221, 101, 253),
  PURPLE_PIZZAZZ       = rgb(255,  80, 218),
  BRIGHT_NEON_PINK     = rgb(244,  51, 255),

  LILAC                = rgb(206, 162, 253),
  PERIWINKLE           = rgb(150, 136, 253),
  PURPLE_MIMOSA        = rgb(158, 123, 255),
  HELIOTROPE_PURPLE    = rgb(212,  98, 255),
  NEON_PURPLE          = rgb(188,  19, 254),

  LIGHT_AQUA           = rgb(140, 255, 219),
  LIGHT_CYAN           = rgb(172, 255, 252),
  FRENCH_PASS          = rgb(189, 237, 253),
  BABY_BLUE            = rgb(162, 207, 254),
  JORDY_BLUE           = rgb(138, 185, 241),
  DENIM_BLUE           = rgb(121, 186, 236),
  CRYSTAL_BLUE         = rgb( 92, 179, 255),
}


do
  local ITEM_MOD_HASTE_SPELL_RATING_SHORT = ITEM_MOD_HASTE_SPELL_RATING_SHORT or strGsub(ITEM_MOD_CRIT_SPELL_RATING_SHORT, Addon:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING_SHORT), Addon:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING_SHORT))
  local ITEM_MOD_HASTE_SPELL_RATING       = ITEM_MOD_HASTE_SPELL_RATING       or strGsub(ITEM_MOD_CRIT_SPELL_RATING,       Addon:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING),       Addon:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING))
  
  
  local statsData = {
    {true, true, true, "Stamina"   , SPELL_STAT3_NAME , ITEM_MOD_STAMINA   , Addon.COLORS.WHITE, Addon.COLORS.PALE_LIGHT_GREEN},
    {true, true, true, "Strength"  , SPELL_STAT1_NAME , ITEM_MOD_STRENGTH  , Addon.COLORS.WHITE, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Agility"   , SPELL_STAT2_NAME , ITEM_MOD_AGILITY   , Addon.COLORS.WHITE, Addon.COLORS.PUMPKIN_ORANGE},
    {true, true, true, "Intellect" , SPELL_STAT4_NAME , ITEM_MOD_INTELLECT , Addon.COLORS.WHITE, Addon.COLORS.JORDY_BLUE},
    {true, true, true, "Spirit"    , SPELL_STAT5_NAME , ITEM_MOD_SPIRIT    , Addon.COLORS.WHITE, Addon.COLORS.LIGHT_AQUA},
    
    -- {true, true, true, "Arcane Resistance", RESISTANCE6_NAME, format(strGsub(Addon:CoverSpecialCharacters(ITEM_RESIST_SINGLE), "%%%%s", "%%s"), STRING_SCHOOL_ARCANE), Addon.COLORS.WHITE, Addon.COLORS.ARCANE},
    -- {true, true, true, "Fire Resistance"  , RESISTANCE2_NAME, format(strGsub(Addon:CoverSpecialCharacters(ITEM_RESIST_SINGLE), "%%%%s", "%%s"), STRING_SCHOOL_FIRE  ), Addon.COLORS.WHITE, Addon.COLORS.FIRE},
    -- {true, true, true, "Nature Resistance", RESISTANCE3_NAME, format(strGsub(Addon:CoverSpecialCharacters(ITEM_RESIST_SINGLE), "%%%%s", "%%s"), STRING_SCHOOL_NATURE), Addon.COLORS.WHITE, Addon.COLORS.NATURE},
    -- {true, true, true, "Frost Resistance" , RESISTANCE4_NAME, format(strGsub(Addon:CoverSpecialCharacters(ITEM_RESIST_SINGLE), "%%%%s", "%%s"), STRING_SCHOOL_FROST ), Addon.COLORS.WHITE, Addon.COLORS.FROST},
    -- {true, true, true, "Shadow Resistance", RESISTANCE5_NAME, format(strGsub(Addon:CoverSpecialCharacters(ITEM_RESIST_SINGLE), "%%%%s", "%%s"), STRING_SCHOOL_SHADOW), Addon.COLORS.WHITE, Addon.COLORS.SHADOW},
    -- -- {true, true, true, "Holy Resistance"  , RESISTANCE1_NAME, format(strGsub(Addon:CoverSpecialCharacters(ITEM_RESIST_SINGLE), "%%%%s", "%%s"), STRING_SCHOOL_HOLY  ), Addon.COLORS.WHITE, Addon.COLORS.HOLY},
    
    {true, true, true, "Arcane Resistance", RESISTANCE6_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%[^s]", "%%%0"}), STRING_SCHOOL_ARCANE), Addon.COLORS.WHITE, Addon.COLORS.ARCANE},
    {true, true, true, "Fire Resistance"  , RESISTANCE2_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%[^s]", "%%%0"}), STRING_SCHOOL_FIRE  ), Addon.COLORS.WHITE, Addon.COLORS.FIRE},
    {true, true, true, "Nature Resistance", RESISTANCE3_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%[^s]", "%%%0"}), STRING_SCHOOL_NATURE), Addon.COLORS.WHITE, Addon.COLORS.NATURE},
    {true, true, true, "Frost Resistance" , RESISTANCE4_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%[^s]", "%%%0"}), STRING_SCHOOL_FROST ), Addon.COLORS.WHITE, Addon.COLORS.FROST},
    {true, true, true, "Shadow Resistance", RESISTANCE5_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%[^s]", "%%%0"}), STRING_SCHOOL_SHADOW), Addon.COLORS.WHITE, Addon.COLORS.SHADOW},
    -- {true, true, true, "Holy Resistance"  , RESISTANCE1_NAME, format(strGsub(Addon:ChainGsub(ITEM_RESIST_SINGLE), {"%%[^s]", "%%0"}), STRING_SCHOOL_HOLY  ), Addon.COLORS.WHITE, Addon.COLORS.HOLY},
    
    {true, true, true, "Defense Rating"   , ITEM_MOD_DEFENSE_SKILL_RATING_SHORT, ITEM_MOD_DEFENSE_SKILL_RATING, Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Dodge Rating"     , ITEM_MOD_DODGE_RATING_SHORT        , ITEM_MOD_DODGE_RATING        , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Parry Rating"     , ITEM_MOD_PARRY_RATING_SHORT        , ITEM_MOD_PARRY_RATING        , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Block Rating"     , ITEM_MOD_BLOCK_RATING_SHORT        , ITEM_MOD_BLOCK_RATING        , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Block Value"      , ITEM_MOD_BLOCK_VALUE_SHORT         , ITEM_MOD_BLOCK_VALUE         , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Resilience Rating", ITEM_MOD_RESILIENCE_RATING_SHORT   , ITEM_MOD_RESILIENCE_RATING   , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    
    {true, true, true, "Expertise Rating"        , ITEM_MOD_EXPERTISE_RATING_SHORT        , ITEM_MOD_EXPERTISE_RATING        , Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Attack Power"            , ITEM_MOD_ATTACK_POWER_SHORT            , ITEM_MOD_ATTACK_POWER            , Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Attack Power In Forms"   , ITEM_MOD_FERAL_ATTACK_POWER_SHORT      , ITEM_MOD_FERAL_ATTACK_POWER      , Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Armor Penetration Rating", ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT, ITEM_MOD_ARMOR_PENETRATION_RATING, Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    
    {nil , nil , true, "Spell Power" , ITEM_MOD_SPELL_POWER_SHORT       , ITEM_MOD_SPELL_POWER       , Addon.COLORS.GREEN, Addon.COLORS.PERIWINKLE},
    {true, true, nil , "Healing"     , ITEM_MOD_SPELL_HEALING_DONE_SHORT, ITEM_MOD_SPELL_HEALING_DONE, Addon.COLORS.GREEN, Addon.COLORS.LIGHT_CYAN},
    {true, true, nil , "Spell Damage", ITEM_MOD_SPELL_DAMAGE_DONE_SHORT , ITEM_MOD_SPELL_DAMAGE_DONE , Addon.COLORS.GREEN, Addon.COLORS.PERIWINKLE},
    
    {true, true, true, "Spell Penetration", ITEM_MOD_SPELL_PENETRATION_SHORT, ITEM_MOD_SPELL_PENETRATION, Addon.COLORS.GREEN, Addon.COLORS.VENUS_SLIPPER_ORCHID},
    
    {nil , nil , true, "Hit Rating"                     , ITEM_MOD_HIT_RATING_SHORT        , ITEM_MOD_HIT_RATING        , Addon.COLORS.GREEN, Addon.COLORS.PINK_SHERBET},
    {nil , nil , true, "Critical Strike Rating"         , ITEM_MOD_CRIT_RATING_SHORT       , ITEM_MOD_CRIT_RATING       , Addon.COLORS.GREEN, Addon.COLORS.PARIS_GREEN} ,
    {nil , nil , true, "Haste Rating"                   , ITEM_MOD_HASTE_RATING_SHORT      , ITEM_MOD_HASTE_RATING      , Addon.COLORS.GREEN, Addon.COLORS.LEMON_LIME}  ,
    {true, true, nil , "Physical Hit Rating"            , ITEM_MOD_HIT_RATING_SHORT        , ITEM_MOD_HIT_RATING        , Addon.COLORS.GREEN, Addon.COLORS.PINK_SHERBET},
    {true, true, nil , "Physical Critical Strike Rating", ITEM_MOD_CRIT_RATING_SHORT       , ITEM_MOD_CRIT_RATING       , Addon.COLORS.GREEN, Addon.COLORS.PARIS_GREEN},
    {nil , true, nil , "Physical Haste Rating"          , ITEM_MOD_HASTE_RATING_SHORT      , ITEM_MOD_HASTE_RATING      , Addon.COLORS.GREEN, Addon.COLORS.LEMON_LIME},
    {true, true, nil , "Spell Hit Rating"               , ITEM_MOD_HIT_SPELL_RATING_SHORT  , ITEM_MOD_HIT_SPELL_RATING  , Addon.COLORS.GREEN, Addon.COLORS.PINK_SHERBET},
    {true, true, nil , "Spell Critical Strike Rating"   , ITEM_MOD_CRIT_SPELL_RATING_SHORT , ITEM_MOD_CRIT_SPELL_RATING , Addon.COLORS.GREEN, Addon.COLORS.PARIS_GREEN},
    {nil , true, nil , "Spell Haste Rating"             , ITEM_MOD_HASTE_SPELL_RATING_SHORT, ITEM_MOD_HASTE_SPELL_RATING, Addon.COLORS.GREEN, Addon.COLORS.LEMON_LIME},
    
    {true, true, true, "Health Regeneration", ITEM_MOD_HEALTH_REGENERATION_SHORT, ITEM_MOD_HEALTH_REGEN     , Addon.COLORS.GREEN, Addon.COLORS.PALE_LIGHT_GREEN},
    {true, true, true, "Mana Regeneration"  , ITEM_MOD_MANA_REGENERATION_SHORT  , ITEM_MOD_MANA_REGENERATION, Addon.COLORS.GREEN, Addon.COLORS.JORDY_BLUE},
    
    
    -- {"Ranged Attack Power", ITEM_MOD_RANGED_ATTACK_POWER_SHORT     , ITEM_MOD_RANGED_ATTACK_POWER},
  }
  
  
  local isReversedLocale = not ITEM_MOD_STAMINA:find"^%%"
  local GetLocaleStatFormat = ITEM_MOD_STAMINA:find"^%%" and function(pre, suf) return format("%s %s", pre, suf) end or function(pre, suf) return format("%s %s", suf, pre) end
  -- instead of flipping them, mess with the normal form pattern instead. format("%s %s", isBaseStat and sign or "+", normalName) vs format("%2$s %1$s", isBaseStat and sign or "+", normalName)
  
  for i, data in ipairs(statsData) do
    local expacs = {}
    expacs.classic       = data[1]
    expacs.tbc           = data[2]
    expacs.wrath         = data[3]
    local stat           = data[4]
    
    
    for expac, list in pairs(Addon.statList) do
      if expacs[expac] then
        tinsert(list, stat)
      end
    end
    if expacs[Addon.expac] then
      local normalName     = data[5]
      -- local function ReorderByLocale() return GetLocaleStatFormat(reorderLocaleMode, normalName) end
      -- local normalPattern  = GetLocaleStatFormat(normalName)
      
      local tooltipPattern = data[6]
      local tooltipPattern2 = strGsub(strGsub(tooltipPattern, "%%c", "%%s"), "%%d", "%%s")
      
      local tooltipColor   = data[7]
      
      local color   = data[8]
      
      Addon.statsInfo[stat] = {}
      local StatInfo = Addon.statsInfo[stat]
      
      StatInfo.tooltipColor = tooltipColor
      StatInfo.color = color
      
      local isBaseStat = strFind(tooltipPattern, "%%%d?%$?c")
      local reorderLocaleMode = isBaseStat and "%s%s" or "+%s"
      
      
      
      
      
      
      local normalNameReplacePattern = Addon:CoverSpecialCharacters(normalName)
      
      local normalFormPattern  = GetLocaleStatFormat(isBaseStat and "%1$s%2$s" or "+%1$s", normalName)
      local normalFormCapture  = strGsub(Addon:ReversePattern(GetLocaleStatFormat(isBaseStat and "%c%s" or "+%s", normalName)), "%$", "%%.?%0")
      local normalFormPattern2 = GetLocaleStatFormat(isBaseStat and "%s%s" or "+%s", normalName)
      -- local aliasPattern = 
      
      
      
      local function ApplyMod(text, normalForm)
        local match1, match2 = strMatch(normalForm, normalFormCapture)
        local origStrNumber = match1 .. (match2 or "")
        local strNumber, percent = strMatch(origStrNumber, "(%d+)(%%?)")
        if DECIMAL_SEPERATOR ~= "." then
          strNumber = strGsub(strNumber, "%"..DECIMAL_SEPERATOR, ".")
        end
        local number = Addon:Round(tonumber(strNumber) * Addon:GetOption("mod", stat), 1 / 10^Addon:GetOption("precision", stat))
        strNumber = tostring(number)
        if DECIMAL_SEPERATOR ~= "." then
          strNumber = strGsub(strNumber, "%.", DECIMAL_SEPERATOR)
        end
        if isBaseStat and number > 0 then
          strNumber = "+" .. strNumber
        end
        return strGsub(text, Addon:CoverSpecialCharacters(origStrNumber), Addon:CoverSpecialCharacters(strNumber .. percent))
      end
      
      local function ConvertToAliasForm(text)
        local alias = Addon:GetOption("reword", stat)
        if alias and alias ~= "" and alias ~= normalName then
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
        local match1, match2 = strMatch(text, Addon:ReversePattern(tooltipPattern))
        if match1 then
          if not HasNumber(match1, match2) then return end
          return format(normalFormPattern, match1, match2)
        end
        local match1, match2 = strMatch(strLower(text), strLower(normalFormCapture))
        if match1 then
          if not HasNumber(match1, match2) then return end
          return format(normalFormPattern, match1, match2)
        end
        for _, rule in ipairs(Addon.localeExtras[stat] or {}) do
          local matches = rule.OUTPUT and {rule.OUTPUT(strMatch(text, rule.INPUT))} or {strMatch(text, rule.INPUT)}
          if #matches > 0 then
            if not HasNumber(matches[1], matches[2]) then return end
            return format(normalFormPattern, matches[1], matches[2])
          end
        end
        return nil
      end
      
      function StatInfo:GetDefaultForm(number)
        local strNumber = tostring(number)
        if DECIMAL_SEPERATOR ~= "." then
          strNumber = strGsub(strNumber, "%.", DECIMAL_SEPERATOR)
        end
        return format(tooltipPattern2, isBaseStat and (number < 0 and "" or "+") or strNumber, isBaseStat and strNumber or nil)
      end
    end
  end
  
  Addon.statsInfo["Trainable"]       = {color = Addon.COLORS.ORANGE}
  Addon.statsInfo["Damage"]          = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["DamagePerSecond"] = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["Enchant"]         = {color = Addon.COLORS.GREEN}
  Addon.statsInfo["WeaponEnchant"]   = {color = Addon.COLORS.GREEN}
  Addon.statsInfo["Speed"]           = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["Speedbar"]        = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["SocketHint"]      = {color = Addon.COLORS.GREEN}
end












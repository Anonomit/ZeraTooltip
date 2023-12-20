
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







--  ███████╗████████╗██████╗ ██╗███╗   ██╗ ██████╗ ███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝ ██╔════╝
--  ███████╗   ██║   ██████╔╝██║██╔██╗ ██║██║  ███╗███████╗
--  ╚════██║   ██║   ██╔══██╗██║██║╚██╗██║██║   ██║╚════██║
--  ███████║   ██║   ██║  ██║██║██║ ╚████║╚██████╔╝███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

do
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
    for i, patterns in ipairs{...} do
      local newText = patterns[#patterns]
      for i = 1, #patterns - 1 do
        local oldText = patterns[i]
        text = strGsub(text, oldText, newText)
      end
    end
    return text
  end
  
  local chainGsubPattern = {
    {"%%%d%$", "%%"},               -- koKR ITEM_RESIST_SINGLE: "%3$s 저항력 %1$c%2$d" -> "%s 저항력 %c%d"
    {"|3%-%d+%((.+)%)", "%1"},      -- ruRU ITEM_RESIST_SINGLE: "%c%d к сопротивлению |3-7(%s)" -> %c%d к сопротивлению %s
    {"[().+-]", "%%%0"},            -- cover special characters with escape codes
    {"%%c", "([+-])"},              -- "%c" -> "([+-])"
    {"%%d", "(%%d+)"},              -- "%d" -> "(%d+)"
    {"%%s", "(.*)"},                -- "%s" -> "(.*)"
    {"|4[^:]-:[^:]-:[^:]-;", ".-"}, -- removes |4singular:plural;
    {"|4[^:]-:[^:]-;", ".-"},       -- removes ruRU |4singular:plural1:plural2;
  }
  local reversedPatternsCache = {}
  function Addon:ReversePattern(text)
    reversedPatternsCache[text] = reversedPatternsCache[text] or ("^" .. self:ChainGsub(text, unpack(chainGsubPattern)) .. "$")
    return reversedPatternsCache[text]
  end
  
  
  function Addon:CoverSpecialCharacters(text)
    return self:ChainGsub(text, {"%p", "%%%0"})
  end
  function Addon:UncoverSpecialCharacters(text)
    return (strGsub(text, "%%(.)", "%1"))
  end
  
  
  
  function Addon:MakeAtlas(atlas, height, width, hex)
    height = tostring(height or "0")
    local tex = "|A:" .. atlas .. ":" .. height .. ":" .. tostring(width or height)
    if hex then
      tex = tex .. format(":::%d:%d:%d", self:ConvertHexToRGB(hex))
    end
    return tex .. "|a"
  end
  function Addon:MakeIcon(texture, height, width, hex)
    local tex = "|T" .. texture .. ":" .. tostring(height or "0") .. ":"
    if width then
      tex = tex .. width
    end
    if hex then
      tex = tex .. format(":::1:1:0:1:0:1:%d:%d:%d", self:ConvertHexToRGB(hex))
    end
    return tex .. "|t"
  end
  function Addon:UnmakeIcon(texture)
    return strMatch(texture, "|T([^:]+):")
  end
  
  function Addon:InsertIcon(text, stat, customTexture)
    if self:GetOption("doIcon", stat) then
      if self:GetOption("iconSpace", stat) then
        text = " " .. text
      end
      text = self:MakeIcon(customTexture or self:GetOption("icon", stat), self:GetOption("iconSizeManual", stat) and self:GetOption("iconSize", stat) or nil) .. text
    end
    return text
  end
  function Addon:InsertAtlas(text, stat, customTexture)
    if self:GetOption("doIcon", stat) then
      if self:GetOption("iconSpace", stat) then
        text = " " .. text
      end
      text = self:MakeAtlas(customTexture or self:GetOption("icon", stat), self:GetOption("iconSizeManual", stat) and self:GetOption("iconSize", stat) or nil) .. text
    end
    return text
  end
end



--  ██╗      ██████╗  ██████╗ █████╗ ██╗     ███████╗    ███████╗██╗  ██╗████████╗██████╗  █████╗ ███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗██║     ██╔════╝    ██╔════╝╚██╗██╔╝╚══██╔══╝██╔══██╗██╔══██╗██╔════╝
--  ██║     ██║   ██║██║     ███████║██║     █████╗      █████╗   ╚███╔╝    ██║   ██████╔╝███████║███████╗
--  ██║     ██║   ██║██║     ██╔══██║██║     ██╔══╝      ██╔══╝   ██╔██╗    ██║   ██╔══██╗██╔══██║╚════██║
--  ███████╗╚██████╔╝╚██████╗██║  ██║███████╗███████╗    ███████╗██╔╝ ██╗   ██║   ██║  ██║██║  ██║███████║
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚══════╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝

do
  local defaultRewordLocaleOverrides    = {}
  local defaultModLocaleOverrides       = {}
  local defaultPrecisionLocaleOverrides = {}
  local localeExtraStatCaptures         = {}
  local localeExtraReplacements         = {}
  
  function Addon:AddDefaultRewordByLocale(stat, val)
    defaultRewordLocaleOverrides[stat] = val
  end
  function Addon:AddDefaultModByLocale(stat, val)
    defaultModLocaleOverrides[stat] = val
  end
  function Addon:AddDefaultPrecisionByLocale(stat, val)
    defaultPrecisionLocaleOverrides[stat] = val
  end
  
  function Addon:GetExtraStatCapture(stat)
    return localeExtraStatCaptures[stat]
  end
  function Addon:AddExtraStatCapture(stat, ...)
    localeExtraStatCaptures[stat] = localeExtraStatCaptures[stat] or {}
    for i, rule in ipairs{...} do
      rule.INPUT = strLower(rule.INPUT)
      tinsert(localeExtraStatCaptures[stat], rule)
    end
  end
  
  local replacementKeys = {}
  function Addon:GetExtraReplacements()
    return localeExtraReplacements
  end
  function Addon:AddExtraReplacement(label, ...)
    if not replacementKeys[label] then
      tinsert(localeExtraReplacements, {label = label})
      replacementKeys[label] = #localeExtraReplacements
    end
    for i, rule in ipairs{...} do
      tinsert(localeExtraReplacements[replacementKeys[label]], rule)
    end
  end
  
  
  -- these functions are run when relevant settings are reset/initialized
  local localeDefaultOverrideMethods = {
    SetDefaultRewordByLocale    = {"reword"   , defaultRewordLocaleOverrides},
    SetDefaultModByLocale       = {"mod"      , defaultModLocaleOverrides},
    SetDefaultPrecisionByLocale = {"precision", defaultPrecisionLocaleOverrides},
  }
  for method, data in pairs(localeDefaultOverrideMethods) do
    local field, overrides = unpack(data, 1, 2)
    Addon[method] = function(self, stat)
      if stat then
        if overrides[stat] then
          Addon.SetOption(self, overrides[stat], field, stat)
        end
      else
        for stat, val in pairs(overrides) do
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
end



--  ███╗   ███╗██╗███████╗ ██████╗
--  ████╗ ████║██║██╔════╝██╔════╝
--  ██╔████╔██║██║███████╗██║     
--  ██║╚██╔╝██║██║╚════██║██║     
--  ██║ ╚═╝ ██║██║███████║╚██████╗
--  ╚═╝     ╚═╝╚═╝╚══════╝ ╚═════╝

do
  Addon.ITEM_QUALITY_DESCRIPTIONS = Addon:MakeLookupTable((function()
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
    [ITEM_SPELL_TRIGGER_ONEQUIP] = "Equip",
    [ITEM_SPELL_TRIGGER_ONPROC]  = "ChanceOnHit",
    [ITEM_SPELL_TRIGGER_ONUSE]   = "Use",
  }
  
  
  
  Addon.statList = {
    [Addon.expansions.classic] = {},
    [Addon.expansions.tbc]     = {},
    [Addon.expansions.wrath]   = {},
  }
  Addon.statsInfo        = setmetatable({}, {__index = function() return {} end})
  Addon.statOrder        = {}
  Addon.statDefaultList  = {}
  Addon.statDefaultOrder = {}
  Addon.statPrefOrder    = {}
  
  
  
  -- Strip text recoloring
  Addon.ITEM_CREATED_BY = ITEM_CREATED_BY
  Addon.ITEM_WRAPPED_BY = ITEM_WRAPPED_BY
  do
    local hex, text = strMatch(Addon.ITEM_CREATED_BY, "^|c%x%x(%x%x%x%x%x%x)(.*)|r$")
    Addon.ITEM_CREATED_BY = text or Addon.ITEM_CREATED_BY
  end
  do
    local hex, text = strMatch(Addon.ITEM_WRAPPED_BY, "^|c%x%x(%x%x%x%x%x%x)(.*)|r$")
    Addon.ITEM_WRAPPED_BY = text or Addon.ITEM_WRAPPED_BY
  end
end



--  ███╗   ██╗ █████╗ ███╗   ███╗███████╗███████╗
--  ████╗  ██║██╔══██╗████╗ ████║██╔════╝██╔════╝
--  ██╔██╗ ██║███████║██╔████╔██║█████╗  ███████╗
--  ██║╚██╗██║██╔══██║██║╚██╔╝██║██╔══╝  ╚════██║
--  ██║ ╚████║██║  ██║██║ ╚═╝ ██║███████╗███████║
--  ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝

do
  Addon.MY_NAME = UnitName"player"
  
  Addon.SAMPLE_NAMES = {
    -- "Activision",
    "Arthas",
    "Batman",
    -- "Blizzard",
    "Bugs Bunny",
    "Captain Hook",
    "Chewbacca",
    "Deckard Cain",
    "Diablo",
    "Doctor Robotnik",
    "Doctor Who",
    "Donkey Kong",
    "Dracula",
    "Elmer Fudd",
    "Frankenstein",
    "Gul'dan",
    "Harry Potter",
    -- "Hello Kitty Island Adventure",
    "Illidan",
    "Indiana Jones",
    "Inspector Gadget",
    "Jack the Ripper",
    "Kael'thas",
    "Kel'Thuzad",
    "Kil'jaeden",
    "King Kong",
    "Kirby",
    "Mal'Ganis",
    -- "Microsoft",
    "Mickey Mouse",
    "Muradin",
    "Nefarion",
    "Nova",
    "Onyxia",
    "Princess Peach",
    "Rexxar",
    "Santa",
    "Scooby Doo",
    "Sherlock Holmes",
    "Spongebob Squarepants",
    "The Lost Vikings",
    "Tyrande",
    "Uncle Roman",
    "Uther",
    "Winnie the Pooh",
    "Yoda",
  }
end



--  ██████╗  █████╗  ██████╗███████╗███████╗
--  ██╔══██╗██╔══██╗██╔════╝██╔════╝██╔════╝
--  ██████╔╝███████║██║     █████╗  ███████╗
--  ██╔══██╗██╔══██║██║     ██╔══╝  ╚════██║
--  ██║  ██║██║  ██║╚██████╗███████╗███████║
--  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚══════╝╚══════╝

do
  Addon.MY_RACE_NAME = UnitRace"player"
  
  -- Races: Human, Orc, Dwarf, Night Elf, Undead, Tauren, Gnome, Troll, Blood Elf, Draenei
  local raceIDs = {}
  raceIDs[Addon.expansions.classic] = {1, 2, 3, 4, 5, 6, 7, 8}
  raceIDs[Addon.expansions.tbc]     = {1, 2, 3, 4, 5, 6, 7, 8, 10, 11}
  raceIDs[Addon.expansions.wrath]   = raceIDs[Addon.expansions.tbc]
  
  Addon.raceNames = {}
  
  local allRaces     = {}
  local factionRaces = {Alliance = {}, Horde = {}}
  
  for _, raceID in ipairs(raceIDs[Addon.expansionLevel]) do
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



--   ██████╗██╗      █████╗ ███████╗███████╗███████╗███████╗
--  ██╔════╝██║     ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝
--  ██║     ██║     ███████║███████╗███████╗█████╗  ███████╗
--  ██║     ██║     ██╔══██║╚════██║╚════██║██╔══╝  ╚════██║
--  ╚██████╗███████╗██║  ██║███████║███████║███████╗███████║
--   ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝

do
  local _
  Addon.MY_CLASS_NAME, _, Addon.MY_CLASS = UnitClass"player"
  
  Addon.myClassString = format(ITEM_CLASSES_ALLOWED, Addon.MY_CLASS_NAME)
  
  local sampleClasses = {{5, 9, 2}, {7, 1, 3}, {4, 6, 8, 11}}
  if Addon.expansionLevel < Addon.expansions.wrath then
    tblRemove(sampleClasses[3], 2)
  end
  
  Addon.sampleRequiredClassesStrings = {}
  for i, classes in ipairs(sampleClasses) do
    local red = true
    for _, class in ipairs(classes) do
      if class == Addon.MY_CLASS then
        red = false
      end
    end
    
    local classes = table.concat(Addon:Map(classes, function(v) return C_CreatureInfo.GetClassInfo(v).className end), red and "|cffff0000, " or ", ")
    local text = format("|cffff%s" .. ITEM_CLASSES_ALLOWED, red and "0000" or "ffff", classes)
    table.insert(Addon.sampleRequiredClassesStrings, text)
    if not red then
      Addon.sampleRequiredClassesStrings.mine = #Addon.sampleRequiredClassesStrings
    end
  end
  
  Addon.sampleRequiredClassesString = format("%s" .. ITEM_CLASSES_ALLOWED, "", table.concat({C_CreatureInfo.GetClassInfo(5).className, C_CreatureInfo.GetClassInfo(9).className, C_CreatureInfo.GetClassInfo(2).className}, ", "))
  
  Addon.classNames        = {}
  Addon.classNamesColored = {}
  Addon.classIconAtlases  = {}
  
  -- WARRIOR, PALADIN, HUNTER, ROGUE, PRIEST, DEATHKNIGHT, SHAMAN, MAGE, WARLOCK, MONK, DRUID, DEMONHUNTER
  local ID = {}
  for i = 1, GetNumClasses() do
    local classInfo = C_CreatureInfo.GetClassInfo(i)
    if classInfo then
      ID[classInfo.classFile] = classInfo.classID
      
      local matcher = "%f[%w%s] " .. classInfo.className
      Addon.classNames[matcher]        = classInfo.className
      Addon.classNamesColored[matcher] = Addon:MakeColorCode(Addon:TrimAlpha(select(4, GetClassColor(classInfo.classFile))), classInfo.className)
      Addon.classIconAtlases[matcher]  = "groupfinder-icon-class-" .. classInfo.classFile:lower()
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



--  ██╗     ███████╗██╗   ██╗███████╗██╗     ███████╗
--  ██║     ██╔════╝██║   ██║██╔════╝██║     ██╔════╝
--  ██║     █████╗  ██║   ██║█████╗  ██║     ███████╗
--  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══╝  ██║     ╚════██║
--  ███████╗███████╗ ╚████╔╝ ███████╗███████╗███████║
--  ╚══════╝╚══════╝  ╚═══╝  ╚══════╝╚══════╝╚══════╝

do
  Addon.MAX_ITEMLEVEL = 284
  
  Addon.MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
  
  Addon.MY_LEVEL = UnitLevel"player"
  
  Addon:RegisterEvent("PLAYER_LEVEL_UP", function(_, level) Addon.MY_LEVEL = UnitLevel"player" end)
end



--  ███████╗ █████╗  ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--  █████╗  ███████║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══╝  ██╔══██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
--  ██║     ██║  ██║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
--  ╚═╝     ╚═╝  ╚═╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  Addon.MY_FACTION = UnitFactionGroup"player"
end





--  ███████╗ █████╗ ███╗   ███╗██████╗ ██╗     ███████╗    ████████╗██╗████████╗██╗     ███████╗
--  ██╔════╝██╔══██╗████╗ ████║██╔══██╗██║     ██╔════╝    ╚══██╔══╝██║╚══██╔══╝██║     ██╔════╝
--  ███████╗███████║██╔████╔██║██████╔╝██║     █████╗         ██║   ██║   ██║   ██║     █████╗  
--  ╚════██║██╔══██║██║╚██╔╝██║██╔═══╝ ██║     ██╔══╝         ██║   ██║   ██║   ██║     ██╔══╝  
--  ███████║██║  ██║██║ ╚═╝ ██║██║     ███████╗███████╗       ██║   ██║   ██║   ███████╗███████╗
--  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝╚══════╝       ╚═╝   ╚═╝   ╚═╝   ╚══════╝╚══════╝

do
  Addon.SAMPLE_TITLE_ID = 6948
  Addon.SAMPLE_TITLE_NAME = GetItemInfo(Addon.SAMPLE_TITLE_ID)
  if not Addon.SAMPLE_TITLE_NAME then
    Addon:RegisterEvent("GET_ITEM_INFO_RECEIVED", function(_, id)
      if id == Addon.SAMPLE_TITLE_ID then
        Addon.SAMPLE_TITLE_NAME = GetItemInfo(Addon.SAMPLE_TITLE_ID)
        if Addon.SAMPLE_TITLE_NAME then
          Addon:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        end
      end
    end)
  end
end



--   ██████╗ ██████╗ ██╗      ██████╗ ██████╗ ███████╗
--  ██╔════╝██╔═══██╗██║     ██╔═══██╗██╔══██╗██╔════╝
--  ██║     ██║   ██║██║     ██║   ██║██████╔╝███████╗
--  ██║     ██║   ██║██║     ██║   ██║██╔══██╗╚════██║
--  ╚██████╗╚██████╔╝███████╗╚██████╔╝██║  ██║███████║
--   ╚═════╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝

do
  local function rgb(r, g, b)
    return Addon:GetHexFromColor(r, g, b)
  end
  
  
  -- https://colornamer.robertcooper.me/
  Addon.COLORS = {
    DEFAULT   = rgb(255, 215,   6), -- used by default font
    SKY_BLUE  = rgb(  0, 204, 255), -- used by BIND_TRADE_TIME_REMAINING
    PURE_RED  = rgb(255,   0,   0), -- used by ITEM_ENCHANT_DISCLAIMER
    FLAVOR    = rgb(255, 209,   0), -- used by item description text
    PURPLE    = rgb(128, 128, 255), -- used by reputation chat channel
    WHITE     = rgb(255, 255, 255),
    GRAY      = rgb(128, 128, 128),
    RED       = rgb(255,  32,  32),
    ORANGE    = rgb(255, 128,  38),
    GREEN     = rgb(  0, 255,   0),
    BLUE      = rgb(  0,   0, 255),
    YELLOW    = rgb(255, 255,   0),

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
    LILAC_GEODE          = rgb(187, 134, 255),
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
end




--  ██╗ ██████╗ ██████╗ ███╗   ██╗███████╗
--  ██║██╔════╝██╔═══██╗████╗  ██║██╔════╝
--  ██║██║     ██║   ██║██╔██╗ ██║███████╗
--  ██║██║     ██║   ██║██║╚██╗██║╚════██║
--  ██║╚██████╗╚██████╔╝██║ ╚████║███████║
--  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  Addon.texturesPath       = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Assets\\Textures\\"
  Addon.retailTexturesPath = Addon.texturesPath .. "Retail\\"
  
  Addon.stealthIcon          = Addon:MakeIcon"132320"
  Addon.socketIcon           = Addon:MakeIcon"Interface\\ITEMSOCKETINGFRAME\\UI-EMPTYSOCKET-META"
  Addon.speedbarEmptyIcon    = Addon:MakeIcon(Addon.texturesPath .. "Speedbar_transparent", nil, 0.25)
  Addon.speedbarFillIconPath = Addon.texturesPath .. "Speedbar"
  
  Addon.classIconsPath = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
  
  Addon.iconPaths = {
    Addon.texturesPath .. "Samwise",
    
    
    "Interface\\Buttons\\UI-AttributeButton-Encourage-Up",
    "Interface\\Buttons\\UI-GroupLoot-Coin-Up",
    "Interface\\Buttons\\UI-GroupLoot-DE-Up",
    "Interface\\Buttons\\UI-GroupLoot-Dice-Up",
    
    "Interface\\Buttons\\UI-PlusButton-Up",
    "Interface\\Buttons\\UI-PlusButton-Disabled",
    "Interface\\Buttons\\UI-CheckBox-Check",
    "Interface\\Buttons\\UI-CheckBox-Check-Disabled",
    -- "Interface\\Buttons\\UI-SliderBar-Button-Vertical",
    
    -- "Interface\\COMMON\\FavoritesIcon",
    -- "Interface\\COMMON\\friendship-archivistscodex",
    -- "Interface\\COMMON\\friendship-FistHuman",
    -- "Interface\\COMMON\\friendship-FistOrc",
    "Interface\\COMMON\\friendship-heart",
    "Interface\\COMMON\\friendship-manaorb",
    -- "Interface\\COMMON\\help-i",
    -- "Interface\\COMMON\\Indicator-Gray",
    -- "Interface\\COMMON\\Indicator-Green",
    -- "Interface\\COMMON\\Indicator-Yellow",
    -- "Interface\\COMMON\\Indicator-Red",
    "Interface\\COMMON\\RingBorder",
    
    "Interface\\ContainerFrame\\KeyRing-Bag-Icon",
    "Interface\\ICONS\\INV_Misc_Key_01",
    "Interface\\ICONS\\INV_Misc_Key_02",
    "Interface\\ICONS\\INV_Misc_Key_03",
    "Interface\\ICONS\\INV_Misc_Key_04",
    "Interface\\ICONS\\INV_Misc_Key_05",
    "Interface\\ICONS\\INV_Misc_Key_06",
    "Interface\\ICONS\\INV_Misc_Key_07",
    "Interface\\ICONS\\INV_Misc_Key_08",
    "Interface\\ICONS\\INV_Misc_Key_09",
    "Interface\\ICONS\\INV_Misc_Key_10",
    "Interface\\ICONS\\INV_Misc_Key_11",
    "Interface\\ICONS\\INV_Misc_Key_12",
    "Interface\\ICONS\\INV_Misc_Key_13",
    "Interface\\ICONS\\INV_Misc_Key_14",
    "Interface\\ICONS\\INV_Misc_Key_15",
    
    
    -- "Interface\\LFGFRAME\\UI-LFG-ICON-LOCK",
    "Interface\\PetBattles\\PetBattle-LockIcon",
    -- "Interface\\Store\\category-icon-key",
    
    "Interface\\MINIMAP\\TRACKING\\Auctioneer",
    
    "Interface\\MINIMAP\\TRACKING\\Poisons",
    -- "Interface\\MINIMAP\\TRACKING\\UpgradeItem-32x32",
    "Interface\\CURSOR\\Attack",
    -- "Interface\\CURSOR\\Missions",
    "Interface\\CURSOR\\Cast",
    "Interface\\CURSOR\\Point",
    "Interface\\CURSOR\\Crosshairs",
    
    "Interface\\FriendsFrame\\InformationIcon",
    -- "Interface\\FriendsFrame\\StatusIcon-Away",
    -- "Interface\\FriendsFrame\\StatusIcon-DnD",
    "Interface\\FriendsFrame\\StatusIcon-Offline",
    "Interface\\FriendsFrame\\StatusIcon-Online",
    
    "Interface\\HELPFRAME\\HotIssueIcon",
    
    "Interface\\ICONS\\INV_Misc_Rune_06",
    
    -- "Interface\\HELPFRAME\\HelpIcon-HotIssues",
    -- "Interface\\HELPFRAME\\HelpIcon-Suggestion",
    -- "Interface\\HELPFRAME\\ReportLagIcon-Spells",
    
    -- "Interface\\ICONS\\ABILITY_Rogue_PlunderArmor",
    -- "Interface\\ICONS\\Garrison_ArmorUpgrade",
    -- "Interface\\ICONS\\Garrison_BlueArmor",
    -- "Interface\\ICONS\\Garrison_BlueArmorUpgrade",
    -- "Interface\\ICONS\\Garrison_GreenArmor",
    -- "Interface\\ICONS\\Garrison_GreenArmorUpgrade",
    -- "Interface\\ICONS\\Garrison_PurpleArmor",
    -- "Interface\\ICONS\\Garrison_PurpleArmorUpgrade",
    Addon.retailTexturesPath .. "ICONS\\ABILITY_Rogue_PlunderArmor",
    Addon.retailTexturesPath .. "ICONS\\Garrison_ArmorUpgrade",
    Addon.retailTexturesPath .. "ICONS\\Garrison_BlueArmor",
    Addon.retailTexturesPath .. "ICONS\\Garrison_BlueArmorUpgrade",
    Addon.retailTexturesPath .. "ICONS\\Garrison_GreenArmor",
    Addon.retailTexturesPath .. "ICONS\\Garrison_GreenArmorUpgrade",
    Addon.retailTexturesPath .. "ICONS\\Garrison_PurpleArmor",
    Addon.retailTexturesPath .. "ICONS\\Garrison_PurpleArmorUpgrade",
    
    
    -- "Interface\\ICONS\\INV_Armor_Chest_LightforgedDraenei_D_01",
    -- "Interface\\ICONS\\INV_Armor_MaldraxxusCosmetic_D_01_Chest",
    -- "Interface\\ICONS\\INV_Armor_RevendrethCosmetic_D_01_Chest",
    -- "Interface\\ICONS\\INV_Armor_RevendrethCosmetic_D_02_Chest",
    -- "Interface\\ICONS\\INV_Armor_Tauren_D_01Chest",
    -- "Interface\\ICONS\\INV_Chest_Armor_ArdenwealdCosmetic_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_BastionCosmetic_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_BloodElf_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_BrawlersGuild_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_DarkIronDwarf_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_Dwarf_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_Gnome_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_Goblin_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_KultiranHuman_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_Nightborne_D_01",
    -- "Interface\\ICONS\\INV_Chest_Armor_Worgen_D_01",
    
    "Interface\\ICONS\\INV_Misc_ArmorKit_01",
    "Interface\\ICONS\\INV_Misc_ArmorKit_02",
    "Interface\\ICONS\\INV_Misc_ArmorKit_03",
    "Interface\\ICONS\\INV_Misc_ArmorKit_04",
    "Interface\\ICONS\\INV_Misc_ArmorKit_05",
    "Interface\\ICONS\\INV_Misc_ArmorKit_06",
    "Interface\\ICONS\\INV_Misc_ArmorKit_07",
    "Interface\\ICONS\\INV_Misc_ArmorKit_08",
    "Interface\\ICONS\\INV_Misc_ArmorKit_09",
    "Interface\\ICONS\\INV_Misc_ArmorKit_10",
    "Interface\\ICONS\\INV_Misc_ArmorKit_11",
    "Interface\\ICONS\\INV_Misc_ArmorKit_12",
    "Interface\\ICONS\\INV_Misc_ArmorKit_14",
    "Interface\\ICONS\\INV_Misc_ArmorKit_15",
    "Interface\\ICONS\\INV_Misc_ArmorKit_16",
    "Interface\\ICONS\\INV_Misc_ArmorKit_17",
    "Interface\\ICONS\\INV_Misc_ArmorKit_18",
    "Interface\\ICONS\\INV_Misc_ArmorKit_19",
    "Interface\\ICONS\\INV_Misc_ArmorKit_20",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_21",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_22",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_23",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_24",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_25",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_26",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_27",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_28",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_29",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_30",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_31",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_32",
    -- "Interface\\ICONS\\INV_Misc_ArmorKit_33",
    
    -- "Interface\\Store\\category-icon-armor",
    "Interface\\MINIMAP\\Minimap_shield_elite",
    "Interface\\MINIMAP\\Minimap_shield_normal",
    
    
    "Interface\\MINIMAP\\TRACKING\\Repair",
    
    "Interface\\ICONS\\INV_Misc_Wrench_01",
    
    "Interface\\MINIMAP\\Vehicle-HammerGold-1",
    "Interface\\MINIMAP\\Vehicle-HammerGold-2",
    "Interface\\MINIMAP\\Vehicle-HammerGold-3",
    "Interface\\MINIMAP\\Vehicle-HammerGold",
    
    
    
    -- "Interface\\ICONS\\Ability_Paladin_ShieldofVengeance",
    -- "Interface\\ICONS\\Ability_Priest_ReflectiveShield",
    "Interface\\ICONS\\Ability_Mage_ShatterShield",
    "Interface\\ICONS\\Ability_Shaman_WaterShield",
    -- "Interface\\ICONS\\Ability_Warrior_ShieldBash",
    -- "Interface\\ICONS\\Ability_Warrior_ShieldBreak",
    -- "Interface\\ICONS\\Ability_Warrior_ShieldGuard",
    "Interface\\ICONS\\Ability_Warrior_ShieldMastery",
    "Interface\\ICONS\\Ability_Paladin_ShieldoftheTemplar",
    "Interface\\ICONS\\Ability_Warrior_ShieldReflection",
    "Interface\\ICONS\\Ability_Warrior_ShieldWall",
    -- "Interface\\ICONS\\INV_Shield_1H_Hyrja_D_01",
    -- "Interface\\ICONS\\INV_Shield_02",
    -- "Interface\\ICONS\\INV_Shield_03",
    "Interface\\ICONS\\INV_Shield_04",
    -- "Interface\\ICONS\\INV_Shield_05",
    "Interface\\ICONS\\INV_Shield_06",
    -- "Interface\\ICONS\\INV_Shield_08",
    "Interface\\ICONS\\INV_Shield_09",
    "Interface\\ICONS\\INV_Shield_10",
    -- "Interface\\ICONS\\_________",
    -- "Interface\\ICONS\\_________",
    -- "Interface\\ICONS\\_________",
    -- "Interface\\ICONS\\_________",
    -- "Interface\\ICONS\\_________",
    -- "Interface\\ICONS\\_________",
    -- "Interface\\ICONS\\_________",
    -- "Interface\\ICONS\\_________",
    
    
    "Interface\\MINIMAP\\Dungeon",
    "Interface\\MINIMAP\\Raid",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_cyan",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_green",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_orange",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_purple",
    "Interface\\MINIMAP\\Vehicle-AllianceMagePortal",
    "Interface\\MINIMAP\\Vehicle-HordeMagePortal",
    -- "Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Tracked",
    -- "Interface\\MINIMAP\\Minimap-Waypoint-MapPin-Untracked",
    
    "Interface\\MONEYFRAME\\Arrow-Left-Down",
    -- "Interface\\MONEYFRAME\\Arrow-Left-Up",
    "Interface\\MONEYFRAME\\Arrow-Right-Down",
    -- "Interface\\MONEYFRAME\\Arrow-Right-Up",
    
    "Interface\\Transmogrify\\transmog-tooltip-arrow",
    
    "Interface\\Tooltips\\ReforgeGreenArrow",
    
    "Interface\\OPTIONSFRAME\\VoiceChat-Play",
    "Interface\\OPTIONSFRAME\\VoiceChat-Record",
    
    "Interface\\RAIDFRAME\\ReadyCheck-Ready",
    
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_1",
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_2",
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_3",
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_4",
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_5",
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_6",
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_7",
    "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8",
  }
  
  
  
  local gemIDs = {
    [Addon.expansions.tbc] = Addon.expansionLevel >= Addon.expansions.tbc and {
      Socket_red = {
        23436,
        23077,
        24031,
        24029,
        32194,
        28362,
        28118,
        32227,
        24030,
        24027,
        28595,
        32196,
        33133,
        23095,
        23097,
        24028,
        32193,
        33131,
        30571,
        23096,
        23233,
        23094,
        24032,
        24036,
        27811,
        27812,
        32197,
        33134,
        35487,
        38545,
        27774,
        28458,
        28460,
        30598,
        32199,
        27777,
        28117,
        28360,
        28461,
        28462,
        32195,
        33132,
        35488,
        35489,
        28361,
        28459,
        32198,
        38549,
      },
      Socket_blue = {
        23438,
        23117,
        24033,
        34831,
        23119,
        24037,
        -- 34256,
        23121,
        23120,
        23118,
        23234,
        24039,
        24035,
        28464,
        28463,
        32200,
        32228,
        32201,
        32202,
        33135,
        28465,
        33137,
        32203,
        27864,
        27863,
      },
      Socket_yellow = {
        23112,
        23440,
        32205,
        23113,
        24048,
        23116,
        24047,
        24051,
        33143,
        24050,
        32209,
        27679,
        35315,
        23114,
        32229,
        23115,
        24052,
        28290,
        32206,
        23235,
        24053,
        31861,
        33139,
        33141,
        28120,
        28466,
        28468,
        32207,
        32210,
        33138,
        33142,
        38546,
        38550,
        28467,
        28469,
        28470,
        31860,
        32208,
        33144,
        28119,
        32204,
        33140,
        34627,
        35761,
      },
      Socket_purple = {
        -- 32836,
        23441,
        23107,
        23108,
        32216,
        23109,
        24056,
        24055,
        23111,
        24054,
        30552,
        31117,
        32230,
        30549,
        23110,
        24057,
        32634,
        35707,
        30574,
        30603,
        30566,
        32214,
        30572,
        31865,
        32215,
        32636,
        37503,
        30555,
        30563,
        30600,
        31116,
        31118,
        31862,
        31863,
        32211,
        32212,
        32213,
        32833,
        30546,
        31864,
      },
      Socket_green = {
        23437,
        23079,
        24065,
        24062,
        23104,
        30606,
        30608,
        32224,
        24066,
        24067,
        35758,
        23103,
        23105,
        23106,
        30586,
        30589,
        32226,
        27820,
        30560,
        27785,
        30548,
        30550,
        30583,
        30590,
        30592,
        30605,
        32249,
        32635,
        32639,
        27786,
        27809,
        32223,
        32225,
        33782,
        35318,
        35759,
        30594,
        30602,
        32735,
      },
      Socket_orange = {
        32231,
        24058,
        24059,
        24060,
        21929,
        30553,
        32218,
        23101,
        23439,
        23098,
        24061,
        30556,
        32220,
        23100,
        35760,
        23099,
        30551,
        30564,
        28123,
        30558,
        30593,
        31867,
        38547,
        28122,
        30565,
        30573,
        30604,
        30607,
        31869,
        32219,
        38548,
        28363,
        30575,
        30581,
        30582,
        30601,
        31868,
        32217,
        32222,
        32637,
        30547,
        30585,
        30591,
        32638,
        30554,
        30559,
        30584,
        30587,
        30588,
        31866,
        32221,
        35316,
      },
      Socket_prismatic = {
        22459,
        22460,
      },
      Socket_meta = {
        25868,
        32409,
        34220,
        25901,
        25867,
        25896,
        25893,
        28557,
        25894,
        32410,
        35501,
        25898,
        25895,
        25899,
        25897,
        32640,
        35503,
        25890,
        32641,
        28556,
        33633,
      },
    } or nil,
    [Addon.expansions.wotlk] = Addon.expansionLevel >= Addon.expansions.wotlk and {
      Socket_red = {
        39998,
        39996,
        45883,
        39999,
        40002,
        36919,
        36918,
        45862,
        45879,
        36917,
        40003,
        42142,
        39997,
        40113,
        40111,
        42144,
        36766,
        42143,
        40112,
        42153,
        42154,
        40114,
        40117,
        40118,
        41432,
        41438,
        41437,
        41434,
        40115,
        40000,
        40001,
        39900,
        41433,
        39905,
        42151,
        39910,
        39911,
        41436,
        42152,
        39908,
        40116,
        39907,
        39909,
        41435,
        41439,
        39906,
      },
      Socket_blue = {
        40008,
        36923,
        45880,
        36767,
        40011,
        36925,
        36924,
        40119,
        45881,
        40122,
        40010,
        42145,
        42155,
        42146,
        40009,
        40120,
        39919,
        40121,
        41443,
        41441,
        41442,
        39920,
        39927,
        39932,
        41440,
      },
      Socket_yellow = {
        36922,
        40014,
        40017,
        40012,
        40016,
        45987,
        36920,
        44066,
        42148,
        45882,
        36921,
        40128,
        40015,
        42158,
        42150,
        40013,
        40125,
        40123,
        42156,
        40124,
        40127,
        40126,
        42149,
        42157,
        39918,
        41449,
        41445,
        41447,
        41448,
        41446,
        39912,
        39914,
        39915,
        39917,
        39916,
        41444,
      },
      Socket_purple = {
        40026,
        40022,
        40027,
        40034,
        40023,
        40031,
        36927,
        36926,
        40133,
        40029,
        36928,
        40130,
        40033,
        40028,
        40025,
        40129,
        40024,
        39934,
        40032,
        40132,
        40141,
        40140,
        41450,
        41462,
        39941,
        40139,
        40134,
        39933,
        40138,
        41457,
        41461,
        39940,
        39943,
        40131,
        41451,
        41460,
        39936,
        39937,
        40136,
        41453,
        41454,
        40137,
        41452,
        41455,
        41458,
        39939,
        39944,
        40030,
        39935,
        39938,
        39942,
        39945,
        40135,
        41456,
        41459,
      },
      Socket_green = {
        40088,
        40089,
        36932,
        40094,
        36933,
        40103,
        36934,
        40099,
        40086,
        40105,
        40104,
        40106,
        40101,
        40090,
        40091,
        40167,
        40095,
        40100,
        40096,
        40098,
        40092,
        40166,
        40168,
        39988,
        40175,
        40178,
        41467,
        41476,
        40165,
        41481,
        39982,
        39985,
        40164,
        40169,
        40177,
        40179,
        39968,
        39980,
        39989,
        40180,
        41468,
        41479,
        39974,
        39975,
        40171,
        40182,
        41475,
        41478,
        39983,
        39984,
        40170,
        40174,
        41464,
        41465,
        41470,
        41471,
        39976,
        39978,
        39979,
        39981,
        39992,
        40085,
        40102,
        40173,
        40176,
        40181,
        41466,
        41472,
        39977,
        39986,
        39990,
        39991,
        40172,
        41463,
        41469,
        41473,
        41474,
        41477,
        41480,
      },
      Socket_orange = {
        40051,
        40048,
        40037,
        40049,
        40038,
        40058,
        40053,
        36930,
        40047,
        36929,
        40055,
        40050,
        40043,
        40052,
        40155,
        36931,
        40044,
        40041,
        40054,
        40152,
        40040,
        40162,
        40045,
        40153,
        40039,
        40059,
        40143,
        40154,
        40056,
        40151,
        40142,
        39959,
        41492,
        40046,
        40146,
        40148,
        40161,
        41502,
        41486,
        41495,
        39952,
        40147,
        40157,
        39950,
        40156,
        40159,
        39947,
        40057,
        40163,
        39954,
        40145,
        41498,
        39948,
        39958,
        39964,
        39965,
        40144,
        40158,
        39953,
        39955,
        39957,
        41488,
        41490,
        41491,
        41493,
        41497,
        41500,
        41501,
        39949,
        39951,
        39956,
        39962,
        39966,
        41429,
        41484,
        41485,
        39946,
        39960,
        39961,
        39963,
        39967,
        40149,
        40150,
        40160,
        41482,
        41483,
        41487,
        41489,
        41494,
        41496,
        41499,
      },
      Socket_meta = {
        41398,
        41285,
        41401,
        41334,
        41380,
        41266,
        41333,
        41382,
        41339,
        41400,
        41376,
        41396,
        41381,
        41385,
        41397,
        41389,
        41377,
        41375,
        41378,
        41395,
        44078,
        41307,
        44082,
        44089,
        41335,
        44087,
        44084,
        44088,
        44081,
        41379,
        44076,
      },
      Socket_prismatic = {
        49110,
        42702,
        42225,
        45054,
        42701,
        34143,
        34142,
      },
    } or nil,
  }
  
  local gemColors = {
    [136258] = "Socket_red",
    [136256] = "Socket_blue",
    [136259] = "Socket_yellow",
    [458977] = "Socket_prismatic",
    [136257] = "Socket_meta",
  }
  for expansion, db in pairs(gemIDs) do
    for color, ids in pairs(db) do
      for _, id in ipairs(ids) do
        local tex = select(5, GetItemInfoInstant(id))
        if tex then
          if gemColors[tex] then
            if gemColors[tex] ~= color then
              Addon:Throwf("Gem texture collision: %s", tostring(tex))
            end
          else
            gemColors[tex] = color
          end
        else
          Addon:Throwf("Gem doesn't exist: %d", id)
        end
      end
    end
  end
  
  local gemTextureCollisions = {
    [134126] = function(text)
      return strMatch(text, 15) and "Socket_blue" or "Socket_purple"
    end,
  }
  
  function Addon:GetGemColor(texture, text)
    local color = gemColors[texture]
    if not color then
      local func = gemTextureCollisions[texture]
      if func then
        color = func(text)
      else
        self:Throwf("Can't determine gem color. texture: %s, text: %s", tostring(texture), tostring(text))
      end
    end
    
    return color
  end
end





local ADDON_NAME, Data = ...


local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



local strLower  = string.lower
local strFind   = string.find
local strMatch  = string.match
local strGsub   = string.gsub

local tinsert   = table.insert
local tblRemove = table.remove
local tblConcat = table.concat

local tostring = tostring







--  ███████╗██╗  ██╗██████╗  █████╗ ███╗   ██╗███████╗██╗ ██████╗ ███╗   ██╗███████╗
--  ██╔════╝╚██╗██╔╝██╔══██╗██╔══██╗████╗  ██║██╔════╝██║██╔═══██╗████╗  ██║██╔════╝
--  █████╗   ╚███╔╝ ██████╔╝███████║██╔██╗ ██║███████╗██║██║   ██║██╔██╗ ██║███████╗
--  ██╔══╝   ██╔██╗ ██╔═══╝ ██╔══██║██║╚██╗██║╚════██║██║██║   ██║██║╚██╗██║╚════██║
--  ███████╗██╔╝ ██╗██║     ██║  ██║██║ ╚████║███████║██║╚██████╔╝██║ ╚████║███████║
--  ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  Addon.expansions = {
    retail  = 9,
    wrath   = 3,
    wotlk   = 3,
    tbc     = 2,
    bcc     = 2,
    classic = 1,
  }
  Addon.expansionLevel = tonumber(GetBuildInfo():match"^(%d+)%.")
  if Addon.expansionLevel >= Addon.expansions.retail then
    Addon.expansionName = "retail"
  elseif Addon.expansionLevel >= Addon.expansions.wrath then
    Addon.expansionName = "wrath"
  elseif Addon.expansionLevel == Addon.expansions.tbc then
    Addon.expansionName = "tbc"
  elseif Addon.expansionLevel == Addon.expansions.classic then
    Addon.expansionName = "classic"
  end
  Addon.isRetail  = Addon.expansionName == "retail"
  Addon.isWrath   = Addon.expansionName == "wrath"
  Addon.isTBC     = Addon.expansionName == "tbc"
  Addon.isClassic = Addon.expansionName == "classic"
end



--  ███╗   ███╗██╗███████╗ ██████╗
--  ████╗ ████║██║██╔════╝██╔════╝
--  ██╔████╔██║██║███████╗██║     
--  ██║╚██╔╝██║██║╚════██║██║     
--  ██║ ╚═╝ ██║██║███████║╚██████╗
--  ╚═╝     ╚═╝╚═╝╚══════╝ ╚═════╝

do
  
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
  Addon.statsInfo = setmetatable({}, {__index = function() return {} end})
  Addon.statOrder = {}
  
  
  
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



--  ██╗      ██████╗  ██████╗ █████╗ ██╗     ███████╗
--  ██║     ██╔═══██╗██╔════╝██╔══██╗██║     ██╔════╝
--  ██║     ██║   ██║██║     ███████║██║     █████╗  
--  ██║     ██║   ██║██║     ██╔══██║██║     ██╔══╝  
--  ███████╗╚██████╔╝╚██████╗██║  ██║███████╗███████╗
--  ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝╚══════╝

do
  Addon.DAMAGE_SCHOOL7 = DAMAGE_SCHOOL7
  Addon.DAMAGE_SCHOOL3 = DAMAGE_SCHOOL3
  Addon.DAMAGE_SCHOOL4 = DAMAGE_SCHOOL4
  Addon.DAMAGE_SCHOOL5 = DAMAGE_SCHOOL5
  Addon.DAMAGE_SCHOOL6 = DAMAGE_SCHOOL6
  
  Addon.ITEM_MOD_STAMINA   = ITEM_MOD_STAMINA
  Addon.ITEM_MOD_STRENGTH  = ITEM_MOD_STRENGTH
  Addon.ITEM_MOD_AGILITY   = ITEM_MOD_AGILITY
  Addon.ITEM_MOD_INTELLECT = ITEM_MOD_INTELLECT
  Addon.ITEM_MOD_SPIRIT    = ITEM_MOD_SPIRIT
  
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
    if Addon.isClassic then
      Addon.DAMAGE_SCHOOL7 = SPELL_SCHOOL6_CAP
      Addon.DAMAGE_SCHOOL3 = SPELL_SCHOOL2_CAP
      Addon.DAMAGE_SCHOOL4 = SPELL_SCHOOL3_CAP
      Addon.DAMAGE_SCHOOL5 = SPELL_SCHOOL4_CAP
      Addon.DAMAGE_SCHOOL6 = SPELL_SCHOOL5_CAP
    else
      Addon.DAMAGE_SCHOOL7 = "тайной магии"
      Addon.DAMAGE_SCHOOL3 = "огню"
      Addon.DAMAGE_SCHOOL4 = "силам природы"
      Addon.DAMAGE_SCHOOL5 = "магии льда"
      Addon.DAMAGE_SCHOOL6 = "темной магии"
    end
  elseif locale == "zhTW" then
    if Addon.isClassic then
      Addon.ITEM_MOD_STAMINA   = strGsub(ITEM_MOD_STAMINA  , " ", "", 1)
      Addon.ITEM_MOD_STRENGTH  = strGsub(ITEM_MOD_STRENGTH , " ", "", 1)
      Addon.ITEM_MOD_AGILITY   = strGsub(ITEM_MOD_AGILITY  , " ", "", 1)
      Addon.ITEM_MOD_INTELLECT = strGsub(ITEM_MOD_INTELLECT, " ", "", 1)
      Addon.ITEM_MOD_SPIRIT    = strGsub(ITEM_MOD_SPIRIT   , " ", "", 1)
    end
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
  Addon.MAX_LEVEL = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]
  
  Addon.MY_LEVEL = UnitLevel"player"
  
  Addon:RegisterEvent("PLAYER_LEVEL_UP", function(_, level) Addon.MY_LEVEL = UnitLevel"player" end)
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
    WHITE     = rgb(255, 255, 255),
    GRAY      = rgb(128, 128, 128),
    RED       = rgb(255,  32,  32),
    ORANGE    = rgb(255, 127,  32),
    GREEN     = rgb(  0, 255,   0),
    BLUE      = rgb(  0,   0, 255),
    SKY_BLUE  = rgb(  0, 204, 255), -- used by BIND_TRADE_TIME_REMAINING
    DEFAULT   = rgb(255, 215,   6), -- used by default font
    PURE_RED  = rgb(255,   0,   0), -- used by ITEM_ENCHANT_DISCLAIMER

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
end




--  ███████╗████████╗ █████╗ ████████╗███████╗
--  ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
--  ███████╗   ██║   ███████║   ██║   ███████╗
--  ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
--  ███████║   ██║   ██║  ██║   ██║   ███████║
--  ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝


do
  local ITEM_MOD_HASTE_SPELL_RATING_SHORT = ITEM_MOD_HASTE_SPELL_RATING_SHORT or strGsub(ITEM_MOD_CRIT_SPELL_RATING_SHORT, Addon:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING_SHORT), Addon:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING_SHORT))
  local ITEM_MOD_HASTE_SPELL_RATING       = ITEM_MOD_HASTE_SPELL_RATING       or strGsub(ITEM_MOD_CRIT_SPELL_RATING,       Addon:CoverSpecialCharacters(ITEM_MOD_CRIT_RATING),       Addon:CoverSpecialCharacters(ITEM_MOD_HASTE_RATING))
  
  local statsData = {
    {true, true, true, "Stamina",   SPELL_STAT3_NAME, Addon.ITEM_MOD_STAMINA,   Addon.COLORS.WHITE, Addon.COLORS.PALE_LIGHT_GREEN},
    {true, true, true, "Strength",  SPELL_STAT1_NAME, Addon.ITEM_MOD_STRENGTH,  Addon.COLORS.WHITE, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Agility",   SPELL_STAT2_NAME, Addon.ITEM_MOD_AGILITY,   Addon.COLORS.WHITE, Addon.COLORS.PUMPKIN_ORANGE},
    {true, true, true, "Intellect", SPELL_STAT4_NAME, Addon.ITEM_MOD_INTELLECT, Addon.COLORS.WHITE, Addon.COLORS.JORDY_BLUE},
    {true, true, true, "Spirit",    SPELL_STAT5_NAME, Addon.ITEM_MOD_SPIRIT,    Addon.COLORS.WHITE, Addon.COLORS.LIGHT_AQUA},
    
    {true, true, true, "Arcane Resistance", RESISTANCE6_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), Addon.DAMAGE_SCHOOL7), Addon.COLORS.WHITE, Addon.COLORS.ARCANE},
    {true, true, true, "Fire Resistance"  , RESISTANCE2_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), Addon.DAMAGE_SCHOOL3), Addon.COLORS.WHITE, Addon.COLORS.FIRE},
    {true, true, true, "Nature Resistance", RESISTANCE3_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), Addon.DAMAGE_SCHOOL4), Addon.COLORS.WHITE, Addon.COLORS.NATURE},
    {true, true, true, "Frost Resistance" , RESISTANCE4_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), Addon.DAMAGE_SCHOOL5), Addon.COLORS.WHITE, Addon.COLORS.FROST},
    {true, true, true, "Shadow Resistance", RESISTANCE5_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), Addon.DAMAGE_SCHOOL6), Addon.COLORS.WHITE, Addon.COLORS.SHADOW},
    -- {true, true, true, "Holy Resistance"  , RESISTANCE1_NAME, format(Addon:ChainGsub(ITEM_RESIST_SINGLE, {"%%%d+%$", "%%"}, {"%%[^s]", "%%%0"}, {"|3%-%d+%((.+)%)", "%1"}), Addon.DAMAGE_SCHOOL2), Addon.COLORS.WHITE, Addon.COLORS.HOLY},
    
    {true, true, true, "Defense Rating"   , ITEM_MOD_DEFENSE_SKILL_RATING_SHORT, ITEM_MOD_DEFENSE_SKILL_RATING, Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Dodge Rating"     , ITEM_MOD_DODGE_RATING_SHORT        , ITEM_MOD_DODGE_RATING        , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Parry Rating"     , ITEM_MOD_PARRY_RATING_SHORT        , ITEM_MOD_PARRY_RATING        , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Block Rating"     , ITEM_MOD_BLOCK_RATING_SHORT        , ITEM_MOD_BLOCK_RATING        , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Block Value"      , ITEM_MOD_BLOCK_VALUE_SHORT         , ITEM_MOD_BLOCK_VALUE         , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    {true, true, true, "Resilience Rating", ITEM_MOD_RESILIENCE_RATING_SHORT   , ITEM_MOD_RESILIENCE_RATING   , Addon.COLORS.GREEN, Addon.COLORS.YELLOW},
    
    {true, true, true, "Expertise Rating"        , ITEM_MOD_EXPERTISE_RATING_SHORT        , ITEM_MOD_EXPERTISE_RATING        , Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Attack Power"            , ITEM_MOD_ATTACK_POWER_SHORT            , ITEM_MOD_ATTACK_POWER            , Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Ranged Attack Power"     , ITEM_MOD_RANGED_ATTACK_POWER_SHORT     , ITEM_MOD_RANGED_ATTACK_POWER     , Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Attack Power In Forms"   , ITEM_MOD_FERAL_ATTACK_POWER_SHORT      , ITEM_MOD_FERAL_ATTACK_POWER      , Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    {true, true, true, "Armor Penetration Rating", ITEM_MOD_ARMOR_PENETRATION_RATING_SHORT, ITEM_MOD_ARMOR_PENETRATION_RATING, Addon.COLORS.GREEN, Addon.COLORS.TUMBLEWEED},
    
    {true, true, true, "Spell Power" , ITEM_MOD_SPELL_POWER_SHORT       , ITEM_MOD_SPELL_POWER       , Addon.COLORS.GREEN, Addon.COLORS.PERIWINKLE},
    -- {nil , nil , nil , "Spell Damage", ITEM_MOD_SPELL_DAMAGE_DONE_SHORT , ITEM_MOD_SPELL_DAMAGE_DONE , Addon.COLORS.GREEN, Addon.COLORS.PERIWINKLE},
    {true, true, nil , "Healing"     , ITEM_MOD_SPELL_HEALING_DONE_SHORT, ITEM_MOD_SPELL_HEALING_DONE, Addon.COLORS.GREEN, Addon.COLORS.LIGHT_CYAN},
    
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
  }
  
  
  local isReversedLocale = not ITEM_MOD_STAMINA:find"^%%"
  local GetLocaleStatFormat = ITEM_MOD_STAMINA:find"^%%" and function(pre, suf, capture) return format("%s %s%s", pre, capture and "?" or "", suf) end or function(pre, suf, capture) return format("%s %s%s", suf, capture and "?" or "", pre) end
  -- instead of flipping them, mess with the normal form pattern instead. format("%s %s", isBaseStat and sign or "+", normalName) vs format("%2$s %1$s", isBaseStat and sign or "+", normalName)
  
  for i, data in ipairs(statsData) do
    local expacs = {}
    expacs[Addon.expansions.classic] = data[1]
    expacs[Addon.expansions.tbc]     = data[2]
    expacs[Addon.expansions.wrath]   = data[3]
    local stat                       = data[4]
    
    
    for expac, list in pairs(Addon.statList) do
      if expacs[expac] then
        tinsert(list, stat)
      end
    end
    if expacs[Addon.expansionLevel] then
      local normalName = data[5]
      
      local tooltipPattern  = data[6]
      local tooltipPattern2 = Addon:ChainGsub(tooltipPattern, {"%%%d%$", "%%"}, {"%%c", "%%d", "%%s"})
      
      local tooltipColor = data[7]
      local color        = data[8]
      
      Addon.statsInfo[stat] = {}
      local StatInfo = Addon.statsInfo[stat]
      
      StatInfo.tooltipColor = tooltipColor
      StatInfo.color = color
      
      local isBaseStat = strFind(tooltipPattern, "%%%d?%$?c")
      local reorderLocaleMode = isBaseStat and "%s%s" or "+%s"
      
      
      local normalNameReplacePattern = Addon:CoverSpecialCharacters(normalName)
      
      local normalFormPattern      = GetLocaleStatFormat(isBaseStat and "%1$s%2$s" or "+%1$s", normalName)
      local normalFormCapture      = strGsub(Addon:ReversePattern(GetLocaleStatFormat(isBaseStat and "%c%s%%?" or "+%s%%?", normalName,  nil)), "%$", "[。%.]*%0")
      local normalFormLooseCapture = strGsub(Addon:ReversePattern(GetLocaleStatFormat(isBaseStat and "%c%s%%?" or "+%s%%?", normalName, true)), "%$", "[。%.]*%0")
      local normalFormPattern2     = GetLocaleStatFormat(isBaseStat and "%s%s" or "+%s", normalName)
      
      local function ApplyMod(text, normalForm)
        local match1, match2 = strMatch(normalForm, normalFormCapture)
        local origStrNumber = match1 .. (match2 or "")
        local strNumber, percent = strMatch(origStrNumber, "(%-?%d+)(%%?)")
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
        local match1, match2 = strMatch(text, Addon:ReversePattern(tooltipPattern))
        if match1 then
          if HasNumber(match1, match2) then return format(normalFormPattern, match1, match2) end
        end
        local match1, match2 = strMatch(strLower(text), strLower(normalFormLooseCapture))
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
  
  Addon.statsInfo["Title"]              = {color = Addon.COLORS.WHITE}
  
  Addon.statsInfo["Heroic"]             = {color = Addon.COLORS.GREEN}
  Addon.statsInfo["ItemLevel"]          = {color = Addon.COLORS.DEFAULT}
  
  Addon.statsInfo["AlreadyBound"]       = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["CharacterBound"]     = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["AccountBound"]       = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["Tradeable"]          = {color = Addon.COLORS.WHITE}
  
  Addon.statsInfo["Trainable"]          = {color = Addon.COLORS.ORANGE}
  
  Addon.statsInfo["Damage"]             = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["Speed"]              = {color = Addon.COLORS.WHITE}
  
  Addon.statsInfo["DamagePerSecond"]    = {color = Addon.COLORS.WHITE}
  Addon.statsInfo["Speedbar"]           = {color = Addon.COLORS.WHITE}
  
  Addon.statsInfo["Enchant"]            = {color = Addon.COLORS.GREEN}
  Addon.statsInfo["WeaponEnchant"]      = {color = Addon.COLORS.GREEN}
  
  Addon.statsInfo["Durability"]         = {color = Addon.COLORS.WHITE}
  
  Addon.statsInfo["MadeBy"]             = {color = Addon.COLORS.GREEN}
  
  Addon.statsInfo["SocketHint"]         = {color = Addon.COLORS.GREEN}
  
  Addon.statsInfo["Refundable"]         = {color = Addon.COLORS.SKY_BLUE}
  Addon.statsInfo["SoulboundTradeable"] = {color = Addon.COLORS.SKY_BLUE}
end



--  ██╗ ██████╗ ██████╗ ███╗   ██╗███████╗
--  ██║██╔════╝██╔═══██╗████╗  ██║██╔════╝
--  ██║██║     ██║   ██║██╔██╗ ██║███████╗
--  ██║██║     ██║   ██║██║╚██╗██║╚════██║
--  ██║╚██████╗╚██████╔╝██║ ╚████║███████║
--  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

do
  Addon.stealthIcon          = Addon:MakeIcon"132320"
  Addon.socketIcon           = Addon:MakeIcon"Interface\\ITEMSOCKETINGFRAME\\UI-EMPTYSOCKET-META"
  Addon.speedbarEmptyIcon    = Addon:MakeIcon("Interface\\AddOns\\" .. ADDON_NAME .. "\\Assets\\Textures\\Speedbar_transparent", nil, 0.25)
  Addon.speedbarFillIconPath = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Assets\\Textures\\Speedbar"
  
  Addon.classIconsPath = "Interface\\GLUES\\CHARACTERCREATE\\UI-CHARACTERCREATE-CLASSES"
  
  Addon.iconPaths = {
    "Interface\\AddOns\\" .. ADDON_NAME .. "\\Assets\\Textures\\Samwise",
    
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
    -- "Interface\\HELPFRAME\\HelpIcon-HotIssues",
    -- "Interface\\HELPFRAME\\HelpIcon-Suggestion",
    -- "Interface\\HELPFRAME\\ReportLagIcon-Spells",
    
    "Interface\\MINIMAP\\TRACKING\\Repair",
    "Interface\\MINIMAP\\Dungeon",
    "Interface\\MINIMAP\\Raid",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_cyan",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_green",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_orange",
    "Interface\\MINIMAP\\TempleofKotmogu_ball_purple",
    "Interface\\MINIMAP\\Vehicle-AllianceMagePortal",
    "Interface\\MINIMAP\\Vehicle-HordeMagePortal",
    
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
end






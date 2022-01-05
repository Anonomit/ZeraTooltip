

local ADDON_NAME, Data = ...


function Data:IsBCC()
  return Data.WOW_VERSION == "BCC"
end
function Data:IsClassic()
  return Data.WOW_VERSION == "Classic"
end


local function rgb(r, g, b)
  return {r, g, b}
end





-- Configuration

-- Fastest weapon speed
Data.WEAPON_SPEED_MIN = 1.2

-- Slowest weapon speed
Data.WEAPON_SPEED_MAX = 4.0

-- How spread out options are in interface options
Data.OPTIONS_DIVIDER_HEIGHT = 3

local COLORS = {
  WHITE  = rgb(255, 255, 255),
  ORANGE = rgb(255, 127,  32),
  GREEN  = rgb(  0, 255,   0),
  BLUE   = rgb(  0,   0, 255),

  ARCANE = rgb(255, 127, 255),
  FIRE   = rgb(255, 128,   0),
  NATURE = rgb( 76, 255,  76),
  FROST  = rgb(127, 255, 255),
  SHADOW = rgb(127, 127, 255),
  HOLY   = rgb(255, 229, 127),

  HONEYSUCKLE        = rgb(237, 252, 132),
  LIGHT_YELLOW_GREEN = rgb(204, 253, 127),
  REEF               = rgb(201, 255, 162),
  PALE_LIGHT_GREEN   = rgb(177, 252, 153),
  FOAM_GREEN         = rgb(144, 253, 169),
  PARIS_GREEN        = rgb( 80, 200, 120),
  LEMON_LIME         = rgb(191, 254,  40),

  YELLOW             = rgb(255, 255,   0),
  SANDY_YELLOW       = rgb(253, 238, 115),

  CITRON             = rgb(158, 169,  31),
  BRASS              = rgb(181, 166,  66),

  TUMBLEWEED         = rgb(222, 166, 129),
  ATOMIC_TANGERINE   = rgb(255, 153, 102),
  PUMPKIN_ORANGE     = rgb(248, 114,  23),

  SUNSET_ORANGE      = rgb(253,  94,  83),
  ROSSO_CORSA        = rgb(212,   0,   0),

  PINK_SHERBET       = rgb(247, 143, 167),
  BLUSH_PINK         = rgb(230, 169, 236),
  LIGHT_FUSCHIA_PINK = rgb(249, 132, 239),
  BRIGHT_NEON_PINK   = rgb(244,  51, 255),

  LILAC              = rgb(206, 162, 253),
  PURPLE_MIMOSA      = rgb(158, 123, 255),
  HELIOTROPE_PURPLE  = rgb(212,  98, 255),
  NEON_PURPLE        = rgb(188,  19, 254),

  LIGHT_AQUA         = rgb(140, 255, 219),
  LIGHT_CYAN         = rgb(172, 255, 252),
  FRENCH_PASS        = rgb(189, 237, 253),
  BABY_BLUE          = rgb(162, 207, 254),
  JORDY_BLUE         = rgb(138, 185, 241),
  DENIM_BLUE         = rgb(121, 186, 236),
  CRYSTAL_BLUE       = rgb( 92, 179, 255),
}


local OPTION_DEFAULTS = {
  profile = {
    SIMPLIFY = true,
    REORDER  = true,
    RECOLOR  = true,
    
    SHOW_SPEEDBAR = true,
    
    -- Bar width. Longer is more accurate but can cause a wider tooltip
    SPEEDBAR_SIZE  = 10,
    
    -- Number of significant decimal places on weapon speeds
    SPEED_ACCURACY = 1,
    
    COLORS = {
      TRAINABLE     = COLORS.ORANGE,
      WEAP_DAMAGE   = COLORS.TUMBLEWEED,
      SPEED         = COLORS.WHITE,
      ENCHANT       = COLORS.GREEN,
      SKILL         = COLORS.GREEN,
      
      ARMOR         = COLORS.YELLOW,
      
      STAMINA       = COLORS.PALE_LIGHT_GREEN,
      STRENGTH      = COLORS.TUMBLEWEED,
      AGILITY       = COLORS.SANDY_YELLOW,
      INTELLECT     = COLORS.JORDY_BLUE,
      SPIRIT        = COLORS.LIGHT_AQUA,
      
      ARCANE_RESIST = COLORS.ARCANE,
      FIRE_RESIST   = COLORS.FIRE,
      NATURE_RESIST = COLORS.NATURE,
      FROST_RESIST  = COLORS.FROST,
      SHADOW_RESIST = COLORS.SHADOW,
      HOLY_RESIST   = COLORS.HOLY,
      
      ARCANE_DAMAGE = COLORS.ARCANE,
      FIRE_DAMAGE   = COLORS.FIRE,
      NATURE_DAMAGE = COLORS.NATURE,
      FROST_DAMAGE  = COLORS.FROST,
      SHADOW_DAMAGE = COLORS.SHADOW,
      HOLY_DAMAGE   = COLORS.HOLY,
      
      DEFENSE       = COLORS.PALE_LIGHT_GREEN,
      RESILIENCE    = COLORS.HONEYSUCKLE,
      DODGE         = COLORS.HONEYSUCKLE,
      PARRY         = COLORS.PARIS_GREEN,
      BLOCK_RATING  = COLORS.LEMON_LIME,
      BLOCK_VALUE   = COLORS.LEMON_LIME,
      RESIST_ALL    = COLORS.PALE_LIGHT_GREEN,
      
      ATTACK_POW    = COLORS.TUMBLEWEED,
      R_ATTACK_POW  = COLORS.TUMBLEWEED,
      PHYS_HIT      = COLORS.SANDY_YELLOW,
      PHYS_CRIT     = COLORS.ATOMIC_TANGERINE,
      PHYS_HASTE    = COLORS.CITRON,
      PHYS_PEN      = COLORS.PUMPKIN_ORANGE,
      EXPERTISE     = COLORS.TUMBLEWEED,
      
      MAGICAL       = COLORS.LIGHT_FUSCHIA_PINK,
      MAGIC_HIT     = COLORS.BLUSH_PINK,
      MAGIC_CRIT    = COLORS.PURPLE_MIMOSA,
      MAGIC_HASTE   = COLORS.LILAC,
      MAGIC_PEN     = COLORS.HELIOTROPE_PURPLE,
      
      HEALING       = COLORS.LIGHT_CYAN,
      HEALTH        = COLORS.PALE_LIGHT_GREEN,
      MANA          = COLORS.JORDY_BLUE,
    },
    
    RECOLOR_STAT = {
      ["**"] = true,
      
      WEAP_DAMAGE = false,
      SPEED       = false,
      ENCHANT     = false,
      SKILL       = false,
    },
  },
}


-- End Configuration



function Data:FontifyColor(color)
  return color[1]/255, color[2]/255, color[3]/255, 1
end
function Data:DefontifyColor(r, g, b)
  return {r*255, g*255, b*255}
end

function Data:IsSameColor(color1, color2)
  for k, v in pairs(color1) do
    if color2[k] ~= v then
      return false
    end
  end
  return true
end

function Data:IsSameColorFuzzy(color1, color2, fuzziness)
  fuzziness = fuzziness or 0.02 * 255
  for k, v in pairs(color1) do
    if math.abs(color2[k] - v) > fuzziness then
      return false
    end
  end
  return true
end




Data.CLASS = select(2, UnitClass"player")

Data.WEAPON_SPEED_DIF = Data.WEAPON_SPEED_MAX - Data.WEAPON_SPEED_MIN

Data.COLOR_CODE       = "|c%x%x%x%x%x%x%x%x"
Data.COLOR_CODE_RESET = "|r"

Data.GRAY  = rgb(127, 127, 127)
Data.RED   = rgb(255,  32,  32)
Data.GREEN = rgb(  0, 255,   0)



local ELEMENTS_ENGLISH = {
  "Arcane",
  "Fire",
  "Nature",
  "Frost",
  "Shadow",
  "Holy",
}
local ELEMENT_KEYS = {}
for i, element in ipairs(ELEMENTS_ENGLISH) do
  ELEMENT_KEYS[i] = element:upper()
end
local ELEMENTS = {
  STRING_SCHOOL_ARCANE,
  STRING_SCHOOL_FIRE,
  STRING_SCHOOL_NATURE,
  STRING_SCHOOL_FROST,
  STRING_SCHOOL_SHADOW,
  STRING_SCHOOL_HOLY,
}
local ELEMENT_PATTERNS = {}
for i, element in ipairs(ELEMENTS) do
  local elementPattern = ""
  for char in element:gmatch"." do
    if char:match"%u" then
      elementPattern = ("%s[%s%s]"):format(elementPattern, char, char:lower())
    elseif char:match"%p" then
      elementPattern = elementPattern .. "%" .. char
    else
      elementPattern = elementPattern .. char
    end
  end
  ELEMENT_PATTERNS[i] = elementPattern
end

function Data:GetElements()
  return ELEMENTS
end
function Data:GetElement(i)
  return self:GetElements()[i]
end
function Data:GetElementPattern(i)
  return ELEMENT_PATTERNS[i]
end
function Data:GetElementEnglish(i)
  return ELEMENTS_ENGLISH[i]
end
function Data:GetElementKey(i)
  return ELEMENT_KEYS[i]
end



function Data:OnInitialize(L)
  
  local LEFT_TYPES = {}
  for _, globalString in ipairs{
    "INVTYPE_WEAPON",
    "INVTYPE_WEAPONOFFHAND",
    "INVTYPE_SHIELD",
    "INVTYPE_RANGED",
    "INVTYPE_2HWEAPON",
    "INVTYPE_HOLDABLE",
    "INVTYPE_WEAPONMAINHAND",
    "INVTYPE_RELIC",
    "INVTYPE_THROWN",
    
    "INVTYPE_HEAD",
    -- "INVTYPE_NECK",
    -- "INVTYPE_BODY",
    "INVTYPE_CHEST",
    "INVTYPE_LEGS",
    "INVTYPE_FEET",
    "INVTYPE_WRIST",
    "INVTYPE_HAND",
    -- "INVTYPE_FINGER",
    -- "INVTYPE_CLOAK",
    -- "INVTYPE_TABARD",
    "INVTYPE_ROBE",
    "INVTYPE_SHOULDER",
    -- "INVTYPE_TRINKET",
    "INVTYPE_WAIST",
    -- "INVTYPE_AMMO",
  } do
    LEFT_TYPES[globalString] = _G[globalString]
  end
  local LEFT_PACKS = {
    ONE_HAND  = {"INVTYPE_WEAPON", "INVTYPE_WEAPONOFFHAND", "INVTYPE_WEAPONMAINHAND"},
    TWO_HAND  = {"INVTYPE_2HWEAPON"},
    EQUIPMENT = { "INVTYPE_HEAD", "INVTYPE_CHEST", "INVTYPE_LEGS", "INVTYPE_FEET", "INVTYPE_WRIST", "INVTYPE_HAND", "INVTYPE_ROBE", "INVTYPE_SHOULDER", "INVTYPE_WAIST"},
  }
  for k, pack in pairs(LEFT_PACKS) do
    for i, invtype in ipairs(pack) do
      pack[i] = LEFT_TYPES[invtype]
    end
  end


  local ITEM_TYPES = {
    [WEAPON] = 2,
    [ARMOR]  = 4,
  }

  local SUBTYPES_DATA = {
    [WEAPON] = {
      [1]  = {subType = "Two-Handed Axes"  , redText = L["Axe"]        , leftText = LEFT_PACKS["TWO_HAND"]},
      [0]  = {subType = "One-Handed Axes"  , redText = L["Axe"]        , leftText = LEFT_PACKS["ONE_HAND"]},
      [8]  = {subType = "Two-Handed Swords", redText = L["Sword"]      , leftText = LEFT_PACKS["TWO_HAND"]},
      [7]  = {subType = "One-Handed Swords", redText = L["Sword"]      , leftText = LEFT_PACKS["ONE_HAND"]},
      [5]  = {subType = "Two-Handed Maces" , redText = L["Mace"]       , leftText = LEFT_PACKS["TWO_HAND"]},
      [4]  = {subType = "One-Handed Maces" , redText = L["Mace"]       , leftText = LEFT_PACKS["ONE_HAND"]},
      [6]  = {subType = "Polearms"         , redText = L["Polearm"]    , leftText = LEFT_PACKS["TWO_HAND"]},
      [10] = {subType = "Staves"           , redText = L["Staff"]      , leftText = LEFT_PACKS["TWO_HAND"]},
      [15] = {subType = "Daggers"          , redText = L["Dagger"]     , leftText = LEFT_PACKS["ONE_HAND"]},
      [13] = {subType = "Fist Weapons"     , redText = L["Fist Weapon"], leftText = LEFT_PACKS["ONE_HAND"]},
      
      [2]  = {subType = "Bows"             , rightText = nil          , redText = L["Bow"]},
      [18] = {subType = "Crossbows"        , rightText = nil          , redText = L["Crossbow"]},
      [3]  = {subType = "Guns"             , rightText = nil          , redText = L["Gun"]},
      [16] = {subType = "Thrown"           , rightText = nil          , redText = L["Thrown"]},
      [19] = {subType = "Wands"            , rightText = nil          , redText = L["Wand"]},
    },
    
    [ARMOR] = {
      -- [0] = {subType = "Miscellaneous", rightText = L["Miscellaneous"], leftText = {LEFT_TYPES["INVTYPE_HOLDABLE"]}},
      -- [1] = {subType = "Cloth"        , rightText = L["Cloth"]        , leftText = LEFT_PACKS["EQUIPMENT"],
      [2] = {subType = "Leather"      , redText = L["Leather"]      , leftText = LEFT_PACKS["EQUIPMENT"]},
      [3] = {subType = "Mail"         , redText = L["Mail"]         , leftText = LEFT_PACKS["EQUIPMENT"]},
      [4] = {subType = "Plate"        , redText = L["Plate"]        , leftText = LEFT_PACKS["EQUIPMENT"]},
      [6] = {subType = "Shields"      , redText = L["Shield"]       , leftText = {LEFT_TYPES["INVTYPE_SHIELD"]}},
      [7] = {subType = "Librams"      , redText = L["Libram"]       , leftText = {LEFT_TYPES["INVTYPE_RELIC"]}},
      [8] = {subType = "Idols"        , redText = L["Idol"]         , leftText = {LEFT_TYPES["INVTYPE_RELIC"]}},
      [9] = {subType = "Totems"       , redText = L["Totem"]        , leftText = {LEFT_TYPES["INVTYPE_RELIC"]}},
    },
  }

  local SUBTYPES_LOCALE_MAP = {}
  local ITEM_SUBTYPES       = {}
  for _, key in ipairs{WEAPON, ARMOR} do
    SUBTYPES_LOCALE_MAP[key] = {}
    ITEM_SUBTYPES[key]       = {}
    for i, data in pairs(SUBTYPES_DATA[key]) do
      SUBTYPES_LOCALE_MAP[key][data.subType] = GetItemSubClassInfo(ITEM_TYPES[key], i)
      ITEM_SUBTYPES[key][GetItemSubClassInfo(ITEM_TYPES[key], i)] = data.redText
    end
  end



  local USABLE_WEAPONS = {
    DRUID   = {"Two-Handed Maces", "One-Handed Maces", "Staves", "Daggers", "Fist Weapons"},
    HUNTER  = {"Two-Handed Axes", "One-Handed Axes", "Two-Handed Swords", "One-Handed Swords", "Polearms", "Staves", "Daggers", "Fist Weapons", "Bows", "Crossbows", "Guns", "Thrown"},
    MAGE    = {"One-Handed Swords", "Staves", "Daggers", "Wands"},
    PALADIN = {"Two-Handed Axes", "One-Handed Axes", "Two-Handed Swords", "One-Handed Swords", "Two-Handed Maces", "One-Handed Maces", "Polearms"},
    PRIEST  = {"One-Handed Maces", "Staves", "Daggers", "Wands"},
    ROGUE   = {"One-Handed Swords", "One-Handed Maces", "Daggers", "Fist Weapons", "Bows", "Crossbows", "Guns", "Thrown"},
    SHAMAN  = {"Two-Handed Axes", "One-Handed Axes", "Two-Handed Maces", "One-Handed Maces", "Staves", "Daggers", "Fist Weapons"},
    WARLOCK = {"One-Handed Swords", "Staves", "Daggers", "Wands"},
    WARRIOR = {"Two-Handed Axes", "One-Handed Axes", "Two-Handed Swords", "One-Handed Swords", "Two-Handed Maces", "One-Handed Maces", "Polearms", "Staves", "Daggers", "Fist Weapons", "Bows", "Crossbows", "Guns", "Thrown"},
  }
  local USABLE_ARMORS = {
    DRUID   = {"Leather", "Idols"},
    HUNTER  = {"Leather", "Mail"},
    MAGE    = {},
    PALADIN = {"Leather", "Mail", "Plate", "Shields", "Librams"},
    PRIEST  = {},
    ROGUE   = {"Leather"},
    SHAMAN  = {"Leather", "Mail", "Shields", "Totems"},
    WARLOCK = {},
    WARRIOR = {"Leather", "Mail", "Plate", "Shields"},
  }
  local UNUSABLE_INVTYPES = {
    DRUID   = {INVTYPE_WEAPONOFFHAND = true},
    HUNTER  = {},
    MAGE    = {INVTYPE_WEAPONOFFHAND = true},
    PALADIN = {INVTYPE_WEAPONOFFHAND = true},
    PRIEST  = {INVTYPE_WEAPONOFFHAND = true},
    ROGUE   = {},
    SHAMAN  = {INVTYPE_WEAPONOFFHAND = true},
    WARLOCK = {INVTYPE_WEAPONOFFHAND = true},
    WARRIOR = {},
  }
  local USABLE_EQUIPMENT = {}
  for class, weapons in pairs(USABLE_WEAPONS) do
    USABLE_EQUIPMENT[class] = {}
    USABLE_EQUIPMENT[class][WEAPON] = {}
    for _, weapon in ipairs(weapons) do
      USABLE_EQUIPMENT[class][WEAPON][SUBTYPES_LOCALE_MAP[WEAPON][weapon]] = true
    end
  end
  for class, armors in pairs(USABLE_ARMORS) do
    USABLE_EQUIPMENT[class][ARMOR] = {}
    for _, armor in ipairs(armors) do
      USABLE_EQUIPMENT[class][ARMOR][SUBTYPES_LOCALE_MAP[ARMOR][armor]] = true
    end
  end



  function Data:IsUsable(itemType, itemSubType, invType)
    return USABLE_EQUIPMENT[self.CLASS][itemType] and USABLE_EQUIPMENT[self.CLASS][itemType][itemSubType] and not UNUSABLE_INVTYPES[invType] and true or false
  end
  
  function Data:GetRedText(itemType, itemSubType, invType)
    -- AnonTable(ITEM_SUBTYPES[itemType]):print()
    return ITEM_SUBTYPES[itemType] and ITEM_SUBTYPES[itemType][itemSubType] or nil, invType == "INVTYPE_WEAPONOFFHAND" and not UNUSABLE_INVTYPES[invType] and LEFT_TYPES["INVTYPE_WEAPONOFFHAND"] or nil
  end
  
end





function Data:Round(num, decimalPlaces)
  local mult = 10^(tonumber(decimalPlaces) or 0)
  return math.floor(tonumber(num) * mult + 0.5) / mult
end








function Data:GetDefaultOptions()
  return OPTION_DEFAULTS
end





local order = 99
local function Order(inc)
  order = order + (inc and inc or 0) + 1
  return order
end


function Data:MakeOptionsTable(profile, L)
  local ADDON_OPTIONS = {
    type = "group",
    args = {}
  }
  
  local function CreateHeader(name)
    ADDON_OPTIONS.args["divider" .. Order()] = {name = name, order = Order(-1), type = "header"}
  end
  
  local function CreateDivider(count)
    for i = 1, count or Data.OPTIONS_DIVIDER_HEIGHT do
      ADDON_OPTIONS.args["divider" .. Order()] = {name  = "", order = Order(-1), type  = "description"}
    end
  end
  local function CreateNewline()
    CreateDivider(1)
  end
  local function CreateDescription(desc)
    CreateNewline()
    ADDON_OPTIONS.args["description" .. Order()] = {name  = L[desc], order = Order(-1), type  = "description"}
  end
  
  local function CreateColorOption(name, key, hasDesc)
    ADDON_OPTIONS.args[key] = {
      name = L[name],
      desc = hasDesc and L[name:upper() .. " DESCRIPTION"] or nil,
      order = Order(),
      type = "toggle",
      set = function(info, val)        profile.RECOLOR_STAT[key] = val end,
      get = function(info)      return profile.RECOLOR_STAT[key]       end,
    }
    
    ADDON_OPTIONS.args[key .. " Color"] = {
      name = L["Color"],
      order = Order(),
      type = "color",
      set = function(_, r, g, b)        profile.COLORS[key] = Data:DefontifyColor(r, g, b) end,
      get = function(info)       return Data:FontifyColor(profile.COLORS[key])             end,
    }
    
    ADDON_OPTIONS.args[key .. " Reset"] = {
      name = L["Reset"],
      order = Order(),
      type = "execute",
      func = function()
        profile.RECOLOR_STAT[key] = OPTION_DEFAULTS.profile.RECOLOR_STAT[key]
        profile.COLORS[key] = OPTION_DEFAULTS.profile.COLORS[key]
      end,
    }
    
    CreateNewline()
  end
  
  ADDON_OPTIONS.args["simplify"] = {
    name = L["Reword tooltips"],
    desc = L["REWORD TOOLTIPS DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        profile.SIMPLIFY = val end,
    get = function(info)      return profile.SIMPLIFY       end,
  }
  
  CreateNewline()
  
  ADDON_OPTIONS.args["reorder"] = {
    name = L["Reorder stats"],
    desc = L["REORDER STATS DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        profile.REORDER = val end,
    get = function(info)      return profile.REORDER       end,
  }
  
  CreateNewline()
  
  ADDON_OPTIONS.args["recolor"] = {
    name = L["Recolor stats"],
    desc = L["RECOLOR STATS DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        profile.RECOLOR = val end,
    get = function(info)      return profile.RECOLOR       end,
  }
  
  
  CreateHeader(L["Speedbar"])
  
  ADDON_OPTIONS.args["show_speedbar"] = {
    name = L["Show Speedbar"],
    desc = L["SHOW SPEEDBAR DESCRIPTION"],
    order = Order(),
    type = "toggle",
    set = function(info, val)        profile.SHOW_SPEEDBAR = val end,
    get = function(info)      return profile.SHOW_SPEEDBAR       end,
  }
  
  CreateNewline()
  
  ADDON_OPTIONS.args["speedbar_size"] = {
    name = L["Speedbar width"],
    desc = L["SPEEDBAR SIZE DESCRIPTION"],
    order = Order(),
    type = "range",
    min = 5,
    max = 25,
    step = 1,
    set = function(info, val)        profile.SPEEDBAR_SIZE = val end,
    get = function(info)      return profile.SPEEDBAR_SIZE       end,
  }
  
  ADDON_OPTIONS.args["speedbar_size Reset"] = {
    name = L["Reset"],
    order = Order(),
    type = "execute",
    func = function() profile.SPEEDBAR_SIZE = OPTION_DEFAULTS.profile.SPEEDBAR_SIZE end,
  }
  
  CreateNewline()
  
  ADDON_OPTIONS.args["speed_accuracy"] = {
    name = L["Speed accuracy"],
    desc = L["SPEED ACCURACY DESCRIPTION"],
    order = Order(),
    type = "range",
    min = 1,
    max = 5,
    step = 1,
    set = function(info, val)        profile.SPEED_ACCURACY = val end,
    get = function(info)      return profile.SPEED_ACCURACY       end,
  }
  
  ADDON_OPTIONS.args["speed_accuracy Reset"] = {
    name = L["Reset"],
    order = Order(),
    type = "execute",
    func = function() profile.SPEED_ACCURACY = OPTION_DEFAULTS.profile.SPEED_ACCURACY end,
  }
  
  
  CreateHeader(L["Colors"])
  
  ADDON_OPTIONS.args["ResetColors"] = {
    name = L["Reset Colors"],
    order = Order(),
    type = "execute",
    func =  function()
      for _, tbl in ipairs{"RECOLOR_STAT", "COLORS"} do
        for key in pairs(profile[tbl]) do
          profile[tbl][key] = OPTION_DEFAULTS.profile[tbl][key]
        end
      end
    end,
  }
  
  CreateDivider()
  
  CreateDescription("Miscellaneous")
  CreateColorOption("Trainable Equipment", "TRAINABLE"  , true)
  CreateColorOption("Weapon Damage"      , "WEAP_DAMAGE", true)
  CreateColorOption("Weapon Speed"       , "SPEED"      , true)
  CreateColorOption("Enchantment"        , "ENCHANT"    , true)
  CreateColorOption("Skill"              , "SKILL"      , true)
  
  CreateDivider()
  
  CreateDescription("Base Stats")
  CreateColorOption("Armor"    , "ARMOR")
  CreateColorOption("Stamina"  , "STAMINA")
  CreateColorOption("Strength" , "STRENGTH")
  CreateColorOption("Agility"  , "AGILITY")
  CreateColorOption("Intellect", "INTELLECT")
  CreateColorOption("Spirit"   , "SPIRIT")
  
  CreateDivider()
  
  CreateDescription("Elemental Resistances")
  CreateColorOption("Arcane Resist", "ARCANE_RESIST")
  CreateColorOption("Fire Resist"  , "FIRE_RESIST")
  CreateColorOption("Nature Resist", "NATURE_RESIST")
  CreateColorOption("Frost Resist" , "FROST_RESIST")
  CreateColorOption("Shadow Resist", "SHADOW_RESIST")
  CreateColorOption("Holy Resist"  , "HOLY_RESIST")
  CreateColorOption("Resist All"  , "RESIST_ALL")
  
  CreateDivider()
  
  CreateDescription("Elemental Damage")
  CreateColorOption("Arcane Damage", "ARCANE_DAMAGE")
  CreateColorOption("Fire Damage"  , "FIRE_DAMAGE")
  CreateColorOption("Nature Damage", "NATURE_DAMAGE")
  CreateColorOption("Frost Damage" , "FROST_DAMAGE")
  CreateColorOption("Shadow Damage", "SHADOW_DAMAGE")
  CreateColorOption("Holy Damage"  , "HOLY_DAMAGE")
  
  CreateDivider()
  
  CreateDescription("Defensive")
  CreateColorOption("Defense", "DEFENSE")
  if Data:IsBCC() then
    CreateColorOption("Resilience", "RESILIENCE")
  end
  CreateColorOption("Dodge"       , "DODGE")
  CreateColorOption("Parry"       , "PARRY")
  CreateColorOption("Block Rating", "BLOCK_RATING")
  CreateColorOption("Block Value" , "BLOCK_VALUE")
  
  CreateDivider()
  
  CreateDescription("Physical")
  CreateColorOption("Attack Power"       , "ATTACK_POW")
  CreateColorOption("Ranged Attack Power", "R_ATTACK_POW")
  CreateColorOption("Physical Hit"       , "PHYS_HIT")
  CreateColorOption("Physical Crit"      , "PHYS_CRIT")
  if Data:IsBCC() then
    CreateColorOption("Physical Haste", "PHYS_HASTE")
    CreateColorOption("Armor Pen"     , "PHYS_PEN")
    CreateColorOption("Expertise"     , "EXPERTISE")
  end
  
  CreateDivider()
  
  CreateDescription("Magical")
  CreateColorOption("Spell Damage", "MAGICAL")
  CreateColorOption("Spell Hit"   , "MAGIC_HIT")
  CreateColorOption("Spell Crit"  , "MAGIC_CRIT")
  if Data:IsBCC() then
    CreateColorOption("Spell Haste", "MAGIC_HASTE")
    CreateColorOption("Spell Pen"  , "MAGIC_PEN")
  end
  
  CreateDivider()
  
  CreateDescription("Healing")
  CreateColorOption("Healing", "HEALING")
  CreateColorOption("Health" , "HEALTH")
  CreateColorOption("Mana"   , "MANA")

  return ADDON_OPTIONS
end









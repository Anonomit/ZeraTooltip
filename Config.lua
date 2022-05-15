

local ADDON_NAME, Data = ...


local buildMajor = tonumber(GetBuildInfo():match"^(%d+)%.")
if buildMajor == 2 then
  Data.WOW_VERSION = "BCC"
elseif buildMajor == 1 then
  Data.WOW_VERSION = "Classic"
end

function Data:IsBCC()
  return Data.WOW_VERSION == "BCC"
end
function Data:IsClassic()
  return Data.WOW_VERSION == "Classic"
end


local function rgb(r, g, b)
  return {r, g, b}
end





--   ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
--  ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
--  ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
--  ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
--  ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--   ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 



Data.CHAT_COMMAND = "zt"

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
  PURPLE_PIZZAZZ     = rgb(255,  80, 218),
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

function Data:MakeDefaultOptions()
  return {
    profile = {
      SIMPLIFY = true,
      REORDER  = true,
      RECOLOR  = true,
      
      RECOLOR_USABLE = true,
      
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
        MAGIC_HIT     = COLORS.PURPLE_PIZZAZZ,
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
      Debug = {
        enabled         = true,
        menu            = false,
        
        showLabels      = false,
        ctrlSupprseeion = false,
      },
    },
  }
end

--  ███████╗███╗   ██╗██████╗      ██████╗ ██████╗ ███╗   ██╗███████╗██╗ ██████╗ 
--  ██╔════╝████╗  ██║██╔══██╗    ██╔════╝██╔═══██╗████╗  ██║██╔════╝██║██╔════╝ 
--  █████╗  ██╔██╗ ██║██║  ██║    ██║     ██║   ██║██╔██╗ ██║█████╗  ██║██║  ███╗
--  ██╔══╝  ██║╚██╗██║██║  ██║    ██║     ██║   ██║██║╚██╗██║██╔══╝  ██║██║   ██║
--  ███████╗██║ ╚████║██████╔╝    ╚██████╗╚██████╔╝██║ ╚████║██║     ██║╚██████╔╝
--  ╚══════╝╚═╝  ╚═══╝╚═════╝      ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝     ╚═╝ ╚═════╝ 





function Data:Round(num, decimalPlaces)
  local mult = 10^(tonumber(decimalPlaces) or 0)
  return math.floor(tonumber(num) * mult + 0.5) / mult
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


  local ITEM_TYPES = {
    [WEAPON] = 2,
    [ARMOR]  = 4,
  }

  local SUBTYPES_DATA = {
    [WEAPON] = {
      [1]  = {subType = "Two-Handed Axes"  , text = L["Axe"]},
      [0]  = {subType = "One-Handed Axes"  , text = L["Axe"]},
      [8]  = {subType = "Two-Handed Swords", text = L["Sword"]},
      [7]  = {subType = "One-Handed Swords", text = L["Sword"]},
      [5]  = {subType = "Two-Handed Maces" , text = L["Mace"]},
      [4]  = {subType = "One-Handed Maces" , text = L["Mace"]},
      [6]  = {subType = "Polearms"         , text = L["Polearm"]},
      [10] = {subType = "Staves"           , text = L["Staff"]},
      [15] = {subType = "Daggers"          , text = L["Dagger"]},
      [13] = {subType = "Fist Weapons"     , text = L["Fist Weapon"]},
      
      [2]  = {subType = "Bows"             , text = L["Bow"]},
      [18] = {subType = "Crossbows"        , text = L["Crossbow"]},
      [3]  = {subType = "Guns"             , text = L["Gun"]},
      [16] = {subType = "Thrown"           , text = L["Thrown"]},
      [19] = {subType = "Wands"            , text = L["Wand"]},
    },
    
    [ARMOR] = {
      -- [0] = {subType = "Miscellaneous", text = L["Miscellaneous"]},
      -- [1] = {subType = "Cloth"        , text = L["Cloth"]},
      [2] = {subType = "Leather"      , text = L["Leather"]},
      [3] = {subType = "Mail"         , text = L["Mail"]},
      [4] = {subType = "Plate"        , text = L["Plate"]},
      [6] = {subType = "Shields"      , text = L["Shield"]},
      [7] = {subType = "Librams"      , text = L["Libram"]},
      [8] = {subType = "Idols"        , text = L["Idol"]},
      [9] = {subType = "Totems"       , text = L["Totem"]},
    },
  }

  local SUBTYPES_LOCALE_MAP = {}
  local ITEM_SUBTYPES       = {}
  for _, key in ipairs{WEAPON, ARMOR} do
    SUBTYPES_LOCALE_MAP[key] = {}
    ITEM_SUBTYPES[key]       = {}
    for i, data in pairs(SUBTYPES_DATA[key]) do
      SUBTYPES_LOCALE_MAP[key][data.subType] = GetItemSubClassInfo(ITEM_TYPES[key], i)
      ITEM_SUBTYPES[key][GetItemSubClassInfo(ITEM_TYPES[key], i)] = data.text
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
    return ITEM_SUBTYPES[itemType] and ITEM_SUBTYPES[itemType][itemSubType] or nil, invType == "INVTYPE_WEAPONOFFHAND" and not UNUSABLE_INVTYPES[invType] and LEFT_TYPES["INVTYPE_WEAPONOFFHAND"] or nil
  end
  
end





function Data:FontifyColor(color)
  return color[1]/255, color[2]/255, color[3]/255, 1
end
function Data:DefontifyColor(r, g, b)
  return {r*255, g*255, b*255}
end
local function GetOptionTableHelpers(Options, Addon)
  local defaultInc = 1000
  local order      = 1000
  
  local GUI = {}
  
  function GUI:GetOrder()
    return order
  end
  function GUI:SetOrder(newOrder)
    order = newOrder
  end
  function GUI:Order(inc)
    self:SetOrder(self:GetOrder() + (inc or defaultInc))
    return self:GetOrder()
  end
  
  function GUI:CreateEntry(keys, name, desc, widgetType, disabled, order)
    if type(keys) ~= "table" then keys = {keys} end
    local key = widgetType .. "_" .. (table.concat(keys, ".") or "")
    Options.args[key] = {name = name, desc = desc, type = widgetType, order = order or self:Order(), disabled = disabled}
    Options.args[key].set = function(info, val)        Addon:SetOption(val, unpack(keys)) end
    Options.args[key].get = function(info)      return Addon:GetOption(unpack(keys))      end
    return Options.args[key]
  end
  
  function GUI:CreateHeader(name)
    local option = self:CreateEntry(self:Order(), name, nil, "header", nil, self:Order(0))
  end
  
  function GUI:CreateDescription(desc, fontSize)
    local option = self:CreateEntry(self:Order(), desc, nil, "description", nil, self:Order(0))
    option.fontSize = fontSize or "large"
  end
  function GUI:CreateDivider(count)
    for i = 1, count or 3 do
      self:CreateDescription("", "small")
    end
  end
  function GUI:CreateNewline()
    return self:CreateDivider(1)
  end
  
  function GUI:CreateToggle(keys, name, desc, disabled)
    local option = self:CreateEntry(keys, name, desc, "toggle", disabled)
    return option
  end
  
  function GUI:CreateRange(keys, name, desc, min, max, step, disabled)
    local option = self:CreateEntry(keys, name, desc, "range", disabled)
    option.min   = min
    option.max   = max
    option.step  = step
    return option
  end
  
  function GUI:CreateInput(keys, name, desc, multiline, disabled)
    local option     = self:CreateEntry(keys, name, desc, "input", disabled)
    option.multiline = multiline
    return option
  end
  
  function GUI:CreateColor(keys, name, desc, disabled)
    local option = self:CreateEntry(keys, name, desc, "color", disabled)
    option.set   = function(info, r, g, b)        Addon:SetOption(Data:DefontifyColor(r, g, b), unpack(keys)) end
    option.get   = function(info)          return Data:FontifyColor(Addon:GetOption(unpack(keys)))            end
    return option
  end
  
  function GUI:CreateExecute(key, name, desc, func, disabled)
    local option = self:CreateEntry(key, name, desc, "execute", disabled)
    option.func  = func
    return option
  end
  
  return GUI
end


function Data:MakeOptionsTable(title, Addon, L)
  local Options = {
    name = title,
    type = "group",
    args = {}
  }
  local GUI = GetOptionTableHelpers(Options, Addon)
  
  
  GUI:CreateToggle("SIMPLIFY", L["Reword tooltips"], L["REWORD TOOLTIPS DESCRIPTION"])
  GUI:CreateNewline()
  GUI:CreateToggle("REORDER", L["Reorder stats"], L["REORDER STATS DESCRIPTION"])
  GUI:CreateNewline()
  GUI:CreateToggle("RECOLOR", L["Recolor stats"], L["RECOLOR STATS DESCRIPTION"])
  
  
  
  
  return Options
end




function Data:MakeSpeedbarOptionsTable(title, Addon, L)
  local Options = {
    name = title,
    type = "group",
    args = {}
  }
  local GUI = GetOptionTableHelpers(Options, Addon)
  
  
  GUI:CreateToggle("SHOW_SPEEDBAR", L["Show Speedbar"], L["SHOW SPEEDBAR DESCRIPTION"])
  GUI:CreateNewline()
  
  GUI:CreateRange("SPEEDBAR_SIZE", L["Speedbar width"], L["SPEEDBAR SIZE DESCRIPTION"], 5, 25, 1)
  GUI:CreateExecute("SPEEDBAR_SIZE Reset", L["Reset"], nil, function() Addon:ResetOption"SPEEDBAR_SIZE" end)
  
  GUI:CreateNewline()
  
  GUI:CreateRange("SPEED_ACCURACY", L["Speed accuracy"], L["SPEED ACCURACY DESCRIPTION"], 1, 5, 1)
  GUI:CreateExecute("SPEED_ACCURACY Reset", L["Reset"], nil, function() Addon:ResetOption"SPEED_ACCURACY" end)
  
  
  return Options
end


function Data:MakeColorsOptionsTable(title, Addon, L)
  local Options = {
    name = title,
    type = "group",
    args = {}
  }
  local GUI = GetOptionTableHelpers(Options, Addon)
  
  
  local function CreateColorOption(key, name, desc)
    GUI:CreateToggle({"RECOLOR_STAT", key}, name, desc)
    GUI:CreateColor({"COLORS", key}, L["Color"], nil, function() return not not not Addon:GetOption("RECOLOR_STAT", key) end)
    GUI:CreateExecute(key .. " Reset", L["Reset"], nil, function() Addon:ResetOption("RECOLOR_STAT", key) Addon:ResetOption("COLORS", key) end)
    GUI:CreateNewline()
  end
  
  
  GUI:CreateExecute("ResetColors", L["Reset Color Options"], nil, function()
    Addon:ResetOption("RECOLOR_USABLE")
    for _, option in ipairs{"RECOLOR_STAT", "COLORS"} do
      for color in pairs(Addon:GetOption(option)) do
        Addon:ResetOption(option, color)
      end
    end
  end)
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Miscellaneous")
  GUI:CreateToggle("RECOLOR_USABLE", L["Recolor Usable Effects"], L["Recolor Usable Effects DESCRIPTION"])
  
  GUI:CreateNewline()
  CreateColorOption("TRAINABLE"  , L["Trainable Equipment"], L["Trainable Equipment DESCRIPTION"])
  CreateColorOption("WEAP_DAMAGE", L["Weapon Damage"]      , L["Weapon Damage DESCRIPTION"])
  CreateColorOption("SPEED"      , L["Weapon Speed"]       , L["Weapon Speed DESCRIPTION"])
  CreateColorOption("ENCHANT"    , L["Enchantment"]        , L["Enchantment DESCRIPTION"])
  CreateColorOption("SKILL"      , L["Skill"]              , L["Skill DESCRIPTION"])
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Base Stats")
  CreateColorOption("ARMOR"    , L["Armor"])
  CreateColorOption("STAMINA"  , L["Stamina"])
  CreateColorOption("STRENGTH" , L["Strength"])
  CreateColorOption("AGILITY"  , L["Agility"])
  CreateColorOption("INTELLECT", L["Intellect"])
  CreateColorOption("SPIRIT"   , L["Spirit"])
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Elemental Resistances")
  CreateColorOption("ARCANE_RESIST", L["Arcane Resist"])
  CreateColorOption("FIRE_RESIST"  , L["Fire Resist"])
  CreateColorOption("NATURE_RESIST", L["Nature Resist"])
  CreateColorOption("FROST_RESIST" , L["Frost Resist"])
  CreateColorOption("SHADOW_RESIST", L["Shadow Resist"])
  CreateColorOption("HOLY_RESIST"  , L["Holy Resist"])
  CreateColorOption("RESIST_ALL"  , L["Resist All"])
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Elemental Damage")
  CreateColorOption("ARCANE_DAMAGE", L["Arcane Damage"])
  CreateColorOption("FIRE_DAMAGE"  , L["Fire Damage"])
  CreateColorOption("NATURE_DAMAGE", L["Nature Damage"])
  CreateColorOption("FROST_DAMAGE" , L["Frost Damage"])
  CreateColorOption("SHADOW_DAMAGE", L["Shadow Damage"])
  CreateColorOption("HOLY_DAMAGE"  , L["Holy Damage"])
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Defensive")
  CreateColorOption("DEFENSE", L["Defense"])
  if Data:IsBCC() then
    CreateColorOption("RESILIENCE", L["Resilience"])
  end
  CreateColorOption("DODGE"       , L["Dodge"])
  CreateColorOption("PARRY"       , L["Parry"])
  CreateColorOption("BLOCK_RATING", L["Block Rating"])
  CreateColorOption("BLOCK_VALUE" , L["Block Value"])
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Physical")
  CreateColorOption("ATTACK_POW"       , L["Attack Power"])
  CreateColorOption("R_ATTACK_POW", L["Ranged Attack Power"])
  CreateColorOption("PHYS_HIT"       , L["Physical Hit"])
  CreateColorOption("PHYS_CRIT"      , L["Physical Crit"])
  if Data:IsBCC() then
    CreateColorOption("PHYS_HASTE", L["Physical Haste"])
    CreateColorOption("PHYS_PEN"     , L["Armor Pen"])
    CreateColorOption("EXPERTISE"     , L["Expertise"])
  end
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Magical")
  CreateColorOption("MAGICAL", L["Spell Damage"])
  CreateColorOption("MAGIC_HIT"   , L["Spell Hit"])
  CreateColorOption("MAGIC_CRIT"  , L["Spell Crit"])
  if Data:IsBCC() then
    CreateColorOption("MAGIC_HASTE", L["Spell Haste"])
    CreateColorOption("MAGIC_PEN"  , L["Spell Pen"])
  end
  
  GUI:CreateDivider()
  
  GUI:CreateDescription("Healing")
  CreateColorOption("HEALING", L["Healing"])
  CreateColorOption("HEALTH" , L["Health"])
  CreateColorOption("MANA"   , L["Mana"])
  
  return Options
end


function Data:MakeDebugOptionsTable(title, Addon, L)
  local Options = {
    name = title,
    type = "group",
    args = {}
  }
  local GUI = GetOptionTableHelpers(Options, Addon)
  
  GUI:CreateToggle({"Debug", "enabled"}        , "Enabled")
  GUI:CreateNewline()
  GUI:CreateToggle({"Debug", "showLabels"}     , "Show Labels")
  GUI:CreateNewline()
  GUI:CreateToggle({"Debug", "ctrlSuppression"}, "CTRL Suppression")
  
  return Options
end







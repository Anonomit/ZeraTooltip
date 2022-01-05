
local ADDON_NAME, Data = ...

local locale = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
local L = {}



L["Miscellaneous"]         = MISCELLANEOUS
for i, element in ipairs(Data:GetElements()) do
  L[Data:GetElementEnglish(i) .. " Resist"] = element .. " Resist"
  L[Data:GetElementEnglish(i) .. " Damage"] = element .. " Damage"
end





L["Equip PATTERN"]           = "^%s*Equip:%s*"
L["Use PATTERN"]             = "^%s*Use:%s*"
L["Set PATTERN"]             = "^%(?%d*%)?%s*Set:%s*"
L["SocketBonus PATTERN"]     = "^%s*Socket Bonus:%s*"
L["ConjunctiveWord PATTERN"] = "%s+and%s+"
L["DisjunctiveWord PATTERN"] = "%s+or%s+"


L["Weapon Speed PATTERN"] = "(Speed) (%d)%.(%d*)"


-- Removes leading/trailing spaces. Also removes leading "your " and appending " spell" or " ability" text when it's meaningless
local function TrimSpell(spell)
  local spell = spell:gsub("^%s*", ""):gsub("%s*$", ""):gsub("%.$", "")
  if spell:match(" spells$") or spell:match(" abilities$") then
    if spell:match(L["ConjunctiveWord PATTERN"]) or spell:match(L["DisjunctiveWord PATTERN"]) then
      spell = spell:gsub(" spells$", ""):gsub( "abilities$", ""):gsub("^your ", "")
    end
  else
    spell = spell:gsub(" spell$", ""):gsub(" ability$", ""):gsub("^your ", "")
  end
  return spell
end

local function FixPercent(amount)
  return amount:gsub("%%", "%%%%")
end


local function debugArgs(...)
  PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3)
  for k, v in ipairs{...} do
    print(("'%s'"):format(v))
  end
end





L["Reword tooltips"]                    = "Reword tooltips"
L["REWORD TOOLTIPS DESCRIPTION"]        = "Shortens some long lines of text on item tooltips. Does not remove any information."

L["Reorder stats"]                      = "Reorder stats"
L["REORDER STATS DESCRIPTION"]          = "Makes tooltips display stats in a consistent order. Always Stamina before Intellect, for example."

L["Recolor stats"]                      = "Recolor stats"
L["RECOLOR STATS DESCRIPTION"]          = "Adds customizable coloring to stats in tooltips."

L["Recolor Usable Effects"]             = "Recolor usable effects"
L["RECOLOR USABLE EFFECTS DESCRIPTION"] = "This applies to active trinkets, as well as consumable items like food, drinks, potions, and bandages."

L["Show Speedbar"]                      = "Show Speedbar"
L["SHOW SPEEDBAR DESCRIPTION"]          = "Displays a bar which visualizes weapon speed. The bar will be more filled for slower weapons."

L["Speedbar width"]                     = "Speedbar width"
L["SPEEDBAR SIZE DESCRIPTION"]          = "The maximum length of the speedbar (for a slow weapon). Higher values make the bar more accurate, but also make the tooltip wider."

L["Speed accuracy"]                     = "Speed accuracy"
L["SPEED ACCURACY DESCRIPTION"]         = "The number of decimal places to appear in a weapon's speed. Default tooltips show two, but only one is ever needed."


L["Reset"]               = "Reset"
L["Color"]               = "Color"
L["Colors"]              = "Colors"
L["Reset Color Options"] = "Reset Color Options"
L["Speedbar"]            = "Speedbar"

L["Base Stats"]            = "Base Stats"
L["Elemental Resistances"] = "Elemental Resistances"
L["Elemental Damage"]      = "Elemental Damage"
L["Defensive"]             = "Defensive"
L["Physical"]              = "Physical"
L["Magical"]               = "Magical"
L["Healing"]               = "Healing"

L["Trainable Equipment"]             = "Trainable Equipment"
L["TRAINABLE EQUIPMENT DESCRIPTION"] = "Items which are equippable after more training will appear as a customizable color instead of the default red."

L["Weapon Damage"]             = "Weapon Damage"
L["WEAPON DAMAGE DESCRIPTION"] = "This will only affect weapons which deal physical damage (not wands)."

L["Weapon Speed"]             = "Weapon Speed"
L["WEAPON SPEED DESCRIPTION"] = "This will also recolor the weapon speedbar, if enabled."

L["Enchantment"]             = "Enchantment"
L["ENCHANTMENT DESCRIPTION"] = "Enchantments will appear in a customizable color."

L["Skill"]             = "Skill"
L["SKILL DESCRIPTION"] = "This applies to weapon and profession skill bonuses."



L["Armor"] = "Armor"

L["Stamina"]   = "Stamina"
L["Strength"]  = "Strength"
L["Agility"]   = "Agility"
L["Intellect"] = "Intellect"
L["Spirit"]    = "Spirit"

L["Defense"]      = "Defense"
L["Resilience"]   = "Resilience"
L["Dodge"]        = "Dodge"
L["Parry"]        = "Parry"
if Data:IsBCC() then
  L["Block Rating"] = "Block Rating"
elseif Data:IsClassic() then
  L["Block Rating"] = "Block Chance"
end
L["Block Value"]  = "Block Value"
L["Resist All"]   = "Resist All"
  
L["Attack Power"]        = "Attack Power"
L["Ranged Attack Power"] = "Ranged Attack Power"
L["Physical Hit"]        = "Physical Hit"
L["Physical Crit"]       = "Physical Crit"
L["Physical Haste"]      = "Physical Haste"
L["Armor Pen"]           = "Armor Pen"
L["Expertise"]           = "Expertise"

L["Spell Damage"] = "Spell Damage"
L["Spell Hit"]    = "Spell Hit"
L["Spell Crit"]   = "Spell Crit"
L["Spell Haste"]  = "Spell Haste"
L["Spell Pen"]    = "Spell Pen"

L["Healing"] = "Healing"
L["Health"]  = "Health"
L["Mana"]    = "Mana"




-- Get localized item subtype names from https://wow.tools/dbc/?dbc=itemsubclass
-- Get correct build with GetBuildInfo()

L["Axe"]         = "Axe"
L["Sword"]       = "Sword"
L["Mace"]        = "Mace"
L["Polearm"]     = "Polearm"
L["Staff"]       = "Staff"
L["Dagger"]      = "Dagger"
L["Fist Weapon"] = "Fist Weapon"
L["Bow"]         = "Bow"
L["Crossbow"]    = "Crossbow"
L["Gun"]         = "Gun"
L["Thrown"]      = "Thrown"
L["Wand"]        = "Wand"

-- L["Miscellaneous"] = "Miscellaneous"
-- L["Cloth"]         = "Cloth"
L["Leather"]       = "Leather"
L["Mail"]          = "Mail"
L["Plate"]         = "Plate"
L["Shield"]        = "Shield"
L["Libram"]        = "Libram"
L["Idol"]          = "Idol"
L["Totem"]         = "Totem"














--  ██╗    ██╗███████╗ █████╗ ██████╗  ██████╗ ███╗   ██╗    ███████╗████████╗ █████╗ ████████╗███████╗
--  ██║    ██║██╔════╝██╔══██╗██╔══██╗██╔═══██╗████╗  ██║    ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
--  ██║ █╗ ██║█████╗  ███████║██████╔╝██║   ██║██╔██╗ ██║    ███████╗   ██║   ███████║   ██║   ███████╗
--  ██║███╗██║██╔══╝  ██╔══██║██╔═══╝ ██║   ██║██║╚██╗██║    ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
--  ╚███╔███╔╝███████╗██║  ██║██║     ╚██████╔╝██║ ╚████║    ███████║   ██║   ██║  ██║   ██║   ███████║
--   ╚══╝╚══╝ ╚══════╝╚═╝  ╚═╝╚═╝      ╚═════╝ ╚═╝  ╚═══╝    ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝


for i, element in pairs(Data:GetElements()) do
  L[#L+1] = {LABEL = element .. " Damage"}
  L[#L].COLOR = Data:GetElementKey(i) .. "_DAMAGE"
  L[#L].MAP = {
    {
      INPUT  = "(%d+) %- (%d+) " .. Data:GetElementPattern(i) .. " Damage$",
      OUTPUT = "%d - %d " .. element .. " Damage",
    },
  }
  L[#L].CAPTURES = {
    "%d+ %- %d+ " .. element .. " Damage",
  }
end

L[#L+1] = {LABEL = "Physical Damage"}
L[#L].COLOR = "WEAP_DAMAGE"
L[#L].CAPTURES = {
  "%d+ %- %d+ Damage",
}

L[#L+1] = {LABEL = "Damage per Second"}
L[#L].MAP = {
  {
    INPUT  = "%(([%d%.]+) damage per second%)",
    OUTPUT = "(%s DPS)",
  },
  {
    INPUT  = "Adds ([%d%.]+) damage per second",
    OUTPUT = "+%s DPS",
  },
 }
L[#L].CAPTURES = {
  "%(%s+ DPS%)",
}










--  ██████╗  █████╗ ███████╗███████╗    ███████╗████████╗ █████╗ ████████╗███████╗
--  ██╔══██╗██╔══██╗██╔════╝██╔════╝    ██╔════╝╚══██╔══╝██╔══██╗╚══██╔══╝██╔════╝
--  ██████╔╝███████║███████╗█████╗      ███████╗   ██║   ███████║   ██║   ███████╗
--  ██╔══██╗██╔══██║╚════██║██╔══╝      ╚════██║   ██║   ██╔══██║   ██║   ╚════██║
--  ██████╔╝██║  ██║███████║███████╗    ███████║   ██║   ██║  ██║   ██║   ███████║
--  ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝    ╚══════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝


L[#L+1] = {LABEL = "Armor"}
L[#L].COLOR = "ARMOR"
L[#L].MAP = {
  {
    INPUT  = "Increases armor by (%d+)",
    OUTPUT = "+%d " .. L["Armor"],
  },
  {
    INPUT  = "^([%+%-]%d+) " .. L["Armor"] .. "%.$",
    OUTPUT = "%s " .. L["Armor"],
  },
}
L[#L].CAPTURES = {
  "[%+%-]?%d+ " .. L["Armor"],
}

L[#L+1] = {LABEL = "Block"}
L[#L].COLOR = "BLOCK_VALUE"
L[#L].MAP = {
  {
    INPUT  = "^(%d+) " .. "Block" .. "%.$",
    OUTPUT = "%d " .. "Block",
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ " .. "Block" .. "$",
}

for _, stat in ipairs{"Stamina", "Strength", "Agility", "Intellect", "Spirit"} do
  L[#L+1] = {LABEL = stat}
  L[#L].COLOR = stat:upper()
  L[#L].MAP = {
    {
      INPUT  = "^[%+%-](%d+) " .. L[stat] .. "%.$",
      OUTPUT = "+%d " .. L[stat],
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ " .. L[stat] .. "$",
  }
end

L[#L+1] = {LABEL = "All Resist"}
L[#L].COLOR = "RESIST_ALL"
L[#L].MAP = {
  {
    INPUT  = "^[%+%-](%d+) All Resistances%.?$",
    OUTPUT = "+%d All Resist",
  },
  {
    INPUT  = "Increases your resistance to all schools of magic by (%d+)%.?",
    OUTPUT = "+%d All Resist",
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ All Resist",
}

for i, element in pairs(Data:GetElements()) do
  L[#L+1] = {LABEL = element .. " Resist"}
  L[#L].COLOR = Data:GetElementKey(i) .. "_RESIST"
  L[#L].MAP = {
    {
      INPUT  = "^%+(%d+) " .. Data:GetElementPattern(i) .. " Resista?n?c?e?%.?$",
      OUTPUT = "+%d " .. element .. " Resist",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ " .. element .. " Resist.*",
  }
end











--  ██████╗ ███████╗███████╗███████╗███╗   ██╗███████╗██╗██╗   ██╗███████╗
--  ██╔══██╗██╔════╝██╔════╝██╔════╝████╗  ██║██╔════╝██║██║   ██║██╔════╝
--  ██║  ██║█████╗  █████╗  █████╗  ██╔██╗ ██║███████╗██║██║   ██║█████╗  
--  ██║  ██║██╔══╝  ██╔══╝  ██╔══╝  ██║╚██╗██║╚════██║██║╚██╗ ██╔╝██╔══╝  
--  ██████╔╝███████╗██║     ███████╗██║ ╚████║███████║██║ ╚████╔╝ ███████╗
--  ╚═════╝ ╚══════╝╚═╝     ╚══════╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═══╝  ╚══════╝


L[#L+1] = {LABEL = "Defense"}
L[#L].COLOR = "ARMOR"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases defense rating by (%d+)%.?",
      OUTPUT = "+%d Defense Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Defense Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "Increased Defense %+(%d+)%.?",
      OUTPUT = "+%d Defense",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Defense.*",
  }
end




if Data:IsBCC() then
  L[#L+1] = {LABEL = "Resilience"}
  L[#L].COLOR = "RESILIENCE"
  L[#L].MAP = {
    {
      INPUT = "Improves your resilience rating by (%d+)%.?",
      OUTPUT = "+%d Resilience",
    },
    {
      INPUT = "%+(%d+) Resilience Rating",
      OUTPUT = "+%d Resilience",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Resilience.*",
  }
end

L[#L+1] = {LABEL = "Dodge"}
L[#L].COLOR = "DODGE"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases your dodge rating by (%d+)%.?",
      OUTPUT = "+%d Dodge Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Dodge Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "Increases your chance to dodge an attack by (%d+)%%%.?",
      OUTPUT = "+%d%%%% Dodge",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+%% Dodge.*",
  }
end

L[#L+1] = {LABEL = "Parry"}
L[#L].COLOR = "PARRY"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases your parry rating by (%d+)%.?",
      OUTPUT = "+%d Parry Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Parry Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "Increases your chance to parry ?a?n? ?a?t?t?a?c?k? by (%d+)%%%.?",
      OUTPUT = "+%d%%%% Parry",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+%% Parry.*",
  }
end

L[#L+1] = {LABEL = "Block Rating"}
L[#L].COLOR = "BLOCK_RATING"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases your ?s?h?i?e?l?d? block rating by (%d+)%.?",
      OUTPUT = "+%d Block Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Block Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "Increases ?y?o?u?r? chance to block attacks with a shield by (%d+)%%%.?",
      OUTPUT = "+%d%%%% Block Chance",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+%% Block Chance.*",
  }
end

L[#L+1] = {LABEL = "Block Value"}
L[#L].MAP = {
  {
    INPUT = "Increases the block value of your shield by (%d+)%.?",
    OUTPUT = "+%d Block Value",
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ Block Value.*",
}
L[#L].COLOR = "BLOCK_VALUE"

for i, element in pairs(Data:GetElements()) do
  L[#L+1] = {LABEL = element .. " Reflect Damage"}
  L[#L].MAP = {
    {
      INPUT = "When struck in combat inflicts (%d+) " .. Data:GetElementPattern(i) .. " damage to the attacker%.?",
      OUTPUT = "+%d " .. element .. " damage reflected to melee attackers",
    },
    {
      INPUT = "Deals (%d+) " .. Data:GetElementPattern(i) .. " damage to anyone who strikes you with a melee attack%.?",
      OUTPUT = "+%d " .. element .. " damage reflected to melee attackers",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ " .. element .. " damage reflected to melee attackers.*",
  }
  L[#L].COLOR = Data:GetElementKey(i) .. "_DAMAGE"

end
L[#L+1] = {LABEL = "Resist All"}
L[#L].MAP = {
  {
    INPUT = "Increases resistances to all schools of magic by (%d+)",
    OUTPUT = "+%d All Resistances",
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ All Resistances.*",
}
L[#L].COLOR = "RESIST_ALL"










--  ██████╗ ██╗  ██╗██╗   ██╗███████╗██╗ ██████╗ █████╗ ██╗     
--  ██╔══██╗██║  ██║╚██╗ ██╔╝██╔════╝██║██╔════╝██╔══██╗██║     
--  ██████╔╝███████║ ╚████╔╝ ███████╗██║██║     ███████║██║     
--  ██╔═══╝ ██╔══██║  ╚██╔╝  ╚════██║██║██║     ██╔══██║██║     
--  ██║     ██║  ██║   ██║   ███████║██║╚██████╗██║  ██║███████╗
--  ╚═╝     ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝


L[#L+1] = {LABEL = "Attack Power In Form"}
L[#L].COLOR = "ATTACK_POW"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases attack power by (%d+) in Cat, Bear, Dire Bear, and Moonkin forms only%.?",
      OUTPUT = "+%d Attack Power while shapeshifted",
    },
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "%+(%d+) Attack Power in Cat, Bear, and Dire Bear forms only%.?",
      OUTPUT = "+%d Attack Power while shapeshifted",
    },
  }
end
L[#L].CAPTURES = {
  "[%+%-]%d+ Attack Power while shapeshifted.*",
}

L[#L+1] = {LABEL = "Attack Power"}
L[#L].COLOR = "ATTACK_POW"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases [Aa]ttack [Pp]ower by (%d+)%.?",
      OUTPUT = "+%d Attack Power",
    },
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "Increases [Aa]ttack [Pp]ower by (%d+)%.?",
      OUTPUT = "+%d Attack Power",
    },
    {
      INPUT = "%+(%d+) Attack Power%.?",
      OUTPUT = "+%d Attack Power",
    },
  }
end
L[#L].CAPTURES = {
  "[%+%-]%d+ Attack Power.*",
}

L[#L+1] = {LABEL = "Ranged Attack Power"}
L[#L].COLOR = "R_ATTACK_POW"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases ranged attack power by (%d+)%.?",
      OUTPUT = "+%d Ranged Attack Power",
    },
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "%+(%d+) ranged Attack Power%.?",
      OUTPUT = "+%d Ranged Attack Power",
    },
  }
end
L[#L].CAPTURES = {
  "[%+%-]%d+ Ranged Attack Power.*",
}

L[#L+1] = {LABEL = "Physical Hit"}
L[#L].COLOR = "PHYS_HIT"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? hit rating by (%d+)%.?",
      OUTPUT = "+%d Physical Hit Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Physical Hit Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "Improves your chance to hit by (%d+)%%%.?",
      OUTPUT = "+%d%%%% Physical Hit Chance",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+%% Physical Hit Chance.*",
  }
end

L[#L+1] = {LABEL = "Physical Crit"}
L[#L].COLOR = "PHYS_CRIT"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? critical strike rating by (%d+)%.?",
      OUTPUT = "+%d Physical Crit Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Physical Crit Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT = "Improves your chance to get a critical strike by (%d+)%%%.?",
      OUTPUT = "+%d%%%% Physical Crit Chance",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+%% Physical Crit Chance.*",
  }
end

if Data:IsBCC() then
  L[#L+1] = {LABEL = "Physical Haste"}
  L[#L].COLOR = "PHYS_HASTE"
  L[#L].MAP = {
    {
      INPUT = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? haste rating by (%d+)%.?",
      OUTPUT = "+%d Physical Haste Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Physical Haste Rating.*",
  }
  
  L[#L+1] = {LABEL = "Armor Penetration"}
  L[#L].COLOR = "PHYS_PEN"
  L[#L].MAP = {
    {
      INPUT = "Your attacks ignore (%d+) of your opponent's armor%.?",
      OUTPUT = "+%d Armor Pen",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Armor Pen.*",
  }
  
  L[#L+1] = {LABEL = "Expertise"}
  L[#L].COLOR = "EXPERTISE"
  L[#L].MAP = {
    {
      INPUT = "Increases? ?y?o?u?r? expertise rating by (%d+)%.?",
      OUTPUT = "+%d Expertise Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Expertise Rating.*",
  }
end

for i, element in pairs(Data:GetElements()) do
  L[#L+1] = {LABEL = element .. " Melee Damage"}
  L[#L].COLOR = Data:GetElementKey(i) .. "_DAMAGE"
  L[#L].MAP = {
    {
      INPUT = "Adds (%d+) " .. Data:GetElementPattern(i) .. " damage to your melee attacks%.?",
      OUTPUT = "+%d melee " .. element .. " damage",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ melee " .. element .. " damage.*",
  }
end







--  ███╗   ███╗ █████╗  ██████╗ ██╗ ██████╗ █████╗ ██╗     
--  ████╗ ████║██╔══██╗██╔════╝ ██║██╔════╝██╔══██╗██║     
--  ██╔████╔██║███████║██║  ███╗██║██║     ███████║██║     
--  ██║╚██╔╝██║██╔══██║██║   ██║██║██║     ██╔══██║██║     
--  ██║ ╚═╝ ██║██║  ██║╚██████╔╝██║╚██████╗██║  ██║███████╗
--  ╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝ ╚═════╝╚═╝  ╚═╝╚══════╝


L[#L+1] = {LABEL = "Spell Power"}
L[#L].COLOR = "MAGICAL"
L[#L].MAP = {
  {
    INPUT  = "Increases damage and healing done by magical spells and effects by up to (%d+)%.?",
    OUTPUT = "+%d Spell Power",
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ Spell Power.*",
}

for i, element in pairs(Data:GetElements()) do
  L[#L+1] = {LABEL = element .. " Spell Damage"}
  L[#L].COLOR = Data:GetElementKey(i) .. "_DAMAGE"
  L[#L].MAP = {
    {
      INPUT = "%+(%d+) " .. Data:GetElementPattern(i) .. " Damage",
      OUTPUT = "+%d " .. element .. " Spell Damage",
    },
    {
      INPUT  = "Increases ?t?h?e? damage done by " .. Data:GetElementPattern(i) .. " spells and effects by up to (%d+)%.?",
      OUTPUT = "+%d " .. element .. " Spell Damage",
    },
    {
      INPUT  = "Increases " .. Data:GetElementPattern(i) .. " spell damage by (%d+)%.?",
      OUTPUT = "+%d " .. element .. " Spell Damage",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ " .. element .. " Spell Damage.*",
  }
end

L[#L+1] = {LABEL = "Spell Damage"}
L[#L].COLOR = "MAGICAL"
L[#L].MAP = {
  {
    INPUT  = "Increases damage done to (%D+) by magical spells and effects by up to (%d+)",
    OUTPUT = function(targets, amount) return ("+%d Spell Damage against %s"):format(amount, targets) end,
  },
  {
    INPUT  = "Increases damage done by magical spells and effects by up to (%d+)",
    OUTPUT = "+%d Spell Damage",
  },
  {
    INPUT  = "Increases damage done from spells by up to (%d+)%.?",
    OUTPUT = "+%d Spell Damage",
  },
  {
    INPUT  = "Increases spell damage by up to (%d+)%.?",
    OUTPUT = "+%d Spell Damage",
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ Spell Damage.*",
  "[%+%-]%d+ Spell Damage and Healing.*",
}

L[#L+1] = {LABEL = "Spell Hit"}
L[#L].COLOR = "MAGIC_HIT"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell hit rating by (%d+)%.?",
      OUTPUT = "+%d Spell Hit Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Spell Hit Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT  = "Improves your chance to hit with spells by (%d+)%%%.?",
      OUTPUT = "+%d%%%% Spell Hit Chance",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+%% Spell Hit Chance.*",
  }
end

L[#L+1] = {LABEL = "Spell Crit"}
L[#L].COLOR = "MAGIC_CRIT"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell critical strike rating by (%d+)%.?",
      OUTPUT = "+%d Spell Crit Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Spell Crit Rating.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT  = "Improves your chance to get a critical strike with spells by (%d+)%%%.?",
      OUTPUT = "+%d%%%% Spell Crit Chance",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+%% Spell Crit Chance.*",
  }
end

if Data:IsBCC() then
  L[#L+1] = {LABEL = "Spell Haste"}
  L[#L].COLOR = "MAGIC_HASTE"
  L[#L].MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell haste rating by (%d+)%.?",
      OUTPUT = "+%d Spell Haste Rating",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Spell Haste Rating.*",
  }
end

L[#L+1] = {LABEL = "Spell Penetration"}
L[#L].COLOR = "MAGIC_PEN"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell penetration by (%d+)%.?",
      OUTPUT = "+%d Spell Pen",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Spell Pen.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT  = "Decreases the magical resistances of your spell targets by (%d+)%.?",
      OUTPUT = "+%d Spell Pen",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Spell Pen.*",
  }
end









--  ██╗  ██╗███████╗ █████╗ ██╗     ██╗███╗   ██╗ ██████╗ 
--  ██║  ██║██╔════╝██╔══██╗██║     ██║████╗  ██║██╔════╝ 
--  ███████║█████╗  ███████║██║     ██║██╔██╗ ██║██║  ███╗
--  ██╔══██║██╔══╝  ██╔══██║██║     ██║██║╚██╗██║██║   ██║
--  ██║  ██║███████╗██║  ██║███████╗██║██║ ╚████║╚██████╔╝
--  ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝ ╚═════╝ 


L[#L+1] = {LABEL = "Healing"}
L[#L].COLOR = "HEALING"
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT = "Increases healing done by up to (%d+) and damage done by up to (%d+) for all magical spells and effects%.?",
      OUTPUT = "+%d Healing and +%d Spell Damage",
    },
    {
      INPUT = "Increases healing done by spells by up to (%d+) and damage done by spells by up to (%d+)%.?",
      OUTPUT = "+%d Healing and +%d Spell Damage",
    },
    {
      INPUT = "Increases your spell damage by up to (%d+) and your healing by up to (%d+)%.?",
      OUTPUT = function(damage, healing) return ("+%d Healing and +%d Spell Damage"):format(healing, damage) end,
    },
    {
      INPUT  = "Increases healing done by magical spells by up to (%d+)%.?",
      OUTPUT = "+%d Healing",
    },
  }
  L[#L].CAPTURES = {
    "[%+%-]%d+ Healing and [%+%-]%d+ Spell Damage.*",
    "[%+%-]%d+ Healing [%+%-]%d+ Spell Damage.*",
    "[%+%-]%d+ Healing.*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT  = "Increases healing done by spells and effects by up to (%d+)%.?",
      OUTPUT = "+%d Healing",
    },
  }
  L[#L].CAPTURES = {
    "%+%d+ Healing.*",
  }
end

L[#L+1] = {LABEL = "Health Restore"}
L[#L].COLOR = "HEALTH"
L[#L].MAP = {
  {
    INPUT  = "Restores (%d+) health per (%d+) sec%.?",
    OUTPUT = function(amount, period) return ("+%d Hp%d%s"):format(amount, period, tonumber(period) > 1 and ("  (+%s HpM)"):format(Data:Round(amount/period*60, 0)) or "") end,
  }
}
L[#L].CAPTURES = {
  "[%+%-]%d+ Hp%d.*",
}

L[#L+1] = {LABEL = "Mana Restore"}
L[#L].COLOR = "MANA"
L[#L].MAP = {
  {
    INPUT  = "Restores (%d+) mana per (%d+) seco?n?d?s?%.?",
    OUTPUT = function(amount, period) return ("+%d Mp%d%s"):format(amount, period, tonumber(period) > 1 and ("  (+%s MpM)"):format(Data:Round(amount/period*60, 0)) or "") end,
  }
}
L[#L].CAPTURES = {
  "[%+%-]%d+ Mp%d.*",
}

L[#L+1] = {LABEL = "Mana Regen"}
L[#L].COLOR = "MANA"
L[#L].MAP = {
  {
    INPUT  = "Allows? (%d+)%% of your Mana regeneration to continue while casting",
    OUTPUT = "+%d%%%% of Mana Regen continues while casting",
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ of Mana Regen continues while casting.*",
}










--  ███╗   ███╗ ██████╗ ██╗   ██╗███████╗███████╗██████╗ ███████╗███████╗██████╗ 
--  ████╗ ████║██╔═══██╗██║   ██║██╔════╝██╔════╝██╔══██╗██╔════╝██╔════╝██╔══██╗
--  ██╔████╔██║██║   ██║██║   ██║█████╗  ███████╗██████╔╝█████╗  █████╗  ██║  ██║
--  ██║╚██╔╝██║██║   ██║╚██╗ ██╔╝██╔══╝  ╚════██║██╔═══╝ ██╔══╝  ██╔══╝  ██║  ██║
--  ██║ ╚═╝ ██║╚██████╔╝ ╚████╔╝ ███████╗███████║██║     ███████╗███████╗██████╔╝
--  ╚═╝     ╚═╝ ╚═════╝   ╚═══╝  ╚══════╝╚══════╝╚═╝     ╚══════╝╚══════╝╚═════╝ 



L[#L+1] = {LABEL = "Shapeshift Run Speed"}
L[#L].MAP = {
  {
    INPUT  = "Increases your movement speed by (%d+)%% while in Bear Form, Cat Form, or Travel Form",
    OUTPUT = "+%d%%%% Run Speed in Bear Form, Cat Form, or Travel Form",
  },
  {
    INPUT  = "Increases the speed of your Ghost Wolf ability by (%d+)%%",
    OUTPUT = "+%d%%%% Run Speed in Ghost Wolf",
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? Run Speed in Bear Form, Cat Form, or Travel Form.*",
  "%+%d+%%? Run Speed in Ghost Wolf.*",
}

L[#L+1] = {LABEL = "Run Speed"}
L[#L].MAP = {
  {
    INPUT  = "Minor Speed Increase",
    OUTPUT = "+8%%%% Run Speed",
  },
  {
    INPUT  = "Minor Speed and %+(%d+) (.*)",
    OUTPUT = "+8%%%% Run Speed and +%d %s",
  },
  {
    INPUT  = "Minor increase to running and swimming speed%.?",
    OUTPUT = "+8%%%% Run Speed and +8%%%% Swim Speed",
  },
  {
    INPUT  = "Increases run speed by (%d+)%%%.?",
    OUTPUT = "+%d%%%% Run Speed",
  },
  {
    INPUT  = "Run speed increased slightly%.?",
    OUTPUT = "+8%%%% Run Speed",
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? Run Speed.*",
}

L[#L+1] = {LABEL = "Swim Speed"}
L[#L].MAP = {
  {
    INPUT  = "Increases swim speed by ([%d%.]*%d+%%?)%.?",
    OUTPUT = function(amount) return ("+%s Swim Speed"):format(FixPercent(amount)) end,
  }
}
L[#L].CAPTURES = {
  "%+%d+%%? Swim Speed.*",
}

L[#L+1] = {LABEL = "Mount Speed"}
L[#L].MAP = {
  {
    INPUT  = "Increases mount speed by ([%d%.]*%d+%%?)%.?",
    OUTPUT = function(amount) return ("+%s Mount Speed"):format(FixPercent(amount)) end,
  },
  {
    INPUT  = "Increases speed in Flight Form and Swift Flight Form by ([%d%.]*%d+%%?)%.?",
    OUTPUT = function(amount) return ("+%s Speed in Flight Forms"):format(FixPercent(amount)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? Mount Speed.*",
  "%+%d+%%? Speed in Flight Forms.*",
}









--  ███████╗ ██████╗  ██████╗ ██████╗        ██╗       ██████╗ ██████╗ ██╗███╗   ██╗██╗  ██╗
--  ██╔════╝██╔═══██╗██╔═══██╗██╔══██╗       ██║       ██╔══██╗██╔══██╗██║████╗  ██║██║ ██╔╝
--  █████╗  ██║   ██║██║   ██║██║  ██║    ████████╗    ██║  ██║██████╔╝██║██╔██╗ ██║█████╔╝ 
--  ██╔══╝  ██║   ██║██║   ██║██║  ██║    ██╔═██╔═╝    ██║  ██║██╔══██╗██║██║╚██╗██║██╔═██╗ 
--  ██║     ╚██████╔╝╚██████╔╝██████╔╝    ██████║      ██████╔╝██║  ██║██║██║ ╚████║██║  ██╗
--  ╚═╝      ╚═════╝  ╚═════╝ ╚═════╝     ╚═════╝      ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝


L[#L+1] = {LABEL = "Food And Drink"}
L[#L].MAP = {
  {
    INPUT  = "Restores (%d+) health and (%d+) mana over (%d+) sec%.%s*Must remain seated while eating",
    OUTPUT = function(healthAmount, manaAmount, duration) return ("+%d health (+%s HpS) and +%d mana (+%s MpS) over %ds while sitting"):format(healthAmount, Data:Round(healthAmount/duration, 0), manaAmount, Data:Round(manaAmount/duration, 0), duration) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ health and %+%d+ mana over %d+s %(%+[%d%.]+ HpS% and %+[%d%.]+ MpS%) while sitting",
}

L[#L+1] = {LABEL = "Buff Food"}
L[#L].MAP = {
  {
    INPUT  = "Restores (%d+) health over (%d+) sec%.%s*Must remain seated while eating.%s+If you spend at least 10 seconds eating you will become well fed and gain (.+) for (%d+) min",
    OUTPUT = function(amount, duration, buff, buffDuration) return ("+%d health (+%s HpS) over %ds while sitting. After 10s, gain %s for %ds"):format(amount, Data:Round(amount/duration, 0), duration, buff, buffDuration) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ health %(%+[%d%.]+ HpS%) over %d+s while sitting%. After %d+s, gain .+ for %d+s",
}

L[#L+1] = {LABEL = "Food"}
L[#L].COLOR = "HEALTH"
L[#L].MAP = {
  {
    INPUT  = "Restores (%d+) health over (%d+) sec%.%s*Must remain seated while eating",
    OUTPUT = function(amount, duration) return ("+%d health (+%s HpS) over %ds while sitting"):format(amount, Data:Round(amount/duration, 0), duration) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ health %(%+[%d%.]+ HpS%) over %d+s while sitting",
}

L[#L+1] = {LABEL = "Buff Drink"}
L[#L].MAP = {
  {
    INPUT  = "Restores (%d+) mana over (%d+) sec%.%s*Must remain seated while drinking.%s+ Also (.+) for (%d+) min",
    OUTPUT = function(amount, duration, buff, buffDuration) return ("+%d mana (+%s HpS) over %ds while sitting. Also %s for %ds"):format(amount, Data:Round(amount/duration, 0), duration, buff, buffDuration) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ health %(%+[%d%.]+ HpS%) over %d+s while sitting%. Also .+ for %d+s",
}

L[#L+1] = {LABEL = "Drink"}
L[#L].COLOR = "MANA"
L[#L].MAP = {
  {
    INPUT  = "Restores (%d+) mana over (%d+) sec%.%s*Must remain seated while drinking",
    OUTPUT = function(amount, duration) return ("+%d mana (+%s MpS) over %ds while sitting"):format(amount, Data:Round(amount/duration, 0), duration) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ mana %(%+[%d%.]+ MpS%) over %d+s while sitting",
}

L[#L+1] = {LABEL = "Bandage"}
L[#L].COLOR = "HEALTH"
L[#L].MAP = {
  {
    INPUT  = "Heals (%d+) damage over (%d+) sec%.",
    OUTPUT = function(amount, duration) return ("+%d health (+%s HpS) over %ds"):format(amount, Data:Round(amount/duration, 0), duration) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ health %(%+[%d%.]+ HpS%) over %d+s",
}



L[#L+1] = {LABEL = "Instant Mana and Health"}
L[#L].MAP = {
  {
    INPUT  = "Restores? (%d+) to (%d+) mana and health",
    OUTPUT = function(amount1, amount2) return ("+%s (%d-%d) mana and health"):format(Data:Round((amount1+amount2)/2, 0), amount1, amount2) end,
  },
  {
    INPUT  = "Restores? (%d+) mana and health",
    OUTPUT = "+%d mana and health",
  },
}
L[#L].CAPTURES = {
  "%+%d+ %(%d+%-%d+%) mana and health.*",
  "%+%d+%%? mana and health.*",
}

L[#L+1] = {LABEL = "Instant Health"}
L[#L].COLOR = "HEALTH"
L[#L].MAP = {
  {
    INPUT  = "Restores? (%d+) to (%d+) health",
    OUTPUT = function(amount1, amount2) return ("+%s (%d-%d) health"):format(Data:Round((amount1+amount2)/2, 0), amount1, amount2) end,
  },
  {
    INPUT  = "Restores? (%d+) health",
    OUTPUT = "+%d health",
  },
}
L[#L].CAPTURES = {
  "%+%d+ %(%d+%-%d+%) health.*",
  "%+%d+%%? health.*",
}

L[#L+1] = {LABEL = "Instant Mana"}
L[#L].COLOR = "MANA"
L[#L].MAP = {
  {
    INPUT  = "Restores? (%d+) to (%d+) mana",
    OUTPUT = function(amount1, amount2) return ("+%s (%d-%d) mana"):format(Data:Round((amount1+amount2)/2, 0), amount1, amount2) end,
  },
  {
    INPUT  = "Restores? (%d+) mana",
    OUTPUT = "+%d mana",
  },
}
L[#L].CAPTURES = {
  "%+%d+ %(%d+%-%d+%) mana.*",
  "%+%d+%%? mana.*",
}

L[#L+1] = {LABEL = "Instant Resource"}
L[#L].MAP = {
  {
    INPUT  = "Regain up to (%d+%%?) ",
    OUTPUT = function(amount) return ("+%s instant "):format(FixPercent(amount)) end,
  },
  {
    INPUT  = "Gain up to (%d+%%?) ",
    OUTPUT = function(amount) return ("+%s instant "):format(FixPercent(amount)) end,
  },
  {
    INPUT  = "Instantly increases your (.+) by (%d+%%?)",
    OUTPUT = function(resource, amount) return ("+%s instant %s"):format(FixPercent(amount), resource) end,
  },
  {
    INPUT  = "Restores? (%d+) to (%d+) ",
    OUTPUT = "+%d to +%d instant ",
  },
  {
    INPUT  = "Restores? (%d+) ",
    OUTPUT = "+%d instant ",
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? instant .*",
  "%+%d+%%? to %+%d+%%? instant .*",
}







--  ███████╗██████╗ ███████╗ ██████╗██╗ █████╗ ██╗         ███████╗███████╗███████╗███████╗ ██████╗████████╗███████╗
--  ██╔════╝██╔══██╗██╔════╝██╔════╝██║██╔══██╗██║         ██╔════╝██╔════╝██╔════╝██╔════╝██╔════╝╚══██╔══╝██╔════╝
--  ███████╗██████╔╝█████╗  ██║     ██║███████║██║         █████╗  █████╗  █████╗  █████╗  ██║        ██║   ███████╗
--  ╚════██║██╔═══╝ ██╔══╝  ██║     ██║██╔══██║██║         ██╔══╝  ██╔══╝  ██╔══╝  ██╔══╝  ██║        ██║   ╚════██║
--  ███████║██║     ███████╗╚██████╗██║██║  ██║███████╗    ███████╗██║     ██║     ███████╗╚██████╗   ██║   ███████║
--  ╚══════╝╚═╝     ╚══════╝ ╚═════╝╚═╝╚═╝  ╚═╝╚══════╝    ╚══════╝╚═╝     ╚═╝     ╚══════╝ ╚═════╝   ╚═╝   ╚══════╝


L[#L+1] = {LABEL = "Skill"}
L[#L].COLOR = "SKILL"
L[#L].MAP = {
  {
    INPUT = "Increased ([%u][%a%-%s]+) %+(%d+)%.?",
    OUTPUT = function(skill, amount) return ("+%d %s skill"):format(amount, skill) end,
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ .+ skill.*",
}

L[#L+1] = {LABEL = "Hit With Ability"}
L[#L].MAP = {
  {
    INPUT = "Reduces the chance (%D-) will be resisted by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s Hit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT = "Improves your chance to hit with (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s Hit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ Hit Chance with .*",
}


L[#L+1] = {LABEL = "Crit With Ability"}
L[#L].MAP = {
  {
    INPUT  = "Increases the critical strike chance of (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s Crit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the critical hit chance of (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s Crit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the critical hit chance of (%D-) (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s Crit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases your chance of a critical hit with (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s Crit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Improves your chance to get a critical strike with (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s Crit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Your (%D-) has (%d+%%) increased critical strike chance%.?",
    OUTPUT = function(spell, amount) return ("+%s Crit Chance with %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+ Crit Chance with .*",
}






L[#L+1] = {LABEL = "Increase Pet Damage"}
L[#L].MAP = {
  {
    INPUT  = "(%d+%%) increased damage from your summoned pets' melee attacks and damage spells%.?",
    OUTPUT = function(amount) return ("+%s pet damage"):format(FixPercent(amount)) end,
  },
  {
    INPUT  = "Increases? your pet's damage by (%d+%%?)%.?",
    OUTPUT = function(amount) return ("+%s pet damage"):format(FixPercent(amount)) end,
  },
}
L[#L].CAPTURES = {
  "[%+%-]%S* pet damage.*",
}


L[#L+1] = {LABEL = "Pet Defences"}
L[#L].MAP = {
  {
    INPUT  = "Your pet gains (%d+) stamina and (%d+) spell resistance against all schools of magic%.?$",
    OUTPUT = function(amount1, amount2) return ("+%s pet Stamina and +%s pet Resist All"):format(amount1, amount2) end,
  },
  {
    INPUT  = "Increases your pet's stamina by (%d+%%?) and all spell resistances by (%d+%%?)%.?$",
    OUTPUT = function(amount1, amount2) return ("+%s pet Stamina and +%s pet Resist All"):format(amount1, amount2) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ pet Stamina and %+%d+ pet Resist All",
}




L[#L+1] = {LABEL = "Proc Spellpower"}
L[#L].MAP = {
  {
    INPUT  = "Chance on (%D-) to increase your damage and healing done by magical spells and effects by up to (%d+) for (%d+) sec%.?$",
    OUTPUT = function(trigger, amount1, amount2) return ("Chance on %s for +%d Spell Power for %ds"):format(trigger, amount1, amount2) end,
  },
  {
    INPUT  = "Chance on (%D-) to increase your damage and healing by up to (%d+) for (%d+) sec%.?$",
    OUTPUT = function(trigger, amount1, amount2) return ("Chance on %s for +%d Spell Power for %ds"):format(trigger, amount1, amount2) end,
  },
}
L[#L].CAPTURES = {
  "Chance on .+ for %+%d+ Spell Power for %d+s",
}






L[#L+1] = {LABEL = "Increase Maximum Resource"}
L[#L].MAP = {
  {
    INPUT  = "Increases your maximum (%D-) by (%d+%%?)%.?$",
    OUTPUT = function(resource, amount) return ("+%s maximum %s"):format(FixPercent(amount), resource) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+ maximum .*",
}






L[#L+1] = {LABEL = "Reduce Cost"}
L[#L].MAP = {
  {
    INPUT  = "Reduces ?t?h?e? (%D*)cost of (%D-) by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("-%s %scost for %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Decreases? ?t?h?e? (%D*)cost of (%D-) by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("-%s %scost for %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Your (%D-) each costs? (%d+%%?) less ([mre][aan][nge][aer]g?y?)%.?",
    OUTPUT = function(spell, amount, resource) return ("-%s %s cost for %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Your (%D-) costs? (%d+%%?) less ([mre][aan][nge][aer]g?y?)%.?",
    OUTPUT = function(spell, amount, resource) return ("-%s %s cost for %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "All of your (%D-) costs? (%d+%%?) less ([mre][aan][nge][aer]g?y?)%.?",
    OUTPUT = function(spell, amount, resource) return ("-%s %s cost for %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "(%D+) cost of (%D-) reduced by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("-%s %s cost for %s"):format(FixPercent(amount), resource:lower(), TrimSpell(spell)) end,
  },
  {
    INPUT  = "%-(%d+) (%D-) cost to ([%a%s]+)%.",
    OUTPUT = function(amount, resource, spell) return ("-%s %s cost for %s"):format(FixPercent(amount), resource:lower(), TrimSpell(spell)) end,
  },
  {
    INPUT  = "%-(%d+) (%D-) cost for ([%a%s]+)%.",
    OUTPUT = function(amount, resource, spell) return ("-%s %s cost for %s"):format(FixPercent(amount), resource:lower(), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%-%d+%%? cost for .*",
}

L[#L+1] = {LABEL = "Cooldown Reduction"}
L[#L].MAP = {
  {
    INPUT  = "Reduces ?t?h?e? cooldown o[fn] (%D-) by (%d+) seco?n?d?s?%.?",
    OUTPUT = function(spell, amount) return ("-%ss cooldown on %s"):format(amount, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Decreases ?t?h?e? cooldown o[fn] (%D-) by (%d+) seco?n?d?s?%.?",
    OUTPUT = function(spell, amount) return ("-%ss cooldown on %s"):format(amount, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Reduces ?t?h?e? cooldown o[fn] (%D-) by %-?(%d+) minu?t?e?s?%.?",
    OUTPUT = function(spell, amount) return ("-%sm cooldown on %s"):format(amount, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Reduces ?t?h?e? cooldown o[fn] (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("-%s cooldown on %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Decreases ?t?h?e? cooldown o[fn] (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("-%s cooldown on %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%-[%d%.]+%%? cooldown on .*",
}

L[#L+1] = {LABEL = "Increase Damage"}
L[#L].MAP = {
  {
    INPUT  = "Increases your (%D-) damage against (%D+) by (%d+%%?)%.?",
    OUTPUT = function(spell, targets, amount) return ("+%s damage for %s against %s"):format(FixPercent(amount), TrimSpell(spell), targets) end,
  },
  {
    INPUT  = "Increases your damage against (%D+) by (%d+%%?)%.?",
    OUTPUT = function(targets, amount) return ("+%s damage against %s"):format(FixPercent(amount), targets) end,
  },
  {
    INPUT  = "Increases the damage dealt by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s damage for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases damage caused by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s damage for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the damage from (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s damage for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the damage of (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s damage for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the damage done by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s damage for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Your (%D-) deals? (%d+%%?) more damage%.?",
    OUTPUT = function(spell, amount) return ("+%s damage for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "(%d+%%?) increased damage [to][on] (%D+)",
    OUTPUT = function(amount, spell) return ("+%s damage for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? damage for .+",
  "%+%d+%%? damage against .+",
}

L[#L+1] = {LABEL = "Increase Healing"}
L[#L].MAP = {
  {
    INPUT  = "Your (%D-) heals an additional (%d+) health%.?",
    OUTPUT = function(spell, amount) return ("+%s healing for %s"):format(amount, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the healing from (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s healing for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the amount healed by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s healing for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases healing done by (%D-) by up to (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s healing for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? healing for .+",
}




L[#L+1] = {LABEL = "Modify Threat"}
L[#L].MAP = {
  {
    INPUT  = "Increases the threat generated by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s threat from %s"):format(FixPercent(amount), spell) end,
  },
  {
    INPUT  = "Decreases the threat generated by your spells by (%d+%%?)%.?",
    OUTPUT = function(amount) return ("-%s threat from spells"):format(FixPercent(amount)) end,
  },
  {
    INPUT  = "Reduces the threat generated by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("-%s threat from %s"):format(FixPercent(amount), spell) end,
  },
  {
    INPUT  = "Reduces the threat you generate by (%d+%%)%.?",
    OUTPUT = function(amount) return ("-%s threat generated"):format(FixPercent(amount)) end,
  },
}
L[#L].CAPTURES = {
  "[%+%-]%d+%%? threat from .*",
  "[%+%-]%d+%%? threat generated.*",
}


L[#L+1] = {LABEL = "Pushback Resist"}
L[#L].MAP = {
  {
    INPUT  = "Gives you a (%d-%%) chance to avoid interruption caused by damage while casting ([%a%s]+)%.?",
    OUTPUT = function(amount, spell) return ("+%s Spell Pushback Resist for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%% Spell Pushback Resist for .*",
}

L[#L+1] = {LABEL = "Increase Duration"}
L[#L].MAP = {
  {
    INPUT  = "Increases the duration of (%D-) by (%d+%%)%.?",
    OUTPUT = function(spell, amount) return ("+%s duration for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "I[mn][pc]r[oe][va]s?es the duration of (%D-) by (%d+) sec?o?n?d?s?%.?$",
    OUTPUT = function(spell, amount) return ("+%ss duration for %s"):format(amount, TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+[%s%a%%]* duration for .+",
}

L[#L+1] = {LABEL = "Reduce Cast Time"}
L[#L].MAP = {
  {
    INPUT  = "%-([%d%.]+) seco?n?d?s? [to][on] ?t?h?e? casting time of (%D+)",
    OUTPUT = function(amount, spell) return ("-%ss cast time for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Reduces ?t?h?e? casti?n?g? time o[fn] (%D-) by ([%d%.]+%%?) seco?n?d?s?%.?",
    OUTPUT = function(spell, amount) return ("-%ss cast time for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%-[%d%.]+%%? cast time for .*",
}

L[#L+1] = {LABEL = "Increase Attack Speed"}
L[#L].MAP = {
  {
    INPUT  = "Increases ranged attack speed by (%d+%%)%.?",
    OUTPUT = function(amount) return ("+%s Ranged Attack Speed"):format(FixPercent(amount)) end,
  },
  {
    INPUT  = "Increases your attack speed by (%d+%%)",
    OUTPUT = function(amount) return ("+%s Attack Speed"):format(FixPercent(amount)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%% Ranged Attack Speed.*",
  "%+%d+%% Attack Speed.*",
}

L[#L+1] = {LABEL = "Increase Range"}
L[#L].MAP = {
  {
    INPUT  = "Increases? the range of (%D-) by (%d+) yds%.?",
    OUTPUT = function(spell, amount) return ("+%sy range for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+y range for .*",
}

L[#L+1] = {LABEL = "Increase Radius"}
L[#L].MAP = {
  {
    INPUT  = "Increases ?t?h?e? radius of (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s radius for %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? radius for .*",
}

L[#L+1] = {LABEL = "Resist Silence or Interrupt"}
if Data:IsBCC() then
  L[#L].MAP = {
    {
      INPUT  = "Reduces the duration of any Silence or Interrupt effects used against the wearer by (%d+%%)%. This effect does not stack with other similar effects%.",
      OUTPUT = function(amount) return ("-%s duration to incoming Silence and Interrupt effects. Does not stack with similar effects."):format(FixPercent(amount)) end,
    },
  }
  L[#L].CAPTURES = {
    "%-%d+%% duration to incoming Silence and Interrupt effects%. Does not stack with similar effects%..*",
  }
elseif Data:IsClassic() then
  L[#L].MAP = {
    {
      INPUT  = "Increases your resistance to [Ss]ilence ?e?f?f?e?c?t?s? by (%d+%%)%.?",
      OUTPUT = function(amount) return ("+%s Resistance to Silence effects"):format(FixPercent(amount)) end,
    },
  }
  L[#L].CAPTURES = {
    "%+%d+%% Resistance to Silence effects.*",
  }
end

L[#L+1] = {LABEL = "Increase Absorb"}
L[#L].MAP = {
  {
    INPUT  = "Increases the amount of %D- absorbed by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s damage absorbed by %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the %D- absorbed by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(spell, amount) return ("+%s damage absorbed by %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
  {
    INPUT  = "(%d+%%) increase to the ?t?o?t?a?l? damage absorbed by ([%a%s]+%%?)%.?",
    OUTPUT = function(amount, spell) return ("+%s damage absorbed by %s"):format(FixPercent(amount), TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? damage absorbed by .*",
}






L[#L+1] = {LABEL = "Increase Ability Effectiveness"}
L[#L].MAP = {
  {
    INPUT  = "You gain (%d+%%? additional) (%D-) from ([%a%s]+)%.?",
    OUTPUT = function(amount, resource, spell) return ("+%s %s from %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Your (%D-) generates an additional (%d+) ([mre][aan][nge][aer]g?y?)%.?",
    OUTPUT = function(spell, amount, resource) return ("+%s %s generated by %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Your (%D-) grants an additional (%d+) ([mre][aan][nge][aer]g?y?)%.?",
    OUTPUT = function(spell, amount, resource) return ("+%s %s granted by %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Your (%D-) grants an additional (%d+) (spell damage)%.?",
    OUTPUT = function(spell, amount, resource) return ("+%s %s granted by %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "(%D+ gained) from (%D-) increased by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("+%s %s from %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the (%D- bonus) [of][fr]om (%D-) by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("+%s %s from %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the (%D- gained) from (%D-) by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("+%s %s from %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the (%D- granted) by (%D-) by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("+%s %s from %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "Increases the (%D-) from your (%D-) by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("+%s %s from %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
  {
    INPUT  = "I[mn][pc]r[oe][va]s?es the (%D-) of (%D-) by (%d+%%?)%.?",
    OUTPUT = function(resource, spell, amount) return ("+%s %s for %s"):format(FixPercent(amount), resource, TrimSpell(spell)) end,
  },
}
L[#L].CAPTURES = {
  "%+%d+%%? .+ from .*",
  "%+%d+%%? .+ for .*",
  "%+%d+%%? .+ generated by .*",
  "%+%d+%%? .+ absorbed by .*",
}



for k, v in pairs(L) do
  locale[k] = v
end



local ADDON_NAME, Shared = ...

local locale = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "enUS", true)
local L = {}


-- Removes leading spaces. Also removes appending " spell" or "ability" text when it's meaningless
local function TrimSpell(spell)
  if (spell:match(" spell") or spell:match(" ability")) and not (spell:match(" spells") or spell:match(" abilities")) then
    spell = spell:gsub(" spell", ""):gsub(" ability", "")
  elseif (spell:match(" spells") or spell:match(" abilities")) and spell:match(" and ") then
    spell = spell:gsub(" spells", ""):gsub(" abilities", "")
  end
  return spell:gsub("%s*$", "")
end



L["Reword tooltips"]             = "Reword tooltips"
L["REWORD TOOLTIPS DESCRIPTION"] = "Shortens some long lines of text on item tooltips. Does not remove any information."

L["Reorder stats"]               = "Reorder stats"
L["REORDER STATS DESCRIPTION"]   = "Makes tooltips display stats in a consistent order. Always Stamina before Intellect, for example."

L["Recolor lines"]               = "Recolor lines"
L["RECOLOR LINES DESCRIPTION"]   = "Adds coloring to some lines in tooltips."

L["Show Speedbar"]               = "Show Speedbar"
L["SHOW SPEEDBAR DESCRIPTION"]   =  "Displays a bar which visualizes weapon speed. The bar will be more filled for slower weapons."

L["Speedbar width"]              = "Speedbar width"
L["SPEEDBAR SIZE DESCRIPTION"]   =  "The maximum length of the speedbar (for a slow weapon). Higher values make the bar more accurate, but also make the tooltip wider."

L["Speed accuracy"]              = "Speed accuracy"
L["SPEED ACCURACY DESCRIPTION"]  = "The number of decimal places to appear in a weapon's speed. Default tooltips show two, but only one is ever needed."


L["Reset"]           = "Reset"
L["Color"]           = "Color"
L["Colors"]          = "Colors"


L["Speed"] = "Speed"

L["Enchantment"] = "Enchantment"

L["Armor"] = "Armor"

L["Stamina"]   = "Stamina"
L["Strength"]  = "Strength"
L["Agility"]   = "Agility"
L["Intellect"] = "Intellect"
L["Spirit"]    = "Spirit"

L["Arcane Resist"] = "Arcane Resist"
L["Fire Resist"]   = "Fire Resist"
L["Nature Resist"] = "Nature Resist"
L["Frost Resist"]  = "Frost Resist"
L["Shadow Resist"] = "Shadow Resist"
L["Holy Resist"]   = "Holy Resist"

L["Arcane Damage"] = "Arcane Damage"
L["Fire Damage"]   = "Fire Damage"
L["Nature Damage"] = "Nature Damage"
L["Frost Damage"]  = "Frost Damage"
L["Shadow Damage"] = "Shadow Damage"
L["Holy Damage"]   = "Holy Damage"

L["Defense"]      = "Defense"
L["Resilience"]   = "Resilience"
L["Dodge"]        = "Dodge"
L["Parry"]        = "Parry"
L["Block Rating"] = "Block Rating"
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














L["Equip Pattern"]           = "^%s*Equip:%s*"
L["SocketBonus Pattern"]     = "^%s*Socket Bonus:%s*"
L["ConjunctiveWord Pattern"] = "%s+and%s+"


L["Speed Pattern"] = "(Speed) (%d)%.(%d*)"



L[#L+1] = {LABEL = "Armor",
  CAPTURES = {
    "%d+ Armor$",
  },
  COLOR = function() return Shared.GetColor"ARMOR" end
}
L[#L+1] = {LABEL = "Stamina",
  CAPTURES = {
    "[%+%-]%d+ Stamina$",
  },
  COLOR = function() return Shared.GetColor"STAMINA" end
}
L[#L+1] = {LABEL = "Strength",
  CAPTURES = {
    "[%+%-]%d+ Strength$",
  },
  COLOR = function() return Shared.GetColor"STRENGTH" end
}
L[#L+1] = {LABEL = "Agility",
  CAPTURES = {
    "[%+%-]%d+ Agility$",
  },
  COLOR = function() return Shared.GetColor"AGILITY" end
}
L[#L+1] = {LABEL = "Intellect",
  CAPTURES = {
    "[%+%-]%d+ Intellect$",
  },
  COLOR = function() return Shared.GetColor"INTELLECT" end
}
L[#L+1] = {LABEL = "Spirit",
  CAPTURES = {
    "[%+%-]%d+ Spirit$",
  },
  COLOR = function() return Shared.GetColor"SPIRIT" end
}

L[#L+1] = {LABEL = "All Resist",
  CAPTURES = {
    "[%+%-]%d+ All Resistances$",
  },
  COLOR = function() return Shared.GetColor"RESIST_ALL" end
}
for _, element in pairs(Shared.ELEMENTS) do
  L[#L+1] = {LABEL = element .. " Resist",
    CAPTURES = {
      "[%+%-]%d+ " .. element .. " Resist.*",
    },
    COLOR = function() return Shared.GetColor(element:upper() .. "_RESIST") end
  }
end







L[#L+1] = {LABEL = "Spell Power",
  MAP = {
    {
      INPUT  = "Increases damage and healing done by magical spells and effects by up to (%d+)%.?",
      OUTPUT = "+%d Spell Power",
    },
   },
  CAPTURES = {
    "[%+%-]%d+ Spell Power.*",
  },
  COLOR = function() return Shared.GetColor"MAGICAL" end
}

L[#L+1] = {LABEL = "Spell Damage",
  MAP = {
    {
      INPUT  = "Increases damage done ?t?o? ?(.-) by magical spells and effects by up to (%d+)",
      OUTPUT = function(targets, amount) return ("+%d Spell Damage%s"):format(amount, #targets > 0 and (" against %s"):format(targets) or "") end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Damage.*",
    "[%+%-]%d+ Spell Damage and Healing.*",
  },
  COLOR = function() return Shared.GetColor"MAGICAL" end
}

L[#L+1] = {LABEL = "School Spell Power",
  MAP = {
    {
      INPUT  = "Increases ?t?h?e? damage done by (.+) spells and effects by up to (%d+)%.?",
      OUTPUT = function(school, amount) return ("+%d %s Spell Damage"):format(amount, school) end,
    },
    {
      INPUT  = "Increases ([^%D]+) spell damage by (%d+%%?)%.?",
      OUTPUT = function(school, amount) return ("+%d %s Spell Damage"):format(amount:gsub("%%", "%%%%"), school) end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Damage.*",
    "[%+%-]%d+ Spell Damage and Healing.*",
  },
  COLOR = function() return Shared.GetColor"MAGICAL" end
}
for _, element in pairs(Shared.ELEMENTS) do
  L[#L+1] = {LABEL = element .. " Spell Damage",
    MAP = {
      {
        INPUT = "([%+%-])(%d+) " .. element .. " Damage",
        OUTPUT = "%s%d " .. element .. " Spell Damage",
      },
    },
    CAPTURES = {
      "[%+%-]%d+ " .. element .. " Spell Damage.*",
    },
    COLOR = function() return Shared.GetColor(element:upper() .. "_DAMAGE") end
  }
end

L[#L+1] = {LABEL = "Healing",
  MAP = {
    {
      INPUT = "Increases healing done by ?u?p? ?t?o? ?(%d+) and damage done by ?u?p? ?t?o? ?(%d+) for all magical spells and effects%.?",
      OUTPUT = "+%d Healing and +%d Spell Damage",
    },
    {
      INPUT = "Increases healing done ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+) and damage done ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+)%.?",
      OUTPUT = "+%d Healing and +%d Spell Damage",
    },
    {
      INPUT = "Increases spell damage ?d?o?n?e? ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+) and healing ?d?o?n?e? ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+)%.?",
      OUTPUT = function(damage, healing) return ("+%d Healing and +%d Spell Damage"):format(healing, damage) end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Healing and [%+%-]%d+ Spell Damage.*",
    "[%+%-]%d+ Healing [%+%-]%d+ Spell Damage.*",
  },
  COLOR = function() return Shared.GetColor"HEALING" end
}






L[#L+1] = {LABEL = "Defense",
  MAP = {
    {
      INPUT = "Increases defense rating by (%d+)%.?",
      OUTPUT = "+%d Defense Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Defense Rating.*",
  },
  COLOR = function() return Shared.GetColor"ARMOR" end
}

L[#L+1] = {LABEL = "Resilience",
  MAP = {
    {
      INPUT = "Improves your resilience rating by (%d+)%.?",
      OUTPUT = "+%d Resilience",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Resilience.*",
  },
  COLOR = function() return Shared.GetColor"RESILIENCE" end,
}

L[#L+1] = {LABEL = "Dodge",
  MAP = {
    {
      INPUT = "Increases your dodge rating by (%d+)%.?",
      OUTPUT = "+%d Dodge Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Dodge Rating.*",
  },
  COLOR = function() return Shared.GetColor"DODGE" end
}
L[#L+1] = {LABEL = "Parry",
  MAP = {
    {
      INPUT = "Increases your parry rating by (%d+)%.?",
      OUTPUT = "+%d Parry Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Parry Rating.*",
  },
  COLOR = function() return Shared.GetColor"PARRY" end
}
L[#L+1] = {LABEL = "Block Rating",
  MAP = {
    {
      INPUT = "Increases your ?s?h?i?e?l?d? block rating by (%d+)%.?",
      OUTPUT = "+%d Block Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Block Rating.*",
  },
  COLOR = function() return Shared.GetColor"BLOCK_RATING" end
}
L[#L+1] = {LABEL = "Block Value",
  MAP = {
    {
      INPUT = "Increases the block value of your shield by (%d+)%.?",
      OUTPUT = "+%d Block Value",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Block Value.*",
  },
  COLOR = function() return Shared.GetColor"BLOCK_VALUE" end
}
for _, element in pairs(Shared.ELEMENTS) do
  L[#L+1] = {LABEL = element .. " Reflect Damage",
    MAP = {
      {
        INPUT = "When struck in combat inflicts (%d+) " .. element .. " damage to the attacker%.?",
        OUTPUT = "+%d " .. element .. " damage reflected to melee attackers",
      },
    },
    CAPTURES = {
      "[%+%-]%d+ " .. element .. " damage reflected to melee attackers.*",
    },
    COLOR = function() return Shared.GetColor(element:upper() .. "_DAMAGE") end
  }
end
L[#L+1] = {LABEL = "Resist All",
  MAP = {
    {
      INPUT = "Increases resistances to all schools of magic by (%d+)",
      OUTPUT = "+%d All Resistances",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ All Resistances.*",
  },
  COLOR = function() return Shared.GetColor"RESIST_ALL" end
}







L[#L+1] = {LABEL = "Attack Power In Form",
  MAP = {
    {
      INPUT = "Increases attack power by (%d+) in Cat, Bear, Dire Bear, and Moonkin forms only%.?",
      OUTPUT = "+%d Attack Power while shapeshifted",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Attack Power while shapeshifted.*",
  },
  COLOR = function() return Shared.GetColor"ATTACK_POW" end
}
L[#L+1] = {LABEL = "Attack Power",
  MAP = {
    {
      INPUT = "Increases attack power by (%d+)%.?",
      OUTPUT = "+%d Attack Power",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Attack Power.*",
  },
  COLOR = function() return Shared.GetColor"ATTACK_POW" end
}
L[#L+1] = {LABEL = "Ranged Attack Power",
  MAP = {
    {
      INPUT = "Increases ranged attack power by (%d+)%.?",
      OUTPUT = "+%d Ranged Attack Power",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Ranged Attack Power.*",
  },
  COLOR = function() return Shared.GetColor"R_ATTACK_POW" end
}
L[#L+1] = {LABEL = "Physical Hit",
  MAP = {
    {
      INPUT = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? hit rating by (%d+)%.?",
      OUTPUT = "+%d Physical Hit Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Physical Hit Rating.*",
  },
  COLOR = function() return Shared.GetColor"PHYS_HIT" end
}
L[#L+1] = {LABEL = "Physical Hit With Spell",
  MAP = {
    {
      INPUT = "Improves ?y?o?u?r? chance to hit with (.*) by (%d+%%)%.?",
      OUTPUT = function(spell, amount) return ("+%s Physical Hit Chance with %s"):format(amount:gsub("%%", "%%%%"), spell) end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Physical Hit Chance with .*",
  },
  COLOR = function() return Shared.GetColor"PHYS_HIT" end
}
L[#L+1] = {LABEL = "Physical Crit",
  MAP = {
    {
      INPUT = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? critical strike rating by (%d+)%.?",
      OUTPUT = "+%d Physical Crit Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Physical Crit Rating.*",
  },
  COLOR = function() return Shared.GetColor"PHYS_CRIT" end
}
L[#L+1] = {LABEL = "Physical Haste",
  MAP = {
    {
      INPUT = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? haste rating by (%d+)%.?",
      OUTPUT = "+%d Physical Haste Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Physical Haste Rating.*",
  },
  COLOR = function() return Shared.GetColor"PHYS_HASTE" end
}
L[#L+1] = {LABEL = "Armor Penetration",
  MAP = {
    {
      INPUT = "Your attacks ignore (%d+) of your opponent's armor%.?",
      OUTPUT = "+%d Armor Pen",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Armor Pen.*",
  },
  COLOR = function() return Shared.GetColor"PHYS_PEN" end
}
L[#L+1] = {LABEL = "Expertise",
  MAP = {
    {
      INPUT = "Increases your expertise rating by (%d+)%.?",
      OUTPUT = "+%d Expertise Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Expertise Rating.*",
  },
  COLOR = function() return Shared.GetColor"EXPERTISE" end
}

for _, element in pairs(Shared.ELEMENTS) do
  L[#L+1] = {LABEL = element .. " Melee Damage",
    MAP = {
      {
        INPUT = "Adds (%d+) " .. element .. " damage to your melee attacks%.?",
        OUTPUT = "+%d melee " .. element .. " damage",
      },
    },
    CAPTURES = {
      "[%+%-]%d+ melee " .. element .. " damage.*",
    },
    COLOR = function() return Shared.GetColor(element:upper() .. "_DAMAGE") end
  }
end










L[#L+1] = {LABEL = "Spell Hit",
  MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell hit rating by (%d+)%.?",
      OUTPUT = "+%d Spell Hit Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Hit Rating.*",
  },
  COLOR = function() return Shared.GetColor"MAGIC_HIT" end
}

L[#L+1] = {LABEL = "Spell Hit With Spell",
  MAP = {
    {
      INPUT  = "Reduces the chance your (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? will be resisted by ?(%d+%%)%.?",
      OUTPUT = function(spell, amount) return ("+%s Spell Hit Rating with %s"):format(amount:gsub("%%", "%%%%"), spell) end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Hit Rating with .*",
  },
  COLOR = function() return Shared.GetColor"MAGIC_HIT" end
}

L[#L+1] = {LABEL = "Spell Crit",
  MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell critical strike rating by (%d+)%.?",
      OUTPUT = "+%d Spell Crit Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Crit Rating.*",
  },
  COLOR = function() return Shared.GetColor"MAGIC_CRIT" end
}

L[#L+1] = {LABEL = "Spell Crit With Spell",
  MAP = {
    {
      INPUT  = "Increases the critical [hs][it][tr]i?k?e? chance of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?b?y? ?(%d+%%)%.?",
      OUTPUT = function(spell, amount) return ("+%s Spell Crit Rating with %s"):format(amount:gsub("%%", "%%%%"), spell) end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Crit Rating with .*",
  },
  COLOR = function() return Shared.GetColor"MAGIC_CRIT" end
}

L[#L+1] = {LABEL = "Spell Haste",
  MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell haste rating by (%d+)%.?",
      OUTPUT = "+%d Spell Haste Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Haste Rating.*",
  },
  COLOR = function() return Shared.GetColor"MAGIC_HASTE" end
}

L[#L+1] = {LABEL = "Spell Penetration",
  MAP = {
    {
      INPUT  = "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell penetration by (%d+)%.?",
      OUTPUT = "+%d Spell Pen",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Spell Pen.*",
  },
  COLOR = function() return Shared.GetColor"MAGIC_PEN" end
}




L[#L+1] = {LABEL = "Health Restore",
  MAP = {
    {
      INPUT  = "Restores (%d+) health per (%d+) sec%.?",
      OUTPUT = function(amount, period) return ("+%d Hp%d%s"):format(amount, period, tonumber(period) > 1 and ("  (+%s HpS)"):format(Shared.Round(tonumber(amount)/tonumber(period), 1)) or "") end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Hp%d.*",
  },
  COLOR = function() return Shared.GetColor"HEALTH" end
}
L[#L+1] = {LABEL = "Mana Regen",
  MAP = {
    {
      INPUT  = "Allows? (%d+)%% of your Mana regeneration to continue while casting",
      OUTPUT = "+%d%%%% of Mana Regen continues while casting",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ of Mana Regen continues while casting.*",
  },
  COLOR = function() return Shared.GetColor"MANA" end
}

L[#L+1] = {LABEL = "Mana Restore",
  MAP = {
    {
      INPUT  = "Restores (%d+) mana per (%d+) sec%.?",
      OUTPUT = function(amount, period) return ("+%d Mp%d%s"):format(amount, period, tonumber(period) > 1 and ("  (+%s MpS)"):format(Shared.Round(tonumber(amount)/tonumber(period), 1)) or "") end,
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Mp%d.*",
  },
  COLOR = function() return Shared.GetColor"MANA" end
}





L[#L+1] = {LABEL = "Cost Reduction",
  MAP = {
    {
      INPUT  = "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? (.+) cost of ?a?l?l? ?y?o?u?r? (.- ?[sa]?[pb]?[ei]?l?[li]?[ts]?[yi]?e?s?) ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(resource, spell, amount) return ("-%s %s cost for %s%s"):format(amount:gsub("%%", "%%%%"), resource:lower(), spell:sub(1, 1):upper(), TrimSpell(spell):sub(2, #TrimSpell(spell))) end,
    },
    {
      INPUT  = "(%s*)([^:]-) cost of ?y?o?u?r? (.- ?[sa]?[pb]?[ei]?l?[li]?[ts]?[yi]?e?s?) ?reduced by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(prefixSpace, resource, spell, amount) return ("%s-%s %s cost for %s%s"):format(prefixSpace, amount:gsub("%%", "%%%%"), resource:lower(), TrimSpell(spell)) end,
    },
    {
      INPUT  = "Your (.- ?[sa]?[pb]?[ei]?l?[li]?[ts]?[yi]?e?s?) ?e?a?c?h? costs? (%d+%%?) less (.-)([%s%.])",
      OUTPUT = function(spell, amount, resource, tail) return ("-%s %s cost for %s%s"):format(amount:gsub("%%", "%%%%"), resource:lower(), TrimSpell(spell), tail == " " and tail or "") end,
    },
  },
  CAPTURES = {
    "[%+%-].* cost for .*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Cooldown Reduction",
  MAP = {
    {
      INPUT  = "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? cooldown o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?),? o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?),? ?a?n?d? o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(spell1, amount1, spell2, amount2, spell3, amount3) return ("-%s %s cooldown, -%s %s cooldown, -%s %s cooldown"):format(amount1:gsub("%%", "%%%%"), spell1, amount2:gsub("%%", "%%%%"), spell2, amount3:gsub("%%", "%%%%"), spell3) end,
    },
    {
      INPUT  = "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? cooldown o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?),? ?a?n?d? o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(spell1, amount1, spell2, amount2) return ("-%s %s cooldown, -%s %s cooldown"):format(amount1:gsub("%%", "%%%%"), spell1, amount2:gsub("%%", "%%%%"), spell2) end,
    },
    {
      INPUT  = "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? cooldown o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(spell, amount) return ("-%s %s cooldown"):format(amount:gsub("%%", "%%%%"), spell) end,
    },
  },
  CAPTURES = {
    "[%+%-].* cooldown, [%+%-].* cooldown, [%+%-].* cooldown.*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Increase Damage",
  MAP = {
    {
      INPUT  = "Increases ?t?h?e? damage ?[dc]?[oae]?[nua]?[esl]?[et]?d? ?[bof][yfr]o?m? ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%?)",
      OUTPUT = function(spell, amount) return ("+%s %s damage"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
    {
      INPUT  = "Your (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? deals? ([%d%.]*%d+%%?) more damage",
      OUTPUT = function(spell, amount) return ("+%s %s damage"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* .* healing.*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Increase Healing",
  MAP = {
    {
      INPUT  = "Increases ?t?h?e? [ha][em][ao][lu][in][nt]g? [dch]?[oae]?[nua]?[esl]?e?d? ?[bof][yfr]o?m? ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%?)",
      OUTPUT = function(spell, amount) return ("+%s %s healing"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* .* healing.*",
  },
  COLOR = nil
}




L[#L+1] = {LABEL = "Modify Threat",
  MAP = {
    {
      INPUT  = "Increases ?t?h?e? threat generated by (.*) by ([%d%.]*%d+%%?)",
      OUTPUT = function(spell, amount) return ("+%s threat from %s"):format(amount:gsub("%%", "%%%%"), spell) end,
    },
    {
      INPUT  = "[DR]e[cd][ru][ec]a?s?es ?t?h?e? threat generated by ?y?o?u?r? (.*) by ([%d%.]*%d+%%?)",
      OUTPUT = function(spell, amount) return ("-%s threat from %s"):format(amount:gsub("%%", "%%%%"), spell) end,
    },
    {
      INPUT  = "Reduces the threat you generate by ([%d%.]*%d+%%?)",
      OUTPUT = function(amount) return ("-%s threat"):format(amount:gsub("%%", "%%%%")) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* threat from .*",
    "[%+%-]%S* threat.*",
  },
  COLOR = nil
}


L[#L+1] = {LABEL = "Increase Interrupt Resist",
  MAP = {
    {
      INPUT  = "Gives you a (%d+)%% chance to avoid interruption caused by damage while c[ah][sa][tn]n?e?l?ing (.*)",
      OUTPUT = "+%s%%%% Spell Pushback Resist for %s",
    },
  },
  CAPTURES = {
    "[%+%-]%d+%% Spell Pushback Resist for .*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Increase Duration",
  MAP = {
    {
      INPUT  = "I[nm][cp]r[eo][av]s?es ?t?h?e? duration of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(spell, amount) return ("+%s to %s duration"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* to .* duration.*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Reduce Cast",
  MAP = {
    {
      INPUT  = "Reduces ?t?h?e? casting time of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(spell, amount) return ("-%s off %s cast time"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* off .* cast time.*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Increase Resource Gained",
  MAP = {
    {
      INPUT  = "Increases ?t?h?e? (.*) gained from ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)",
      OUTPUT = function(resource, spell, amount) return ("+%s %s gained from %s"):format(amount:gsub("%%", "%%%%"), resource, TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* .* gained from .*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Increase Range",
  MAP = {
    {
      INPUT  = "Increases? ?t?h?e? range of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?y?a?r?d?s?)",
      OUTPUT = function(spell, amount) return ("+%s range for %s"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* range for .*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Increase Radius",
  MAP = {
    {
      INPUT  = "Increases ?t?h?e? radius of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?y?a?r?d?s?)",
      OUTPUT = function(spell, amount) return ("+%s radius for %s"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* radius for .*",
  },
  COLOR = nil
}

L[#L+1] = {LABEL = "Increase Attack Power Granted",
  MAP = {
    {
      INPUT  = "Increases ?t?h?e? attack power granted by ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%?)",
      OUTPUT = function(spell, amount) return ("+%s attack power for %s"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end,
    },
  },
  CAPTURES = {
    "[%+%-]%S* attack power for .*",
  },
  COLOR = nil
}





for k, v in pairs(L) do
  locale[k] = v
end


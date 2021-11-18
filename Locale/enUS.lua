
local ADDON_NAME, Shared = ...

local locale = LibStub("AceLocale-3.0"):NewLocale("ZeraTooltip", "enUS", true)
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



L["Equip"]           = "^%s*Equip:%s*"
L["SocketBonus"]     = "^%s*Socket Bonus:%s*"
L["ConjunctiveWord"] = "%s+and%s+"




L.COLORS = {}

L.COLORS.DEFENSIVE   = {217, 255, 82}
L.COLORS.DEF_EQUIP   = {179, 174, 50}

L.COLORS.PHYSICAL    = {252, 198, 154}
L.COLORS.PHYS_HIT    = {255, 239, 115}
L.COLORS.PHYS_CRIT   = {255, 145, 115}

L.COLORS.MAGICAL     = {161, 178, 255}
L.COLORS.MAGIC_HIT   = {242, 161, 255}
L.COLORS.MAGIC_CRIT  = {255, 145, 169}
L.COLORS.MAGIC_HASTE = {122, 180, 255}
L.COLORS.MAGIC_PEN   = {230, 77, 255}

L.COLORS.HEALING     = {143, 255, 184}
L.COLORS.MANA        = {127, 255, 228}


L.COLORS.ELEMENTS = {}
L.COLORS.ELEMENTS["Arcane"] = {235, 204, 255}
L.COLORS.ELEMENTS["Fire"]   = {255, 135, 79}
L.COLORS.ELEMENTS["Nature"] = {0, 212, 0}
L.COLORS.ELEMENTS["Frost"]  = {115, 243, 255}
L.COLORS.ELEMENTS["Shadow"] = {190, 92, 255}
L.COLORS.ELEMENTS["Holy"]   = {255, 255, 127}








L[#L+1] = {LABEL = "Armor",
  CAPTURES = {
    "%d+ Armor$",
  },
  COLOR = L.COLORS.DEFENSIVE
}
L[#L+1] = {LABEL = "Stamina",
  CAPTURES = {
    "[%+%-]%d+ Stamina$",
  },
  COLOR = L.COLORS.DEFENSIVE
}
L[#L+1] = {LABEL = "Strength",
  CAPTURES = {
    "[%+%-]%d+ Strength$",
  },
  COLOR = L.COLORS.PHYSICAL
}
L[#L+1] = {LABEL = "Agility",
  CAPTURES = {
    "[%+%-]%d+ Agility$",
  },
  COLOR = L.COLORS.PHYS_CRIT
}
L[#L+1] = {LABEL = "Intellect",
  CAPTURES = {
    "[%+%-]%d+ Intellect$",
  },
  COLOR = L.COLORS.MAGICAL
}
L[#L+1] = {LABEL = "Spirit",
  CAPTURES = {
    "[%+%-]%d+ Spirit$",
  },
  COLOR = L.COLORS.MANA
}

L[#L+1] = {LABEL = "All Resist",
  CAPTURES = {
    "[%+%-]%d+ All Resistances$",
  },
  COLOR = L.COLORS.DEFENSIVE
}
for element, color in pairs(L.COLORS.ELEMENTS) do
  L[#L+1] = {LABEL = element .. " Resist",
    CAPTURES = {
      "[%+%-]%d+ " .. element .. " Resist.*",
    },
    COLOR = color
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
  COLOR = L.COLORS.MAGICAL
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
  COLOR = L.COLORS.MAGICAL
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
  COLOR = L.COLORS.MAGICAL
}
for element, color in pairs(L.COLORS.ELEMENTS) do
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
    COLOR = color
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
  COLOR = L.COLORS.HEALING
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
  COLOR = L.COLORS.DEFENSIVE
}

L[#L+1] = {LABEL = "Resilience",
  MAP = {
    {
      INPUT = "Improves your resilience rating by (%d+)%.?",
      OUTPUT = "+%d Resilience Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Resilience Rating.*",
  },
  COLOR = L.COLORS.DEFENSIVE,
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
  COLOR = L.COLORS.DEFENSIVE
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
  COLOR = L.COLORS.DEF_EQUIP
}
L[#L+1] = {LABEL = "BlockRating",
  MAP = {
    {
      INPUT = "Increases your ?s?h?i?e?l?d? block rating by (%d+)%.?",
      OUTPUT = "+%d Block Rating",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Block Rating.*",
  },
  COLOR = L.COLORS.DEF_EQUIP
}
L[#L+1] = {LABEL = "BlockValue",
  MAP = {
    {
      INPUT = "Increases the block value of your shield by (%d+)%.?",
      OUTPUT = "+%d Block Value",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ Block Value.*",
  },
  COLOR = L.COLORS.DEF_EQUIP
}
L[#L+1] = {LABEL = "ReflectDamage",
  MAP = {
    {
      INPUT = "When struck in combat inflicts (%d+) (.+) damage to the attacker%.?",
      OUTPUT = "Reflect %d %s damage to melee attackers",
    },
  },
  CAPTURES = {
    "Reflect [%+%-]%d+ .+ damage to melee attackers.*",
  },
  COLOR = L.COLORS.DEFENSIVE
}
L[#L+1] = {LABEL = "ResistAll",
  MAP = {
    {
      INPUT = "Increases resistances to all schools of magic by (%d+)",
      OUTPUT = "+%d All Resistances",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ All Resistances.*",
  },
  COLOR = L.COLORS.DEFENSIVE
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
  COLOR = L.COLORS.PHYSICAL
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
  COLOR = L.COLORS.PHYSICAL
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
  COLOR = L.COLORS.PHYSICAL
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
  COLOR = L.COLORS.PHYS_HIT
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
  COLOR = L.COLORS.PHYS_HIT
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
  COLOR = L.COLORS.PHYS_CRIT
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
  COLOR = L.COLORS.PHYSICAL
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
  COLOR = L.COLORS.PHYSICAL
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
  COLOR = L.COLORS.PHYSICAL
}

L[#L+1] = {LABEL = "Extra Melee School Damage",
  MAP = {
    {
      INPUT = "Adds (%d+) (.+) damage to your melee attacks%.?",
      OUTPUT = "+%d melee %s damage",
    },
  },
  CAPTURES = {
    "[%+%-]%d+ melee .+ damage.*",
    "[%+%-]%d+ Hp%d.*",
  },
  COLOR = L.COLORS.PHYSICAL,
}










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
  COLOR = L.COLORS.MAGIC_HIT
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
  COLOR = L.COLORS.MAGIC_HIT
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
  COLOR = L.COLORS.MAGIC_CRIT
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
  COLOR = L.COLORS.MAGIC_CRIT
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
  COLOR = L.COLORS.MAGIC_HASTE
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
  COLOR = L.COLORS.MAGIC_PEN
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
  COLOR = L.COLORS.MANA
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
  COLOR = L.COLORS.MANA
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
  COLOR = L.COLORS.DEFENSIVE
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







-- table.insert(L.ORDER,  "[%+%-]%d+ ___________$")






for k, v in pairs(L) do
  locale[k] = v
end


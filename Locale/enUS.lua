
local ADDON_NAME, Shared = ...

local locale = LibStub("AceLocale-3.0"):NewLocale("ZeraTooltip", "enUS", true)
local L = {
  LABEL     = {},
  INPUT     = {},
  OUTPUT    = {},
  ORDER     = {},
  COLOR     = {},
}


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
L.COLORS.ELEMENTS["Arcane"] = {247, 235, 255}
L.COLORS.ELEMENTS["Fire"]   = {255, 135, 79}
L.COLORS.ELEMENTS["Nature"] = {0, 212, 0}
L.COLORS.ELEMENTS["Frost"]  = {115, 243, 255}
L.COLORS.ELEMENTS["Shadow"] = {190, 92, 255}
L.COLORS.ELEMENTS["Holy"]   = {255, 255, 127}





table.insert(L.ORDER, "%d+ Armor$")
table.insert(L.COLOR, L.COLORS.DEFENSIVE)


table.insert(L.ORDER, "[%+%-]%d+ Stamina$")
table.insert(L.COLOR, L.COLORS.DEFENSIVE)
table.insert(L.ORDER, "[%+%-]%d+ Strength$")
table.insert(L.COLOR, L.COLORS.PHYSICAL)
table.insert(L.ORDER, "[%+%-]%d+ Agility$")
table.insert(L.COLOR, L.COLORS.PHYS_HIT)
table.insert(L.ORDER, "[%+%-]%d+ Intellect$")
table.insert(L.COLOR, L.COLORS.MAGICAL)
table.insert(L.ORDER, "[%+%-]%d+ Spirit$")
table.insert(L.COLOR, L.COLORS.MANA)

table.insert(L.ORDER, "[%+%-]%d+ All Resistances$")
table.insert(L.COLOR, L.COLORS.DEFENSIVE)
for element, color in pairs(L.COLORS.ELEMENTS) do
  table.insert(L.ORDER,  "[%+%-]%d+ " .. element .. " Resist.*")
  table.insert(L.COLOR,  color)
end





table.insert(L.LABEL,  "SpellPower")
table.insert(L.INPUT,  "Increases damage and healing done by magical spells and effects by up to (%d+)%.?")
table.insert(L.OUTPUT, "+%d Spell Power")
table.insert(L.ORDER,  "[%+%-]%d+ Spell Power.*")
table.insert(L.COLOR,  L.COLORS.MAGICAL)

table.insert(L.LABEL,  "SpellDamage")
table.insert(L.INPUT,  "Increases damage done ?t?o? ?(.-) by magical spells and effects by up to (%d+)")
table.insert(L.OUTPUT, function(targets, amount) return ("+%d Spell Damage%s"):format(amount, #targets > 0 and (" against %s"):format(targets) or "") end)
table.insert(L.ORDER,  "[%+%-]%d+ Spell Damage.*")
table.insert(L.COLOR,  L.COLORS.MAGICAL)
table.insert(L.ORDER,  "[%+%-]%d+ Spell Damage and Healing.*")
table.insert(L.COLOR,  L.COLORS.MAGICAL)

table.insert(L.LABEL,  "SpellSchoolPower1")
table.insert(L.INPUT,  "Increases ?t?h?e? damage done by (.+) spells and effects by up to (%d+)%.?")
table.insert(L.OUTPUT, function(school, amount) return ("+%d %s Spell Damage"):format(amount, school) end)
for element, color in pairs(L.COLORS.ELEMENTS) do
  table.insert(L.ORDER,  "[%+%-]%d+ " .. element .. " Spell Damage.*")
  table.insert(L.COLOR,  color)
end
table.insert(L.ORDER,  "[%+%-]%d+ %S+ Spell Damage.*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "SpellSchoolPower2")
table.insert(L.INPUT,  "Increases ([^%D]+) spell damage by (%d+%%?)%.?")
table.insert(L.OUTPUT, function(school, amount) return ("+%d %s Spell Damage"):format(amount:gsub("%%", "%%%%"), school) end)

table.insert(L.LABEL,  "Healing1")
table.insert(L.INPUT,  "Increases healing done by ?u?p? ?t?o? ?(%d+) and damage done by ?u?p? ?t?o? ?(%d+) for all magical spells and effects%.?")
table.insert(L.OUTPUT, "+%d Healing and +%d Spell Damage")
table.insert(L.ORDER,  "[%+%-]%d+ Healing and [%+%-]%d+ Spell Damage.*")
table.insert(L.COLOR,  L.COLORS.HEALING)
table.insert(L.ORDER,  "[%+%-]%d+ Healing [%+%-]%d+ Spell Damage.*")
table.insert(L.COLOR,  L.COLORS.HEALING)

table.insert(L.LABEL,  "Healing2")
table.insert(L.INPUT,  "Increases healing done ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+) and damage done ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+)%.?")
table.insert(L.OUTPUT, "+%d Healing and +%d Spell Damage")

table.insert(L.LABEL,  "Healing3")
table.insert(L.INPUT,  "Increases spell damage ?d?o?n?e? ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+) and healing ?d?o?n?e? ?b?y? ?m?a?g?i?c?a?l? ?s?p?e?l?l?s? ?a?n?d? ?e?f?f?e?c?t?s? by ?u?p? ?t?o? ?(%d+)%.?")
table.insert(L.OUTPUT, function(damage, healing) return ("+%d Healing and +%d Spell Damage"):format(healing, damage) end)



table.insert(L.LABEL,  "Defense")
table.insert(L.INPUT,  "Increases defense rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Defense Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Defense Rating.*")
table.insert(L.COLOR,  L.COLORS.DEFENSIVE)

table.insert(L.LABEL,  "Resilience")
table.insert(L.INPUT,  "Improves your resilience rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Resilience Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Resilience Rating.*")
table.insert(L.COLOR,  L.COLORS.DEFENSIVE)

table.insert(L.LABEL,  "Dodge")
table.insert(L.INPUT,  "Increases your dodge rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Dodge Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Dodge Rating.*")
table.insert(L.COLOR,  L.COLORS.DEFENSIVE)

table.insert(L.LABEL,  "Parry")
table.insert(L.INPUT,  "Increases your parry rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Parry Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Parry Rating.*")
table.insert(L.COLOR,  L.COLORS.DEF_EQUIP)

table.insert(L.LABEL,  "BlockRating")
table.insert(L.INPUT,  "Increases your ?s?h?i?e?l?d? block rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Block Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Block Rating.*")
table.insert(L.COLOR,  L.COLORS.DEF_EQUIP)

table.insert(L.LABEL,  "BlockValue")
table.insert(L.INPUT,  "Increases the block value of your shield by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Block Value")
table.insert(L.ORDER,  "[%+%-]%d+ Block Value.*")
table.insert(L.COLOR,  L.COLORS.DEF_EQUIP)

table.insert(L.LABEL,  "ReflectDamage")
table.insert(L.INPUT,  "When struck in combat inflicts (%d+) (.+) damage to the attacker%.?")
table.insert(L.OUTPUT, "Reflect %d %s damage to melee attackers")
table.insert(L.ORDER,  "Reflect [%+%-]%d+ .+ damage to melee attackers.*")
table.insert(L.COLOR,  L.COLORS.DEFENSIVE)

table.insert(L.LABEL,  "ResistAll")
table.insert(L.INPUT,  "Increases resistances to all schools of magic by (%d+)")
table.insert(L.OUTPUT, "+%d All Resistances")
table.insert(L.ORDER,  "[%+%-]%d+ All Resistances.*")
table.insert(L.COLOR,  L.COLORS.DEFENSIVE)



table.insert(L.LABEL,  "AttackPowerInForm")
table.insert(L.INPUT,  "Increases attack power by (%d+) in Cat, Bear, Dire Bear, and Moonkin forms only%.?")
table.insert(L.OUTPUT, "+%d Attack Power while shapeshifted")
table.insert(L.ORDER,  "[%+%-]%d+ Attack Power while shapeshifted.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)

table.insert(L.LABEL,  "AttackPower")
table.insert(L.INPUT,  "Increases attack power by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Attack Power")
table.insert(L.ORDER,  "[%+%-]%d+ Attack Power.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)

table.insert(L.LABEL,  "RangedAttackPower")
table.insert(L.INPUT,  "Increases ranged attack power by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Ranged Attack Power")
table.insert(L.ORDER,  "[%+%-]%d+ Ranged Attack Power.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)

table.insert(L.LABEL,  "PhysicalHit")
table.insert(L.INPUT,  "I[mn][pc]r[oe][va]s?es ?y?o?u?r? hit rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Physical Hit Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Physical Hit Rating.*")
table.insert(L.COLOR,  L.COLORS.PHYS_HIT)

table.insert(L.LABEL,  "PhysicalHitWithSpell")
table.insert(L.INPUT,  "Improves ?y?o?u?r? chance to hit with (.*) by (%d+%%)%.?")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s Physical Hit Chance with %s"):format(amount:gsub("%%", "%%%%"), spell) end)
table.insert(L.ORDER,  "[%+%-]%d+ Physical Hit Chance with .*")
table.insert(L.COLOR,  L.COLORS.PHYS_HIT)

table.insert(L.LABEL,  "PhysicalCrit")
table.insert(L.INPUT,  "I[mn][pc]r[oe][va]s?es ?y?o?u?r? critical strike rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Physical Crit Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Physical Crit Rating.*")
table.insert(L.COLOR,  L.COLORS.PHYS_CRIT)

table.insert(L.LABEL,  "PhysicalHaste")
table.insert(L.INPUT,  "I[mn][pc]r[oe][va]s?es ?y?o?u?r? haste rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Physical Haste Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Physical Haste Rating.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)

table.insert(L.LABEL,  "ArmorPenetration")
table.insert(L.INPUT,  "Your attacks ignore (%d+) of your opponent's armor%.?")
table.insert(L.OUTPUT, "+%d Armor Pen")
table.insert(L.ORDER,  "[%+%-]%d+ Armor Pen.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)

table.insert(L.LABEL,  "Expertise")
table.insert(L.INPUT,  "Increases your expertise rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Expertise Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Expertise Rating.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)

table.insert(L.LABEL,  "ExtraMeleeSchoolDamage")
table.insert(L.INPUT,  "Adds (%d+) (.+) damage to your melee attacks%.?")
table.insert(L.OUTPUT, "+%d melee %s damage")
table.insert(L.ORDER,  "[%+%-]%d+ melee .+ damage.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)
table.insert(L.ORDER,  "[%+%-]%d+ Hp%d.*")
table.insert(L.COLOR,  L.COLORS.PHYSICAL)



table.insert(L.LABEL,  "SpellHit")
table.insert(L.INPUT,  "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell hit rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Spell Hit Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Spell Hit Rating.*")
table.insert(L.COLOR,  L.COLORS.MAGIC_HIT)

table.insert(L.LABEL,  "SpellHitWithSpell")
table.insert(L.INPUT,  "Reduces the chance your (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? will be resisted by ?(%d+%%)%.?")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s Spell Hit Rating with %s"):format(amount:gsub("%%", "%%%%"), spell) end)
table.insert(L.ORDER,  "[%+%-]%d+ Spell Hit Rating with .*")
table.insert(L.COLOR,  L.COLORS.MAGIC_HIT)

table.insert(L.LABEL,  "SpellCrit")
table.insert(L.INPUT,  "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell critical strike rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Spell Crit Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Spell Crit Rating.*")
table.insert(L.COLOR,  L.COLORS.MAGIC_CRIT)

table.insert(L.LABEL,  "SpellCritWithSpell")
table.insert(L.INPUT,  "Increases the critical [hs][it][tr]i?k?e? chance of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?b?y? ?(%d+%%)%.?")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s Spell Crit Rating with %s"):format(amount:gsub("%%", "%%%%"), spell) end)
table.insert(L.ORDER,  "[%+%-]%d+ Spell Crit Rating with .*")
table.insert(L.COLOR,  L.COLORS.MAGIC_CRIT)

table.insert(L.LABEL,  "SpellHaste")
table.insert(L.INPUT,  "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell haste rating by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Spell Haste Rating")
table.insert(L.ORDER,  "[%+%-]%d+ Spell Haste Rating.*")
table.insert(L.COLOR,  L.COLORS.MAGIC_HASTE)

table.insert(L.LABEL,  "SpellPenetration")
table.insert(L.INPUT,  "I[mn][pc]r[oe][va]s?es ?y?o?u?r? spell penetration by (%d+)%.?")
table.insert(L.OUTPUT, "+%d Spell Pen")
table.insert(L.ORDER,  "[%+%-]%d+ Spell Pen.*")
table.insert(L.COLOR,  L.COLORS.MAGIC_PEN)



table.insert(L.LABEL,  "ManaRegen")
table.insert(L.INPUT,  "Allows? (%d+)%% of your Mana regeneration to continue while casting")
table.insert(L.OUTPUT, "+%d%%%% of Mana Regen continues while casting")
table.insert(L.ORDER,  "[%+%-]%d+ of Mana Regen continues while casting.*")
table.insert(L.COLOR,  L.COLORS.MANA)

table.insert(L.LABEL,  "ManaRestore")
table.insert(L.INPUT,  "Restores (%d+) mana per (%d+) sec%.?")
table.insert(L.OUTPUT, function(amount, period) return ("+%d Mp%d%s"):format(amount, period, tonumber(period) > 1 and ("  (+%s MpS)"):format(Shared.Round(tonumber(amount)/tonumber(period), 1)) or "") end)
table.insert(L.ORDER,  "[%+%-]%d+ Mp%d.*")
table.insert(L.COLOR,  L.COLORS.MANA)

table.insert(L.LABEL,  "HealthRestore")
table.insert(L.INPUT,  "Restores (%d+) health per (%d+) sec%.?")
table.insert(L.OUTPUT, function(amount, period) return ("+%d Hp%d%s"):format(amount, period, tonumber(period) > 1 and ("  (+%s HpS)"):format(Shared.Round(tonumber(amount)/tonumber(period), 1)) or "") end)
table.insert(L.ORDER,  "[%+%-]%d+ Hp%d.*")
table.insert(L.COLOR,  L.COLORS.DEFENSIVE)


table.insert(L.LABEL,  "CostReduction1")
table.insert(L.INPUT,  "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? (.+) cost of ?a?l?l? ?y?o?u?r? (.- ?[sa]?[pb]?[ei]?l?[li]?[ts]?[yi]?e?s?) ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT,  function(resource, spell, amount) return ("-%s %s cost for %s%s"):format(amount:gsub("%%", "%%%%"), resource:lower(), spell:sub(1, 1):upper(), TrimSpell(spell):sub(2, #TrimSpell(spell))) end)
table.insert(L.ORDER,  "[%+%-].* cost for .*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "CostReduction2")
table.insert(L.INPUT,  "(%s*)([^:]-) cost of ?y?o?u?r? (.- ?[sa]?[pb]?[ei]?l?[li]?[ts]?[yi]?e?s?) ?reduced by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT,  function(prefixSpace, resource, spell, amount) return ("%s-%s %s cost for %s%s"):format(prefixSpace, amount:gsub("%%", "%%%%"), resource:lower(), TrimSpell(spell)) end)

table.insert(L.LABEL,  "CostReduction3")
table.insert(L.INPUT,  "Your (.- ?[sa]?[pb]?[ei]?l?[li]?[ts]?[yi]?e?s?) ?e?a?c?h? costs? (%d+%%?) less (.-)([%s%.])")
table.insert(L.OUTPUT,  function(spell, amount, resource, tail) return ("-%s %s cost for %s%s"):format(amount:gsub("%%", "%%%%"), resource:lower(), TrimSpell(spell), tail == " " and tail or "") end)

table.insert(L.LABEL,  "CooldownReduction1")
table.insert(L.INPUT,  "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? cooldown o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?),? o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?),? ?a?n?d? o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT, function(spell1, amount1, spell2, amount2, spell3, amount3) return ("-%s %s cooldown, -%s %s cooldown, -%s %s cooldown"):format(amount1:gsub("%%", "%%%%"), spell1, amount2:gsub("%%", "%%%%"), spell2, amount3:gsub("%%", "%%%%"), spell3) end)
table.insert(L.ORDER,  "[%+%-].* cooldown, [%+%-].* cooldown, [%+%-].* cooldown.*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "CooldownReduction2")
table.insert(L.INPUT,  "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? cooldown o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?),? ?a?n?d? o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT, function(spell1, amount1, spell2, amount2) return ("-%s %s cooldown, -%s %s cooldown"):format(amount1:gsub("%%", "%%%%"), spell1, amount2:gsub("%%", "%%%%"), spell2) end)
table.insert(L.ORDER,  "[%+%-].* cooldown, [%+%-].* cooldown.*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "CooldownReduction3")
table.insert(L.INPUT,  "[RD]e[dc][ur][ce][ea]se?s? ?t?h?e? cooldown o[fn] ?y?o?u?r? (.-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT, function(spell, amount) return ("-%s %s cooldown"):format(amount:gsub("%%", "%%%%"), spell) end)
table.insert(L.ORDER,  "[%+%-].* cooldown.*")
table.insert(L.COLOR,  {})



table.insert(L.LABEL,  "IncreaseDamage1")
table.insert(L.INPUT,  "Increases ?t?h?e? damage ?[dc]?[oae]?[nua]?[esl]?[et]?d? ?[bof][yfr]o?m? ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%?)")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s %s damage"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* .* damage.*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "IncreaseDamage2")
table.insert(L.INPUT,  "Your (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? deal ([%d%.]*%d+%%?) more damage")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s %s damage"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)

table.insert(L.LABEL,  "IncreaseHealing")
table.insert(L.INPUT,  "Increases ?t?h?e? [ha][em][ao][lu][in][nt]g? [dch]?[oae]?[nua]?[esl]?e?d? ?[bof][yfr]o?m? ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%?)")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s %s healing"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* .* healing.*")
table.insert(L.COLOR,  {})



table.insert(L.LABEL,  "IncreaseThreat")
table.insert(L.INPUT,  "Increases ?t?h?e? threat generated by (.*) by ([%d%.]*%d+%%?)")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s threat from %s"):format(amount:gsub("%%", "%%%%"), spell) end)
table.insert(L.ORDER,  "[%+%-]%S* threat from .*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "DecreaseThreat")
table.insert(L.INPUT,  "[DR]e[cd][ru][ec]a?s?es ?t?h?e? threat generated by ?y?o?u?r? (.*) by ([%d%.]*%d+%%?)")
table.insert(L.OUTPUT, function(spell, amount) return ("-%s threat from %s"):format(amount:gsub("%%", "%%%%"), spell) end)

table.insert(L.LABEL,  "ReduceYourThreat")
table.insert(L.INPUT,  "Reduces the threat you generate by ([%d%.]*%d+%%?)")
table.insert(L.OUTPUT, function(amount) return ("-%s threat"):format(amount:gsub("%%", "%%%%")) end)
table.insert(L.ORDER,  "[%+%-]%S* threat.*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "IncreaseInterruptResist")
table.insert(L.INPUT,  "Gives you a (%d+)%% chance to avoid interruption caused by damage while c[ah][sa][tn]n?e?l?ing (.*)")
table.insert(L.OUTPUT, "+%s%%%% Spell Pushback Resist for %s")
table.insert(L.ORDER,  "[%+%-]%d+%% Spell Pushback Resist for .*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "IncreaseDuration")
table.insert(L.INPUT,  "I[nm][cp]r[eo][av]s?es ?t?h?e? duration of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s to %s duration"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* to .* duration.*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "ReduceCast")
table.insert(L.INPUT,  "Reduces ?t?h?e? casting time of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT, function(spell, amount) return ("-%s off %s cast time"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* off .* cast time.*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "IncreaseResourceGained")
table.insert(L.INPUT,  "Increases ?t?h?e? (.*) gained from ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?[sm]?[ei]?[cn]?[ou]?[nt]?[de]?s?)")
table.insert(L.OUTPUT, function(resource, spell, amount) return ("+%s %s gained from %s"):format(amount:gsub("%%", "%%%%"), resource, TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* .* gained from .*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "IncreaseRange")
table.insert(L.INPUT,  "Increases? ?t?h?e? range of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?y?a?r?d?s?)")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s range for %s"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* range for .*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "IncreaseRadius")
table.insert(L.INPUT,  "Increases ?t?h?e? radius of ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%? ?y?a?r?d?s?)")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s radius for %s"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* radius for .*")
table.insert(L.COLOR,  {})

table.insert(L.LABEL,  "IncreaseAttackPowerGranted")
table.insert(L.INPUT,  "Increases ?t?h?e? attack power granted by ?y?o?u?r? (%D-) [as]?[bp]?[ie]?l?[il]?t?[yi]?e?s? ?by ?u?p? ?t?o? ([%d%.]*%d+%%?)")
table.insert(L.OUTPUT, function(spell, amount) return ("+%s attack power for %s"):format(amount:gsub("%%", "%%%%"), TrimSpell(spell)) end)
table.insert(L.ORDER,  "[%+%-]%S* attack power for .*")
table.insert(L.COLOR,  {})







-- table.insert(L.ORDER,  "[%+%-]%d+ ___________$")






for k, v in pairs(L) do
  locale[k] = v
end


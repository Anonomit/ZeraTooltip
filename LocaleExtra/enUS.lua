if GetLocale() ~= "enUS" then return end
-- This file is for optional modifications which are specific to a locale.


local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




-- override the default stat rewords for this locale
do
  -- Addon:AddDefaultRewordByLocale(stat, val)
  Addon:AddDefaultRewordByLocale("BonusArmor", "Bonus Armor")
  
  Addon:AddDefaultRewordByLocale("All Resistance",    "All Resist")
  Addon:AddDefaultRewordByLocale("Arcane Resistance", "Arcane Resist")
  Addon:AddDefaultRewordByLocale("Fire Resistance",   "Fire Resist")
  Addon:AddDefaultRewordByLocale("Nature Resistance", "Nature Resist")
  Addon:AddDefaultRewordByLocale("Frost Resistance",  "Frost Resist")
  Addon:AddDefaultRewordByLocale("Shadow Resistance", "Shadow Resist")
  
  Addon:AddDefaultRewordByLocale("Attack Power In Forms",    "Feral Attack Power")
  Addon:AddDefaultRewordByLocale("Defense Rating",           "Defense")
  Addon:AddDefaultRewordByLocale("Parry Rating",             "Parry")
  Addon:AddDefaultRewordByLocale("Dodge Rating",             "Dodge")
  Addon:AddDefaultRewordByLocale("Armor Penetration Rating", "Armor Pen")
  Addon:AddDefaultRewordByLocale("Expertise Rating",         "Expertise")
  Addon:AddDefaultRewordByLocale("Resilience Rating",        "Resilience")
  
  Addon:AddDefaultRewordByLocale("Spell Damage", "Spell Damage")
  Addon:AddDefaultRewordByLocale("Healing",      "Healing")
  
  Addon:AddDefaultRewordByLocale("Hit Rating",             "Hit")
  Addon:AddDefaultRewordByLocale("Critical Strike Rating", "Crit")
  Addon:AddDefaultRewordByLocale("Haste Rating",           "Haste")
  
  Addon:AddDefaultRewordByLocale("Physical Hit Rating",             "Physical Hit")
  Addon:AddDefaultRewordByLocale("Physical Critical Strike Rating", "Physical Crit")
  Addon:AddDefaultRewordByLocale("Physical Haste Rating",           "Physical Haste")
  Addon:AddDefaultRewordByLocale("Spell Hit Rating",                "Spell Hit")
  Addon:AddDefaultRewordByLocale("Spell Critical Strike Rating",    "Spell Crit")
  Addon:AddDefaultRewordByLocale("Spell Haste Rating",              "Spell Haste")
  
  Addon:AddDefaultRewordByLocale("Health Regeneration", "Health per Minute")
  Addon:AddDefaultRewordByLocale("Mana Regeneration",   "Mana per Minute")
end

-- override the default stat mods for this locale
do
  -- Addon:AddDefaultModByLocale(stat, val)
  
  Addon:AddDefaultModByLocale("Health Regeneration", 12)
  Addon:AddDefaultModByLocale("Mana Regeneration",   12)
end


-- override the default stat precision for this locale
do
  -- Addon:AddDefaultPrecisionByLocale(stat, val)
end



-- These functions define additional pattern captures that can be used to recognize a stat in this locale.
-- A line of text is matched against INPUT. If the match is successful, the line is recognized as that stat.
-- The results of the match as then used to reword the line.
-- OUTPUT can also be defined (in the same table as INPUT). It must be a function.
-- OUTPUT accepts the results of matching INPUT, and returns them. They could be returned in a different order.








Addon:AddExtraStatCapture("Arcane Damage",
  {INPUT = "%+([%d,]+) Arcane Spell Damage"})

Addon:AddExtraStatCapture("Fire Damage",
  {INPUT = "%+([%d,]+) Fire Spell Damage"})

Addon:AddExtraStatCapture("Nature Damage",
  {INPUT = "%+([%d,]+) Nature Spell Damage"})

Addon:AddExtraStatCapture("Frost Damage",
  {INPUT = "%+([%d,]+) Frost Spell Damage"})

Addon:AddExtraStatCapture("Shadow Damage",
  {INPUT = "%+([%d,]+) Shadow Spell Damage"})

Addon:AddExtraStatCapture("Holy Damage",
  {INPUT = "%+([%d,]+) Holy Spell Damage"})

Addon:AddExtraStatCapture("Health Regeneration",
  {INPUT = "^%+([%d,]+) health every 5 sec%.$"})



if Addon.isEra then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Increased Defense %+([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Increases your chance to dodge an attack by ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Increases your chance to parry an attack by ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Increases your chance to block attacks with a shield by ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+([%d,]+) Attack Power in Cat, Bear, and Dire Bear forms only%.$"})
  
  Addon:SetDefaultStatPattern("Expertise Rating", "Reduces the chance for your attacks to be dodged or parried by %s.")
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Increases damage and healing done by magical spells and effects by up to ([%d,]+)%.$"},
    {INPUT = "^%+([%d,]+) Damage and Healing Spells$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Increases healing done by spells and effects by up to ([%d,]+)%.$"},
    {INPUT = "^%+([%d,]+) Healing Spells$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^Increases damage done by Arcane spells and effects by up to ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^Increases damage done by Fire spells and effects by up to ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^Increases damage done by Nature spells and effects by up to ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^Increases damage done by Frost spells and effects by up to ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^Increases damage done by Shadow spells and effects by up to ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^Increases damage done by Holy spells and effects by up to ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Decreases the magical resistances of your spell targets by ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Improves your chance to hit with all spells and attacks by ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Improves your chance to get a critical strike with all spells and attacks by ([%d,]+%%)%.$"},
    {INPUT = "^Improves your chance to get a critical strike with melee and ranged attacks and with spells by ([%d,]+%%)%.$"},
    {INPUT = "^Increases your critical strike chance with spells and attacks by ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Improves your chance to hit by ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Improves your chance to get a critical strike by ([%d,]+%%)%.$"})
  
  Addon:SetDefaultStatPattern("Physical Haste Rating", "Increases your attack speed by %s.")
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Improves your chance to hit with spells by ([%d,]+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Improves your chance to get a critical strike with spells by ([%d,]+%%)%.$"})
  
  Addon:SetDefaultStatPattern("Spell Haste Rating", "Increases your casting speed by %s.")
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^Restores ([%d,]+) health every 5 sec%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^%+([%d,]+) mana every 5 sec%.$"})
else
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Increases your block rating by ([%d,]+)%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Increases your spell power by ([%d,]+)%.$"}) -- Atiesh 22631
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Increases your hit rating by ([%d,]+)%.$"}) -- Maexxna's Fang 22804
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Increases your critical strike rating by ([%d,]+)%.$"}) -- Staff of Balzaphon 23124
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Increases armor penetration rating by ([%d,]+)%.$"}) -- Maexxna's Femur 39226
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Increases your spell penetration by ([%d,]+)%.$"}) -- Hatefury Mantle 30884
end

if Addon.isSoD or Addon.isTBC then
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Increases healing done by up to ([%d,]+) and damage done by up to %d+ for all magical spells and effects%.$"})
end







-- These tables define additional text replacements that can take place in certain lines.
-- Partial matches are found and replaced with gsub().

Addon:AddExtraReplacement("Run Speed",
  {
    INPUT  = "Engage the rocket boots to greatly increase your speed%.", -- Rocket Boots Xtreme Lite 35581
    OUTPUT = "+300%% Run Speed for 3 sec",
  },
  {
    INPUT  = "Activate a set of jets to increase your movement speed by up to 160%%, for up to 8 sec%.", -- Tinkerbox: Nitro Boosts 238735
    OUTPUT = "+140%% (120%%-160%%) Run Speed for 8 sec",
  },
  {
    INPUT  = "Minor Speed Increase", -- Enchant Boots - Minor Speed
    OUTPUT = "+8%% Run Speed",
  },
  {
    INPUT  = "Minor Run Speed Increase", -- Meta gems
    OUTPUT = "+8%% Run Speed",
  },
  {
    INPUT  = "Minor Speed ", -- Enchant Boots - Boar's Speed
    OUTPUT = "+8%% Run Speed ",
  },
  {
    INPUT  = "Minor increase to running and swimming speed", -- Primal Batskin set
    OUTPUT = "+8%% Run Speed and +8%% Swim Speed",
  },
  {
    INPUT  = "Increases run speed by (%d+)%%", -- Swiftness Potion
    OUTPUT = "+%1%% Run Speed",
  },
  {
    INPUT  = "Run speed increased slightly", -- Highlander's / Defiler's PvP boots
    OUTPUT = "+8%% Run Speed",
  },
  {
    INPUT  = "Greatly increase your run speed", -- Nitro Boosts
    OUTPUT = "+150%% Run Speed",
  }
)

-- Swim Speed
Addon:AddExtraReplacement("Swim Speed",
  {
    INPUT  = "Increases swim speed by (%d+)%%", -- Azure Silk Belt
    OUTPUT = "+%1%% Swim Speed",
  }
)

-- Mount Speed
Addon:AddExtraReplacement("Mount Speed",
  {
    INPUT  = "Increases mount speed by (%d+)%%", -- Carrot on a Stick
    OUTPUT = "+%1%% Mount Speed",
  }
)
if Addon.isTBC then
  Addon:AddExtraReplacement("Mount Speed",
    {
      INPUT  = "Increases speed in Flight Form and Swift Flight Form by (%d+)%%", -- Charm of Swift Flight Form
      OUTPUT = "+%1%% Speed in Flight Forms",
    }
  )
end
if Addon.isEra then
  Addon:AddExtraReplacement("Mount Speed",
    {
      INPUT  = "^Mithril Spurs", -- Mithril Spurs Enchantment (Mithril Spurs (464))
      OUTPUT = "+4%% Mount Speed",
    },
    {
      INPUT  = "^Minor Mount Speed Increase", -- Enchant Gloves - Riding (Minor Mount Speed Increase (930))
      OUTPUT = "+2%% Mount Speed",
    },
    {
      INPUT  = "Attaches spurs to your boots that increase your mounted movement speed slightly", -- Mithril Spurs
      OUTPUT = "+4%% Mount Speed when attached to boots",
    }
  )
end

-- Fishing Skill
Addon:AddExtraReplacement("Fishing Skill",
  {
    INPUT  = "Replaces the fishing line on your fishing pole with a high test eternium line", -- High Test Eternium Fishing Line
    OUTPUT = "Adds +5 Fishing to an owned Fishing Pole",
  },
  {
    INPUT  = "^Eternium Line$", -- Eternium Fishing Line (Eternium Line (2603))
    OUTPUT = "+5 Fishing",
  }
)

-- Mana Regen
Addon:AddExtraReplacement("Mana Regen",
  {
    INPUT  = "Allow (%d+)%% of your Mana regeneration to continue while casting", -- Primal Mooncloth set
    OUTPUT = "+%1%% of Mana Regen continues while casting",
  }
)

-- Hp5
Addon:AddExtraReplacement("Hp5",
  {
    INPUT  = "restores (%d+) health every 5 seconds", -- Nightfin Soup
    OUTPUT = function(amount) return format("+%s health per minute (%s Hp5)", Addon:ToFormattedNumber(Addon:ToNumber(amount)*12), Addon:ToFormattedNumber(amount)) end,
  }
)

-- Mp5
Addon:AddExtraReplacement("Mp5",
  {
    INPUT  = "restores (%d+) Mana every 5 seconds", -- Nightfin Soup
    OUTPUT = function(amount) return format("+%s mana per minute (%s Mp5)", Addon:ToFormattedNumber(Addon:ToNumber(amount)*12), Addon:ToFormattedNumber(amount)) end,
  }
)






-- Food and Drink
Addon:AddExtraReplacement("Food And Drink",
  {
    INPUT  = "Restores? ([%d,]+) health and ([%d,]+) mana over (%d+) sec%.%s+Must remain seated while eating", -- Conjured Mana Biscuit
    OUTPUT = function(healthAmount, manaAmount, duration) return format("+%s health (+%s/s) and +%s mana (+%s/s) over %ds while seated", Addon:ToFormattedNumber(healthAmount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(healthAmount)/duration, 1)), Addon:ToFormattedNumber(manaAmount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(manaAmount)/duration, 1)), duration) end,
  }
)

Addon:AddExtraReplacement("Buff Food",
  {
    INPUT  = "Restores? ([%d,]+) health over (%d+) sec%.%s+Must remain seated while eating.%s+If you spend at least 10 seconds eating you will become well fed and (.+) for (%d+) min", -- Golden Fish Sticks
    OUTPUT = function(amount, duration, buff, buffDuration) return format("+%s health (+%s/s) over %ds while seated. After 10s, %s for %dm", Addon:ToFormattedNumber(amount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(amount)/duration, 1)), duration, buff, buffDuration) end,
  }
)

Addon:AddExtraReplacement("Food",
  {
    INPUT  = "Restores? ([%d,]+) health over (%d+) sec%.%s+Must remain seated while eating", -- Telaari Grapes
    OUTPUT = function(amount, duration) return format("+%s health (+%s/s) over %ds while seated", Addon:ToFormattedNumber(amount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(amount)/duration, 1)), duration) end,
  }
)

Addon:AddExtraReplacement("Buff Drink",
  {
    INPUT  = "Restores? ([%d,]+) mana over (%d+) sec%.%s+Must remain seated while drinking.%s+If you spend at least 10 seconds drinking you will become well fed and (.+) for (%d+) min", -- Hot Apple Cider
    OUTPUT = function(amount, duration, buff, buffDuration) return format("+%s mana (+%s/s) over %ds while seated. After 10s, %s for %dm", Addon:ToFormattedNumber(amount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(amount)/duration, 1)), duration, buff, buffDuration) end,
  },
  {
    INPUT  = "Restores? ([%d,]+) mana over (%d+) sec%.%s+Must remain seated while drinking.%s+If you spend at least 10 seconds drinking you will become enlightened and (.+) for (%d+) min", -- Skullfish Soup
    OUTPUT = function(amount, duration, buff, buffDuration) return format("+%s mana (+%s/s) over %ds while seated. After 10s, %s for %dm", Addon:ToFormattedNumber(amount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(amount)/duration, 1)), duration, buff, buffDuration) end,
  }
  -- {
  --   INPUT  = "Restores? ([%d,]+) mana over (%d+) sec%.%s+Must remain seated while drinking.%s+ Also (.+) for (%d+) min",
  --   OUTPUT = function(amount, duration, buff, buffDuration) return format("+%s mana (+%s/s) over %ds while seated. Also %s for %dm", Addon:ToFormattedNumber(amount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(amount)/duration, 1)), duration, buff, buffDuration) end,
  -- }
)

Addon:AddExtraReplacement("Drink",
  {
    INPUT  = "Restores ([%d,]+) mana over (%d+) sec%.%s+Must remain seated while drinking", -- Purified Draenic Water
    OUTPUT = function(amount, duration) return format("+%s mana (+%s/s) over %ds while seated", Addon:ToFormattedNumber(amount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(amount)/duration, 1)), duration) end,
  }
)

Addon:AddExtraReplacement("Bandage",
  {
    INPUT  = "Heals ([%d,]+) damage over (%d+) sec",
    OUTPUT = function(amount, duration) return format("+%s health (+%s/s) over %ds", Addon:ToFormattedNumber(amount), Addon:ToFormattedNumber(Addon:Round(Addon:ToNumber(amount)/duration, 1)), duration) end,
  }
)


Addon:AddExtraReplacement("Average Range",
  {
    INPUT  = "([%d,]+) to (%d*,?%d+)", -- don't capture trailing commas
    OUTPUT = function(amount1, amount2) return format("%s (%s-%s)", Addon:ToFormattedNumber(Addon:Round((Addon:ToNumber(amount1)+Addon:ToNumber(amount2))/2, 1)), Addon:ToFormattedNumber(amount1), Addon:ToFormattedNumber(amount2)) end, -- Health/mana Potions, Demonic Rune
  }
)


-- Spellpower
Addon:AddExtraReplacement("Spellpower text",
  {
    INPUT  = "damage and healing done by magical spells and effects",
    OUTPUT = "Spellpower",
  }
)

-- Temp Stat Buff
Addon:AddExtraReplacement("Temp Stat Buff",
  {
    INPUT  = "Increases the ([^%d]-) by ([%d,]+%%?) (for %d+ sec%.?)", -- 236337
    OUTPUT = "+%2 %1 %3",
  },
  {
    INPUT  = "Increases ?y?o?u?r? ([^%d]-) by ([%d,]+%%?) (for %d+ sec%.?)", -- Shadowmoon Insignia, Steely Naaru Sliver
    OUTPUT = "+%2 %1 %3",
  },
  {
    INPUT  = "Increases ?y?o?u?r? ([^%d]-) by up to ([%d,]+%%?) (for %d+ sec%.?)", -- Dark Iron Smoking Pipe
    OUTPUT = "+%2 %1 %3",
  }
)









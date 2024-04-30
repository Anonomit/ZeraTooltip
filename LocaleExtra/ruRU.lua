if GetLocale() ~= "ruRU" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



-- override the default stat rewords for this locale
do
  -- Addon:AddDefaultRewordByLocale(stat, val)
  
  Addon:AddDefaultRewordByLocale("Stamina",   "к выносливости")
  Addon:AddDefaultRewordByLocale("Strength",  "к силе")
  Addon:AddDefaultRewordByLocale("Agility",   "к ловкости")
  Addon:AddDefaultRewordByLocale("Intellect", "к интеллекту")
  Addon:AddDefaultRewordByLocale("Spirit",    "к духу")
  
  Addon:AddDefaultRewordByLocale("All Resistance",    "ко всем сопротивлениям")
  Addon:AddDefaultRewordByLocale("Arcane Resistance", "к сопротивлению тайной магии")
  Addon:AddDefaultRewordByLocale("Fire Resistance",   "к сопротивлению огню")
  Addon:AddDefaultRewordByLocale("Nature Resistance", "к сопротивлению силам природы")
  Addon:AddDefaultRewordByLocale("Frost Resistance",  "к сопротивлению магии льда")
  Addon:AddDefaultRewordByLocale("Shadow Resistance", "к сопротивлению темной магии")
  
  Addon:AddDefaultRewordByLocale("Spell Power",   "к силе заклинаний")
  -- Addon:AddDefaultRewordByLocale("Spell Damage",  "к силе заклинаний")
  Addon:AddDefaultRewordByLocale("Arcane Damage", "к силе заклинаний тайной магии")
  Addon:AddDefaultRewordByLocale("Fire Damage",   "к силе заклинаний огня")
  Addon:AddDefaultRewordByLocale("Nature Damage", "к силе заклинаний природы")
  Addon:AddDefaultRewordByLocale("Frost Damage",  "к силе заклинаний магии льда")
  Addon:AddDefaultRewordByLocale("Shadow Damage", "к силе заклинаний темной магии")
  Addon:AddDefaultRewordByLocale("Holy Damage",   "к силе заклинаний светлой магии")
  
  Addon:AddDefaultRewordByLocale("Spell Penetration", "к проникающей способности заклинаний")
  
  
  if Addon.isSoD then
    Addon:AddDefaultRewordByLocale("Hit Rating",             "к меткости атаки и заклинаний")
    Addon:AddDefaultRewordByLocale("Critical Strike Rating", "к критическому эффекту атаки и заклинаний")
    Addon:AddDefaultRewordByLocale("Haste Rating",           "к скорости атаки и заклинаний")
  else
    Addon:AddDefaultRewordByLocale("Hit Rating",             "к меткости")
    Addon:AddDefaultRewordByLocale("Critical Strike Rating", "к критическому удару")
    Addon:AddDefaultRewordByLocale("Haste Rating",           "к скорости")
  end
  
  Addon:AddDefaultRewordByLocale("Physical Hit Rating",             "к меткости атаки")
  Addon:AddDefaultRewordByLocale("Physical Critical Strike Rating", "к критическому удару")
  Addon:AddDefaultRewordByLocale("Physical Haste Rating",           "к скорости атаки")
  Addon:AddDefaultRewordByLocale("Spell Hit Rating",                "к меткости заклинаний")
  Addon:AddDefaultRewordByLocale("Spell Critical Strike Rating",    "к критическому эффекту заклинаний")
  Addon:AddDefaultRewordByLocale("Spell Haste Rating",              "к скорости заклинаний")
  
  
  Addon:AddDefaultRewordByLocale("Health Regeneration", "к восстановлению здоровья за минуту")
  Addon:AddDefaultRewordByLocale("Mana Regeneration",   "к восполнению маны за минуту")
end






-- override the default stat mods for this locale
do
  -- Addon:AddDefaultModByLocale(stat, val)
  
  Addon:AddDefaultModByLocale("Health Regeneration", 12)
  Addon:AddDefaultModByLocale("Mana Regeneration", 12)
end




Addon:AddExtraStatCapture("Arcane Damage",
  {INPUT = "^%+(%d+) к урону от заклинаний тайной магии$"})

Addon:AddExtraStatCapture("Fire Damage",
  {INPUT = "^%+(%d+) к урону от заклинаний огня$"})

Addon:AddExtraStatCapture("Nature Damage",
  {INPUT = "^%+(%d+) к урону от сил природы$"})

Addon:AddExtraStatCapture("Frost Damage",
  {INPUT = "^%+(%d+) к урону от заклинаний магии льда$"})

Addon:AddExtraStatCapture("Shadow Damage",
  {INPUT = "^%+(%d+) к урону от заклинаний темной магии$"})

Addon:AddExtraStatCapture("Holy Damage",
  {INPUT = "^%+(%d+) к урону от заклинаний светлой магии$"})

Addon:AddExtraStatCapture("Health Regeneration",
  {INPUT = "^%+(%d+) ед%. здоровья каждые 5 секунд$"})


if Addon.isEra then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Увеличение рейтинга защиты на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Увеличение рейтинга уклонения на (%d+%%)%.$"},
    {INPUT = "^%+(%d+%%) к рейтингу уклонения$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Увеличение рейтинга парирования атак на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Повышает вероятность блокирования атаки щитом на (%d+%%)[.,]$"},
    {INPUT = "^%+(%d+%%) к рейтингу блока$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^Увеличение показателя блока щитом на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Увеличение силы атаки в дальнем бою на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Увеличивает силу атаки на (%d+) ед%. в облике кошки, медведя и лютого медведя%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Увеличение урона и целительного действия магических заклинаний и эффектов не более чем на (%d+) ед%.$"},
    {INPUT = "^%+(%d+) к наносящим урон и исцеляющим заклинаниям$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^Увеличение урона, наносимого заклинаниями и эффектами тайной магии, на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^Увеличение наносимого урона от заклинаний и эффектов огня не более чем на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^Увеличение урона, наносимого заклинаниями и эффектами сил природы, на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^Увеличение урона, наносимого заклинаниями и эффектами льда, на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^Увеличение урона, наносимого заклинаниями и эффектами темной магии, на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^Увеличение урона, наносимого заклинаниями и эффектами светлой магии, на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Усиливает исцеление от заклинаний и эффектов максимум на (%d+) ед%.$"},
    {INPUT = "^%+(%d+) к исцеляющим заклинаниям$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Снижает сопротивление магии целей ваших заклинаний на (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Повышает вероятность попадания атак и заклинаний на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Повышает вероятность критического удара атак и заклинаний на (%d+%%)%.$"},
    {INPUT = "^Повышает вероятность критического эффекта атак и заклинаний на (%d+%%)%.$"},
    {INPUT = "^Повышает вероятность нанести критический удар атаками ближнего и дальнего боя, а также заклинаниями на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Вероятность нанесения удара увеличена на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Увеличение вероятности нанесения критического урона на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Повышение на (%d+%%) рейтинга меткости заклинаний%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Увеличение рейтинга критического эффекта заклинаний на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^Восполняет (%d+) ед%. здоровья каждые 5 сек%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^Восполнение (%d+) ед%. маны раз в 5 сек%.$"},
    {INPUT = "^%+(%d+) ед%. маны каждые 5 секунд$"})
else
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Увеличивает рейтинг уклонения на (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Увеличивает рейтинг парирования на (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Увеличение рейтинга блока на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^Увеличивает показатель блокирования вашего щита на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Attack Power",
    {INPUT = "^Повышает силу атаки на (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Увеличивает силу атак дальнего боя на (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Увеличивает силу атаки на (%d+) в облике кошки, медведя, лютого медведя и лунного совуха%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Увеличивает рейтинг пробивания брони на (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Увеличивает вашу силу заклинаний на (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^Восполняет (%d+) ед%. здоровья каждые 5 секунд%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^Восполнение (%d+) ед%. маны за 5 сек%.$"})
end



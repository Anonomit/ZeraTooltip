if GetLocale() ~= "ruRU" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Увеличение рейтинга защиты на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Увеличение рейтинга уклонения на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Увеличение рейтинга парирования атак на (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Повышает вероятность блокирования атаки щитом на (%d+%%)[.,]$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^Увеличение показателя блока щитом на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Увеличение силы атаки в дальнем бою на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Увеличивает силу атаки на (%d+) ед%. в облике кошки, медведя и лютого медведя%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Увеличение урона и целительного действия магических заклинаний и эффектов не более чем на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Усиливает исцеление от заклинаний и эффектов максимум на (%d+) ед%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Снижает сопротивление магии целей ваших заклинаний на (%d+)%.$"})
  
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
    {INPUT = "^Восполнение (%d+) ед%. маны раз в 5 сек%.$"})
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



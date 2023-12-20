if GetLocale() ~= "deDE" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)


  
Addon:AddExtraStatCapture("Arcane Damage",
  {INPUT = "^%+(%d+) Arkanzauberschaden$"})

Addon:AddExtraStatCapture("Fire Damage",
  {INPUT = "^%+(%d+) Feuerzauberschaden$"})

Addon:AddExtraStatCapture("Nature Damage",
  {INPUT = "^%+(%d+) Naturzauberschaden$"})

Addon:AddExtraStatCapture("Frost Damage",
  {INPUT = "^%+(%d+) Frostzauberschaden$"})

Addon:AddExtraStatCapture("Shadow Damage",
  {INPUT = "^%+(%d+) Schattenzauberschaden$"})

Addon:AddExtraStatCapture("Holy Damage",
  {INPUT = "^%+(%d+) Heiligzauberschaden$"})


if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Verteidigung %+(%d+)%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Erhöht Eure Chance, einem Angriff auszuweichen, um (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Erhöht Eure Chance, einen Angriff zu parieren, um (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Erhöht Eure Chance, Angriffe mit einem Schild zu blocken, um (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+(%d+) Angriffskraft in Katzengestalt, Bärengestalt oder Terrorbärengestalt%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Erhöht durch Zauber und magische Effekte zugefügten Schaden und Heilung um bis zu (%d+)%.$"},
    {INPUT = "^%+(%d+) Schadenszauber und Heilzauber$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^Erhöht durch Arkanzauber und Arkaneffekte zugefügten Schaden um bis zu (%d+)%.$"})

  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^Erhöht durch Feuerzauber und Feuereffekte zugefügten Schaden um bis zu (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^Erhöht durch Naturzauber und Natureffekte zugefügten Schaden um bis zu (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^Erhöht durch Frostzauber und Frosteffekte zugefügten Schaden um bis zu (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^Erhöht durch Schattenzauber und Schatteneffekte zugefügten Schaden um bis zu (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^Erhöht durch Heiligzauber und Heiligeffekte zugefügten Schaden um bis zu (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Erhöht durch Zauber und Effekte verursachte Heilung um bis zu (%d+)%.$"},
    {INPUT = "^%+(%d+) Heilzauber$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Reduziert die Magiewiderstände der Ziele Eurer Zauber um (%d+)%.$"},
    {INPUT = "^Verringert die Magiewiderstände der Ziele Eurer Zauber um (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Verbessert Eure Trefferchance um (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Erhöht Eure Chance, einen kritischen Treffer zu erzielen, um (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Erhöht Eure Chance mit Zaubern zu treffen um (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Erhöht Eure Chance, einen kritischen Treffer durch Zauber zu erzielen, um (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^%+(%d+) Gesundheit alle 5 Sek%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^Stellt alle 5 Sek%. (%d+) Punkt%(e%) Mana wieder her%.$"},
    {INPUT = "^%+(%d+) Mana alle 5 Sek%.$"})
else
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Erhöht Verteidigungswertung um (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Erhöht Eure kritische Trefferwertung um (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Erhöht die Angriffskraft um (%d+) nur in Katzen%-, Bären%-, Terrorbären%- und Mondkingestalt%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Erhöht die Rüstungsdurchschlagwertung um (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Erhöht Eure Zaubermacht um (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Erhöht Eure Zauberdurchschlagskraft um (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Erhöht Eure Trefferwertung um (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^Alle 5 Sek%. (%d+) Gesundheit$"})
end





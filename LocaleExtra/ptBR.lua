if GetLocale() ~= "ptBR" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



Addon:AddExtraStatCapture("Mana Regeneration",
  {INPUT = "^Restaura (%d+) de mana a cada 5 s%.$"})

if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Defesa aumentada em (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta em (%d+%%) a chance de esquivar%-se de ataques%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta em (%d+%%) a sua chance de aparar ataques%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta em (%d+%%) a chance de bloquear ataques com o escudo%.$"})
  
  Addon:AddExtraStatCapture("Attack Power",
    {INPUT = "^%+(%d+) de Poder de Ataque%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^%+(%d+) de Poder de Ataque de Longo Alcance%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+(%d+) de Poder de Ataque sob forma de Felino, Urso e Urso Hediondo%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta em até (%d+) o dano causado e a cura realizada por feitiços e efeitos mágicos%.$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^Aumenta em até (%d+) o dano causado por feitiços e efeitos Arcanos%.$"},
    {INPUT = "^%+(%d+) Dano Mágico Arcano$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^Aumenta em até (%d+) o dano causado por feitiços e efeitos de Fogo%.$"},
    {INPUT = "^%+(%d+) Dano Mágico de Fogo$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^Aumenta em até (%d+) o dano causado por feitiços e efeitos de Natureza%.$"},
    {INPUT = "^%+(%d+) Dano Mágico de Natureza$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^Aumenta em até (%d+) o dano causado por feitiços e efeitos de Gelo%.$"},
    {INPUT = "^%+(%d+) Dano Mágico de Gelo$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^Aumenta em até (%d+) o dano causado por feitiços e efeitos de Sombra%.$"},
    {INPUT = "^%+(%d+) Dano Mágico de Sombra$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^Aumenta em até (%d+) o dano causado por feitiços e efeitos Sagrados%.$"},
    {INPUT = "^%+(%d+) Dano Mágico Sagrado$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Aumenta em até (%d+) a cura realizada por feitiços e efeitos mágicos%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Reduz em (%d+) as resistências mágicas dos alvos dos seus feitiços%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Aumenta em (%d+%%) a chance de acerto%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Aumenta em (%d+%%) a chance de realizar acertos críticos%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Aumenta em (%d+%%) sua chance de acertar com feitiços%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Aumenta em (%d+%%) a chance de realizar acertos críticos com feitiços%.$"})
else
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta em (%d+) a sua taxa de esquiva%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta em (%d+) a sua taxa de aparo%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta em (%d+) a sua taxa de bloqueio%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Aumenta o poder de ataque de longo alcance em (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Aumenta em (%d+) o poder de ataque quando em forma de Felino, Urso, Urso Hediondo e Luniscante%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Aumenta em (%d+) a taxa de penetração em armadura%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Aumenta em (%d+) sua penetração de feitiços%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Aumenta em (%d+) a sua taxa de acerto%.$"})
end



if GetLocale() ~= "frFR" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



if Addon.isClassic then
    Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Défense augmentée de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Augmente vos chances d'esquiver une attaque de (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Augmente vos chances de parer une attaque de (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Augmente vos chances de bloquer les attaques avec un bouclier de (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^Augmente le score de blocage de votre bouclier de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Attack Power",
    {INPUT = "^%+(%d+) à la puissance d'attaque%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^%+(%d+) à la puissance des attaques à distance%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+(%d+) à la puissance d'attaque pour les formes de félin, d'ours et d'ours redoutable uniquement%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Augmente les dégâts et les soins produits par les sorts et effets magiques de (%d+) au maximum%.$"},
    {INPUT = "^Augmente les soins et dégâts produits par les sorts et effets magiques de (%d+) au maximum%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Augmente les soins prodigués par les sorts et effets de (%d+) au maximum%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Diminue les résistances magiques des cibles de vos sorts de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Augmente vos chances de toucher de (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Augmente vos chances d'infliger un coup critique de (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Augmente vos chances de toucher avec des sorts de (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Augmente vos chances d'infliger un coup critique avec vos sorts de (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^Rend (%d+) points de vie toutes les 5 sec%.$"})
else
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Score de défense augmenté de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Augmente votre score d'esquive de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Augmente votre score de parade de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Augmente votre score de blocage de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^Augmente la valeur de blocage de votre bouclier de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Augmente la puissance des attaques à distance de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Augmente de (%d+) le score de pénétration d'armure%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Augmente la puissance des sorts de (%d+)%.$"},
    {INPUT = "^Augmente la puissance de vos sorts de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Augmente la pénétration de vos sorts de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Augmente votre score de toucher de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Augmente votre score de coup critique de (%d+)%.$"})
  
  Addon:AddExtraStatCapture("Health Regeneration",
    {INPUT = "^Rend (%d+) points de vie toutes les 5 sec%.$"})
  
  Addon:AddExtraStatCapture("Mana Regeneration",
    {INPUT = "^Rend (%d+) points de mana toutes les 5 sec%.$"})
end



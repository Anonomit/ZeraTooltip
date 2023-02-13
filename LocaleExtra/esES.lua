if GetLocale() ~= "esES" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)



if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Defensa aumentada %+(%d+)%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta la probabilidad de esquivar un ataque en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta la probabilidad de parar un ataque en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta la probabilidad de bloquear ataques con un escudo en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Block Value",
    {INPUT = "^Aumenta el valor de bloqueo de tu escudo en (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Attack Power",
    {INPUT = "^%+(%d+) p%. de poder de ataque%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^%+(%d+) p%. de poder de ataque a distancia%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+(%d+) p%. de poder de ataque solo bajo formas felinas, de oso y de oso nefasto%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta el daño y la curación de los hechizos mágicos y los efectos hasta en (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Aumenta la curación de los hechizos y los efectos hasta en (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Reduce las resistencias mágicas de los objetivos de tus hechizos en (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Mejora tu probabilidad de alcanzar el objetivo en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Mejora tu probabilidad de conseguir un golpe crítico en (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Mejora tu probabilidad de alcanzar el objetivo con hechizos en un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Mejora tu probabilidad de conseguir un golpe crítico en (%d+%%) con los hechizos%.$"})
else
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Aumenta el índice de defensa (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta tu índice de esquivar (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta tu índice de parada (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta tu índice de bloqueo (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Attack Power",
    {INPUT = "^Aumenta (%d+) p%. el poder de ataque%.$"})
  
  Addon:AddExtraStatCapture("Ranged Attack Power",
    {INPUT = "^Aumenta (%d+) p%. el poder de ataque a distancia%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Aumenta el poder de ataque (%d+) p%. solo con las formas de gato, oso, oso temible y lechúcico lunar%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Aumenta el índice de penetración de armadura (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta tu poder con hechizos hasta (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Aumenta la penetración de tus hechizos (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Aumenta tu índice de golpe (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Aumenta tu índice de golpe crítico (%d+) p%.$"})
end



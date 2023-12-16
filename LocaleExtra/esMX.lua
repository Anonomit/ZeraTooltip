if GetLocale() ~= "esMX" then return end

local ADDON_NAME, Data = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)




Addon:AddExtraStatCapture("Block Value",
  {INPUT = "^Aumenta el valor de bloqueo de tu escudo (%d+) p%.$"})

if Addon.isClassic then
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Aumenta (%d+) p%. el índice de defensa%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta un (%d+%%) tu probabilidad de esquivar un ataque%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta un (%d+%%) tu probabilidad de parar un ataque%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta la probabilidad de bloquear ataques con un escudo un (%d+%%)%.$"},
    {INPUT = "^Aumenta un (%d+%%) tu probabilidad de bloquear ataques con un escudo%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^%+(%d+) p%. de poder de ataque solo en las formas felina, de oso y de oso temible%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta hasta (%d+) p%. el daño y la sanación de los hechizos y efectos mágicos%.$"})
  
  Addon:AddExtraStatCapture("Arcane Damage",
    {INPUT = "^Aumenta hasta (%d+) p%. el daño que infligen los hechizos y efectos Arcanos%.$"},
    {INPUT = "^%+(%d+) daño con hechizos Arcano$"})
  
  Addon:AddExtraStatCapture("Fire Damage",
    {INPUT = "^Aumenta hasta (%d+) p%. el daño que infligen los hechizos y efectos de Fuego%.$"},
    {INPUT = "^%+(%d+) daño con hechizos de Fuego$"})
  
  Addon:AddExtraStatCapture("Nature Damage",
    {INPUT = "^Aumenta hasta (%d+) p%. el daño que infligen los hechizos y efectos de Naturaleza%.$"},
    {INPUT = "^%+(%d+) daño con hechizos de Naturaleza$"})
  
  Addon:AddExtraStatCapture("Frost Damage",
    {INPUT = "^Aumenta hasta (%d+) p%. el daño que infligen los hechizos y efectos de Escarcha%.$"},
    {INPUT = "^%+(%d+) daño con hechizos de Escarcha$"})
  
  Addon:AddExtraStatCapture("Shadow Damage",
    {INPUT = "^Aumenta hasta (%d+) p%. el daño que infligen los hechizos y efectos de las Sombras%.$"},
    {INPUT = "^%+(%d+) daño con hechizos de las Sombras$"})
  
  Addon:AddExtraStatCapture("Holy Damage",
    {INPUT = "^Aumenta hasta (%d+) p%. el daño que infligen los hechizos y efectos Sagrados%.$"},
    {INPUT = "^%+(%d+) daño con hechizos Sagrado$"})
  
  Addon:AddExtraStatCapture("Healing",
    {INPUT = "^Aumenta hasta (%d+) p%. la sanación de los hechizos y efectos%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Las resistencias mágicas de los objetivos de tus hechizos se reducen (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Physical Hit Rating",
    {INPUT = "^Mejora tu probabilidad de golpear un (%d+%%)%.$"})
  
  Addon:AddExtraStatCapture("Physical Critical Strike Rating",
    {INPUT = "^Mejora un (%d+%%) tu probabilidad de conseguir un golpe crítico%.$"})
  
  Addon:AddExtraStatCapture("Spell Hit Rating",
    {INPUT = "^Mejora un (%d+%%) tu probabilidad de golpear con hechizos%.$"})
  
  Addon:AddExtraStatCapture("Spell Critical Strike Rating",
    {INPUT = "^Mejora tu probabilidad de asestar un golpe crítico con hechizos un (%d+%%)%.$"})
else
  Addon:AddExtraStatCapture("Defense Rating",
    {INPUT = "^Aumenta el índice de defensa (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Dodge Rating",
    {INPUT = "^Aumenta tu índice de esquivar (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Parry Rating",
    {INPUT = "^Aumenta tu índice de parada (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Block Rating",
    {INPUT = "^Aumenta tu índice de bloqueo (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Attack Power In Forms",
    {INPUT = "^Aumenta el poder de ataque (%d+) p%. solo con las formas de gato, oso, oso temible y lechúcico lunar%.$"})
  
  Addon:AddExtraStatCapture("Armor Penetration Rating",
    {INPUT = "^Aumenta el índice de penetración de armadura (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Power",
    {INPUT = "^Aumenta el poder con hechizos (%d+) p%.$"},
    {INPUT = "^Aumenta tu poder con hechizos hasta (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Spell Penetration",
    {INPUT = "^Aumenta la penetración de tus hechizos (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Hit Rating",
    {INPUT = "^Aumenta tu índice de golpe (%d+) p%.$"})
  
  Addon:AddExtraStatCapture("Critical Strike Rating",
    {INPUT = "^Aumenta tu índice de golpe crítico (%d+) p%.$"})
end


